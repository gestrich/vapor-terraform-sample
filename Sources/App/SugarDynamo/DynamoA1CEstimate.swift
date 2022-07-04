//
//  DynamoA1CEstimate.swift
//  
//
//  Created by Bill Gestrich on 3/30/21.
//

import Foundation
import SotoDynamoDB

public struct DynamoA1CEstimate: DynamoEventModel {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "A1C"
    public static let calculationDateKey = DynamoStoreService.sortKey
    public static let valueKey = "value"
    
    public let value: Float
    public let calculationDate: Date
    
    public init(value: Float, calculationDate: Date){
        self.value = value
        self.calculationDate = calculationDate
    }
    
    public init?(dictionary: [String : DynamoDB.AttributeValue]) {
        guard case let .s(calculationDateString) = dictionary[DynamoA1CEstimate.calculationDateKey], let calculationDate = Utils.iso8601Formatter.date(from: calculationDateString) else {
            return nil
        }
        
        self.calculationDate = calculationDate
        
        guard case let .n(valueString) = dictionary[DynamoA1CEstimate.valueKey], let value = Float(valueString) else {
            return nil
        }
        
        self.value = value
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoA1CEstimate.partitionKey: DynamoDB.AttributeValue.s( String(DynamoA1CEstimate.partitionValue)),
            DynamoA1CEstimate.valueKey: DynamoDB.AttributeValue.n(String(value)),
            DynamoA1CEstimate.calculationDateKey: DynamoDB.AttributeValue.s( Utils.iso8601Formatter.string(from: calculationDate))
        ]
        
        return dictionary
    }
    
    public func endDate() -> Date {
        return self.calculationDate
    }
}
