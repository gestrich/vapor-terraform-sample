//
//  DynamoNotificationEvent.swift
//  
//
//  Created by Bill Gestrich on 12/9/20.
//

import Foundation
import SotoDynamoDB

public struct DynamoNotificationEvent: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "Notification"
    public static let dateKey = DynamoStoreService.sortKey
    public static let eventTypeKey = "eventType"
    public static let userPhoneKey = "userPhone"
    public static let stateUUIDKey = "stateUUID"
    
    public let date: Date
    public let eventType: String
    public let userPhone: String
    public let stateUUID: String
    
    
    public init(date: Date, eventType: String, userPhone: String, stateUUID: String) {
        self.date = date
        self.eventType = eventType
        self.userPhone = userPhone
        self.stateUUID = stateUUID
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(dateAsString) = dictionary[DynamoNotificationEvent.dateKey], let date = Utils.iso8601Formatter.date(from: dateAsString) else {
            return nil
        }
        
        self.date = date
        
        guard case let .s(eventType) = dictionary[DynamoNotificationEvent.eventTypeKey] else {
            return nil
        }
        
        self.eventType = eventType
        
        guard case let .s(userPhone) = dictionary[DynamoNotificationEvent.userPhoneKey] else {
            return nil
        }
        
        self.userPhone = userPhone
        
        guard case let .s(stateUUID) = dictionary[DynamoNotificationEvent.stateUUIDKey] else {
            return nil
        }
        
        self.stateUUID = stateUUID
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoNotificationEvent.partitionKey: DynamoDB.AttributeValue.s(String(DynamoNotificationEvent.partitionValue)),
            DynamoNotificationEvent.dateKey: DynamoDB.AttributeValue.s(Utils.iso8601Formatter.string(from: date)),
            DynamoNotificationEvent.eventTypeKey: DynamoDB.AttributeValue.s(eventType),
            DynamoNotificationEvent.userPhoneKey: DynamoDB.AttributeValue.s(userPhone),
            DynamoNotificationEvent.stateUUIDKey: DynamoDB.AttributeValue.s(stateUUID),
        ]
        
        return dictionary
    }
}


