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

@test:Config {
}
public function testInsertData() {
    log:printInfo("------------------ Inserting Data ------------------");

    json insertDocument = { name : "The Lion King", year : "2019", rating : 8 };
    var returned = mongoClient->insert("moviedetails", insertDocument);
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
public function testFindData() {
    log:printInfo("----------------- Querying All Data ----------------");

    json insertDocument1 = { name : "Joker", year : "2019", rating : 7 };
    json insertDocument2 = { name : "Black Panther", year : "2018", rating : 7 };
    var returned1 = mongoClient->insert("moviedetails", insertDocument1);
    var returned2 = mongoClient->insert("moviedetails", insertDocument2);

    json findDoc = { year : "2019" };
    json[] returned = mongoClient->find("moviedetails", findDoc);
    test:assertEquals(returned.length(), 2, msg = "Querying all data failed");
}

@test:Config {
    dependsOn: ["testFindData"]
}
public function testFindOneData() {
    log:printInfo("----------------- Querying One Data ----------------");

    json findOneDoc = { year : "2019" };
    json returned = mongoClient->findOne("moviedetails", findOneDoc);
    test:assertNotEquals(returned.toString(), "null", "Querying one data failed");
}

@test:Config {
    dependsOn: ["testFindOneData"]
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
   json deleteFilter = {"rating": 7};
   int deleteRet = mongoClient->delete("moviedetails", deleteFilter, true);
   log:printInfo("Deleted count: " + deleteRet.toString());
   test:assertNotEquals(deleteRet, 0, msg = "Document deletion failed");
}

