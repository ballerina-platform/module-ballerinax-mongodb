The Mongo DB connector allows you to connect to a Mongo DB from Ballerina and perform various operations such as `getDatabaseNames`, `getCollectionNames`, `count`, `find`, `insert`, `update`, and `delete`.

## Compatibility

|                             |       Version               |
|:---------------------------:|:---------------------------:|
| Ballerina Language          | Swan Lake Alpha 1           |
| Mongo DB                    | V4.2.0                      |

## MongoDB Clients

There are 3 clients provided by Ballerina to interact with MongoDB.

1. **mongodb:Client** - This connects to the running MongoDB node and lists the database names as well as gets a client for a specific database.

    ```ballerina
    ClientConfig mongoConfig = {
            host: "localhost",
            options: {sslEnabled: false, serverSelectionTimeout: 5000}
        };
    Client mongoClient = check new (mongoConfig);
    ```

2. **mongodb:Database** - This connects to a specific MongoDB database and lists the collection names as well as gets a client for a specific collection.

    ```ballerina
    Database mongoDatabase = check mongoClient->getDatabase("moviecollection");
    ```

3. **mongodb:Collection** - This connects to a specific collection and performs various operations such as `count`, `listIndexes`, `insert`, `find`, `update`, and `delete`.

    ```ballerina
    Collection mongoCollection = check mongoDatabase->getCollection("moviedetails");
    ```

## Sample

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

    mongodb:Client mongoClient = checkpanic new (mongoConfig);
    mongodb:Database mongoDatabase = checkpanic mongoClient->getDatabase("Ballerina");
    mongodb:Collection mongoCollection = checkpanic mongoDatabase->getCollection("projects");

    map<json> doc1 = { "name": "ballerina", "type": "src" };
    map<json> doc2 = { "name": "connectors", "type": "artifacts" };
    map<json> doc3 = { "name": "docerina", "type": "src" };
    map<json> doc4 = { "name": "test", "type": "artifacts" };

    log:print("------------------ Inserting Data -------------------");
    checkpanic mongoCollection->insert(doc1);
    checkpanic mongoCollection->insert(doc2);
    checkpanic mongoCollection->insert(doc3);
    checkpanic mongoCollection->insert(doc4);
  
    log:print("------------------ Counting Data -------------------");
    int count = checkpanic mongoCollection->countDocuments(());
    log:print("Count of the documents '" + count.toString() + "'.");


    log:print("------------------ Querying Data -------------------");
    map<json>[] jsonRet = checkpanic mongoCollection->find(());
    log:print("Returned documents '" + jsonRet.toString() + "'.");

    map<json> queryString = {name: "connectors" };
    jsonRet = checkpanic mongoCollection->find(queryString);
    log:print("Returned Filtered documents '" + jsonRet.toString() + "'.");


    log:print("------------------ Updating Data -------------------");
    map<json> replaceFilter = { "type": "artifacts" };
    map<json> replaceDoc = { "name": "main", "type": "artifacts" };

    int response = checkpanic mongoCollection->update(replaceDoc, replaceFilter, true);
    if (response > 0 ) {
        log:print("Modified count: '" + response.toString() + "'.") ;
    } else {
        log:print("Error in replacing data");
    }

   log:print("------------------ Deleting Data -------------------");
   map<json> deleteFilter = { "name": "ballerina" };
   var deleteRet = checkpanic mongoCollection->delete(deleteFilter, true);
    if (response > 0 ) {
        log:print("Delete count: '" + response.toString() + "'.") ;
    } else {
        log:print("Error in deleting data");
    }

     mongoClient->close();
}
```
