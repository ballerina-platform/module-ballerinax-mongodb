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

import ballerina/java;

# Represents the MongoDB client.
public type Client client object {

    handle datasource;

    # Initialises the `Client` object with the provided `ClientConfig` properties.
    # 
    # + return - An `ApplicationError` if there is any error in the provided configurations 
    public function __init(ClientConfig config) returns ApplicationError? {
        self.datasource = check initClient(config);
    }

# Lists the database names in the MongoDB server.
# ```ballerina
# string[]|mongodb:DatabaseError result = mongoClient->getDatabasesNames();
# ```
#
# + return - An array of database names on success or else a`mongodb:DatabaseError` if unable to reach the DB 
    public remote function getDatabasesNames() returns string[]|DatabaseError {
        return getDatabasesNames(self.datasource);
    }

# Returns the `Database` client.
# ```ballerina
# mongodb:Database|mongodb:Error result = mongoClient->getDatabase("Ballerina");
# ```
# 
# + name - Name of the database
# + return - A database client object on success or else a `mongodb:Error` if unable to reach the DB
    public remote function getDatabase(string name) returns Database|Error {
        if (name.trim().length() == 0) {
            return ApplicationError(message = "Database Name cannot be empty.");
        }

        handle database = check getDatabase(self.datasource, name);
        return new Database(database);
    }

# Closes the client.
# ```ballerina
# mongoClient->close();
# ```
    public remote function close() {
        close(self.datasource);
    }
};

function initClient(ClientConfig config) returns handle|ApplicationError = @java:Method {
    class: "org.wso2.mongo.MongoDBDataSourceUtil"
} external;

function getDatabasesNames(handle datasource) returns string[]|DatabaseError = @java:Method {
    class: "org.wso2.mongo.MongoDBDataSourceUtil"
} external;

function getDatabase(handle datasource, string databaseName) returns handle|Error = @java:Method {
    class: "org.wso2.mongo.MongoDBDataSourceUtil"
} external;

function close(handle datasource) = @java:Method {
    class: "org.wso2.mongo.MongoDBDataSourceUtil"
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
#                   Possible values are PLAIN, SCRAM_SHA_1, SCRAM_SHA_256, MONGODB_X509, or GSSAPI
# + gssapiServiceName - Authentications GSSAPI Service name
# + replicaSet - The replica set name if it is to connect to replicas
# + sslEnabled - Whether SSL connection is enabled
# + sslInvalidHostNameAllowed - Whether invalid host names should be allowed
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
