// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/crypto;
import ballerina/jballerina.java;

# Represents the MongoDB client.
@display {label: "MongoDB Client", iconPath: "MongoDBLogo.png"}
public client class Client {

    handle datasource;
    handle database = java:createNull();

    # Initialises the `Client` object with the provided `ClientConfig` properties.
    #
    # + config - `ClientConfig` properties
    # + databaseName - Database name to connect
    # + return - A `mongodb:Error` if there is any error in the provided configurations or database name
    public function init(ClientConfig config, string? databaseName = ()) returns Error? {
        if (config.options.sslEnabled && config.options.secureSocket is ()) {
            return error ApplicationError("The connection property `secureSocket` is mandatory " +
                "when ssl is enabled for connection.");
        }
        self.datasource = check initClient(config);
        if (databaseName is string){
            self.database = check self.getDatabase(databaseName);
        }
    }

    //Database management operations
    # Lists the database names in the MongoDB server.
    #
    # + return - An array of database names on success or else a `mongodb:DatabaseError` if unable to reach the DB
    @display {label: "Get database names"}
    remote function getDatabasesNames() returns @display {label: "Database names"} string[]|DatabaseError {
        return getDatabasesNames(self.datasource);
    }

    # Returns the `Database` handle.
    #
    # + databaseName - Name of the database
    # + return - A database handle on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Get a database"}
    function getDatabase(@display {label: "Database name"} string databaseName)
                         returns @display {label: "Database"} handle|Error {
        if (databaseName.trim().length() == 0) {
            return error ApplicationError("Database Name cannot be empty.");
        }
        handle database = check getDatabase(self.datasource, databaseName);
        return database;
    }

    //Collection management operations
    # Lists the collection names in the MongoDB database.
    #
    # + databaseName - Name of the database
    # + return - An array of collection names on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Get collection names"}
    remote function getCollectionNames(@display {label: "Database name"} string? databaseName = ())
                                       returns @display {label: "List of collections"} string[]|Error {
        handle database = check self.getCurrentDatabase(databaseName);
        return getCollectionNames(database);
    }

    # Returns the collection handle.
    #
    # + databaseName - Name of the database
    # + collectionName - Name of the collection
    # + return - A collection object on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Get a collection"}
    function getCollection(@display {label: "Collection name"} string collectionName,
                           @display {label: "Database name"} string? databaseName = ())
                           returns @display {label: "Collection"} handle|Error {
        if (collectionName.trim().length() == 0) {
            return error ApplicationError("Collection Name cannot be empty.");
        }
        handle database = check self.getCurrentDatabase(databaseName);
        handle collection = check getCollection(database, collectionName);
        return collection;
    }

    // Collection service operations
    # Counts the documents based on the filter. When the filter is (), it counts all the documents in the collection.
    #
    # + databaseName - Name of the database
    # + collectionName - Name of the collection
    # + filter - Filter for the count ($where & $near can be used)
    # + return - Count of the documents in the collection or else `mongodb:Error` if unable to reach the DB
    @display {label: "Get number of documents in the collection"}
    remote function countDocuments(@display {label: "Collection name"} string collectionName,
                                   @display {label: "Database name"} string? databaseName = (),
                                   @display {label: "Filter"} map<json>? filter = ())
                                   returns @display {label: "Number of documents"} int|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        if (filter is ()) {
            return countDocuments(collection, ());
        }
        string filterString = filter.toJsonString();
        return countDocuments(collection, java:fromString(filterString));
    }

    # Lists the indices associated with the collection.
    #
    # + databaseName - Name of the database
    # + collectionName - Name of the collection
    # + return - a JSON object with indices on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "List indices"}
    remote function listIndices(@display {label: "Collection name"} string collectionName,
                                @display {label: "Database name"} string? databaseName = ())
                                returns @display {label: "List of indices"} map<json>[]|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        return listIndices(collection);
    }


    # Inserts one document.
    #
    # + databaseName - Name of the database
    # + collectionName - Name of the collection
    # + document - Document to be inserted
    # + return - `()` on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Insert a document"}
    remote function insert(@display {label: "Document"} map<json> document,
                           @display {label: "Collection name"} string collectionName,
                           @display {label: "Database name"} string? databaseName = ()) returns Error? {
        handle collection = check self.getCollection(collectionName, databaseName);
        string documentStr = document.toJsonString();
        return insert(collection, java:fromString(documentStr));
    }

    # The queries collection for documents, which sorts and limits the returned results.
    #
    # + databaseName - Name of the database
    # + collectionName - Name of the collection
    # + filter - Filter for the query
    # + sort - Sort options for the query
    # + limit - Limit options for the query results. No limit is applied for -1
    # + return - JSON array of the documents in the collection or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Query collection for documents"}
    remote function find(@display {label: "Collection name"} string collectionName,
                         @display {label: "Database name"} string? databaseName = (),
                         @display {label: "Filter for the query"} map<json>? filter = (),
                         @display {label: "Sort options"} map<json>? sort = (),
                         @display {label: "Limit"} int 'limit = -1)
                         returns @display {label: "List of documents"} map<json>[]|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        if (filter is ()) {
            if (sort is ()) {
                return find(collection, (), (), 'limit);
            }
            string sortString = sort.toJsonString();
            return find(collection, (), java:fromString(sortString), 'limit);
        }
        string filterStr = filter.toJsonString();
        if (sort is ()) {
            return find(collection, java:fromString(filterStr), (), 'limit);
        }
        string sortString = sort.toJsonString();
        return find(collection, java:fromString(filterStr), java:fromString(sortString), 'limit);
    }

    # Updates a document based on a condition.
    #
    # + databaseName - Name of the database
    # + collectionName - Name of the collection
    # + set - Document for the update condition
    # + filter - Filter for the query
    # + isMultiple - Whether to update multiple documents
    # + upsert - Whether to insert if update cannot be achieved
    # + return - JSON array of the documents in the collection or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Update a document"}
    remote function update(@display {label: "Document for the update"} map<json> set,
                           @display {label: "Collection name"} string collectionName,
                           @display {label: "Database name"} string? databaseName = (),
                           @display {label: "Filter for the query"} map<json>? filter = (),
                           @display {label: "Is updating multiple clients"} boolean isMultiple = false,
                           @display {label: "Insert if update cannot be acheived"} boolean upsert = false)
                           returns @display {label: "Number of updated documents"} int|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        string updateDoc = set.toJsonString();
        if (filter is ()) {
            return update(collection, java:fromString(updateDoc), (), isMultiple, upsert);
        }
        string filterStr = filter.toJsonString();
        return update(collection, java:fromString(updateDoc), java:fromString(filterStr), isMultiple, upsert);
    }

    # Deletes a document based on a condition.
    #
    # + databaseName - Name of the database
    # + collectionName - Name of the collection
    # + filter - Filter for the query
    # + isMultiple - Delete multiple documents if the condition is matched
    # + return - The number of deleted documents or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Delete a document"}
    remote function delete(@display {label: "Collection name"} string collectionName,
                           @display {label: "Database name"} string? databaseName = (),
                           @display {label: "Filter"} map<json>? filter = (),
                           @display {label: "Is deleting multiple documents"} boolean isMultiple = false)
                           returns @display {label: "Number of deleted documents"} int|Error {
        handle collection = check self.getCollection(collectionName, databaseName);
        if (filter is ()) {
            return delete(collection, (), isMultiple);
        }
        string filterStr = filter.toJsonString();
        return delete(collection, java:fromString(filterStr), isMultiple);
    }

    # Closes the client.
    @display {label: "Close the client"}
    remote function close() {
        close(self.datasource);
    }

    @display {label: "Get current database"}
    function getCurrentDatabase(@display {label: "Database name"} string? databaseName)
                                returns @display {label: "Database"} handle|Error {
        if (databaseName is string) {
            handle database = check self.getDatabase(databaseName);
            return database;
        } else {
            if (!java:isNull(self.database)) {
                return self.database;
            } else {
                return error ApplicationError("No database is set. Set a database.");
            }
        }
    }
}

function initClient(ClientConfig config) returns handle|ApplicationError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

function getDatabasesNames(handle datasource) returns string[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

function getDatabase(handle datasource, string databaseName) returns handle|Error = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

function close(handle datasource) = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

//Database Client Java

function getCollectionNames(handle database) returns string[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDatabaseUtil"
} external;

function getCollection(handle database, string collectionName) returns handle|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDatabaseUtil"
} external;

// Collection Client Java
function countDocuments(handle collection, handle? filter) returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

function listIndices(handle collection) returns map<json>[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

function insert(handle collection, handle document) returns DatabaseError? = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

function find(handle collection, handle? filter, handle? sort, int 'limit)
              returns map<json>[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

function update(handle collection, handle update, handle? filter, boolean isMultiple, boolean upsert)
                returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;


function delete(handle collection, handle? filter, boolean isMultiple) returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

# The Client configurations for MongoDB.
#
# + host - The database's host address
# + port - The port on which the database is running
# + username - Username for the database connection
# + password - Password for the database connection
# + options - Properties for the connection configuration
public type ClientConfig record {|
    string host = "127.0.0.1";
    int port = 27017;
    string username?;
    string password?;
    ConnectionProperties options = {};
|};

# MongoDB connection pool properties
#
# + url - MongoDB URL for connecting to replicas
# + readConcern - The read concern to use
# + writeConcern - The write concern to use. The default value is `WriteConcern.ACKNOWLEDGED`
# + readPreference - The read preference for the replica set
# + authSource - The source in which the user is defined
# + authMechanism - Authentication mechanism to use.
#                   Possible values are PLAIN, SCRAM_SHA_1, SCRAM_SHA_256, MONGODB-X509, or GSSAPI
# + gssapiServiceName - Authentications GSSAPI Service name
# + replicaSet - The replica set name if it is to connect to replicas
# + sslEnabled - Whether SSL connection is enabled
# + sslInvalidHostNameAllowed - Whether invalid host names should be allowed
# + secureSocket - Configurations related to facilitating secure connection
# + retryWrites - Whether to retry writing failures
# + maxPoolSize - Maximum connection pool size
# + minPoolSize - Minimum connection pool size
# + socketTimeout - The socket timeout in milliseconds
# + connectionTimeout - The connection timeout in milliseconds
# + serverSelectionTimeout - The server selection timeout in milliseconds
# + maxIdleTime - The maximum idle time for a pooled connection in milliseconds
# + maxLifeTime - The maximum life time for a pooled connection in milliseconds
# + waitQueueMultiple - The multiplier for the number of threads allowed to block waiting for a connection
# + waitQueueTimeout - The maximum time that a thread will block waiting for a connection in milliseconds
# + localThreshold - The local threshold latency in milliseconds
# + heartbeatFrequency - The heartbeat frequency (ms). This is the frequency that the driver will attempt to
#                        determine the current state of each server in the cluster.
public type ConnectionProperties record {|
    string url = "";
    string readConcern = "";
    string writeConcern = "";
    string readPreference = "";
    string authSource = "admin";
    string authMechanism = "";
    string gssapiServiceName = "";
    string replicaSet = "";
    boolean sslEnabled = false;
    boolean sslInvalidHostNameAllowed = false;
    SecureSocket? secureSocket = ();
    boolean retryWrites = false;
    int socketTimeout = -1;
    int connectionTimeout = -1;
    int maxPoolSize = -1;
    int serverSelectionTimeout = -1;
    int maxIdleTime = -1;
    int maxLifeTime = -1;
    int minPoolSize = -1;
    int waitQueueMultiple = -1;
    int waitQueueTimeout = -1;
    int localThreshold = -1;
    int heartbeatFrequency = -1;
|};

# Configurations related to facilitating secure connection.
#
# + trustStore - Configurations associated with the TrustStore
# + keyStore - Configurations associated with the KeyStore
# + protocol - The standard name of the requested protocol
public type SecureSocket record {|
    crypto:TrustStore trustStore;
    crypto:KeyStore keyStore;
    string protocol = "TLS";
|};
