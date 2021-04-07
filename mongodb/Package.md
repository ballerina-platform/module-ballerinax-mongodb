# Ballerina MongoDB Connector

Connects to MongoDB from ballerina 

## Module Overview

The Mongo DB connector allows you to connect to a Mongo DB from Ballerina and perform various operations such as `getDatabaseNames`, `getCollectionNames`, `count`, `listIndices`, `find`, `insert`, `update`, and `delete`.

## Prerequisites

* A mongodb with username and password

* Java 11 Installed <br/> Java Development Kit (JDK) with version 11 is required.

* Ballerina SLAlpha2 Installed <br/> Ballerina Swan Lake Alpha 2 is required.

## Compatibility

|                             |       Version               |
|:---------------------------:|:---------------------------:|
| Ballerina Language          | Swan Lake Alpha 2           |
| Mongo DB                    | V4.2.0                      |


## Quickstart(s)

## Insert a document

### Step 1: Import the Mongo DB module
First, import the `ballerinax/mongodb` module into the Ballerina project.
```ballerina
import ballerinax/mongodb;
```
### Step 2: Set up configurable values
You can add required variables as configurable values in the ballerina file and can add those values in `Config.toml` file. 
1. In Ballerina file 
```ballerina
configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;
```
2. In Config.toml

```
host = "<YOUR_HOST_NAME>""
port = <PORT>
username = "<DB_USERNAME>"
password = "<DB_PASSWORD>"

database = "<DATABASE_NAME>"
collection = "<COLLECTION_NAME>"
```

### Step 3: Initialize the Mongodb Client giving necessary credentials

You can now enter the credentials in the mongo client config. If you use this client for a particular database then you can pass the database name along with config during client initialization(It is optional). Otherwise you can pass the database name for each remote method call. This is not recommended unless you need to connect more than one database using a client. You need to set the database using atleast one of these methods.
```ballerina
mongodb:ClientConfig mongoConfig = {
        host: host,
        port: port,
        username: username,
        password: password,
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig, database);
```
### Step 4: Insert the document
You can invoke the remote method `insert` to insert the document.
```ballerina
map<json> doc = { "name": "Gmail", "version": "0.99.1", "type" : "Service" };

    checkpanic  mongoClient->insert(doc, collection);
```
### Step 5: Close the db client connection. 

```ballerina
mongoClient->close();
```

## Sample

You can find samples here : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/

### All operations in a single sample

First, import the `ballerinax/mongodb` module into the Ballerina project.

```ballerina
import ballerina/log;
import ballerinax/mongodb;

public function main() {

    mongodb:ClientConfig mongoConfig = {
        host: "localhost",
        port: 27017,
        username: "admin",
        password: "admin",
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig, "Ballerina");

    map<json> doc1 = { "name": "ballerina", "type": "src" };
    map<json> doc2 = { "name": "connectors", "type": "artifacts" };
    map<json> doc3 = { "name": "docerina", "type": "src" };
    map<json> doc4 = { "name": "test", "type": "artifacts" };

    log:print("------------------ Inserting Data -------------------");
    checkpanic mongoClient->insert(doc1,"projects");
    checkpanic mongoClient->insert(doc2,"projects");
    checkpanic mongoClient->insert(doc3,"projects");
    checkpanic mongoClient->insert(doc4,"projects");
  
    log:print("------------------ Counting Data -------------------");
    int count = checkpanic mongoClient->countDocuments("projects",());
    log:print("Count of the documents '" + count.toString() + "'.");


    log:print("------------------ Querying Data -------------------");
    map<json>[] jsonRet = checkpanic mongoClient->find("projects",(),());
    log:print("Returned documents '" + jsonRet.toString() + "'.");

    map<json> queryString = {"name": "connectors" };
    jsonRet = checkpanic mongoClient->find("projects", (), queryString);
    log:print("Returned Filtered documents '" + jsonRet.toString() + "'.");


    log:print("------------------ Updating Data -------------------");
    map<json> replaceFilter = { "type": "artifacts" };
    map<json> replaceDoc = { "name": "main", "type": "artifacts" };

    int response = checkpanic mongoClient->update(replaceDoc,"projects", (), replaceFilter, true);
    if (response > 0 ) {
        log:print("Modified count: '" + response.toString() + "'.") ;
    } else {
        log:print("Error in replacing data");
    }

   log:print("------------------ Deleting Data -------------------");
   map<json> deleteFilter = { "name": "ballerina" };
   int deleteRet = checkpanic mongoClient->delete("projects", (), deleteFilter, true);
   if (deleteRet > 0 ) {
       log:print("Delete count: '" + deleteRet.toString() + "'.") ;
   } else {
       log:print("Error in deleting data");
   }

     mongoClient->close();
}
```