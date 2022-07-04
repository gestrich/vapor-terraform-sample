//
//  DynamoStoreService.swift
//  
//
//  Created by Bill Gestrich on 11/8/20.
//

import Foundation
import NIO
import NIOHelpers
import SotoDynamoDB
import AsyncHTTPClient
import Vapor

public struct DynamoStoreService {
    
    public static let partitionKey = "partitionKey"
    public static let sortKey = "sort"
    public static let testDatabaseName = "EGVTest"
    
    let awsClient: SotoCore.AWSClient
    let db: DynamoDB
    let tableName: String
    let nowDateProvider: () -> Date
    
    
    //General
    
    public init(tableName: String, awsClient: AWSClient, nowDateProvider: @escaping () -> Date = { Date()} ) {
        let provider = AsyncHTTPClient.HTTPClient.EventLoopGroupProvider.createNew
        self.awsClient = awsClient
        self.db = DynamoDB(client: awsClient, region: .useast1)
        self.tableName = tableName
        self.nowDateProvider = nowDateProvider
    }
    
    public func syncShutdown() throws {
//        try self.awsClient.syncShutdown()
    }
    
    public func createTable() async throws -> DynamoDB.CreateTableOutput {
        
        let keySchema = [
            DynamoDB.KeySchemaElement(attributeName: DynamoStoreService.partitionKey, keyType: .hash),
            DynamoDB.KeySchemaElement(attributeName: DynamoStoreService.sortKey, keyType: .range),
        ]
        
        let attributeDefinitions = [
            DynamoDB.AttributeDefinition(attributeName: DynamoStoreService.partitionKey, attributeType: .s),
            DynamoDB.AttributeDefinition(attributeName: DynamoStoreService.sortKey, attributeType: .s),
        ]
        
        let provisionThroughput = DynamoDB.ProvisionedThroughput(readCapacityUnits: 5, writeCapacityUnits: 5)
        
        let tableInput = DynamoDB.CreateTableInput(attributeDefinitions: attributeDefinitions, keySchema: keySchema, provisionedThroughput: provisionThroughput, tableName: tableName)
        
        return try await db.createTable(tableInput).awaitFuture()
    }
    
    func getItems(partition: String, startSort: String, endSort: String) async throws -> [[String: DynamoDB.AttributeValue]] {

        var items = [[String: DynamoDB.AttributeValue]]()
        var lastEvaluatedKey: [String: DynamoDB.AttributeValue]? = nil

        repeat {
            
            if lastEvaluatedKey != nil {
                //Delay to avoid throughput throttling
                try await Task.sleep(nanoseconds: 3 *  1_000_000_000)
            }
            
            let output = try await db.query(.init(
                exclusiveStartKey: lastEvaluatedKey,
                expressionAttributeNames: ["#u" : DynamoStoreService.partitionKey],
                expressionAttributeValues: [":u": DynamoDB.AttributeValue.s( partition), ":d1" : DynamoDB.AttributeValue.s( startSort), ":d2" : DynamoDB.AttributeValue.s( endSort)],
                keyConditionExpression: "#u = :u AND \(DynamoStoreService.sortKey) BETWEEN :d1 AND :d2",
                tableName: tableName
            )).awaitFuture()
            if let outputItems = output.items {
                items += outputItems
            }
            lastEvaluatedKey = output.lastEvaluatedKey
        } while lastEvaluatedKey != nil
        
        return items
    }
    
    
    //MARK: DynamoEventModel
    
    func save(model: DynamoEventModel) async throws {
        let input = DynamoDB.PutItemInput(item: model.attributeValues, tableName: tableName)
        let _ = try await db.putItem(input).awaitFuture()
    }
    
    func getModelsSinceDate<T: DynamoEventModel>(oldestDate: Date, latestDate: Date, type: T.Type) async throws -> [T] {
        
        let oldestDateAsString = Utils.iso8601Formatter.string(from: oldestDate)
        let lastestLogAsString = Utils.iso8601Formatter.string(from: latestDate)
        
        let items = try await getItems(partition: T.partitionValue, startSort: oldestDateAsString, endSort: lastestLogAsString)
        return items.compactMap({ (dict) -> T? in
            return T(dictionary: dict)
        })
    }
    
    func getModelsInPastMinutes<T: DynamoEventModel>(modelType: T.Type, minutes: Int) async throws -> [T] {
        let interval = TimeInterval(minutes) * -60
        let now = nowDateProvider()
        let date = now.addingTimeInterval(interval)
        return try await self.getModelsSinceDate(oldestDate: date, latestDate: now, type: T.self)
    }
    
    func getLatest<T: DynamoEventModel>(modelType: T.Type, minutesLookback: Int) async throws-> T? {
        let models = try await self.getModelsInPastMinutes(modelType: T.self, minutes: minutesLookback)
        return models.last
    }
    
    
    //MARK: A1C
    
    public func getLatestA1CEstimate() async throws -> DynamoA1CEstimate? {
        return try await getLatest(modelType: DynamoA1CEstimate.self, minutesLookback: 60 * 24)
    }
    
    public func saveA1CEstimate(dynamoA1CEstimate: DynamoA1CEstimate) async throws {
        try await dynamoA1CEstimate.save(store: self)
    }
    
    
    //MARK: Event Log
    
    public func getLatestEventLog() async throws -> DynamoEventLog? {
        let lookbackMinutes = 60 * 24 * 1
        return try await getLatest(modelType: DynamoEventLog.self, minutesLookback: lookbackMinutes)
    }
    
