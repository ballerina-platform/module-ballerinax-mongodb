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

public isolated client class Collection {

    private final Database database;
    private final string collectionName;

    isolated function init(Database database, string collectionName) returns Error? {
        self.database = database;
        self.collectionName = collectionName;
        check initCollection(self, database, collectionName);
    }

    isolated function name() returns string {
        return self.collectionName;
    }

    # Inserts a single document into the collection.
    #
    # + document - The document to insert
    # + options - The options to apply to the operation
    # + return - An error if the operation failed, otherwise nil
    isolated remote function insertOne(record {} document, InsertOneOptions options = {}) returns Error? {
        string documentString = document.toJsonString();
        return check insertOne(self, documentString, options);
    }

    # Inserts multiple documents into the collection.
    # + documents - The documents to insert
    # + options - The options to apply to the operation
    # + return - An error if the operation failed, otherwise nil
    isolated remote function insertMany(record {}[] documents, InsertManyOptions options = {}) returns Error? {
        string[] documentString = documents.'map((doc) => doc.toJsonString());
        return check insertMany(self, documentString, options);
    }

    # Finds all the documents in the collection.
    #
    # + filter - The query filter to apply when retrieving documents
    # + findOptions - The additional options to apply to the find operation
    # + targetType - The type of the returned documents
    # + return - A stream of documents which match the provided filter, or an error if the operation failed
    isolated remote function find(map<json> filter = {}, FindOptions findOptions = {}, typedesc targetType = <>)
    returns stream<targetType, error?>|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Counts the number of documents in the collection.
    #
    # + filter - The query filter to apply when counting documents
    # + options - The additional options to apply to the count operation
    # + return - The number of documents in the collection, or an error if the operation failed
    isolated remote function countDocuments(map<json> filter = {}, CountOptions options = {}) returns int|Error =
    @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;
}

isolated function initCollection(Collection collection, Database database, string collectionName) returns Error? =
@java:Method {
    'class: "io.ballerina.lib.mongodb.Collection"
} external;

isolated function insertOne(Collection collection, string document, InsertOneOptions options) returns Error? =
@java:Method {
    'class: "io.ballerina.lib.mongodb.Collection"
} external;

isolated function insertMany(Collection collection, string[] documents, InsertManyOptions options) returns Error? =
@java:Method {
    'class: "io.ballerina.lib.mongodb.Collection"
} external;
