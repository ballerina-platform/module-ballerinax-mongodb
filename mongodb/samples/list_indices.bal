import ballerina/log;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;

public function main() {
    
    mongodb:ConnectionConfig mongoConfig = {
        host: host,
        port: port,
        username: username,
        password: password,
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig, database);

    log:printInfo("------------------ List Indicies -------------------");
    map<json>[] indicies = checkpanic mongoClient->listIndices(collection);
    foreach var index in indicies {
        log:printInfo(index.toString());
    }
    
    mongoClient->close();
}
