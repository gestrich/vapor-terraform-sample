//
//  DynamoInsulinOverride.swift
//  
//
//  Created by Bill Gestrich on 2/20/21.
//

import Foundation
import SotoDynamoDB

public struct DynamoInsulinOverride: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "InsulinOverride"
    public static let dateKey = DynamoStoreService.sortKey
    public static let triggeringUserKey = "triggeringUser"
    public static let insulinPercentKey = "insulinPercent"
    
    public let date: Date
    public let insulinPercent: Int
    public let triggeringUser: String
    
    
    public init(date: Date, insulinPercent: Int, user: String) {
        self.date = date
        self.insulinPercent = insulinPercent
        self.triggeringUser = user
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(dateAsSring) = dictionary[DynamoInsulinOverride.dateKey], let date = Utils.iso8601Formatter.date(from: dateAsSring) else {
            return nil
        }
        
        self.date = date
        
        guard case let .n(insulinPercentString) = dictionary[DynamoInsulinOverride.insulinPercentKey], let insulinPercent = Int(insulinPercentString) else {
            return nil
        }
        
        self.insulinPercent = insulinPercent
        
        guard case let .s(triggeringUser) = dictionary[DynamoInsulinOverride.triggeringUserKey] else {
            return nil
        }
        
        self.triggeringUser = triggeringUser
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoInsulinOverride.partitionKey: DynamoDB.AttributeValue.s( String(DynamoInsulinOverride.partitionValue)),
            DynamoInsulinOverride.dateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: date)),
            DynamoInsulinOverride.insulinPercentKey: DynamoDB.AttributeValue.n(String(insulinPercent)),
            DynamoInsulinOverride.triggeringUserKey: DynamoDB.AttributeValue.s( triggeringUser),
        ]
        
        return dictionary
    }
}



