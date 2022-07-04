//
//  DynamoEGV.swift
//  
//
//  Created by Bill Gestrich on 11/7/20.
//

import Foundation
import SotoDynamoDB


public struct DynamoEGV: DynamoEventModel {

    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "EGV"
    public static let systemTimeKey = DynamoStoreService.sortKey
    public static let displayTimeKey = "displayTime"
    public static let trendKey = "trend"
    public static let valueKey = "value"
    
    public let trend: Float
    public let value: Int
    public let displayTime: Date
    public let systemTime: Date
    
    public init(trend: Float, value: Int, displayTime: Date, systemTime: Date){
        self.trend = trend
        self.value = value
        self.displayTime = displayTime
        self.systemTime = systemTime
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(displayTimeString) = dictionary[DynamoEGV.displayTimeKey], let displayTime = Utils.iso8601Formatter.date(from: displayTimeString) else {
            return nil
        }
        
        self.displayTime = displayTime
        
        guard case let .s(systemTimeString) = dictionary[DynamoEGV.systemTimeKey], let systemTime = Utils.iso8601Formatter.date(from: systemTimeString) else {
            return nil
        }
        
        self.systemTime = systemTime
        
        guard case let .n(trendString) = dictionary[DynamoEGV.trendKey], let trend = Float(trendString) else {
            return nil
        }
        
        self.trend = trend
        
        guard case let .n(valueString) = dictionary[DynamoEGV.valueKey], let value = Int(valueString) else {
            return nil
        }
        
        self.value = value
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        var dictionary = [
            DynamoEGV.partitionKey: DynamoDB.AttributeValue.s( String(DynamoEGV.partitionValue)),
            DynamoEGV.trendKey: DynamoDB.AttributeValue.n(String(trend)),
            DynamoEGV.valueKey: DynamoDB.AttributeValue.n(String(value)),
        ]
        
        dictionary[DynamoEGV.displayTimeKey] = DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: displayTime))
        dictionary[DynamoEGV.systemTimeKey] = DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: systemTime))
        
        return dictionary
    }

}
