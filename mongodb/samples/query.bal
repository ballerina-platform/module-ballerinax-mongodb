import ballerina/log;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;

type Movie record {
    string name;
    int year;
    int rating;
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
    log:printInfo("------------------ Insert Data to query -------------------");
    map<json> insertDocument1 = {name: "Joker", year: 2019, rating: 7};
    map<json> insertDocument2 = {name: "Black Panther", year: 2018, rating: 6};

    check mongoClient->insert(insertDocument1, collection);
    check mongoClient->insert(insertDocument2, collection);

    log:printInfo("------------------ Querying Data -------------------");
    stream<Movie, error?> result = check mongoClient->find(collection, (), ());
    check result.forEach(function(Movie movieResult){
        log:printInfo(movieResult.name);
    });

    log:printInfo("------------------ Querying Data with Filter -------------------");
    map<json> queryString = {rating: 2019};
    result = check mongoClient->find(collection, (), queryString);
    check result.forEach(function(Movie movieResult){
        log:printInfo(movieResult.name + " released in " + movieResult.year.toString());
    });

     mongoClient->close();
}
