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

import ballerina/jballerina.java;
import ballerina/log;

# Represents a MongoDB client that can be used to interact with a MongoDB server.
@display {label: "MongoDB Client", iconPath: "icon.png"}
public isolated client class Client {

    # Initialises the `Client` object with the provided `ConnectionConfig` properties.
    #
    # + config - The connection configurations for connecting to a MongoDB server
    # + return - A `mongodb:Error` if the provided configurations are invalid. `()` otherwise.
    public isolated function init(*ConnectionConfig config) returns Error? {
        ConnectionProperties? options = config.options;
        if options is ConnectionProperties {
            boolean? sslEnabled = options?.sslEnabled;
            SecureSocket? secureSocket = options?.secureSocket;
            if sslEnabled is boolean {
                if !sslEnabled {
                    if secureSocket is SecureSocket {
                        log:printWarn("The connection property `secureSocket` is ignored when ssl is disabled.");
                    }
                }
            }
        }
        return initClient(self, config.connection, options);
    }

    # Lists the database names in the MongoDB server.
    #
    # + return - An array of database names on success or else a `mongodb:DatabaseError` if unable to reach the DB
    @display {label: "List Database Names"}
    isolated remote function listDatabaseNames()
    returns @display {label: "Database Names"} string[]|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Client"
    } external;

    # Retrieves a database from the MongoDB server.
    #
    # + databaseName - Name of the database
    # + return - A `mongodb:Database` object on success or else a `mongodb:DatabaseError` if unable to reach the DB
    @display {label: "Get Database"}
    isolated remote function getDatabase(@display {label: "Database Name"} string databaseName) returns Database|Error {
        return new Database(self, databaseName);
    }

    # Closes the client.
    #
    # + return - A `mongodb:Error` if the client is already closed or failed to close the client. `()` otherwise.
    @display {label: "Close the Client"}
    remote isolated function close() returns Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Client"
    } external;
}

isolated function initClient(Client 'client, ConnectionParameters|string connection, ConnectionProperties? options)
returns Error? = @java:Method {
    'class: "io.ballerina.lib.mongodb.Client"
} external;
