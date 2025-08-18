# Specification: Ballerina MongoDB connector

_Authors_: @ThisaruGuruge \
_Reviewers_: @DimuthuMadushan @Nuvindu \
_Created_: 2024/03/01 \
_Updated_: 2025/08/18 \
_Edition_: Swan Lake

## Introduction

The Ballerina MongoDB connector allows you to connect to the MongoDB database and perform various operations such as insert, update, delete, and retrieve data from the database.

The Ballerina MongoDB connector specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` on GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

- [1. Overview](#1-overview)
- [2. Components](#2-components)
  - [2.1 Client](#21-client)
    - [2.1.1 Create a MongoDB Client](#211-create-a-mongodb-client)
      - [2.1.1.1 Create a MongoDB Client From the Connection String](#2111-create-a-mongodb-client-from-the-connection-string)
      - [2.1.1.2 Create a MongoDB Client From the Connection Parameters](#2112-create-a-mongodb-client-from-the-connection-parameters)
      - [2.1.1.3 Pass Connection Properties for the MongoDB Client](#2113-pass-connection-properties-for-the-mongodb-client)
      - [2.1.1.4 Create a MongoDB Client with SSL](#2114-create-a-mongodb-client-with-ssl)
    - [2.1.2 Client Operations](#212-client-operations)
      - [2.1.2.1 List Database Names](#2121-list-database-names)
      - [2.1.2.2 Get a Database](#2122-get-a-database)
      - [2.1.2.3 Close the Client](#2123-close-the-client)
  - [2.2 Database](#22-database)
    - [2.2.1 Create a Database](#221-create-a-database)
    - [2.2.2 Database Operations](#222-database-operations)
      - [2.2.2.1 List the Collections](#2221-list-the-collections)
      - [2.2.2.2 Create a Collection](#2222-create-a-collection)
      - [2.2.2.3 Get a Collection](#2223-get-a-collection)
      - [2.2.2.4 Drop the Database](#2224-drop-the-database)
  - [2.3 Collection](#23-collection)
    - [2.3.1 Create a Collection](#231-create-a-collection)
    - [2.3.2 Collection Operations](#232-collection-operations)
      - [2.3.2.1 Retrieve the Collection Name](#2321-retrieve-the-collection-name)
      - [2.3.2.2 Insert a Single Document](#2322-insert-a-single-document)
        - [2.3.2.2.1 Parameters of the `insertOne` Remote Method](#23221-parameters-of-the-insertone-remote-method)
      - [2.3.2.3 Insert Multiple Documents](#2323-insert-multiple-documents)
        - [2.3.2.3.1 Parameters of the `insertMany` Remote Method](#23231-parameters-of-the-insertmany-remote-method)
      - [2.3.2.4 Find Documents](#2324-find-documents)
        - [2.3.2.4.1 Parameters of the `find` Remote Method](#23241-parameters-of-the-find-remote-method)
        - [2.3.2.4.2 Projection](#23242-projection)
      - [2.3.2.5 Count Documents](#2325-count-documents)
        - [2.3.2.5.1 Parameters of the `countDocuments` Remote Method](#23251-parameters-of-the-countdocuments-remote-method)
      - [2.3.2.6 Create Index](#2326-create-index)
        - [2.3.2.6.1 Parameters of the `createIndex` Remote Method](#23261-parameters-of-the-createindex-remote-method)
      - [2.3.2.7 List Indexes](#2327-list-indexes)
      - [2.3.2.8 Drop Index](#2328-drop-index)
        - [2.3.2.8.1 Parameters of `dropIndex` Remote Method](#23281-parameters-of-the-dropindex-remote-method)
      - [2.3.2.9 Drop All Indexes](#2329-drop-all-indexes)
      - [2.3.2.10 Drop Collection](#23210-drop-collection)
      - [2.3.2.11 Update Single Document](#23211-update-single-document)
        - [2.3.2.11.1 Parameters of `updateOne` Remote Method](#232111-parameters-of-the-updateone-remote-method)
      - [2.3.2.12 Update Multiple Documents](#23212-update-multiple-documents)
        - [2.3.2.12.1 Parameters of `updateMany` Remote Method](#232121-parameters-of-the-updatemany-remote-method)
      - [2.3.2.13 Retrieve Distinct Values](#23213-retrieve-distinct-values)
        - [2.3.2.13.1 Parameters of `distinct` Remote Method](#232131-parameters-of-distinct-remote-method)
      - [2.3.2.14 Delete Single Document](#23214-delete-single-document)
        - [2.3.2.14.1 Parameters of `deleteOne` Remote Method](#232141-parameters-of-deleteone-remote-method)
      - [2.3.2.15 Delete Multiple Documents](#23215-delete-multiple-documents)
        - [2.3.2.15.1 Parameters of `deleteMany` Remote Method](#232151-parameters-of-deletemany-remote-method)
      - [2.3.2.16 Aggregate Documents](#23216-aggregate-documents)
        - [2.3.2.16.1 Parameters of `aggregate` Remote Method](#232161-parameters-of-aggregate-remote-method)
        - [2.3.2.16.2 Aggregation Pipeline](#232162-aggregation-pipeline)

## 1. Overview

MongoDB is a document-oriented NoSQL database. It is a popular choice for many modern applications because of its flexibility and scalability. MongoDB uses JSON-like documents to store data, which makes it easy to work with.

The Ballerina MongoDB connector allows you to connect to a MongoDB server and perform various database operations such as insert, update, delete, and retrieve data from the database. The in-build support for JSON-like data structures in Ballerina helps to work with MongoDB easily. The Ballerina MongoDB client supports to connect self-hosted MongoDB servers, MongoDB clusters, and MongoDB Atlas.

This specification defines the Ballerina MongoDB connector and its components.

## 2. Components

To use the Ballerina MongoDB connector, it should first be imported to the Ballerina program.

###### Example: Import the MongoDB Connector

```ballerina
import ballerinax/mongodb;
```

###### Example: Import the MongoDB Connector with an Alias

```ballerina
import ballerinax/mongodb as mongo;
```

The Ballerina MongoDB connector has 3 main components.

1. Client
2. Database
3. Collection

This section describes each of these components in detail.

### 2.1 Client

The `mongodb:Client` object represents a MongoDB client. It is used to create a connection to the MongoDB server.

> **Note:** As a best practice, use a single MongoDB client for the entire life cycle of the application. Creating multiple clients can lead to performance issues.

#### 2.1.1 Create a MongoDB Client

The MongoDB client can be created using the object constructor. The MongoDB connection string or the `mongodb:ConnectionParameters` record can be used to create the client. Additionally, `mongodb:ConnectionProperties` can be passed when creating the client to define the client properties.

##### 2.1.1.1 Create a MongoDB Client From the Connection String

The MongoDB connection string which includes the connection details such as the host, port, and database name can be used to create the MongoDB client. It can be obtained from the MongoDB Atlas or the self-hosted MongoDB server.

###### Example: Create a MongoDB Client From the Connection String as a Record Field

The connection string can be provided as a field of the `mongodb:ConnectionParameters` record.

```ballerina
import ballerinax/mongodb;

