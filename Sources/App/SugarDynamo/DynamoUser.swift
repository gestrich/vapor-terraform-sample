//
//  DynamoUser.swift
//  
//
//  Created by Bill Gestrich on 12/9/20.
//

import Foundation
import SotoDynamoDB

public struct DynamoUser {
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "User"
    public static let emailKey = DynamoStoreService.sortKey
    public static let passwordKey: String = "passwordKey"
    public static let firstNameKey: String = "firstName"
    public static let lastNameKey: String = "lastName"
    public static let nickNameKey: String = "nickName"
    public static let phoneKey: String = "phone"
    public static let slackIDKey: String = "slackID"
    
    public let email: String
    public let password: String
    public let firstName: String
    public let lastName: String
    public let nickName: String
    public let phone: String
    public let slackID: String
    
    public init(email: String, password: String, firstName: String, lastName: String, nickName: String, phone: String, slackID: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.nickName = nickName
        self.phone = phone
        self.slackID = slackID
    }
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        let dictionary = [
            DynamoUser.partitionKey: DynamoDB.AttributeValue.s( String(DynamoUser.partitionValue)),
            DynamoUser.emailKey: DynamoDB.AttributeValue.s( String(email)),
            DynamoUser.passwordKey: DynamoDB.AttributeValue.s( String(password)),
            DynamoUser.firstNameKey: DynamoDB.AttributeValue.s( String(firstName)),
            DynamoUser.lastNameKey: DynamoDB.AttributeValue.s( String(lastName)),
            DynamoUser.nickNameKey: DynamoDB.AttributeValue.s( String(nickName)),
            DynamoUser.phoneKey: DynamoDB.AttributeValue.s( String(phone)),
            DynamoUser.slackIDKey: DynamoDB.AttributeValue.s( String(slackID)),
        ]
        
        return dictionary
    }

    public static func userWith(dictionary: [String: DynamoDB.AttributeValue]) -> DynamoUser? {
        
        guard case let .s(email) = dictionary[DynamoUser.emailKey] else {
            return nil
        }
        
        guard case let .s(password) = dictionary[DynamoUser.passwordKey] else {
            return nil
        }
        
        guard case let .s(firstName) = dictionary[DynamoUser.firstNameKey] else {
            return nil
        }
        
        guard case let .s(lastName) = dictionary[DynamoUser.lastNameKey] else {
            return nil
        }
        
        guard case let .s(nickName) = dictionary[DynamoUser.nickNameKey] else {
            return nil
        }
        
        guard case let .s(phone) = dictionary[DynamoUser.phoneKey] else {
            return nil
        }
        
        guard case let .s(slackID) = dictionary[DynamoUser.slackIDKey] else {
            return nil
        }
        
        return DynamoUser(email: email, password: password, firstName: firstName, lastName: lastName, nickName: nickName, phone: phone, slackID: slackID)
    }
}


