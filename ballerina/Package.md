## Overview

[MongoDB](https://docs.mongodb.com/v4.2/) is a general purpose, document-based, distributed database built for modern application developers and for the cloud era. MongoDB offers both a Community and an Enterprise version of the database.

The `ballerinax/mongodb` package offers APIs to connect to MongoDB servers and to perform various operations including CRUD operations, indexing, and aggregation. The Ballerina MongoDB connector uses the MongoDB Java Sync library underneath. It is compatible with MongoDB 3.6 and later versions.

## Setup guide

To use the MongoDB connector, you need to have a MongoDB server running and accessible. For that, you can either install MongoDB locally or use the [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register), the cloud offering of the MongoDB.

### Setup a MongoDB server locally

#### Step 1: Install and run the MongoDB server

1. Download and install the MongoDB server from the [MongoDB download center](https://www.mongodb.com/try/download/community).

2. Follow the installation instructions provided in the download center.

3. Follow the [instructions](https://www.mongodb.com/docs/manual/administration/install-community/#std-label-install-mdb-community-edition) for each operating system to start the MongoDB server.

> **Note:** This guide uses the MongoDB community edition for the setup. Alternatively, the enterprise edition can also be used.

### Setup a MongoDB server using MongoDB Atlas

1. Sign up for a free account in [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register).

2. Follow the instructions provided in the [MongoDB Atlas documentation](https://docs.atlas.mongodb.com/getting-started/) to create a new cluster.

3. Navigate to your MongoDB Atlas cluster.

4. Select "Database" from the left navigation pane under the "Deployment" section and click "connect" button to open connection instructions.

    ![MongoDB Atlas Connect](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-mongodb/master/docs/setup/resources/mongodb-atlas-connect.png)

5. Add your IP address to the IP access list or select "Allow access from anywhere" to allow all IP addresses to access the cluster.

    ![MongoDB Atlas IP Access List](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-mongodb/master/docs/setup/resources/mongodb-atlas-ip-access-list.png)

6. Click "Choose a connection method" and select "Drivers" under the "Connect your application". There you can find the connection string to connect to the MongoDB Atlas cluster.

    ![MongoDB Atlas Connection Method](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-mongodb/master/docs/setup/resources/mongodb-atlas-connection-method.png)

## Quickstart

### Step 1: Import the module

Import the `mongodb` module into the Ballerina project.

```ballerina
import ballerinax/mongodb;
```

### Step 2: Initialize the MongoDB client

#### Initialize the MongoDB client using the connection parameters

```ballerina
mongodb:Client mongoDb = new ({
    connection: {
        serverAddress: {
            host: "localhost",
            port: 27017
        },
        auth: <mongodb:ScramSha256AuthCredential>{
            username: <username>,
            password: <password>,
            database: <admin-database>
        }
    }
});

#### Initialize the MongoDB client using the connection string.

```ballerina
mongodb:Client mongoDb = new ({
    connectionString: <connection string obtained from the MongoDB server>
});
```

### Step 3: Invoke the connector operation

Now, you can use the available connector operations to interact with MongoDB server.

#### Retrieve a Database

```ballerina
mongodb:Database moviesDb = check mongoDb->getDatabase("movies");
```

#### Retrieve a Collection

```ballerina
mongodb:Collection moviesCollection = check moviesDb->getCollection("movies");
```

#### Insert a Document

```ballerina
// Insert the document
Movie movie = {title: "Inception", year: 2010};
check moviesCollection->insert(movie);
```

### Step 4: Run the Ballerina application

Save the changes and run the Ballerina application using the following command.

```bash
bal run
```

## Examples

The MongoDB connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples/) covering common MongoDB operations.

1. [Movie database](https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples/movie-database) - Implement a movie database using MongoDB.
