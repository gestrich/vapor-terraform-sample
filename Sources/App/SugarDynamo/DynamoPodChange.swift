//
//  DynamoPodChange.swift
//
//
//  Created by Bill Gestrich on 4/24/22.
//

import Foundation
import SotoDynamoDB

public struct DynamoPodChange: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "PodChange"
    public static let inputDateKey = DynamoStoreService.sortKey
    public static let changeDateKey = "changeDate"
    
    public let changeDate: Date
    public let inputDate: Date
    
    public init(changeDate: Date, inputDate: Date){
        self.changeDate = changeDate
        self.inputDate = inputDate
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(changeDateString) = dictionary[DynamoPodChange.changeDateKey], let changeDate = Utils.iso8601Formatter.date(from: changeDateString) else {
            return nil
        }
        
        self.changeDate = changeDate
        
        guard case let .s(inputDateString) = dictionary[DynamoPodChange.inputDateKey], let inputDate = Utils.iso8601Formatter.date(from: inputDateString) else {
            return nil
        }
        
        self.inputDate = inputDate
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoPodChange.partitionKey: DynamoDB.AttributeValue.s( String(DynamoPodChange.partitionValue)),
            DynamoPodChange.changeDateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: changeDate)),
            DynamoPodChange.inputDateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: inputDate)),
        ]
        
        return dictionary
    }
}
