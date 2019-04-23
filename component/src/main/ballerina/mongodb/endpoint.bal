// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

///////////////////////////////
// MongoDB Client Endpoint
///////////////////////////////

# Represents MongoDB client endpoint.
public type Client client object {
    private ClientEndpointConfig clientEndpointConfig;

    # Gets called when the endpoint is being initialized during the package initialization.
    public function __init(ClientEndpointConfig config) {
        self.clientEndpointConfig = config;
        initClient(self, config);
    }

    # Stops the registered service.
    public function stop() {
        close(self);
    }

    # The find operation implementation which selects a document in a given collection.
    #
    # + collectionName - The name of the collection to be queried
    # + queryString - Query to use to select data
    # + return - `json` result from the find operation or `error` if an error occurs
    public remote function find(string collectionName, json? queryString) returns (json|error) = external;

    # The findOne operation implementation which selects the first document that matches with the query.
    #
    # + collectionName - The name of the collection to be queried
    # + queryString - Query to use to select data
    # + return - `json` The result from the findOne operation or `error` if an error occurs
    public remote function findOne(string collectionName, json? queryString) returns (json|error) = external;

    # The insert operation implementation which inserts a document to a collection.
    #
    # + collectionName - The name of the collection
    # + document - The document to be inserted
    # + return - `nil` or `error` if an error occurs
    public remote function insert(string collectionName, json document) returns (error?) = external;

    # The delete operation implementation which deletes documents that match the given filter.
    #
    # + collectionName - The name of the collection
    # + filter - The criteria used to be delete the documents
    # + multi - Specifies whether to delete multiple documents or not
    # + return - `int` deleted count or `error` if an error occurs
    public remote function delete(string collectionName, json filter, boolean multi) returns (int|error) = external;

    # The update operation implementation which updates documents that matches to given filter.
    #
    # + collectionName - The name of the collection
    # + filter - The criteria used to update the documents
    # + multi - Specifies whether to update multiple documents or not
    # + upsert - Specifies whether to create a new document when no document matches the filter
    # + return - `int` The updated count or `error` if an error occurs
    public remote function update(string collectionName, json filter, json document, boolean multi, boolean upsert)
                               returns (int|error) = external;

    # The batchInsert operation implementation which inserts an array of documents to the given collection.
    #
    # + collectionName - The name of the collection
    # + documents - The document array to be inserted
    # + return - `nil` or `error` if an error occurs
    public remote function batchInsert(string collectionName, json documents) returns (error?) = external;

};

function initClient(Client mongoDBClient, ClientEndpointConfig clientEndpointConfig) = external;

# An internal function used by clients to shutdown the connection pool.
function close(Client mongoDBClient) = external;

# The Client endpoint configuration for MongoDB.
#
# + host - The host of the database to connect
# + port - The port of the database to connect
# + username - Username for the database connection
# + password - Password for the database connection
# + options - Properties for the connection configuration
public type ClientEndpointConfig record {|
    string host = "";
    string dbName;
    string username = "";
    string password = "";
    ConnectionProperties options = {};
|};

# ConnectionProperties type represents the properties which are used to configure MongoDB connection.
#
# + url - The complete MongoDB connection URL. If this is provided, this will be directly used connect to the database
#   instead of any provided host/port/username/password information. You still need to provide the `dbName` property
# + readConcern - Controls the consistency and isolation properties of the data read from replica sets and replica set
#   shards
# + writeConcern - Describes the level of acknowledgement requested from MongoDB for write operations to a standalone
#   mongod or to replica sets or to sharded clusters
# + readPreference - Describes how MongoDB clients route read operations to the members of a replica set
# + authSource - The database name associated with the user’s credentials.
# + authMechanism - The authentication mechanism that MongoDB will use to authenticate the connection
# + gssapiServiceName - Sets the Kerberos service name when connecting to Kerberized MongoDB instances
# + sslEnabled - Whether to connect using SSL
# + sslInvalidHostNameAllowed - Whether to allow invalid host names for SSL connections
# + socketTimeout - How long a send or receive on a socket can take before timing out
# + connectionTimeout - How long a connection can take to be opened before timing out
# + maxPoolSize - The maximum number of connections in the connection pool
# + minPoolSize - The minimum number of connections in the connection pool
# + waitQueueMultiple - This multiplier, multiplied with the maxPoolSize setting, gives the maximum number of
#   waiting connection requests. All further requests will get an error right away
# + waitQueueTimeout - The maximum wait time in milliseconds to wait for a connection to
#   become available
# + localThreshold - When choosing among multiple MongoDB servers to send a request, the driver will only
#   send that request to a server whose ping time is less than or equal to the server with the fastest ping time plus the local
#   threshold
# + heartbeatFrequency - The frequency that the driver will attempt to determine the current state of each server in the
#   cluster
# + replicaSet - Implies that the hosts given are a seed list, and the driver will attempt to find all members of the
#   set
# + retryWrites - If true write operations will be retried if they fail due to a network error
public type ConnectionProperties record {|
    string url = "";
    string readConcern = "";
    string writeConcern = "";
    string readPreference = "";
    string authSource = "";
    string authMechanism = "";
    string gssapiServiceName = "";
    string replicaSet = "";
    boolean sslEnabled = false;
    boolean sslInvalidHostNameAllowed = false;
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

public type DatabaseErrorData record {|
    string message;
|};

