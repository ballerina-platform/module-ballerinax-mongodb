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
//
//mongodb:ClientEndpointConfig mongoConfig = {
//    host: "localhost",
//    dbName: "projectsTest1",
//    username: "",
//    password: "",
//    options: {sslEnabled: false, serverSelectionTimeout: 500}
//};
//
//mongodb:Client mongoClient = check new (mongoConfig);
//
//json doc1 = {"name": "ballerina", "type": "src"};
//json doc2 = {"name": "connectors", "type": "artifacts"};
//json doc3 = {"name": "docerina", "type": "src"};
//json doc4 = {"name": "test", "type": "artifacts"};
//
//json queryString = {name: "connectors"};
//json replaceFilter = {"type": "artifacts"};
//json doc5 = {"name": "main", "type": "artifacts"};
//boolean upsert = true;
//
//json deleteFilter = { "name": "ballerina" };
//
//@test:Config {}
//function testCreateSpreadsheet() {
//    io:println("-----------------Test case for createSpreadsheet method------------------");
//
//    var ret = mongoClient->insert("projects", doc1);
//    handleInsert(ret, "Insert to projects");
//    ret = mongoClient->insert("projects", doc2);
//    handleInsert(ret, "Insert to projects");
//    ret = mongoClient->insert("projects", doc3);
//
//
//}


