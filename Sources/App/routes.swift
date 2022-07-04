import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!!!!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.get("health") { req -> String in
        return "We are healthy!"
    }
    
    app.get("accounts") { req async throws -> String in
        let store = DynamoStoreService(tableName: "sugar-monitor")
        return try await store.getUser(email: "wgestrich@gmail.com")?.email ?? "Could not find"
    }
}
