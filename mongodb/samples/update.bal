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

    log:printInfo("------------------ Updating Data -------------------");
    map<json> replaceFilter = { "type": "DataBase" };
    map<json> replaceDoc = { "type": "Database" };

    int response = checkpanic mongoClient->update(replaceDoc, collection, (), replaceFilter, true);
    if (response > 0 ) {
        log:printInfo("Modified count: '" + response.toString() + "'.") ;
    } else {
        log:printInfo("Nothing modified.");
    }

    log:printInfo("------------------ Updating Data with another filter -------------------");
    map<json> replaceFilter2 = { "name": "Mongodb" };
    map<json> replaceDoc2 = { "name": "Mongodb", "version": "0.92.3", "type" : "Database" };

    int response2 = checkpanic mongoClient->update(replaceDoc2, collection, (), replaceFilter2, true);
    if (response2 > 0 ) {
        log:printInfo("Modified count with another filter: '" + response2.toString() + "'.") ;
    } else {
        log:printInfo("Nothing modified with another filter.");
    }

    mongoClient->close();
}