final mongodb:Client mongodb = new ({connection: "<mongodb.connection.string>"});
```

###### Example: Create a MongoDB Client From the Connection String as a Named Parameter

The connection string can be provided as a named parameter to the Client constructor.

```ballerina
import ballerinax/mongodb;

final mongodb:Client mongodb = new (connection = "<mongodb.connection.string>");
```

> **Note:** The connection string from the MongoDB atlas contains the user password. If this password contains special characters such as colon (`:`) or an at sign (`@`), it should be URL encoded before using it in the connection string.

##### 2.1.1.2 Create a MongoDB Client From the Connection Parameters

The `mongodb:ConnectionParameters` record can be used to create the MongoDB client. Following is the definition of the `mongodb:ConnectionParameters` record.

```ballerina
# Represents the MongoDB connection parameters.
public type ConnectionParameters record {|
    # Server address (or the list of server addresses for replica sets) of the MongoDB server
    ServerAddress|ServerAddress[] serverAddress = {};
    # The authentication configurations for the MongoDB connection
    BasicAuthCredential|ScramSha1AuthCredential|ScramSha256AuthCredential|X509Credential|GssApiCredential auth?;
|};
```

The `mongodb:ConnectionParameters` record has two fields, the `serverAddress` and the `auth`.

The `serverAddress` field is used to define the server address (or the list of server addresses for replica sets) of the MongoDB server. Following is the definition of the `ServerAddress` record.

```ballerina
# Represents the MongoDB server address.
public type ServerAddress record {|
    # The host address of the MongoDB server
    string host = "localhost";
    # The port of the MongoDB server
    int port = 27017;
|};
```

The `auth` field is used to define the authentication configurations for the MongoDB connection. The `auth` field can be used to define the authentication configurations such as the basic authentication, SCRAM-SHA-1 authentication, SCRAM-SHA-256 authentication, X.509 authentication, and GSSAPI authentication. For each of these authentication methods, a separate record is defined. The type of the `auth` field is a union of these records.

Following are the definitions of the records for the authentication configurations.

```ballerina
# Represents the Basic Authentication configurations for MongoDB.
public type BasicAuthCredential record {|
    # The authentication mechanism to use
    readonly AUTH_PLAIN authMechanism = AUTH_PLAIN;
    # The username for the database connection
    string username;
    # The password for the database connection
    string password;
    # The source database for authenticate the client. Usually the database name
    string database;
|};

