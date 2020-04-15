[![Build Status](https://travis-ci.org/ballerina-platform/module-mongodb.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-mongodb)

The Ballerina MongoDB Client is used to connect Ballerina with a MongoDB data source.
 The following operations are supported by the Ballerina MongoDB client.

1. getDatabaseNames - Get the database names in a given MongoDB node
2. getCollectionNames - Get the collection names in a given MongoDB collection
3. countDocuments - Count the documents in a given collection
4. insert - To insert a document to a given collection
5. find - To select a document from a given collection according to a given query
6. update - To update the documents, which matche the given filter
7. delete - To delete the documents, which match the given filter

## Samples

### Performing CRUD operations with a MongoDB client

The following is a simple Ballerina program, which can be used to perform CRUD operations.

```ballerina
import ballerina/log;
import ballerina/mongodb;

public function main() {

    mongodb:ClientConfig mongoConfig = {
        host: "localhost",
        port: 27017,
        username: "admin",
        password: "admin",
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig);
    mongodb:Database mongoDatabase = checkpanic mongoClient->getDatabase("Ballerina");
    mongodb:Collection mongoCollection = checkpanic mongoDatabase->getCollection("projects");

    map<json> doc1 = { "name": "ballerina", "type": "src" };
    map<json> doc2 = { "name": "connectors", "type": "artifacts" };
    map<json> doc3 = { "name": "docerina", "type": "src" };
    map<json> doc4 = { "name": "test", "type": "artifacts" };

    log:printInfo("------------------ Inserting Data -------------------");
    checkpanic mongoCollection->insert(doc1);
    checkpanic mongoCollection->insert(doc2);
    checkpanic mongoCollection->insert(doc3);
    checkpanic mongoCollection->insert(doc4);
  
    log:printInfo("------------------ Counting Data -------------------");
    int count = checkpanic mongoCollection->countDocuments(());
    log:printInfo("Count of the documents '" + count.toString() + "'.");


    log:printInfo("------------------ Querying Data -------------------");
    map<json>[] jsonRet = checkpanic mongoCollection->find(());
    log:printInfo("Returned documents '" + jsonRet.toString() + "'.");

    map<json> queryString = {name: "connectors" };
    jsonRet = checkpanic mongoCollection->find(queryString);
    log:printInfo("Returned Filtered documents '" + jsonRet.toString() + "'.");


    log:printInfo("------------------ Updating Data -------------------");
    map<json> replaceFilter = { "type": "artifacts" };
    map<json> replaceDoc = { "name": "main", "type": "artifacts" };

    int response = checkpanic mongoCollection->update(replaceDoc, replaceFilter, true);
    if (response > 0 ) {
        log:printInfo("Modified count: '" + response.toString() + "'.") ;
    } else {
        log:printInfo("Error in replacing data");
    }

   log:printInfo("------------------ Deleting Data -------------------");
   map<json> deleteFilter = { "name": "ballerina" };
   var deleteRet = checkpanic mongoCollection->delete(deleteFilter, true);
    if (response > 0 ) {
        log:printInfo("Delete count: '" + response.toString() + "'.") ;
    } else {
        log:printInfo("Error in deleting data");
    }

     mongoClient->close();
}
```
