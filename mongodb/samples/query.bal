import ballerina/log;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;

public function main() {
    
    mongodb:ClientConfig mongoConfig = {
        host: host,
        port: port,
        username: username,
        password: password,
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig, database);
    log:printInfo("------------------ Querying Data -------------------");
    map<json>[] jsonRet = checkpanic mongoClient->find(collection, (), ());
    log:printInfo("Returned documents '" + jsonRet.toString() + "'.");

    log:printInfo("------------------ Querying Data with Filter -------------------");
    map<json> queryString = {"name": "Gmail" };
    jsonRet = checkpanic mongoClient->find(collection, (), queryString);
    log:printInfo("Returned Filtered documents '" + jsonRet.toString() + "'.");

     mongoClient->close();
}
