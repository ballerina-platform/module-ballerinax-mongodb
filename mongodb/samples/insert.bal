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

    map<json> doc1 = { "name": "Gmail", "version": "0.99.1", "type" : "Service" };
    map<json> doc2 = { "name": "Salesforce", "version": "0.99.5", "type" : "Enterprise" };
    map<json> doc3 = { "name": "Mongodb", "version": "0.89.5", "type" : "DataBase" };

    log:printInfo("------------------ Inserting Data -------------------");
    check mongoClient->insert(doc1, collection);
    check mongoClient->insert(doc2, collection);
    check mongoClient->insert(doc3, collection);
    
    mongoClient->close();
}
