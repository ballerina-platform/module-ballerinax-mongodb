# Ballerina MongoDB Connector

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-mongodb/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/actions?query=workflow%3ACI)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-mongodb/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/actions/workflows/trivy-scan.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-mongodb/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-mongodb)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-mongodb.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-mongodb/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

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
2. [Order management system](https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples/order-management-system) - Implement an order management system using MongoDB.

## Issues and projects

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc., visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library).

## Building from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 17. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Building the source

Execute the commands below to build from the source.

1. To build the package:

    ```bash
        ./gradlew clean build
    ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run selected test groups:

   ```bash
   ./gradlew clean test -P groups=<Comma separated groups/test cases>
   ```

5. To debug package with a remote debugger:

   ```bash
   ./gradlew clean build -P debug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -P balJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -P publishToLocalCentral=true
    ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`mongodb` package](https://lib.ballerina.io/ballerinax/mongodb/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
