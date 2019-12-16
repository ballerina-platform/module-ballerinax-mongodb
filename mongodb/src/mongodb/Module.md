Connects to Mongo DB from Ballerina.

# Module Overview

The Mongo DB connector allows you to connect to Mongo DB from Ballerina and perform `insert`, `find`, `findOne`, `replaceOne`, `delete` operations.

## Compatibility

|                             |       Version               |
|:---------------------------:|:---------------------------:|
| Ballerina Language          | 1.0.1                       |
| Mongo DB                    | V4.2.0                      |

## Sample

First, import the `wso2/mongodb` module into the ballerina project.

```ballerina
import ballerina/config;
import ballerina/log;
import wso2/mongodb;

public function main() returns error? {
    host: config:getAsString("MONGO_HOST"),
    dbName: config:getAsString("MONGO_DB_NAME"),
    username: config:getAsString("MONGO_USERNAME"),
    password: config:getAsString("MONGO_PASSWORD"),
    options: {sslEnabled: false, serverSelectionTimeout: 500}

    mongodb:Client mongoClient = check new (mongoConfig);

    json doc1 = { "name": "ballerina", "type": "src" };
    json doc2 = { "name": "connectors", "type": "artifacts" };
    json doc3 = { "name": "docerina", "type": "src" };
    json doc4 = { "name": "test", "type": "artifacts" };

    log:printInfo("------------------ Inserting Data -------------------");
    var result = mongoClient->insert("projects", doc1);
    handleInsert(result);
    result = mongoClient->insert("projects", doc2);
    handleInsert(result);
    result = mongoClient->insert("projects", doc3);
    handleInsert(result);
  
    log:printInfo("------------------ Querying Data -------------------");
    var jsonRet = mongoClient->find("projects", ());
    handleFind(jsonRet);

    json queryString = {name: "connectors" };
    jsonRet = mongoClient->find("projects", queryString);
    handleFind(jsonRet);

    json jsonRetOne = mongoClient->findOne("projects", queryString);
    handleFind(jsonRetOne);

    log:printInfo("------------------ Updating Data -------------------");
    json replaceFilter = { "type": "artifacts" };
    json doc5 = { "name": "main", "type": "artifacts" };
    boolean upsert = true;

    int response = mongoClient->replace("projects", replaceFilter, doc5,upsert);
    if (response > 0 ) {
        log:printInfo("Modified count: ") ;
        log:printInfo(response.toString());
    } else {
        log:printInfo("Error in replacing data");
    }

   log:printInfo("------------------ Deleting Data -------------------");
   json deleteFilter = { "name": "ballerina" };
   var deleteRet = mongoClient->delete("projects", deleteFilter, true);
    if (response > 0 ) {
        log:printInfo("Modified count: ") ;
        log:printInfo(response.toString());
    } else {
        log:printInfo("Error in replacing data");
    }
    
     mongoClient.stop();
}

function handleInsert(json|error returned) {
    if (returned is json) {
        log:printInfo("Successfully inserted data to mongo db");
    } else {
        log:printError(returned.reason());
    }
}

function handleFind(json|error returned) {
    if (returned is json) {
        log:printInfo("Find operation failed");
    } else {
        log:printError(returned.reason());
    }
}
```