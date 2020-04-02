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

public type Database client object {
    handle database;

    public function __init(handle database) {
        self.database = database;
    }

    # Lists the collection names in the MongoDB database.
    #
    # + return - An array of collection names on success or else returns an error
    public remote function getCollectionNames() returns string[]|DatabaseError {
        return getCollectionNames(self.database);
    }

    #
    # + name - Name of the collection
    # + return - A collection object on success or else returns an error
    public remote function getCollection(string name) returns Collection|Error {
        if (name.trim().length() == 0) {
            return ApplicationError( message = "Collection Name cannot be empty.");
        }
        handle collection = check getCollection(self.database, name);
        return new Collection(collection);
    }
};

function getCollectionNames(handle database) returns string[]|DatabaseError = @java:Method {
    class: "org.wso2.mongo.MongoDBDatabaseUtil"
} external;

function getCollection(handle database, string collectionName) returns handle|DatabaseError = @java:Method {
    class: "org.wso2.mongo.MongoDBDatabaseUtil"
} external;
