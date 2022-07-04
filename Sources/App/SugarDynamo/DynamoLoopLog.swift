//
//  DynamoLoopLog.swift
//
//
//  Created by Bill Gestrich on 11/7/21.
//

import Foundation
import SotoDynamoDB

public struct DynamoLoopLog: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "LoopLog"
    
    public static let logDateKey = DynamoStoreService.sortKey
    public static let messageKey = "message"
    public static let subsystemKey = "subsystem"
    public static let categoryKey = "category"
    public static let typeKey = "type"

    public let logDate: Date
    public let message: String
    public let subsystem: String
    public let category: String
    public let type: String
    
    public init(logDate: Date, message: String, subsystem: String, category: String, type: String){
        self.logDate = logDate
        self.message = message
        self.subsystem = subsystem
        self.category = category
        self.type = type
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(logDateString) = dictionary[DynamoLoopLog.logDateKey], let logDate = Utils.iso8601Formatter.date(from: logDateString) else {
            return nil
        }
        
        self.logDate = logDate
        
        guard case let .s(message) = dictionary[DynamoLoopLog.messageKey] else {
            return nil
        }

        self.message = message
        
        guard case let .s(subsystem) = dictionary[DynamoLoopLog.subsystemKey] else {
            return nil
        }
        
        self.subsystem = subsystem
        
        guard case let .s(category) = dictionary[DynamoLoopLog.categoryKey] else {
            return nil
        }
        
        self.category = category
        
        guard case let .s(type) = dictionary[DynamoLoopLog.typeKey] else {
            return nil
        }
        
        self.type = type
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoLoopLog.partitionKey: DynamoDB.AttributeValue.s( String(DynamoLoopLog.partitionValue)),
            DynamoLoopLog.logDateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: logDate)),
            DynamoLoopLog.messageKey: DynamoDB.AttributeValue.s( String(message)),
            DynamoLoopLog.subsystemKey: DynamoDB.AttributeValue.s( String(subsystem)),
            DynamoLoopLog.categoryKey: DynamoDB.AttributeValue.s( String(category)),
            DynamoLoopLog.typeKey: DynamoDB.AttributeValue.s( String(type)),
        ]
        
        return dictionary
    }
}
