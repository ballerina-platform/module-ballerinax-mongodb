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
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # connection - Connection string or the connection parameters for the MongoDB connection
    @display {label: "Connection"}
    ConnectionParameters|string connection;
    # The additional connection options for the MongoDB connection
    @display {label: "Connection Options"}
    ConnectionProperties options?;
|};

# Represents the MongoDB server address.
public type ServerAddress record {|
    # The host address of the MongoDB server
    @display {label: "Host"}
    string host = "localhost";
    # The port of the MongoDB server
    @display {label: "Port"}
    int port = 27017;
|};

# Represents the MongoDB connection parameters.
public type ConnectionParameters record {|
    # Server address (or the list of server addresses for replica sets) of the MongoDB server
    @display {label: "Server Address"}
    ServerAddress|ServerAddress[] serverAddress = {};
    # The authentication configurations for the MongoDB connection
    BasicAuthCredential|ScramSha1AuthCredential|ScramSha256AuthCredential|X509Credential|GSSAPICredential auth?;
|};

# Represents the Basic Authentication configurations for MongoDB.
public type BasicAuthCredential record {|
    # The authentication mechanism to use
    @display {label: "Auth Mechanism"}
    readonly AUTH_PLAIN authMechanism = AUTH_PLAIN;
    # The username for the database connection
    @display {label: "Username"}
    string username;
    # The password for the database connection
    @display {label: "Password"}
    string password;
    # The source database for authenticate the client. Usually the database name
    @display {label: "Auth Source Database"}
    string database;
|};

# Represents the SCRAM-SHA-1 authentication configurations for MongoDB.
public type ScramSha1AuthCredential record {|
    # The authentication mechanism to use
    @display {label: "Auth Mechanism"}
    readonly AUTH_SCRAM_SHA_1 authMechanism = AUTH_SCRAM_SHA_1;
    # The username for the database connection
    @display {label: "Username"}
    string username;
    # The password for the database connection
    @display {label: "Password"}
    string password;
    # The source database for authenticate the client. Usually the database name
    @display {label: "Auth Source Database"}
    string database;
|};

# Represents the SCRAM-SHA-256 authentication configurations for MongoDB.
public type ScramSha256AuthCredential record {|
    # The authentication mechanism to use
    @display {label: "Auth Mechanism"}
    readonly AUTH_SCRAM_SHA_256 authMechanism = AUTH_SCRAM_SHA_256;
    # The username for the database connection
    @display {label: "Username"}
    string username;
    # The password for the database connection
    @display {label: "Password"}
    string password;
    # The source database for authenticate the client. Usually the database name
    @display {label: "Auth Source Database"}
    string database;
|};

# Represents the X509 authentication configurations for MongoDB.
public type X509Credential record {|
    # The authentication mechanism to use
    @display {label: "Auth Mechanism"}
    readonly AUTH_MONGODB_X509 authMechanism = AUTH_MONGODB_X509;
    # The username for authenticating the client certificate
    @display {label: "Username"}
    string username?;
|};

# Represents the GSSAPI authentication configurations for MongoDB.
public type GSSAPICredential record {|
    # The authentication mechanism to use
    @display {label: "Auth Mechanism"}
    readonly AUTH_GSSAPI authMechanism = AUTH_GSSAPI;
    # The username for the database connection
    @display {label: "Username"}
    string username;
    # The service name for the database connection. Use this to override the default service name of `mongodb`
    @display {label: "Service Name"}
    string serviceName?;
|};

