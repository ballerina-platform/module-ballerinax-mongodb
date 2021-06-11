// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# The Client configurations for MongoDB.
#
# + host - The database's host address
# + port - The port on which the database is running
# + username - Username for the database connection
# + password - Password for the database connection
# + options - Properties for the connection configuration
public type ClientConfig record {|
    string host?;
    int port?;
    string username?;
    string password?;
    ConnectionProperties options?;
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
    string url?;
    string readConcern?;
    string writeConcern?;
    string readPreference?;
    string authSource?;
    string authMechanism?;
    string gssapiServiceName?;
    string replicaSet?;
    boolean sslEnabled?;
    boolean sslInvalidHostNameAllowed?;
    SecureSocket? secureSocket?;
    boolean retryWrites?;
    int socketTimeout?;
    int connectionTimeout?;
    int maxPoolSize?;
    int serverSelectionTimeout?;
    int maxIdleTime?;
    int maxLifeTime?;
    int minPoolSize?;
    int waitQueueMultiple?;
    int waitQueueTimeout?;
    int localThreshold?;
    int heartbeatFrequency?;
|};

# Configurations related to facilitating secure connection.
#
# + trustStore - Configurations associated with the TrustStore
# + keyStore - Configurations associated with the KeyStore
# + protocol - The standard name of the requested protocol
public type SecureSocket record {|
    crypto:TrustStore trustStore;
    crypto:KeyStore keyStore;
    string protocol;
|};
