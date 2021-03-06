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
    
    try app.register(collection: DynamoController(awsClient: app.aws.client))
}
