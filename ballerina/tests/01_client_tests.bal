// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
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

import ballerina/test;

const string username = "admin";
const string password = "admin";

const string keystorePath = "./tests/resources/docker/certs/mongodb-client.jks";

configurable string connectionString = "mongodb://localhost:27017";

@test:Config {
    groups: ["client", "negative"]
}
public function testInvalidClientConfig() {
    Client|Error mongoClient = new (invalidConfig);
    test:assertTrue(mongoClient is ApplicationError, "Error expected when url is invalid.");
    ApplicationError err = <ApplicationError>mongoClient;
    test:assertEquals(err.message(), "Error occurred while initializing the MongoDB client.");
    ApplicationError cause = <ApplicationError>err.cause();
    test:assertEquals(cause.message(),
        "The connection string is invalid. Connection strings must start with either 'mongodb://' or 'mongodb+srv://");
}

@test:Config {
    groups: ["client"]
}
isolated function testClientInitWithNamedParameters() returns error? {
    Client mongoClient = check new (connection = {
        serverAddress: {
            host: "localhost",
            port: 27016
        }
    });
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertEquals(databaseNames.length(), 3, "Expected 3 databases but found " + databaseNames.length().toString());
    check mongoClient->close();
}

@test:Config {
    groups: ["client"]
}
public function testCreateClient() returns error? {
    Client mongoClient = check new (connection = {
        serverAddress: {
            host: "localhost",
            port: 27017
        },
        auth: <ScramSha256AuthCredential>{
            username: username,
            password: password,
            database: "admin"
        }
    });
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertEquals(databaseNames.length(), 3, "Expected 3 databases but found " + databaseNames.length().toString());
    test:assertEquals(databaseNames, ["admin", "config", "local"]);
}

@test:Config {
    groups: ["client", "connection_string"]
}
public function testCreateClientWithConnectionString() returns error? {
    string connection = string `mongodb://${username}:${password}@localhost:27017/admin`;
    Client mongoClient = check new ({connection});
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertEquals(databaseNames.length(), 3, "Expected 3 databases but found " + databaseNames.length().toString());
    test:assertEquals(databaseNames, ["admin", "config", "local"]);
}

@test:Config {
    groups: ["client"]
}
isolated function testCreateClientNoAuth() returns error? {
    ConnectionConfig clientConfigNoAuth = {
        connection: {
            serverAddress: {
                host: "localhost",
                port: 27016
            }
        }
    };
    Client mongoClient = check new (clientConfigNoAuth);
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertEquals(databaseNames.length(), 3, "Expected 3 databases but found " + databaseNames.length().toString());
    test:assertEquals(databaseNames, ["admin", "config", "local"]);
    check mongoClient->close();
}

@test:Config {
    groups: ["client"]
}
function testSslConfigWithSslDisabled() returns error? {
    ConnectionConfig validSslConfig = {
        connection: {
            serverAddress: {
                host: "localhost",
                port: 27018
            },
            auth: <X509Credential>{
                username: "C=LK,ST=Western,L=Colombo,O=WSO2,OU=Ballerina,CN=admin"
            }
        },
        options: {
            socketTimeout: 10000,
            sslEnabled: false,
            secureSocket: {
                trustStore: {
                    path: keystorePath,
                    password: "123456"
                },
                keyStore: {
                    path: keystorePath,
                    password: "123456"
                },
                protocol: "TLS"
            }
        }
    };
    test:when(logWarn).call("mockLogWarn");
    Client mongodb = check new Client(validSslConfig);
    test:assertEquals(message, "The connection property `secureSocket` is ignored when ssl is disabled.");
    check mongodb->close();
}

@test:Config {
    groups: ["client", "replicaSet"],
    enable: false // Configure the replica set properly with a primary node and enable this test
}
public function testConnectToReplicaSet() returns error? {
    Client mongoClient = check new (replicaSetConfig);
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertEquals(databaseNames.length(), 3, "Expected 3 databases but found " + databaseNames.length().toString());
    test:assertEquals(databaseNames, ["admin", "local"]);
}

