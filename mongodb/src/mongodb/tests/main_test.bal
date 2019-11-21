// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/log;
import ballerina/test;

ClientEndpointConfig mongoConfig = {
    host: "localhost",
    dbName: "moviecollection",
    username: "",
    password: "",
    options: {sslEnabled: false, serverSelectionTimeout: 500}
};

Client mongoClient = check new (mongoConfig);

json doc = {"name": "The Lion King", "year": "2019", "rating" : 8};

@test:Config {
}
public function testInsertData() {
    log:printInfo("------------------ Inserting Data -------------------");

    var returned = mongoClient->insert("moviedetails", doc);
    if (returned is error) {
        log:printInfo("Inserting data failed");
        test:assertFalse(false, msg = "Inserting data failed");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }
}

@test:Config {
    dependsOn: ["testInsertData"]
}
function testUpdateDocument() {

   log:printInfo("------------------ Updating Data -------------------");

   json replaceFilter = {"name":"The Lion King"};
   json replaceDoc = {"name": "The Lion King", "year": "2019", "rating" : 7};

   int modifiedCount = mongoClient->replace("moviedetails", replaceFilter, replaceDoc, true);
   log:printInfo("Modified count: " + modifiedCount.toString());
   test:assertNotEquals(modifiedCount, 0, msg = "Document modification failed");
}

@test:Config {
   dependsOn: ["testUpdateDocument"]
}
function testDelete() {
   log:printInfo("------------------ Deleting Data -------------------");
   json deleteFilter = {"name": "The Lion King"};
   int deleteRet = mongoClient->delete("moviedetails", deleteFilter, true);
   log:printInfo("Deleted count: " + deleteRet.toString());
   test:assertNotEquals(deleteRet, 0, msg = "Document deletion failed");
}

