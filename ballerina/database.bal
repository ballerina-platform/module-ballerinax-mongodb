// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/jballerina.java;

# Represents a MongoDB database.
@display {
    label: "MongoDB Database"
}
public isolated client class Database {

    private final Client 'client;

    isolated function init(Client 'client, string databaseName) returns Error? {
        self.'client = 'client;
        check initDatabase(self, 'client, databaseName);
    }

    # Lists all the collections in the database.
    #
    # + return - An array of collection names
    isolated remote function listCollectionNames() returns string[]|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Database"
    } external;

    # Creates a collection in the database.
    #
    # + collectionName - The name of the collection to be created
    # + return - Nil on success or else an error
    isolated remote function createCollection(string collectionName) returns Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Database"
    } external;

    # Get a collection from the database.
    #
    # + collectionName - The name of the collection to be retrieved
    # + return - The `mogodb:Collection` on success or else an error
    isolated remote function getCollection(string collectionName) returns Collection|Error {
        return new (self, collectionName);
    }

    # Drops the database.
    #
    # + return - Nil on success or else and error
    isolated remote function drop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Database"
    } external;
}

isolated function initDatabase(Database database, Client 'client, string databaseName) returns Error? = @java:Method {
    'class: "io.ballerina.lib.mongodb.Database"
} external;
