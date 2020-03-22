[![Build Status](https://travis-ci.org/ballerina-platform/module-mongodb.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-mongodb)

Ballerina MongoDB Client is used to connect Ballerina with MongoDB data source.<br/> <br/>
 With the Ballerina MongoDB client following operations are supported.

1. insert - To insert document to a given collection <br/>
2. find - To select document from a given collection according to given query. <br/>
3. findOne - To select the first document match with the query.<br/>
4. update - To update documents that matches to the given filter. <br/>
5. delete - To delete documents that matches to the given filter.
Steps to Configure <br/>

## Samples

### Performing CRUD operations with MongoDB client

Following is a simple Ballerina program that can be used to perform CRUD operations.

```ballerina
import ballerina/io;
import ballerina/mongodb;
import ballerina/log;

mongodb:ClientEndpointConfig mongoConfig = {
    host: "localhost",
    dbName: "projectsTest1",
    username: "",
    password: "",
    options: {sslEnabled: false, serverSelectionTimeout: 500}
};

public function main() returns error? {
   
mongodb:Client mongoClient =  check new (mongoConfig);

    json doc1 = { "name": "ballerina", "type": "src" };
    json doc2 = { "name": "connectors", "type": "artifacts" };
    json doc3 = { "name": "docerina", "type": "src" };
    json doc4 = { "name": "test", "type": "artifacts" };

    log:printInfo("------------------ Inserting Data -------------------");
    var ret = mongoClient->insert("projects", doc1);
    handleInsert(ret, "Insert to projects");
    ret = mongoClient->insert("projects", doc2);
    handleInsert(ret, "Insert to projects");
    ret = mongoClient->insert("projects", doc3);
    handleInsert(ret, "Insert to projects");
  
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

function handleInsert(json|error returned, string message) {
    if (returned is error) {
        log:printInfo(message + " failed: " , returned.reason());
    } else {
        log:printInfo(message + " success ");
    }
}

function handleFind(json|error returned) {
    if (returned is json) {
        log:printInfo("initial data:");
        log:printInfo(io:sprintf("%s", returned));
    } else {
        log:printInfo("find failed: " + returned.reason());
    }
}```

