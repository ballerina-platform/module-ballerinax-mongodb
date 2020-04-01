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

ClientConfig mongoConfig = {
    host: "localhost",
    options: {sslEnabled: false, serverSelectionTimeout: 5000}
};

ClientConfig mongoConfigError = {
    options: {
        url: "asdakjdk"
    }
};

Client mongoClient = check new (mongoConfig);
Database mongoDatabase = check mongoClient->getDatabase("moviecollection");
Collection mongoCollection = check mongoDatabase->getCollection("moviedetails");

@test:Config {
}
public function initaliseInValidClient() {
    log:printInfo("Start initalisation test failure");
    Client|ApplicationError mongoClient = new (mongoConfigError);
    if (mongoClient is ApplicationError) {
        log:printInfo("Creating client failed '" + mongoClient.detail().message + "'.");
    } else {
        test:assertFail("Error expected when url is invalid.");
    }
}

@test:Config {
    dependsOn: ["initaliseInValidClient"]
}
public function testListDatabaseNames() {
    log:printInfo("----------------- List Databases------------------");
    var returned = mongoClient->getDatabasesNames();

    if (returned is string[]) {
        log:printInfo("Database Names " + returned.toString());
    } else {
        test:assertFail("List databases falied " + returned.toString());
    }
}

@test:Config {
    dependsOn: ["testListDatabaseNames"]
}
public function testGetDatabase() {
    log:printInfo("----------------- Get Database------------------");
    var returned = mongoClient->getDatabase("  ");
    if (returned is ApplicationError) {
        log:printInfo("Empty dbName validated successfully");
    } else {
        test:assertFail("Validation Failure");
    }
}

@test:Config {
    dependsOn: ["testGetDatabase"]
}
public function testListCollections() {
    log:printInfo("----------------- List Collections------------------");
    var returned = mongoDatabase->getCollectionNames();

    if (returned is string[]) {
        log:printInfo("Database Names " + returned.toString());
    } else {
        test:assertFail("List databases falied " + returned.toString());
    }
}

@test:Config {
    dependsOn: ["testListCollections"]
}
public function testGetCollection() {
    log:printInfo("----------------- Get Collection------------------");
    var returned = mongoDatabase->getCollection("  ");
    if (returned is ApplicationError) {
        log:printInfo("Empty collection name validated successfully");
    } else {
        test:assertFail("Validation Failure");
    }
}

@test:Config {
    dependsOn: ["testGetCollection"]
}
public function testInsertData() {
    log:printInfo("------------------ Inserting Data ------------------");
    map<json> insertDocument = {name: "The Lion King", year: "2019", rating: 8};
    map<json> insertDocument2 = {name: "Black Panther", year: "2018", rating: 7};

    var returned = mongoCollection->insert(insertDocument);
    if (returned is DatabaseError) {
        log:printInfo("Inserting data failed");
        test:assertFalse(true, msg = <string>returned.detail().message);
    } else {
        log:printInfo("Successfully inserted document into collection");
        test:assertTrue(true);
    }

    returned = mongoCollection->insert(insertDocument2);
    if (returned is DatabaseError) {
        log:printInfo("Inserting data failed");
        test:assertFalse(true, msg = <string>returned.detail().message);
    } else {
        log:printInfo("Successfully inserted document into collection");
        test:assertTrue(true);
    }
}

@test:Config {
    dependsOn: ["testInsertData"]
}
public function testCountDocuments() {
    log:printInfo("----------------- Count Documents------------------");
    var returned = mongoCollection->countDocuments(());
    if (returned is int) {
        log:printInfo("Documents counted successfully '" + returned.toString() + "'");
        test:assertEquals(2, returned);
    } else {
        test:assertFail("Count Failure");
    }

    returned = mongoCollection->countDocuments({
        year: "2018"
    });
    if (returned is int) {
        log:printInfo("Documents counted successfully '" + returned.toString() + "'");
        test:assertEquals(1, returned);
    } else {
        test:assertFail("Count Failure");
    }
}

@test:Config {
    dependsOn: ["testCountDocuments"]
}
public function testListIndices() {
    log:printInfo("----------------- Count Documents------------------");
    var returned = mongoCollection->listIndices();
    if (returned is map<json>[]) {
        log:printInfo("Indices returned successfully '" + returned.toString() + "'");
        test:assertEquals(1, returned.length());
    } else {
        test:assertFail("Indices List Failure");
    }
}

