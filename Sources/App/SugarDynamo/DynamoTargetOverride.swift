//
//  DynamoTargetOverride.swift
//  
//
//  Created by Bill Gestrich on 2/21/21.
//

import Foundation
import SotoDynamoDB

public struct DynamoTargetOverride: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "TargetOverride"
    public static let dateKey = DynamoStoreService.sortKey
    public static let triggeringUserKey = "triggeringUser"
    public static let targetBaseKey = "targetBase"
    
    public let date: Date
    public let targetBase: Int
    public let triggeringUser: String
    
    
    public init(date: Date, targetBase: Int, user: String) {
        self.date = date
        self.targetBase = targetBase
        self.triggeringUser = user
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(dateAsString) = dictionary[DynamoTargetOverride.dateKey], let date = Utils.iso8601Formatter.date(from: dateAsString) else {
            return nil
        }
        
        self.date = date
        
        guard case let .n(targetBaseString) = dictionary[DynamoTargetOverride.targetBaseKey], let targetBase = Int(targetBaseString) else {
            return nil
        }
        
        self.targetBase = targetBase
        
        guard case let .s(triggeringUser) = dictionary[DynamoTargetOverride.triggeringUserKey] else {
            return nil
        }
        
        self.triggeringUser = triggeringUser
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        
        let dictionary = [
            DynamoTargetOverride.partitionKey: DynamoDB.AttributeValue.s(String(DynamoTargetOverride.partitionValue)),
            DynamoTargetOverride.dateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: date)),
            DynamoTargetOverride.targetBaseKey: DynamoDB.AttributeValue.n(String(targetBase)),
            DynamoTargetOverride.triggeringUserKey: DynamoDB.AttributeValue.s( triggeringUser),
        ]
        
        return dictionary
    }
}