# Represents the SCRAM-SHA-1 authentication configurations for MongoDB.
public type ScramSha1AuthCredential record {|
    # The authentication mechanism to use
    readonly AUTH_SCRAM_SHA_1 authMechanism = AUTH_SCRAM_SHA_1;
    # The username for the database connection
    string username;
    # The password for the database connection
    string password;
    # The source database for authenticate the client. Usually the database name
    string database;
|};

# Represents the SCRAM-SHA-256 authentication configurations for MongoDB.
public type ScramSha256AuthCredential record {|
    # The authentication mechanism to use
    readonly AUTH_SCRAM_SHA_256 authMechanism = AUTH_SCRAM_SHA_256;
    # The username for the database connection
    string username;
    # The password for the database connection
    string password;
    # The source database for authenticate the client. Usually the database name
    string database;
|};

# Represents the X509 authentication configurations for MongoDB.
public type X509Credential record {|
    # The authentication mechanism to use
    readonly AUTH_MONGODB_X509 authMechanism = AUTH_MONGODB_X509;
    # The username for authenticating the client certificate
    string username?;
|};

# Represents the GSSAPI authentication configurations for MongoDB.
public type GssApiCredential record {|
    # The authentication mechanism to use
    readonly AUTH_GSSAPI authMechanism = AUTH_GSSAPI;
    # The username for the database connection
    string username;
    # The service name for the database connection. Use this to override the default service name of `mongodb`
    string serviceName?;
|};
```

###### Example: Create a MongoDB Client From the Connection Parameters

```ballerina
import ballerinax/mongodb;

// Define the server address
mongodb:ServerAddress serverAddress = {
    host: "localhost",
    port: 27017
};

// Define the authentication configurations
mongodb:BasicAuthCredential auth = {
    username: "username",
    password: "password",
    database: "admin"
};

// Create the MongoDB client
final mongodb:Client mongodb = check new (connection = {
    serverAddress: serverAddress,
    auth
});
```

###### Example: Create a MongoDB Client From the Connection Parameters Inline with Multiple Server Addresses

```ballerina
import ballerinax/mongodb;

final mongodb:Client mongodb = check new ({
    connection: {
        serverAddress: [
            {
                host: "localhost",
                port: 27017
            },
            {
                host: "localhost",
                port: 27018
            }
        ],
        auth: <mongodb:BasicAuthCredential>{
            username: "username",
            password: "password",
            database: "admin"
        }
    }
});
```

##### 2.1.1.3 Pass Connection Properties for the MongoDB Client

The `mongodb:ConnectionProperties` record can be used to define the client properties when creating the MongoDB client. Following is the definition of the `mongodb:ConnectionProperties` record.

```ballerina
# Represents the MongoDB connection pool properties.
public type ConnectionProperties record {|
    # The read concern level to use
    ReadConcern readConcern?;
    # The write concern level to use
    string writeConcern?;
    # The read preference for the replica set
    string readPreference?;
    # The replica set name if it is to connect to replicas
    string replicaSet?;
    # Whether SSL connection is enabled
    boolean sslEnabled = false;
    # Whether invalid host names should be allowed
    boolean invalidHostNameAllowed = false;
    # Configurations related to facilitating secure connection
    SecureSocket secureSocket?;
    # Whether to retry writing failures
    boolean retryWrites?;
    # The timeout for the socket
    int socketTimeout?;
    # The timeout for the connection
    int connectionTimeout?;
    # The maximum connection pool size
    int maxPoolSize?;
    # The maximum idle time for a pooled connection in milliseconds
    int maxIdleTime?;
    # The maximum life time for a pooled connection in milliseconds
    int maxLifeTime?;
    # The minimum connection pool size
    int minPoolSize?;
    # The local threshold latency in milliseconds
    int localThreshold?;
    # The heartbeat frequency in milliseconds. This is the frequency that the driver will attempt
    # to determine the current state of each server in the cluster.
    int heartbeatFrequency?;
|};
```

This `mongodb:ConnectionProperties` record can be used to define various client properties such as the read concern, write concern, read preference, replica set, SSL connection, secure socket configurations, retry writes, socket timeout, connection timeout, maximum connection pool size, maximum idle time, maximum life time, minimum connection pool size, local threshold, and heartbeat frequency.

##### 2.1.1.4 Create a MongoDB Client with SSL

The `mongodb:ConnectionProperties` record can be used to define the SSL connection properties when creating the MongoDB client. To enable secure communication with SSL, the `sslEnabled` field of the `mongodb:ConnectionProperties` record should be set to `true`. Additionally, the `secureSocket` field of the `mongodb:ConnectionProperties` record can be used to define the secure socket configurations.

###### Example: Create a MongoDB Client with SSL

```ballerina
import ballerinax/mongodb;