# Represents the MongoDB connection pool properties.
@display {label: "Connection Properties"}
public type ConnectionProperties record {|
    # The read concern level to use
    @display {label: "Read Concern"}
    ReadConcern readConcern?;
    # The write concern level to use
    @display {label: "Write Concern"}
    string writeConcern?;
    # The read preference for the replica set
    @display {label: "Read Preference"}
    string readPreference?;
    # The replica set name if it is to connect to replicas
    @display {label: "Replica Set"}
    string replicaSet?;
    # Whether SSL connection is enabled
    @display {label: "SSL Enabled"}
    boolean sslEnabled = false;
    # Whether invalid host names should be allowed
    @display {label: "SSL Invalid Host Name Allowed"}
    boolean invalidHostNameAllowed = false;
    # Configurations related to facilitating secure connection
    @display {label: "Secure Socket"}
    SecureSocket secureSocket?;
    # Whether to retry writing failures
    @display {label: "Retry Writes"}
    boolean retryWrites?;
    # The timeout for the socket
    @display {label: "Socket Timeout"}
    int socketTimeout?;
    # The timeout for the connection
    @display {label: "Connection Timeout"}
    int connectionTimeout?;
    # The maximum connection pool size
    @display {label: "Maximum Pool Size"}
    int maxPoolSize?;
    # The maximum idle time for a pooled connection in milliseconds
    @display {label: "Maximum Idle Time"}
    int maxIdleTime?;
    # The maximum life time for a pooled connection in milliseconds
    @display {label: "Maximum Life Time"}
    int maxLifeTime?;
    # The minimum connection pool size
    @display {label: "Minimum Pool Size"}
    int minPoolSize?;
    # The local threshold latency in milliseconds
    @display {label: "Local Threshold"}
    int localThreshold?;
    # The heartbeat frequency in milliseconds. This is the frequency that the driver will attempt
    # to determine the current state of each server in the cluster.
    @display {label: "Heartbeat Frequency"}
    int heartbeatFrequency?;
|};

# Represents the configurations related to facilitating secure connection.
@display {label: "Secure Socket"}
public type SecureSocket record {|
    # Configurations associated with the TrustStore
    @display {label: "Trust Store"}
    crypto:TrustStore trustStore;
    # Configurations associated with the KeyStore
    @display {label: "Key Store"}
    crypto:KeyStore keyStore;
    # The standard name of the requested protocol
    @display {label: "Protocol"}
    string protocol;
|};

# The PLAIN authentication mechanism.
public const AUTH_PLAIN = "PLAIN";

# The SCRAM-SHA-1 authentication mechanism.
public const AUTH_SCRAM_SHA_1 = "SCRAM_SHA_1";

# The SCRAM-SHA-256 authentication mechanism.
public const AUTH_SCRAM_SHA_256 = "SCRAM_SHA_256";

# The X509 authentication mechanism.
public const AUTH_MONGODB_X509 = "MONGODB_X509";

# The GSSAPI authentication mechanism.
public const AUTH_GSSAPI = "GSSAPI";

# Read concern level.
public enum ReadConcern {
    LOCAL = "local",
    AVAILABLE = "available",
    MAJORITY = "majority",
    LINEARIZABLE = "linearizable",
    SNAPSHOT = "snapshot"
};

# Represents the options for the `Collection.insertOne()` operation.
public type InsertOneOptions record {|
    # The comment to send with the operation
    @display {label: "Comment"}
    string comment?;
    # Whether to bypass the document validation
    @display {label: "Bypass Document Validation"}
    boolean bypassDocumentValidation = false;
|};

# Represents the options for the `Collection.insertMany()` operation.
public type InsertManyOptions record {|
    # The comment to send with the operation
    @display {label: "Comment"}
    string comment?;
    # Whether to bypass the document validation
    @display {label: "Bypass Document Validation"}
    boolean bypassDocumentValidation = false;
    # Whether to insert documents in the order provided
    @display {label: "Ordered"}
    boolean ordered = true;
|};

# Represents the options for the `Collection.find()` operation.
public type FindOptions record {|
    # The sort options for the query
    map<json> sort = {};
    # The maximum limit of the number of documents to retrive. -1 means no limit
    int 'limit?;
    # The batch size of the query
    int batchSize?;
    # The number of documents to skip
    int skip?;
|};

# Represents the options for the `Collection.countDocuments()` operation.
public type CountOptions record {|
    # The maximum limit of the number of documents to count
    int 'limit?;
    # The number of documents to skip
    int skip?;
    # The maximum time to count documents in milliseconds
    int maxTimeMS?;
    # The hint to use
    string hint?;
|};
