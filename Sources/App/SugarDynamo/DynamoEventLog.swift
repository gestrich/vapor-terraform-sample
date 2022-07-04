//
//  DynamoEventLog.swift
//
//
//  Created by Bill Gestrich on 11/7/21.
//

import Foundation
import SotoDynamoDB

public struct DynamoEventLog: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "EventLog"
    public static let dateKey = DynamoStoreService.sortKey
    public static let messageKey = "message"
    
    public let message: String
    public let eventDate: Date
    
    public init(message: String, eventDate: Date){
        self.message = message
        self.eventDate = eventDate
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        
        guard case let .s(eventDateString) = dictionary[DynamoEventLog.dateKey], let eventDate = Utils.iso8601Formatter.date(from: eventDateString) else {
            return nil
        }
        
        self.eventDate = eventDate
        
        guard case let .s(message) = dictionary[DynamoEventLog.messageKey] else {
            return nil
        }
        
        self.message = message
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoEventLog.partitionKey: DynamoDB.AttributeValue.s( String(DynamoEventLog.partitionValue)),
            DynamoEventLog.messageKey: DynamoDB.AttributeValue.s( String(message)),
            DynamoEventLog.dateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: eventDate))
        ]
        
        return dictionary
    }
}