// Define the secure socket configurations
mongodb:SecureSocket secureSocket = {
    keyStore: {
        path: "<path-to-key-store>",
        password: "<key-store-password>"
    },
    trustStore: {
        path: "<path-to-trust-store>",
        password: "<trust-store-password>"
    },
    protocol: "TLS"
};

// Create the MongoDB client with SSL
final mongodb:Client mongodb = check new (
    connection = {
        serverAddress: {
            host: "localhost",
            port: 27017
        },
        auth: <mongodb:BasicAuthCredential>{
            username: "username",
            password: "password",
            database: "admin"
        }
    },
    options = {
        sslEnabled: true,
        secureSocket
    }
);
```

###### Example: Create a MongoDB Client with SSL From the Connection String Without Secure Socket Configurations

```ballerina
import ballerinax/mongodb;

// Create the MongoDB client with SSL using the connection string
final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>", options = {sslEnabled: true});
```

> **Note:** When the `sslEnabled` field is set to `true`, the `secureSocket` field should be defined with the secure socket configurations. If the `secureSocket` field is not defined, the default secure socket configurations will be used. If the `secureSocket` field is defined without setting the `sslEnabled` field to `true`, the secure socket configurations will be ignored and a warning will be logged.

#### 2.1.2 Client Operations

The MongoDB client can be used to perform various operations such as creating a database, accessing a database, and closing the client.

Following are the operations that can be performed using the MongoDB client.

##### 2.1.2.1 List Database Names

The `listDatabaseNames` remote method can be used to list the databases in the MongoDB server. This will return an array of `string`s containing the database names or an error if the operation fails.

###### Example: List Database Names

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // List the database names
    string[] databases = check mongodb->listDatabaseNames();

    // Close the client
    check mongodb->close();
}
```

##### 2.1.2.2 Get a Database

The `getDatabase` remote method can be used to get a database from the MongoDB server.

###### 2.1.2.2.1 Parameters of the `getDatabase` Remote Method

- `databaseName`: The name of the database to get. This should be of type `string`.

###### Example: Get a Database

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // ...

    // Close the client
    check mongodb->close();
}
```

##### 2.1.2.3 Close the Client

The `close` remote method can be used to close the connection to the MongoDB server. This will return an error if the operation fails.

###### Example: Close the Client

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Close the client
    check mongodb->close();
}
```

### 2.2 Database

The `mongodb:Database` object represents a MongoDB database. It is used to perform database operations such as creating collections and accessing collections. A single MongoDB client can be used to access multiple databases.

#### 2.2.1 Create a Database

The `createDatabase` remote method of the [`mongodb:Client`](#21-client) object can be used to create a database. The database name should be passed as a parameter to it. An error will be returned from this method if the operation fails, otherwise, a `mongodb:Database` object will be returned.

###### Example: Create a Database

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Create a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // ...

    // Close the client
    check mongodb->close();
}
```

> **Note:** A `mongodb:Database` object will be returned even if the database does not exist, but it does not create a database in the MongoDB server. The database will be created when the data is stored for the first time in the database.

#### 2.2.2 Database Operations

The MongoDB database can be used to perform various operations such as creating collections, accessing collections, and dropping the database.

Following are the operations that can be performed using the MongoDB database.

##### 2.2.2.1 List the Collections

The `listCollectionNames` remote method can be used to list the collection names in the database. This will return an array of `string`s containing the collection names or an error if the operation fails.

###### Example: List Collections

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // List the collections
    string[] collections = check moviesDb->listCollectionNames();

    // Close the client
    check mongodb->close();
}
```

##### 2.2.2.2 Create a Collection

The `createCollection` remote method can be used to create a collection in the database. This will return an error if the operation fails.

###### 2.2.2.2.1 Parameters of the `createCollection` Remote Method

- `collectionName`: The name of the collection to create. This should be of type `string`.

###### Example: Create a Collection

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Create a collection
    mongodb:Collection moviesCollection = check moviesDb->createCollection("movies");

    // Close the client
    check mongodb->close();
}
```

##### 2.2.2.3 Get a Collection

The `getCollection` remote method can be used to get a collection from the database. This will return a `mongodb:Collection` object or an error if the operation fails.

###### 2.2.2.3.1 Parameters of the `getCollection` Remote Method

- `collectionName`: The name of the collection to get. This should be of type `string`. If the collection does not exist in the database, it will be created.

###### Example: Get a Collection

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check movies->getCollection("movies");

    // Close the client
    check mongodb->close();
}
```

