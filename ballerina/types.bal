  dvEREC    33// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # connection - Connection string or the connection parameters for the MongoDB connection
    @display {label: "Connection"}
    ConnectionParameters|string connection;
    # The additional connection options for the MongoDB connection
    @display {label: "Connection Options"}
    ConnectionProperties options?;
|};

# The MongoDB server address.
@display {label: "Server Address"}
public type ServerAddress record {|
    # The host address of the MongoDB server
    @display {label: "Host"}
    string host = "localhost";
    # The port of the MongoDB server
    @display {label: "Port"}
    int port = 27017;
|};

# The MongoDB connection parameters.
@display {label: "Connection Parameters"}
public type ConnectionParameters record {|
    # Server address (or the list of server addresses for replica sets) of the MongoDB server
    @display {label: "Server Address"}
    ServerAddress|ServerAddress[] serverAddress = {};
    # The authentication configurations for the MongoDB connection
    @display {label: "Authentication"}
    BasicAuthCredential|ScramSha1AuthCredential|ScramSha256AuthCredential|X509Credential|GssApiCredential auth?;
|};

# The Basic Authentication configurations for MongoDB.
@display {label: "Basic Auth Credential"}
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

# The SCRAM-SHA-1 authentication configurations for MongoDB.
@display {label: "SCRAM-SHA-1 Credential"}
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

# The SCRAM-SHA-256 authentication configurations for MongoDB.
@display {label: "SCRAM-SHA-256 Credential"}
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

# The X509 authentication configurations for MongoDB.
@display {label: "X509 Credential"}
public type X509Credential record {|
    # The authentication mechanism to use
    @display {label: "Auth Mechanism"}
    readonly AUTH_MONGODB_X509 authMechanism = AUTH_MONGODB_X509;
    # The username for authenticating the client certificate
    @display {label: "Username"}
    string username?;
|};

# The GSSAPI authentication configurations for MongoDB.
@display {label: "GSSAPI Credential"}
public type GssApiCredential record {|
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

# The MongoDB connection pool properties.
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

# The configurations related to facilitating secure connection.
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

# The options for the `Collection.insertOne()` operation.
public type InsertOneOptions record {|
    # The comment to send with the operation
    @display {label: "Comment"}
    string comment?;
    # Whether to bypass the document validation
    @display {label: "Bypass Document Validation"}
    boolean bypassDocumentValidation = false;
|};

# The options for the `Collection.insertMany()` operation.
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

# The options for the `Collection.find()` operation.
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

# The options for the `Collection.countDocuments()` operation.
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

# The options for the `Collection.createIndex()` operation.
public type CreateIndexOptions record {|
    # Whether to create the index in the background
    @display {label: "Background"}
    boolean background?;
    # Whether to create a unique index
    @display {label: "Unique"}
    boolean unique?;
    # Name of the index
    @display {label: "Index Name"}
    string name?;
    # Should the index only reference documents with the specified field
    @display {label: "Sparse"}
    boolean sparse?;
    # The time to live for documents in the collection in seconds
    @display {label: "Time to Live"}
    int expireAfterSeconds?;
    # The version of the index
    @display {label: "Version"}
    int version?;
    # Sets the weighting object for use with a text index
    @display {label: "Weights"}
    map<json> weights?;
    # The default language for the index
    @display {label: "Default Language"}
    string defaultLanguage?;
    # Sets the name of the field that contains the language string
    @display {label: "Language Override"}
    string languageOverride?;
    # Set the text index version number
    @display {label: "Text Index Version"}
    int textVersion?;
    # Sets the 2D sphere index version number
    @display {label: "2D Sphere Index Version"}
    int sphereVersion?;
    # Sets the number of precision of the stored geohash value of the location data in 2D indexes
    @display {label: "Bits"}
    int bits?;
    # Sets the lower inclusive boundary for the longitude and latitude values for 2D indexes
    @display {label: "Min"}
    float min?;
    # Sets the upper inclusive boundary for the longitude and latitude values for 2D indexes
    @display {label: "Max"}
    float max?;
    # Sets the filter expression for the documents to be included in the index
    @display {label: "Partial Filter Expression"}
    map<json> partialFilterExpression = {};
    # Should the index be hidden from the query planner
    @display {label: "Hidden"}
    boolean hidden?;
|};

# The options for the `Collection.updateOne()` operation.
public type UpdateOptions record {|
    # Whether to upsert if the document does not exist
    @display {label: "Upsert"}
    boolean upsert = false;
    # Whether to bypass the document validation
    @display {label: "Bypass Document Validation"}
    boolean bypassDocumentValidation = false;
    # The comment to send with the operation
    @display {label: "Comment"}
    string comment?;
    # The hint to use
    @display {label: "Hint"}
    map<json> hint?;
    # The hint string to use
    @display {label: "Hint String"}
    string hintString?;
|};

# The options for the `Collection.deleteOne()` operation.
public type DeleteOptions record {|
    # The comment to send with the operation
    @display {label: "Comment"}
    string comment?;
    # The hint to use
    @display {label: "Hint"}
    map<json> hint?;
    # The hint string to use
    @display {label: "Hint String"}
    string hintString?;
|};

# The MongoDB collection index.
public type Index record {
    # The name space of the index
    @display {label: "Name Space"}
    string ns;
    # The index version
    @display {label: "Version"}
    int v;
    # The name of the index
    @display {label: "Name"}
    string name;
    # The key of the index
    @display {label: "Key"}
    map<json> key;
};

# An update operation for single entry.
public type Update record {|
    # Sets the value of a field to the current date, either as a Date or a Timestamp
    map<json> currentDate?;
    # Increments the value of the field by the specified amount
    map<json> inc?;
    # Only updates the field if the specified value is less than the existing field value
    map<json> min?;
    # Only updates the field if the specified value is greater than the existing field value
    map<json> max?;
    # Multiplies the value of the field by the specified amount
    map<json> mul?;
    # Renames a field
    map<json> rename?;
    # Sets the value of a field in a document
    map<json> set?;
    # Sets the value of a field if it is an insert operation
    map<json> setOnInsert?;
    # Unsets the value of a field in a document
    map<json> unset?;
    // Allow user to add additional operators
    map<json>...;
|};

# The return type of the Update operation.
public type UpdateResult record {|
    # The number of documents matched by the update operation
    @display {label: "Matched Count"}
    int matchedCount;
    # The number of documents modified by the update operation
    @display {label: "Modified Count"}
    int modifiedCount;
    # The identifier of the inserted document if the upsert option is used
    @display {label: "Upserted Id"}
    string upsertedId?;
|};

# The return type of the Delete operation.
public type DeleteResult record {|
    # The number of documents deleted by the delete operation
    @display {label: "Deleted Count"}
    int deletedCount;
    # Whether the delete operation was acknowledged
    @display {label: "Acknowledged"}
    boolean acknowledged;
|};
