//
//  DynamoSensorInventory.swift
//
//
//  Created by Bill Gestrich on 11/7/21.
//

import Foundation
import SotoDynamoDB

public struct DynamoSensorInventory: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "SensorInventory"
    public static let date = DynamoStoreService.sortKey
    public static let inventoryCountKey = "inventoryCount"
    
    public let inventoryCount: Int
    public let inventoryDate: Date
    
    public init(inventoryCount: Int, inventoryDate: Date){
        self.inventoryCount = inventoryCount
        self.inventoryDate = inventoryDate
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(inventoryDateString) = dictionary[DynamoSensorInventory.date], let inventoryDate = Utils.iso8601Formatter.date(from: inventoryDateString) else {
            return nil
        }
        
        self.inventoryDate = inventoryDate
        
        guard case let .n(inventoryCountString) = dictionary[DynamoSensorInventory.inventoryCountKey], let inventoryCount = Int(inventoryCountString) else {
            return nil
        }
        
        self.inventoryCount = inventoryCount
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoSensorInventory.partitionKey: DynamoDB.AttributeValue.s( String(DynamoSensorInventory.partitionValue)),
            DynamoSensorInventory.inventoryCountKey: DynamoDB.AttributeValue.n(String(inventoryCount)),
            DynamoSensorInventory.date: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: inventoryDate))
        ]
        
        return dictionary
    }
}