> **Note:** A `mongodb:Collection` object will be returned even if the collection does not exist, but it does not create a collection in the database. The collection will be created when the data is stored for the first time in the collection.

##### 2.2.2.4 Drop the Database

The `drop` remote method can be used to drop the database. This will return an error if the operation fails.

###### Example: Drop the Database

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Drop the database
    check moviesDb->drop();

    // Close the client
    check mongodb->close();
}
```

### 2.3 Collection

The `mongodb:Collection` object represents a MongoDB collection. It is used to perform collection operations such as inserting documents, updating documents, deleting documents, and retrieving documents. A single MongoDB database can contain multiple collections.

#### 2.3.1 Create a Collection

The `createCollection` remote method of the [`mongodb:Database`](#22-database) object can be used to create a collection in the database. The name of the collection should be passed as a parameter to it.

###### Example: Create a Collection

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Create a collection
    check moviesDb->createCollection("movies");

    // Close the client
    check mongodb->close();
}
```

#### 2.3.2 Collection Operations

The MongoDB collection can be used to perform various operations such as inserting documents, updating documents, deleting documents, and retrieving documents.

Following are the operations that can be performed using the MongoDB collection.

##### 2.3.2.1 Retrieve the Collection Name

The `name` method can be used to retrieve the name of the collection. This will return the name of the collection as a `string`.

###### Example: Retrieve the Collection Name

```ballerina
import ballerinax/mongodb;


public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Retrieve the collection name
    string collectionName = movies.name();

    // Close the client
    check mongodb->close();
}
```

> **Note:** Retrieving the collection name is not a remote method, as this does not invoke any network calls to the MongoDB server.

##### 2.3.2.2 Insert a Single Document

The `insertOne` remote method can be used to insert a single document into the collection. This will return an error if the operation fails.

Ballerina record types can be used to insert documents into the collection. The Ballerina record types are automatically converted to the `BSON` format when inserting documents into the collection.

###### 2.3.2.2.1 Parameters of the `insertOne` Remote Method

- `document`: The document to insert. This should be of type `record<anydata>`.
- `options`: The options to apply to the insert operation. This should be of type `mongodb:InsertOneOptions` record. This parameter is optional.

###### Example: Insert a Single Document

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Insert a single document
    check movies->insertOne({
        title: "Interstellar",
        year: 2014,
        rating: 10
    });

    // Close the client
    check mongodb->close();
}
```

###### Example: Insert a Single Document Using a Ballerina Record Value

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Insert a single document
    Movie movie = {
        title: "Interstellar",
        year: 2014,
        rating: 10
    };
    check movies->insertOne(movie);

    // Close the client
    check mongodb->close();
}
```

###### Example: Insert a Single Document with Insert Options

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Insert a single document with insert options
    check movies->insertOne({
        title: "Interstellar",
        year: 2014,
        rating: 10
    }, {
        comment: "Adding a new movie",
        bypassDocumentValidation: true
    });

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.3 Insert Multiple Documents

The `insertMany` remote method can be used to insert multiple documents into the collection. This will return an error if the operation fails.

###### 2.3.2.3.1 Parameters of the `insertMany` Remote Method

- `documents`: The documents to insert. This should be an array of Ballerina `record<anydata>` values.
- `options`: The options to apply to the insert operation. This should be of type `mongodb:InsertManyOptions` record. This parameter is optional.

###### Example: Insert Multiple Documents

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Insert multiple documents
    check movies->insertMany([
        {
            title: "Inception",
            year: 2010,
            rating: 9
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 10
        }
    ]);

    // Close the client
    check mongodb->close();
}
```

###### Example: Insert Multiple Documents Using an Array of Ballerina Record Values

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Insert multiple documents
    Movie[] movieArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 9
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 10
        }
    ];
    check movies->insertMany(movieArray);

    // Close the client
    check mongodb->close();
}
```

###### Example: Insert Multiple Documents with Insert Options

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Insert multiple documents with insert options
    check movies->insertMany([
        {
            title: "Inception",
            year: 2010,
            rating: 9
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 10
        }
    ], {
        comment: "Adding new movies",
        ordered: true,
        bypassDocumentValidation: true
    });

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.4 Find Documents

