//
//  DynamoNotificationsDisableEvent.swift
//
//
//  Created by Bill Gestrich on 12/9/20.
//

import Foundation
import SotoDynamoDB

public struct DynamoNotificationsDisableEvent: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "NotificationsDisable"
    public static let dateKey = DynamoStoreService.sortKey
    public static let triggeringUserKey = "triggeringUser"
    public static let minutesKey = "minutes"
    
    public let date: Date
    public let minutes: Int
    public let triggeringUser: String
    
    
    public init(date: Date, minutes: Int, user: String) {
        self.date = date
        self.minutes = minutes
        self.triggeringUser = user
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(dateAsString) = dictionary[DynamoNotificationsDisableEvent.dateKey], let date = Utils.iso8601Formatter.date(from: dateAsString) else {
            return nil
        }
        
        self.date = date
        
        guard case let .n(minutesString) = dictionary[DynamoNotificationsDisableEvent.minutesKey], let minutes = Int(minutesString) else {
            
            return nil
        }
        
        self.minutes = minutes
        
        guard case let .s(triggeringUser) = dictionary[DynamoNotificationsDisableEvent.triggeringUserKey] else {
            return nil
        }
        
        self.triggeringUser = triggeringUser
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoNotificationsDisableEvent.partitionKey: DynamoDB.AttributeValue.s( String(DynamoNotificationsDisableEvent.partitionValue)),
            DynamoNotificationsDisableEvent.dateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: date)),
            DynamoNotificationsDisableEvent.minutesKey: DynamoDB.AttributeValue.n(String(minutes)),
            DynamoNotificationsDisableEvent.triggeringUserKey: DynamoDB.AttributeValue.s( triggeringUser),
        ]
        
        return dictionary
    }
}

