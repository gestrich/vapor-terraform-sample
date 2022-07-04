import Vapor
import SotoCore

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.aws.client = AWSClient(httpClientProvider: .shared(app.http.client.shared))

    // register routes
    try routes(app)
}