The `find` remote method can be used to find documents in the collection. The return type of this method is `stream`. This method is a dependently-typed method, and the return type depends on the left hand side (_LHS_) of the expression. Refer [projection](#23242-projection) section for more information.

###### 2.3.2.4.1 Parameters of the `find` Remote Method

- `filter`: The filter to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is an optional parameter and if not provided, an empty filter will be used and all the documents in the collection will be returned.
- `options`: The options to apply to the query. This should be of type `mongodb:FindOptions` record. This is an optional parameter.
- `projection`: The projection to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is an optional parameter. If not provided, the projection will be inferred from the expected type of the query result. Providing a value for the projection will override the inferred projection.
- `targetType` - The return type of the stream. This is an optional parameter and if not provided, it will be inferred from the LHS of the expression.

###### 2.3.2.4.2 Projection

MongoDB has projection feature which helps to define the fields to return in the query result. The projection can be used to include or exclude fields from the query result. The Ballerina MongoDB connector supports projection in two ways.

- Inferred Projection: The projection will be inferred from the LHS of the expression.
- Manual Projection: The projection is provided as an input of the find method. When the projection is provided, it will override the inferred projection.

> **Note:** Manual projection might cause runtime errors since it ignores the target type when returning the stream. If the LHS expression does not match the projection, a `ConversionError` will occur at the runtime.

###### Example: Find Documents

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Find documents with inferred projection
    stream<Movie, error?> movieStream = movies->find({
        year: 2014
    });

    // Close the client
    check mongodb->close();
}
```

###### Example: Find Documents with Inferred Projection

```ballerina
import ballerina/io;
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Define a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 10
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 10
        },
        {
            title: "Tenet",
            year: 2020,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Find documents with inferred projection
    // This will only retrieve the titles of the movies since the LHS of the expression is a record with only the
    // `title` field
    stream<record {|string title;|}, error?> movieStream = check movies->find({
        rating: 10
    });

    // Filter the stream and add the results to a record array
    record {|string title;|}[] result = check from record {|string title;|} m in movieStream
        select m;

    // Close the stream
    check movieStream.close();

    io:println(result); // Prints "[{"title":"Inception"},{"title":"Interstellar"}]"

    // Close the client
    check mongodb->close();
}
```

###### Example: Find Documents with Manual Projection

```ballerina
import ballerina/io;
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Define a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 10
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 10
        },
        {
            title: "Tenet",
            year: 2020,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Find documents with manual projection
    // This will only retrieve the titles of the movies with rating 10
    stream<record {}, error?> movieStream = check movies->find({
        rating: 10
    }, projection = {
        _id: 0, // Removes the `_id` field from the query result
        title: 1 // Includes the `title` field in the query result
    });

    // Filter the stream and add the results to a record array
    record {}[] result = check from record {} m in movieStream
        select m;

    // Close the stream
    check movieStream.close();

    io:println(result); // Prints "[{"title":"Inception"},{"title":"Interstellar"}]"

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.5 Count Documents

The `countDocuments` remote method can be used to count the number of documents in the collection. This will return the count of the documents as an `int` or an error if the operation fails.

###### 2.3.2.5.1 Parameters of the `countDocuments` Remote Method

- `filter`: The filter to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is an optional parameter and if not provided, an empty filter will be used and the count of all the documents in the collection will be returned.
- `options`: The options to apply to the query. This should be of type `mongodb:CountOptions` record. This is an optional parameter.

###### Example: Count Documents

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Count documents
    int count = check movies->countDocuments({
        year: 2014
    });

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.6 Create Index

Indexes are used to improve the performance of queries. The `createIndex` remote method can be used to create an index in the collection. This will return an error if the operation fails.

###### 2.3.2.6.1 Parameters of the `createIndex` Remote Method

- `keys`: The keys of the index. This should be of type `map<json>`, where the keys are the field names and the values are the index types. The index types can be `1` for ascending order, `-1` for descending order. This is a required parameter. Learn more about MongoDB indexes on [MongoDB Documentation](https://www.mongodb.com/docs/manual/core/indexes/index-types/#std-label-index-types)
- `options`: The options to apply to the index. This should be of type `mongodb:IndexOptions` record. This is an optional parameter with the default index options.

###### Example: Create Index

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create an index
    check movies->createIndex({
        year: 1
    });

    // Close the client
    check mongodb->close();
}
```

###### Example: Create Index with Options

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create an index with options
    check movies->createIndex(
        {
            year: 1
        },
        {
            name: "year_index",
            unique: true,
            partialFilterExpression: {
                rating: {
                    $gte: 8 // Indexes movies with rating greater than or equal to 8
                }
            }
        }
    );

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.7 List Indexes

The `listIndexes` remote method can be used to list the indexes in the collection. This will return a `stream<mongodb:Index, error?>`.

###### Example: List Indexes

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // List indexes
    stream<mongodb:Index, error?> indexStream = check movies->listIndexes();

    // Close the stream
    check indexStream.close();

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.8 Drop Index

The `dropIndex` remote method can be used to drop an index from the collection. This will return an error if the operation fails.

###### 2.3.2.8.1 Parameters of the `dropIndex` Remote Method

- `indexName`: The name of the index to drop. This should be of type `string`.

###### Example: Drop Index

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Drop an index
    check movies->dropIndex("year_index");

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.9 Drop All Indexes

The `dropIndexes` remote method can be used to drop all the indexes from the collection. This will return an error if the operation fails.

###### Example: Drop All Indexes

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Drop all indexes
    check movies->dropIndexes();

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.10 Drop Collection

The `drop` remote method can be used to drop the collection. This will return an error if the operation fails.

###### Example: Drop Collection

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Drop the collection
    check moviesDb->drop();

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.11 Update Single Document

The `updateOne` remote method can be used to update a single document in the collection. This will return an error if the operation fails. A successful update will return a `mongodb:UpdateResult` record.

###### 2.3.2.11.1 Parameters of the `updateOne` Remote Method

- `filter`: The filter to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is a required parameter.
- `update`: The update to apply to the query. This should be of type `mongodb:Update`. This is a required parameter.
- `options`: The options to apply to the update operation. This should be of type `mongodb:UpdateOptions` record. This is an optional parameter.

###### Example: Update Single Document

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 8
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Update a single document
    check movies->updateOne(
        {
            title: "Inception"
        },
        {
            set: {
                rating: 9
            }
        }
    );

    // Close the client
    check mongodb->close();
}
```

###### Example: Update Single Document with Update Options

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 8
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Update a single document
    check movies->updateOne(
        {
            title: "Inception"
        },
        {
            set: {
                rating: 9
            }
        },
        {
            comment: "Increasing the rating of the movie"
        }
    );

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.12 Update Multiple Documents

The `updateMany` remote method can be used to update multiple documents in the collection. This will return an error if the operation fails. A successful update will return a `mongodb:UpdateResult` record.

###### 2.3.2.12.1 Parameters of the `updateMany` Remote Method

- `filter`: The filter to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is a required parameter.
- `update`: The update to apply to the query. This should be of type `mongodb:Update`. This is a required parameter.
- `options`: The options to apply to the update operation. This should be of type `mongodb:UpdateOptions` record. This is an optional parameter.

###### Example: Update Multiple Documents

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 8
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Update multiple documents
    mongodb:UpdateResult result = check movies->updateMany(
        {
            rating: {
                $gte: 8
            }
        },
        {
            set: {
                rating: 10
            }
        }
    );

    // Close the client
    check mongodb->close();
}
```

###### Example: Update Multiple Documents with Update Options

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 8
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Update multiple documents
    mongodb:UpdateResult result = check movies->updateMany(
        {
            rating: {
                $gte: 8
            }
        },
        {
            set: {
                rating: 10
            }
        },
        {
            comment: "Increasing the rating of the movies",
            bypassDocumentValidation: true
        }
    );

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.13 Retrieve Distinct Values

The `distinct` remote method can be used to retrieve distinct values for a field in the collection. The return type of this method is `stream`. This method is dependently-typed method, and the return type depends on the left hand side (_LHS_) of the expression.

###### 2.3.2.13.1 Parameters of `distinct` Remote Method

- `fieldName`: The name of the field to retrieve distinct values. This should be of type `string`. This is a required parameter.
- `filter`: The filter to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is an optional parameter.
- `targetType`: The return type of the stream. This is an optional parameter and if not provided, it will be inferred from the LHS of the expression.

###### Example: Retrieve Distinct Values

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Retrieve distinct values for the "year" field without a filter
    stream<int, error?> distinctYears = movies->'distinct("year");

    // ...

    // Close the stream
    check distinctYears.close();

    // Close the client
    check mongodb->close();
}
```

