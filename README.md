# Ballerina MongoDB Connector

Connects to MongoDB from ballerina 

# Introduction
## What is MongoDB?
[MongoDB](https://docs.mongodb.com/v4.2/) is a general purpose, document-based, distributed database built for modern application developers and for the cloud era. MongoDB offers both a Community and an Enterprise version of the database.

## Key Features of MongoDB

- List database names
- List collection names
- Insert
- Update
- Find
- Delete
- Count

## Connector Overview

The Mongo DB connector allows you to connect to a Mongo DB from Ballerina and perform various operations such as `getDatabaseNames`, `getCollectionNames`, `count`, `listIndices`, `find`, `insert`, `update`, and `delete`.

# Prerequisites

* A mongodb with username and password

* Java 11 Installed <br/> Java Development Kit (JDK) with version 11 is required.

* Ballerina SLAlpha5 Installed <br/> Ballerina Swan Lake Alpha 5 is required.

# Supported Versions 

|                             |       Version               |
|:---------------------------:|:---------------------------:|
| Ballerina Language          | Swan Lake Alpha 5           |
| Mongo DB                    | V4.2.0                      |



# Quickstart(s)

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

# Samples
Following are some samples to use Mongodb connector

## List all database names
This sample shows how to listdown all available database names. 
Sample is available at : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/get_all_db_names.bal

```ballerina
import ballerina/log;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;

public function main() {
    
    mongodb:ClientConfig mongoConfig = {
        host: host,
        port: port,
        username: username,
        password: password,
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig);
    string [] dbNames = checkpanic mongoClient->getDatabasesNames();
    log:printInfo("------------------ Database Names -------------------");
    foreach var dbName in dbNames {
        log:printInfo("Database Name : " + dbName);
    }
     mongoClient->close();
}

```
## List all collection names in a DB
This sample shows how to listdown all available collection names of a particular database. 
Sample is available at : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/get_all_collection_names.bal

```ballerina
import ballerina/log;
import ballerinax/mongodb;

configurable string host = ?;
configurable int port = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;

public function main() {
    
    mongodb:ClientConfig mongoConfig = {
        host: host,
        port: port,
        username: username,
        password: password,
        options: {sslEnabled: false, serverSelectionTimeout: 5000}
    };

    mongodb:Client mongoClient = checkpanic new (mongoConfig);
    
    string [] collectionNames = checkpanic mongoClient->getCollectionNames(database);
    log:printInfo("------------------ Collection Names -------------------");
    foreach var collectionName in collectionNames {
        log:printInfo("Collection Name : " + collectionName);
    }
     mongoClient->close();
}

```
## Insert a document
This sample shows how to insert a document into a particular collection. 
Sample is available at : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/insert.bal

```ballerina
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

    map<json> doc1 = { "name": "Gmail", "version": "0.99.1", "type" : "Service" };
    map<json> doc2 = { "name": "Salesforce", "version": "0.99.5", "type" : "Enterprise" };
    map<json> doc3 = { "name": "Mongodb", "version": "0.89.5", "type" : "DataBase" };

    log:printInfo("------------------ Inserting Data -------------------");
    checkpanic  mongoClient->insert(doc1, collection);
    checkpanic  mongoClient->insert(doc2, collection);
    checkpanic  mongoClient->insert(doc3, collection);
    
    mongoClient->close();
}

```
## Update a document
This sample shows how to update a document into a particular collection 
Sample is available at : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/update.bal

```ballerina
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

```
## Query
This sample shows how to query a collection. 
Sample is available at :https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/query.bal

```ballerina
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

```
## Count Documents
This sample shows how to get the count of available documents in a particular collection. 

Sample is available at : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/count_documents.bal

```ballerina
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

    log:printInfo("------------------ Counting Data -------------------");
    int count = checkpanic mongoClient->countDocuments(collection);
    log:printInfo("Count of the documents '" + count.toString() + "'.");
    
    mongoClient->close();
}

```
## Delete a document
This sample shows how to delete a document from a particular collection.

Sample is available at : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/delete.bal

```ballerina
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

    log:printInfo("------------------ Deleting Data -------------------");
    map<json> deleteFilter = { "name": "Salesforce" };
    int deleteRet = checkpanic mongoClient->delete(collection, (), deleteFilter, true);
    if (deleteRet > 0 ) {
        log:printInfo("Delete count: '" + deleteRet.toString() + "'.") ;
    } else {
        log:printInfo("Error in deleting data");
    }
    
    mongoClient->close();
}

```
## List indices
This sample shows how to listdown all indices of a collection. 

Sample is available at : https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/list_indices.bal

```ballerina
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

    log:printInfo("------------------ List Indicies -------------------");
    map<json>[] indicies = checkpanic mongoClient->listIndices(collection);
    foreach var index in indicies {
        log:printInfo(index.toString());
    }
    
    mongoClient->close();
}

```
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

    log:printInfo("------------------ Inserting Data -------------------");
    checkpanic mongoClient->insert(doc1,"projects");
    checkpanic mongoClient->insert(doc2,"projects");
    checkpanic mongoClient->insert(doc3,"projects");
    checkpanic mongoClient->insert(doc4,"projects");
  
    log:printInfo("------------------ Counting Data -------------------");
    int count = checkpanic mongoClient->countDocuments("projects",());
    log:printInfo("Count of the documents '" + count.toString() + "'.");


    log:printInfo("------------------ Querying Data -------------------");
    map<json>[] jsonRet = checkpanic mongoClient->find("projects",(),());
    log:printInfo("Returned documents '" + jsonRet.toString() + "'.");

    map<json> queryString = {"name": "connectors" };
    jsonRet = checkpanic mongoClient->find("projects", (), queryString);
    log:printInfo("Returned Filtered documents '" + jsonRet.toString() + "'.");


    log:printInfo("------------------ Updating Data -------------------");
    map<json> replaceFilter = { "type": "artifacts" };
    map<json> replaceDoc = { "name": "main", "type": "artifacts" };

    int response = checkpanic mongoClient->update(replaceDoc,"projects", (), replaceFilter, true);
    if (response > 0 ) {
        log:printInfo("Modified count: '" + response.toString() + "'.") ;
    } else {
        log:printInfo("Error in replacing data");
    }

   log:printInfo("------------------ Deleting Data -------------------");
   map<json> deleteFilter = { "name": "ballerina" };
   int deleteRet = checkpanic mongoClient->delete("projects", (), deleteFilter, true);
   if (deleteRet > 0 ) {
       log:printInfo("Delete count: '" + deleteRet.toString() + "'.") ;
   } else {
       log:printInfo("Error in deleting data");
   }

     mongoClient->close();
}
```

# Building from the Source

## Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Swann Lake Alpha5](https://ballerina.io/). 

## Building the Source

Execute the commands below to build the connector from the source after setting up the prerequisites.

1. To build the entire connector:

Execute the following command from root directory
```shell script
    ./gradlew build
```

2. To build the ballerina module only without the tests:

change the directory to `mongodb`
```shell script
    cd mongodb
```
Then execute the following command
```shell script
    bal build -c --skip-tests
```
3. To test the connector, follow the instructions given in https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/tests/Ballerina.md

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of Conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful Links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
