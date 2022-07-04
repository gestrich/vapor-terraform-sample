//
//  DynamoSensorChange.swift
//
//
//  Created by Bill Gestrich on 11/7/21.
//

import Foundation
import SotoDynamoDB

public struct DynamoSensorChange: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "SensorChange"
    public static let inputDateKey = DynamoStoreService.sortKey
    public static let changeDateKey = "changeDate"
    
    public let changeDate: Date
    public let inputDate: Date
    
    public init(changeDate: Date, inputDate: Date){
        self.changeDate = changeDate
        self.inputDate = inputDate
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(changeDateString) = dictionary[DynamoSensorChange.changeDateKey], let changeDate = Utils.iso8601Formatter.date(from: changeDateString) else {
            return nil
        }
        
        self.changeDate = changeDate
        
        guard case let .s(inputDateString) = dictionary[DynamoSensorChange.inputDateKey], let inputDate = Utils.iso8601Formatter.date(from: inputDateString) else {
            return nil
        }
        
        self.inputDate = inputDate
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoSensorChange.partitionKey: DynamoDB.AttributeValue.s( String(DynamoSensorChange.partitionValue)),
            DynamoSensorChange.changeDateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: changeDate)),
            DynamoSensorChange.inputDateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: inputDate)),
        ]
        
        return dictionary
    }
}
