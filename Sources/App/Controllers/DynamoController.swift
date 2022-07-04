//
//  DynamoController.swift
//  
//
//  Created by Bill Gestrich on 7/4/22.
//

import Vapor

struct DynamoController: RouteCollection {
    
    let store = DynamoStoreService(tableName: "sugar-monitor")

    
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("accounts")
        todos.get(use: show)
    }

    func show(req: Request) async throws -> String {
        let users = try await store.getUsers()
        return "\(users.count)"
    }}
