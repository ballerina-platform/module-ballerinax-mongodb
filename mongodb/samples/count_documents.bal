import ballerina/log;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;

public function main() returns error? {
    
    mongodb:ConnectionConfig mongoConfig = {
        host: host,
        port: port,
        username: username,
        password: password,
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = check new (mongoConfig, database);

    log:printInfo("------------------ Counting Data -------------------");
    int count = check mongoClient->countDocuments(collection);
    log:printInfo("Count of the documents '" + count.toString() + "'.");
    
    mongoClient->close();
}