@test:Config {
    dependsOn: ["testListIndices"]
}
public function testFindData() {
    log:printInfo("----------------- Querying Data ----------------");

    map<json> insertDocument1 = {name: "Joker", year: "2019", rating: 7};
    map<json> insertDocument2 = {name: "Black Panther", year: "2018", rating: 7};

    var returned1 = mongoCollection->insert(insertDocument1);
    var returned2 = mongoCollection->insert(insertDocument2);

    map<json> findDoc = {year: "2019"};
    var returned = mongoCollection->find(filter = findDoc);
    if (returned is map<json>[]) {
        log:printInfo(returned.toString());
        test:assertEquals(returned.length(), 2, msg = "Querying year 2019 filter failed");
    } else {
        log:printInfo("Finding data failed");
        test:assertFalse(true);
    }

    map<json> sortDoc = {name: 1};
    returned = mongoCollection->find(filter = findDoc, sort = sortDoc);
    if (returned is map<json>[]) {
        log:printInfo(returned.toString());
        test:assertEquals(returned.length(), 2, msg = "Querying year 2019 sort data failed");
        test:assertEquals(returned[0].name, "Joker");
    } else {
        log:printInfo("Finding data sort failed");
        test:assertFalse(true, msg = returned.detail().message);
    }

    returned = mongoCollection->find(findDoc, sortDoc, 1);
    if (returned is map<json>[]) {
        log:printInfo(returned.toString());
        test:assertEquals(returned.length(), 1, msg = "Querying filtered sort and limit failed");
        test:assertEquals(returned[0].name, "Joker");
    } else {
        log:printInfo("Finding data limit failed");
        test:assertFalse(true, msg = returned.detail().message);
    }

}


@test:Config {
    dependsOn: ["testFindData"]
}
function testUpdateDocument() {
    log:printInfo("------------------ Updating Data -------------------");
    map<json> replaceFilter = {name: "The Lion King"};
    map<json> replaceDoc = {name: "The Lion King", year: "2019", rating: 6};

    var modifiedCount = mongoCollection->update(replaceDoc, replaceFilter, false);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 1, msg = "Document modification failed");
    } else {
        log:printInfo("Replacing data failed");
        test:assertFalse(true, msg = modifiedCount.detail().message);
    }

    replaceFilter = {rating: 7};
    replaceDoc = {rating: 9};

    modifiedCount = mongoCollection->update(replaceDoc, replaceFilter, true);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 3, msg = "Document modification multiple failed");
    } else {
        log:printInfo("Replacing data failed");
        test:assertFalse(true, msg = modifiedCount.detail().message);
    }
}

@test:Config {
    dependsOn: ["testUpdateDocument"]
}
function testUpdateDocumentUpsertTrue() {
    log:printInfo("------------------ Updating Data (Upsert) -------------------");
    map<json> replaceFilter = {name: "The Lion King 2"};
    map<json> replaceDoc = {name: "The Lion King 2", year: "2019", rating: 7};

    var modifiedCount = mongoCollection->update(replaceDoc, replaceFilter, true, true);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 0, msg = "Document modification failed");

        map<json> findOneDoc = {name: "The Lion King 2"};
        var returned = mongoCollection->find(filter = findOneDoc);
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
}

@test:Config {
    dependsOn: ["testUpdateDocumentUpsertTrue"]
}
function testDelete() {
    log:printInfo("------------------ Deleting Data -------------------");
    map<json> deleteFilter = {"rating": 9};

    var deleteRet = mongoCollection->delete(deleteFilter, true);
    if (deleteRet is int) {
        log:printInfo("Deleted count: " + deleteRet.toString());
        test:assertEquals(deleteRet, 3, msg = "Document deletion multiple failed");
    } else {
        log:printInfo("Deleting filter multiple failed");
        test:assertFalse(true, msg = deleteRet.detail()?.message);
    }

    deleteRet = mongoCollection->delete((), true);
    if (deleteRet is int) {
        log:printInfo("Deleted count: " + deleteRet.toString());
        test:assertEquals(deleteRet, 2, msg = "Document deletion failed");
    } else {
        log:printInfo("Deleting data failed");
        test:assertFalse(true, msg = deleteRet.detail()?.message);
    }
}
