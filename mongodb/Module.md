## Overview
MongoDB is a document database designed to cater to modern application requirements. It is a scalable and a flexible solution that inherently supports distributed system design. Ballerina MongoDB Connector allows you to perform the MongoDB CRUD operations.

This module supports [MongoDB version 4.2](https://docs.mongodb.com/v4.2/).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

1. Make sure a MongoDB is available to connect.

2. Obtain connection details such as connection URL or hostname, port number, username, and password to connect the database.

## Quickstart

To use the `MongoDB` connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the `ballerinax/mongodb` module into the Ballerina project.
```ballerina
import ballerinax/mongodb;
```

### Step 2: Create a new connector instance
Create a `mongodb:ClientConfig` with connection details obtained, and initialize the connector with it.

To use the MongoDB client you need to specify the database it needs to connect to. If you plan to use this client to connect to single database then you can pass the database name along with the other configurations required for client initialization(optional). Alternatively, you can pass the database name for each remote method call. This is not recommended unless you need to connect to more than one database using the client.

```ballerina
mongodb:ClientConfig mongoConfig = {
    host: <YOUR_HOST_NAME>,
    port: <PORT>,
    username: <DB_USERNAME>,
    password: <DB_PASSWORD>,
    options: {sslEnabled: false, serverSelectionTimeout: 5000}
};
string database = <DATABASE_NAME>
mongodb:Client mongoClient = check new (mongoConfig, database);
```

### Step 3: Invoke connector operation
1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.  
Following is an example on how to insert a document into a collection using the connector.
    ```ballerina
    public function main() returns error? {
        
        string collection = "<COLLECTION_NAME>"
        map<json> doc = { "name": "Gmail", "version": "0.99.1", "type" : "Service" };

        check mongoClient->insert(doc, collection);

        mongoClient->close();
    }
    ```
2. Use `bal run` command to compile and run the Ballerina program.

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/samples/)**