###### Example: Retrieve Distinct Values with a Filter

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Retrieve distinct values for the "year" field with a filter
    stream<int, error?> distinctYears = movies->'distinct("year", {
        rating: {
            $gte: 8
        }
    });

    // ...

    // Close the stream
    check distinctYears.close();

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.14 Delete Single Document

The `deleteOne` remote method can be used to delete a single document from the collection. This will return an error if the operation fails. A successful delete will return a `mongodb:DeleteResult` record.

###### 2.3.2.14.1 Parameters of `deleteOne` Remote Method

- `filter`: The filter to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is a required parameter.

###### Example: Delete Single Document

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 8
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Delete a single document with the title "Inception"
    mongodb:DeleteResult result = check movies->deleteOne({
        title: "Inception"
    });

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.15 Delete Multiple Documents

The `deleteMany` remote method can be used to delete multiple documents from the collection. This will return an error if the operation fails. A successful delete will return a `mongodb:DeleteResult` record.

###### 2.3.2.15.1 Parameters of `deleteMany` Remote Method

- `filter`: The filter to apply to the query. This should be of type `map<json>`, where the keys are the field names and the values are the field values. This is a required parameter.

###### Example: Delete Multiple Documents

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movie record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Create a set of movies
    Movie[] moviesArray = [
        {
            title: "Inception",
            year: 2010,
            rating: 8
        },
        {
            title: "Interstellar",
            year: 2014,
            rating: 9
        }
    ];

    // Insert documents
    check movies->insertMany(moviesArray);

    // Delete multiple documents that has a rating greater than or equal to 8
    mongodb:DeleteResult result = check movies->deleteMany({
        rating: {
            $gte: 8
        }
    });

    // Close the client
    check mongodb->close();
}
```

##### 2.3.2.16 Aggregate Documents

The `aggregate` remote method can be used to perform aggregation operations on the collection. The return type of this method is `stream`. This method is dependently-typed method, and the return type depends on the left hand side (_LHS_) of the expression. Refer [aggregation pipeline](#232162-aggregation-pipeline) section for more information.

###### 2.3.2.16.1 Parameters of `aggregate` Remote Method

- `pipeline`: The pipeline of aggregation operations to apply to the collection. This should be of type `map<json>[]`. This is a required parameter.
- `targetType`: The return type of the stream. This is an optional parameter and if not provided, it will be inferred from the LHS of the expression.

###### 2.3.2.16.2 Aggregation Pipeline

MongoDB has aggregation feature which helps to perform operations on the collection. Aggregation can be done by providing an aggregation pipeline. It should be an array of stages, where each stage represents an operation. There is a stage for projecting where the fields to return in the query result can be defined. The Ballerina MongoDB connector supports aggregation in two ways.

- Inferred Projection: The projection will be inferred from the LHS of the expression
- Manual Projection: The projection will be provided as a stage in the pipeline. If this is provided, the target type will be ignored when defining the projection.

> **Note:** Manual projection might cause runtime errors since it ignores the target type when returning the stream. If the LHS expression does not match the projection, a `ConversionError` will occur at the runtime.

###### Example: Aggregate Documents

```ballerina
import ballerinax/mongodb;

