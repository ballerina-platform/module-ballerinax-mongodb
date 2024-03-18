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

@test:Config {
    groups: ["database"]
}
function testDatabaseConnection() returns error? {
    Database database = check mongoClient->getDatabase("testDatabaseConnection");
    string[] collectionNames = check database->listCollectionNames();
    test:assertEquals(collectionNames, []);
    check database->createCollection("Movies");
    collectionNames = check database->listCollectionNames();
    test:assertEquals(collectionNames, ["Movies"]);
    check database->drop();
}

@test:Config {
    groups: ["database", "collection", "list"]
}
function testGetCollection() returns error? {
    Database database = check mongoClient->getDatabase("testGetCollection");
    Collection collection = check database->getCollection("Movies");
    test:assertEquals(collection.name(), "Movies");
    check database->drop();
}

@test:Config {
    groups: ["database"]
}
isolated function testDropDatabase() returns error? {
    string[] databaseNames = check mongoClient->listDatabaseNames();
    test:assertTrue(databaseNames.indexOf("sampleDB") !is int);
    Database db = check mongoClient->getDatabase("sampleDB");
    check db->createCollection("testCollection");
    databaseNames = check mongoClient->listDatabaseNames();
    test:assertTrue(databaseNames.indexOf("sampleDB") is int);
    check db->drop();
    databaseNames = check mongoClient->listDatabaseNames();
    test:assertTrue(databaseNames.indexOf("sampleDB") !is int);
}
