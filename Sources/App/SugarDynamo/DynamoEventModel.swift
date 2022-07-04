//
//  DynamoEventModel.swift
//  
//
//  Created by Bill Gestrich on 11/25/21.
//

import Foundation
import SotoDynamoDB

public protocol DynamoEventModel {
    
    static var partitionValue: String { get }
    
    init?(dictionary: [String: DynamoDB.AttributeValue])
    var attributeValues: [String: DynamoDB.AttributeValue] { get }
    func save(store: DynamoStoreService) async throws
}

extension DynamoEventModel {
    public func save(store: DynamoStoreService) async throws {
        try await store.save(model: self)
    }
}

//extension DynamoModel {
//    //change this to iterate through AWS Dynamo dictionarys
//    //then convert that to model
//
//    static func toDictionary() -> [String: Codable]{
//
//        var toRet = [String: Codable]()
//        let mirror = Mirror(reflecting: self)
//
//        for child in mirror.children {
//            guard let label = child.label else {
//                continue
//            }
//
//            guard let value = child.value as? Codable else {
//                continue
//            }
//
//            toRet[label] = value
//            print("Property name:", label)
//            print("Property value:", child.value)
//
//        }
//
//        return toRet
//    }
//}
//Couldn't get this to do what I need.
//I wanted the key for the dynamo attribute to be
//the projected value. Property properties don't
//seem meant to have extra data that you initialize with... the
//projected value seems more like a calculated value.
/*
 
@propertyWrapper
public struct DynamoStringAttribute {

    public var projectedValue: String
    private var stringValue = ""
    
    public var wrappedValue: String {
        get {
            return stringValue
        }
        
        set {

        }
    }
    

    init(wrappedValue: String, identifier: String) {
        stringValue = wrappedValue
        self.projectedValue = identifier
    }
}
*/

/*
static func dynamoKeysToKeyPaths() -> [KeyPath<DynamoLoopLog, String>] {
    return [
        \.message
    ]
}
 */
