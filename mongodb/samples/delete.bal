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

    log:print("------------------ Deleting Data -------------------");
    map<json> deleteFilter = { "name": "Salesforce" };
    int deleteRet = checkpanic mongoClient->delete(collection, (), deleteFilter, true);
    if (deleteRet > 0 ) {
        log:print("Delete count: '" + deleteRet.toString() + "'.") ;
    } else {
        log:print("Error in deleting data");
    }
    
    mongoClient->close();
}