@test:Config {
    groups: ["client", "atlas", "connection_string"],
    enable: false
}
public function testConnectionString() returns error? {
    Client mongoClient = check new ({connection: connectionString});
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertEquals(databaseNames.length(), 3, "Expected 3 databases but found " + databaseNames.length().toString());
}

@test:Config {
    groups: ["client", "ssl"]
}
public function testSSLConnection() returns error? {
    ConnectionConfig validSslConfig = {
        connection: {
            serverAddress: {
                host: "localhost",
                port: 27018
            },
            auth: <X509Credential>{
                username: "C=LK,ST=Western,L=Colombo,O=WSO2,OU=Ballerina,CN=admin"
            }
        },
        options: {
            socketTimeout: 10000,
            sslEnabled: true,
            secureSocket: {
                trustStore: {
                    path: keystorePath,
                    password: "123456"
                },
                keyStore: {
                    path: keystorePath,
                    password: "123456"
                },
                protocol: "TLS"
            }
        }
    };
    Client mongoClient = check new (validSslConfig);
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertEquals(databaseNames, ["admin", "config", "local"]);
    check mongoClient->close();
}

@test:Config {
    groups: ["client", "negative"]
}
public function testClientReuseAfterClose() returns error? {
    Client mongoClient = check new (connection = {
        serverAddress: {
            host: "localhost",
            port: 27016
        }
    });

    check mongoClient->close();

    // Attempting to use client after close should fail
    string[]|Error result = mongoClient->listDatabaseNames();
    test:assertTrue(result is ApplicationError, "Expected error when using closed client");
}

@test:Config {
    groups: ["client", "negative", "connection_string"]
}
public function testInvalidConnectionString() returns error? {
    // Test various invalid connection string formats
    string[] invalidConnections = [
        "invalid://localhost:27017", // Invalid protocol
        "mongodb://localhost:99999", // Invalid port
        "mongodb://", // Empty host
        "mongodb://localhost:abc" // Non-numeric port
    ];

    foreach string conn in invalidConnections {
        Client|Error mongoClient = new ({connection: conn});
        test:assertTrue(mongoClient is ApplicationError, "Expected error for invalid connection: " + conn);
    }
}

@test:Config {
    groups: ["client", "negative", "ssl"]
}
public function testSSLWithInvalidCertificate() returns error? {
    ConnectionConfig invalidSslConfig = {
        connection: {
            serverAddress: {
                host: "localhost",
                port: 27018
            }
        },
        options: {
            sslEnabled: true,
            secureSocket: {
                protocol: "TLS",
                keyStore: {
                    path: "./tests/resources/docker/certs/invalid-cert.jks",
                    password: "123456"
                },
                trustStore: {
                    path: "./tests/resources/docker/certs/invalid-cert.jks",
                    password: "123456"
                }
            }
        }
    };

    Client|Error mongoClient = new (invalidSslConfig);
    test:assertTrue(mongoClient is ApplicationError, "Expected error when using invalid SSL configuration");
}
@test:Config {
    groups: ["client", "connection_string"]
}
public function testConnectionStringWithManyOptions() returns error? {
    string complexConnectionString = "mongodb://localhost:27016/?"
    + "maxPoolSize=10"
    + "&minPoolSize=1"
    + "&maxIdleTimeMS=30000"
    + "&waitQueueMultiple=5"
    + "&waitQueueTimeoutMS=10000"
    + "&serverSelectionTimeoutMS=30000"
    + "&socketTimeoutMS=10000"
    + "&connectTimeoutMS=10000"
    + "&retryWrites=true"
    + "&retryReads=true";

    Client mongoClient = check new ({connection: complexConnectionString});
    string[] databases = check mongoClient->listDatabaseNames();
    test:assertTrue(databases.length() >= 0);
    check mongoClient->close();
}

@test:Config {
    groups: ["client", "negative", "test", "tttttttttttttt"]
}
public function testEmptyDatabaseName() returns error? {
    Client mongoClient = check new (connection = {
        serverAddress: {
            host: "localhost",
            port: 27016
        }
    });
    Database|Error db = mongoClient->getDatabase("");
    test:assertTrue(db is Error, "Expected error for empty database name");
    if db is Error {
        test:assertTrue(db.message() == "state should be: databaseName is not empty");
    }
    check mongoClient->close();
}
