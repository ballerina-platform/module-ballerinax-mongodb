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

ClientEndpointConfig mongoConfigError = {
    host: "",
    dbName: "",
    username: "",
    password: ""
};

@test:Config {
}
public function initaliseInValidClient() {
    log:printInfo("Start initalisation test failure");
    Client|ApplicationError mongoClient = new(mongoConfigError);
    if (mongoClient is ApplicationError) {
        log:printInfo("Creating client failed");
        test:assertTrue(true, mongoClient.reason());
    } else {
        log:printInfo("Creating client passed");
        test:assertFail("Error expected when dBName in the config is null.");
    }
}

@test:Config {
        dependsOn: ["initaliseInValidClient"]
}
public function initaliseValidClient() {
    log:printInfo("Start initalisation test failure");
    Client|ApplicationError mongoClient = new(mongoConfig);
    if (mongoClient is ApplicationError) {
        log:printInfo("Creating client failed");
        test:assertFalse(true, mongoClient.reason());
    } else {
        log:printInfo("Creating client passed");
        test:assertTrue(true);
    }
}

@test:Config {
    dependsOn: ["initaliseValidClient"]
}
public function testInsertData() {
    log:printInfo("------------------ Inserting Data ------------------");
    json insertDocument = { name : "The Lion King", year : "2019", rating : 8 };
    Client|error mongoClient = new(mongoConfig);
    if (mongoClient is Client) {
        var returned = mongoClient->insert("moviedetails", insertDocument);
        if (returned is ConnectorError) {
            log:printInfo("Inserting data failed");
            test:assertFalse(true, msg = <string>returned.detail()?.message);
        } else {
            log:printInfo("Successfully inserted document into collection");
            test:assertTrue(true);
        }
    } else {
        log:printInfo("Inserting data failed");
        test:assertFalse(true, msg = <string>mongoClient.detail()?.message);
    }
}

@test:Config {
   dependsOn: ["testInsertData"]
}
public function testFindData() {
   log:printInfo("----------------- Querying All Data ----------------");

   json insertDocument1 = { name : "Joker", year : "2019", rating : 7 };
   json insertDocument2 = { name : "Black Panther", year : "2018", rating : 7 };
   Client|error mongoClient = new(mongoConfig);
   if (mongoClient is Client) {
       var returned1 = mongoClient->insert("moviedetails", insertDocument1);
       var returned2 = mongoClient->insert("moviedetails", insertDocument2);

       json findDoc = { year : "2019" };
       var returned = mongoClient->find("moviedetails", findDoc);
       if (returned is json[]) {
           test:assertEquals(returned.length(), 2, msg = "Querying all data failed");
       } else {
           log:printInfo("Finding data failed");
           test:assertFalse(true, msg = returned.detail()?.message);
       }
   } else {
       log:printInfo("Error occured during client initialization");
       test:assertFail(<string>mongoClient.detail()?.message);
   }
}

@test:Config {
   dependsOn: ["testFindData"]
}
public function testFindOneData() { 
    log:printInfo("----------------- Querying One Data ----------------");

    json findOneDoc = { year : "2019" };
    Client|error mongoClient = new(mongoConfig);
    if (mongoClient is Client) {
        var returned = mongoClient->findOne("moviedetails", findOneDoc);
        if (returned is json) {
            test:assertNotEquals(returned.toString(), "null", "Querying one data failed");
        } else {
            log:printInfo("Finding data failed");
            test:assertFalse(true, msg = returned.detail()?.message);
        }
    } else {
        log:printInfo("Error occured during client initialization");
        test:assertFail(<string>mongoClient.detail()?.message);
    }
}

@test:Config {
    dependsOn: ["testFindOneData"]
}
function testUpdateDocument() {
    log:printInfo("------------------ Updating Data -------------------");
    json replaceFilter = {"name":"The Lion King"};
    json replaceDoc = {"name": "The Lion King", "year": "2019", "rating" : 7};

    Client|error mongoClient = new(mongoConfig);
    if (mongoClient is Client) {
        var modifiedCount = mongoClient->replace("moviedetails", replaceFilter, replaceDoc, false);
        if (modifiedCount is int) {
            log:printInfo("Modified count: " + modifiedCount.toString());
            test:assertNotEquals(modifiedCount, 0, msg = "Document modification failed");
        } else {
            log:printInfo("Replacing data failed");
            test:assertFalse(true, msg = modifiedCount.detail()?.message);
        }
    } else {
        log:printInfo("Error occured during client initialization");
        test:assertFail(<string>mongoClient.detail()?.message);
    }
}


@test:Config {
    dependsOn: ["testUpdateDocument"]
}
function testUpdateDocumentUpsertTrue() {
    log:printInfo("------------------ Updating Data (Upsert) -------------------");
    json replaceFilter = {"name":"The Lion King 2"};
    json replaceDoc = {"name": "The Lion King 2", "year": "2019", "rating" : 7};

    Client|error mongoClient = new(mongoConfig);
    if (mongoClient is Client) {
        var modifiedCount = mongoClient->replace("moviedetails", replaceFilter, replaceDoc, true);
        if (modifiedCount is int) {
            log:printInfo("Modified count: " + modifiedCount.toString());
            test:assertEquals(modifiedCount, 0, msg = "Document modification failed");

            json findOneDoc = { "name":"The Lion King 2" };
            var returned = mongoClient->findOne("moviedetails", findOneDoc);
            if (returned is json) {
                log:printInfo("Queried data " + returned.toString());
                test:assertNotEquals(returned.toString(), "null", "Querying one data failed");
            } else {
                log:printInfo("Finding data failed");
                test:assertFalse(true, msg = returned.detail()?.message);
            }

        } else {
            log:printInfo("Replacing data failed");
            test:assertFail(msg = modifiedCount.detail()?.message);
        }
    } else {
        log:printInfo("Error occured during client initialization");
        test:assertFail(<string>mongoClient.detail()?.message);
    }
}

@test:Config {
    dependsOn: ["testUpdateDocumentUpsertTrue"]
}
function testDelete() {
    log:printInfo("------------------ Deleting Data -------------------");
    json deleteFilter = {"rating": 7};

    Client|error mongoClient = new(mongoConfig);
    if (mongoClient is Client) {
        var deleteRet = mongoClient->delete("moviedetails", deleteFilter, true);
        if (deleteRet is int) {
            log:printInfo("Deleted count: " + deleteRet.toString());
            test:assertNotEquals(deleteRet, 0, msg = "Document deletion failed");
        } else {
            log:printInfo("Deleting data failed");
            test:assertFalse(true, msg = deleteRet.detail()?.message);
        } 
    }
}