// Define the Ballerina record type
public type Movies record {|
    string title;
    int year;
    int rating;
|};

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Aggregate documents with inferred projection
    stream<Movie, error?> resultStream = movies->aggregate([
        {
            \$match: {
                rating: {
                    $gte: 8
                }
            }
        },
        {
            \$sort: {
                name: 1
            }
        }
    ]);

    // ...

    // Close the stream
    check resultStream.close();

    // Close the client
    check mongodb->close();
}
```

###### Example: Aggregate Documents with Inferred Projection

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Aggregate documents with inferred projection
    // This will only retrieve the titles of the movies since the LHS of the expression is a record with only the
    // `title` field
    stream<record {|string title;|}, error?> resultStream = movies->aggregate([
        {
            \$match: {
                rating: {
                    $gte: 8
                }
            }
        },
        {
            \$sort: {
                name: 1
            }
        }
    ]);

    // ...

    // Close the stream
    check resultStream.close();

    // Close the client
    check mongodb->close();
}
```

###### Example: Aggregate Documents with Manual Projection

```ballerina
import ballerinax/mongodb;

public function main() returns error? {
    // Create the MongoDB client
    final mongodb:Client mongodb = check new (connection = "<mongodb.connection.string>");

    // Get a database
    mongodb:Database moviesDb = check mongodb->getDatabase("moviesDB");

    // Get a collection
    mongodb:Collection movies = check moviesDb->getCollection("movies");

    // Aggregate documents with manual projection
    // This will only retrieve the titles of the movies with rating 10
    // The LHS is ignored here since the `$project` field is provided in the aggregation pipeline
    stream<record {|string title;|}, error?> resultStream = movies->aggregate([
        {
            \$match: {
                rating: {
                    $gte: 8
                }
            }
        },
        {
            \$sort: {
                name: 1
            }
        },
        {
            \$project: {
                _id: 0, // Removes the `_id` field from the query result
                title: 1 // Includes the `title` field in the query result
            }
        }
    });

    // ...

    // Close the stream
    check resultStream.close();

    // Close the client
    check mongodb->close();
}
```