    public func saveEventLog(_ eventLog: DynamoEventLog) async throws {
        try await eventLog.save(store: self)
    }
    
    
    //MARK: Insulin Override
            
    public func getActiveInsulinOverride() async throws -> DynamoInsulinOverride? {
        let lookbackMinutes = 60 * 24 * 365
        return try await getLatest(modelType: DynamoInsulinOverride.self, minutesLookback: lookbackMinutes)
    }
    
    public func saveInsulinOverride(_ insulinOverride: DynamoInsulinOverride) async throws {
        try await insulinOverride.save(store: self)
    }
    
    
    //MARK: Loop Log
    
    public func getLoopLogs(startDate: Date, endDate: Date) async throws -> [DynamoLoopLog] {
        return try await getModelsSinceDate(oldestDate: startDate, latestDate: endDate, type: DynamoLoopLog.self)
    }
    
    public func saveLoopLog(_ loopLog: DynamoLoopLog) async throws {
        try await loopLog.save(store: self)
    }
    
    
    //MARK: Notification Event
    
    public func getNotificationEvents(minutesLookBack: Int) async throws -> [DynamoNotificationEvent] {
        return try await getModelsInPastMinutes(modelType: DynamoNotificationEvent.self, minutes: minutesLookBack)
    }
    
    public func saveNotificationEvent(_ notificationEvent: DynamoNotificationEvent) async throws {
        try await notificationEvent.save(store: self)
    }
    
    
    //MARK: Notification Disable Event

    public func getActiveNotificationsDisabledEvent() async throws -> DynamoNotificationsDisableEvent? {
        let lookbackMinutes = 60 * 24
        guard let latestEvent = try await getLatest(modelType: DynamoNotificationsDisableEvent.self, minutesLookback: lookbackMinutes) else {
            return nil
        }
        
        let disabledUntil = latestEvent.date.adding(minutes: latestEvent.minutes)
        
        if nowDateProvider().timeIntervalSince(disabledUntil) > 0 {
            //past
            return nil
        } else {
            return latestEvent
        }
    }
    
    public func saveNotificationsDisabledEvent(_ notificationDisabledEvent: DynamoNotificationsDisableEvent) async throws {
        try await notificationDisabledEvent.save(store: self)
    }

    
    //MARK: Pod Change
    
    public func getLatestPodChange() async throws -> DynamoPodChange? {
        let lookbackMinutes = 60 * 24 * 60
        return try await getLatest(modelType: DynamoPodChange.self, minutesLookback: lookbackMinutes)
    }
    
    public func savePodChange(_ podChange: DynamoPodChange) async throws {
        try await podChange.save(store: self)
    }
    
    
    //MARK: Pod Inventory
    
    public func getLatestPodInventory() async throws -> DynamoPodInventory? {
        let lookbackMinutes = 60 * 24 * 60
        return try await getLatest(modelType: DynamoPodInventory.self, minutesLookback: lookbackMinutes)
    }
    
    public func savePodInventory(_ podInventory: DynamoPodInventory) async throws {
        try await podInventory.save(store: self)
    }
    
    
    //MARK: Sensor Change
    
    public func getLatestSensorChange() async throws -> DynamoSensorChange? {
        let lookbackMinutes = 60 * 24 * 60
        return try await getLatest(modelType: DynamoSensorChange.self, minutesLookback: lookbackMinutes)
    }
    
    public func saveSensorChange(_ sensorChange: DynamoSensorChange) async throws {
        try await sensorChange.save(store: self)
    }
    
    
    //MARK: Sensor Inventory
    
    public func getLatestSensorInventory() async throws -> DynamoSensorInventory? {
        let lookbackMinutes = 60 * 24 * 60
        return try await getLatest(modelType: DynamoSensorInventory.self, minutesLookback: lookbackMinutes)
    }
    
    public func saveSensorInventory(_ sensorInventory: DynamoSensorInventory) async throws {
        try await sensorInventory.save(store: self)
    }

    
    //MARK: Target Override
    
    public func getActiveTargetOverride() async throws -> DynamoTargetOverride? {
        let lookbackMinutes = 60 * 24 * 365
        return try await getLatest(modelType: DynamoTargetOverride.self, minutesLookback: lookbackMinutes)
    }
    
    public func saveTargetOverride(_ targetOverride: DynamoTargetOverride) async throws {
        try await targetOverride.save(store: self)
    }
    
    
    //MARK: User
    
    public func saveUser(user: DynamoUser) async throws -> DynamoUser {
        let input = DynamoDB.PutItemInput(item: user.attributeValues, tableName: tableName)
        let _ = try await db.putItem(input).awaitFuture()
        return user
    }
    
    public func getUser(email: String) async throws -> DynamoUser? {
        let users = try await getUsers()
        return users.filter {$0.email == email}.last
    }
    
    public func getUser(phone: String) async throws -> DynamoUser? {
        let users = try await getUsers()
        return users.filter {$0.phone == phone}.last
    }
    
    public func getUsers() async throws -> [DynamoUser] {
        //You can use the start/end to specificy a specific name in search.
        let items = try await getItems(partition: DynamoUser.partitionValue, startSort: "A", endSort: "ZZZZZZZZZZZZZZZZZZZZZZZZZZ")
        let userValues = items.compactMap({ (dict) -> DynamoUser? in
            return DynamoUser.userWith(dictionary: dict)
        })
        
        return userValues
    }
    
    public func deleteUser(user: DynamoUser) async throws {
        fatalError("Not implemented")
    }
}
