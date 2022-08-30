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

# Represents the Client configurations for MongoDB.
#
# + host - The database's host address
# + port - The port on which the database is running
# + username - Username for the database connection
# + password - Password for the database connection
# + options - Properties for the connection configuration
# + databaseName - Database name to connect. This is optional. You can pass the database name in each
#                  remote function as well.The precedence will be given to the database name which is passed
#                  in the remote function. 
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    @display {label: "Host"}
    string host?;
    @display {label: "Port"}
    int port?;
    @display {label: "Username"}
    string username?;
    @display {label: "Password"}
    string password?;
    @display {label: "Connection Options"}
    ConnectionProperties options?;
    @display {label: "Database Name"} 
    string databaseName?;
|};

# Represents the MongoDB connection pool properties
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
@display {label: "Connection Properties"}
public type ConnectionProperties record {|
    @display {label: "URL"}
    string url?;
    @display {label: "Read Concern"}
    string readConcern?;
    @display {label: "Write Concern"}
    string writeConcern?;
    @display {label: "Read Preference"}
    string readPreference?;
    @display {label: "Auth Source"}
    string authSource?;
    @display {label: "Auth Mechanism"}
    string authMechanism?;
    @display {label: "GSS API Service Name"}
    string gssapiServiceName?;
    @display {label: "Replica Set"}
    string replicaSet?;
    @display {label: "SSL Enabled"}
    boolean sslEnabled?;
    @display {label: "SSL Invalid Host Name Allowed"}
    boolean sslInvalidHostNameAllowed?;
    @display {label: "Secure Socket"}
    SecureSocket secureSocket?;
    @display {label: "Retry Writes"}
    boolean retryWrites?;
    @display {label: "Socket Timeout"}
    int socketTimeout?;
    @display {label: "Connection Timeout"}
    int connectionTimeout?;
    @display {label: "Maximum Pool Size"}
    int maxPoolSize?;
    @display {label: "Server Selection Timeout"}
    int serverSelectionTimeout?;
    @display {label: "Maximum Idle Time"}
    int maxIdleTime?;
    @display {label: "Maximum Life Time"}
    int maxLifeTime?;
    @display {label: "Minimum Pool Size"}
    int minPoolSize?;
    @display {label: "Wait Queue Multiple"}
    int waitQueueMultiple?;
    @display {label: "Wait Queue Timeout"}
    int waitQueueTimeout?;
    @display {label: "Local Threshold"}
    int localThreshold?;
    @display {label: "Heartbeat Frequency"}
    int heartbeatFrequency?;
|};

# Represents the configurations related to facilitating secure connection.
#
# + trustStore - Configurations associated with the TrustStore
# + keyStore - Configurations associated with the KeyStore
# + protocol - The standard name of the requested protocol
@display {label: "Secure Socket"}
public type SecureSocket record {|
    @display {label: "Trust Store"}
    crypto:TrustStore trustStore;
    @display {label: "Key Store"}
    crypto:KeyStore keyStore;
    @display {label: "Protocol"}
    string protocol;
|};
