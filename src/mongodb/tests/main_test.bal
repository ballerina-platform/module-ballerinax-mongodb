// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
//import ballerina/config;
//import ballerina/io;
//import ballerina/test;

import ballerina/io;
import ballerina/log;
import ballerina/test;

ClientEndpointConfig mongoConfig = {
    host: "localhost",
    dbName: "projectsTest1",
    username: "",
    password: "",
    options: {sslEnabled: false, serverSelectionTimeout: 500}
};

Client mongoClient = check new (mongoConfig);

json doc1 = {"name": "ballerina", "type": "src"};
json doc2 = {"name": "connectors", "type": "artifacts"};
json doc3 = {"name": "docerina", "type": "src"};
json doc4 = {"name": "test", "type": "artifacts"};

json queryString = {name: "connectors"};
json replaceFilter = {"type": "artifacts"};
json doc5 = {"name": "main", "type": "artifacts"};
boolean upsert = true;

json deleteFilter = {"name": "ballerina"};


//function handleInsert(json | error returned, string message) {


@test:Config {
}
public function testInsertData() {
    log:printInfo("------------------ Inserting Data -------------------");

    var returned = mongoClient->insert("projects", doc1);

    if (returned is error) {
        io:println(" failed: ");
        test:assertFalse(false, msg = "Assert False failed");
    } else {
        io:println(" success ");
    }
}

@test:Config {
    dependsOn: ["testInsertData"]
}
function testUpdate() {

    log:printInfo("------------------ Updating Data -------------------");
    var jsonRet = mongoClient->find("projects", ());

    json replaceFilter = {"type": "artifacts"};
    json doc5 = {"name": "main", "type": "artifacts"};

    int response = mongoClient->replace("projects", replaceFilter, doc5, true);
    if (response > 0) {
        log:printInfo("Modified count: ");
        log:printInfo(response.toString());
        test:assertEquals(response, 1, msg = "Assert failed");
    } else {
        test:assertFail(msg = response.toString());
    }
}

@test:Config {
    dependsOn: ["testInsertData"]
}
function testDelete() {

    log:printInfo("------------------ Deleting Data -------------------");
    json deleteFilter = {"name": "ballerina"};
    var deleteRet = mongoClient->delete("projects", deleteFilter, true);

    int response = mongoClient->replace("projects", replaceFilter, doc5, true);
    if (response > 0) {
        log:printInfo("Modified count: ");
        log:printInfo(response.toString());
        test:assertEquals(response, 1, msg = "Assert failed");
    } else {
        test:assertFail(msg = response.toString());
    }
}



