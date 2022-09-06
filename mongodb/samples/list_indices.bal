import ballerina/log;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;

type Index record {
    int v;
    json key;
    string name;
    string ns;
};
public function main() returns error? {
    
    mongodb:ConnectionConfig mongoConfig = {
        connection: {
            host: host,
            port: port,
            auth: {
                username: username,
                password: password
            },
            options: {
                sslEnabled: false, 
                serverSelectionTimeout: 5000
            } 
        },
        databaseName: database
    };

    mongodb:Client mongoClient = check new (mongoConfig);

    log:printInfo("------------------ List Indicies -------------------");
    stream<Index, error?> indicies = check mongoClient->listIndices(collection);
    check indicies.forEach(function(Index index){
        log:printInfo(index.name);
    });
    
    mongoClient->close();
}
