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
import ballerina/system;
import ballerina/test;
import ballerina/lang.'int;

string testHostName = system:getEnv("MONGODB_HOST") != "" ? system:getEnv("MONGODB_HOST") : "localhost";
int testPort = system:getEnv("MONGODB_PORT") != "" ? check 'int:fromString(system:getEnv("MONGODB_PORT")) : 27017;
string testUser = system:getEnv("MONGODB_USER") != "" ? system:getEnv("MONGODB_USER") : "";
string testPass = system:getEnv("MONGODB_PASSWORD") != "" ? system:getEnv("MONGODB_PASSWORD") : "";

ClientConfig mongoConfig = {
    host: testHostName,
    username: testUser,
    password: testPass,
    options: {sslEnabled: false, serverSelectionTimeout: 5000}
};

ClientConfig mongoConfigError = {
    options: {
        url: "asdakjdk"
    }
};

Client mongoClient = check new (mongoConfig);
const DATABASE_NAME = "moviecollection";
const COLLECTION_NAME = "moviedetails";

@test:Config {
        groups: ["mongodb"]
}
public function initializeInValidClient() {
    log:printInfo("Start initialization test failure");
    Client|ApplicationError mongoClient = new (mongoConfigError);
    if (mongoClient is ApplicationError) {
        log:printInfo("Creating client failed '" + mongoClient.message() + "'.");
    } else {
        test:assertFail("Error expected when url is invalid.");
    }
}

@test:Config {
    dependsOn: ["initializeInValidClient"],
    groups: ["mongodb"]
}
public function testListDatabaseNames() {
    log:printInfo("----------------- List Databases------------------");
    var returned = mongoClient->getDatabasesNames();

    if (returned is string[]) {
        log:printInfo("Database Names " + returned.toString());
    } else {
        log:printInfo(returned.toString());
        test:assertFail("List databases failed!");
    }
}

@test:Config {
    dependsOn: ["testListDatabaseNames"],
    groups: ["mongodb"]
}
public function testGetDatabase() {
    log:printInfo("----------------- Get Database------------------");
    var returned = mongoClient->getDatabase("  ");
    if (returned is ApplicationError) {
        log:printInfo("Empty dbName validated successfully");
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Validation Failure");
    }
}

@test:Config {
    dependsOn: ["testGetDatabase"],
    groups: ["mongodb"]
}
public function testListCollections() returns Error? {
    log:printInfo("----------------- List Collections------------------");
    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    var returned = mongoDatabase->getCollectionNames();

    if (returned is string[]) {
        log:printInfo("Database Names " + returned.toString());
    } else {
        log:printInfo(returned.toString());
        test:assertFail("List collections failed!");
    }
}

@test:Config {
    dependsOn: ["testListCollections"],
    groups: ["mongodb"]
}
public function testGetCollection() returns Error? {
    log:printInfo("----------------- Get Collection------------------");
    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    var returned = mongoDatabase->getCollection("  ");
    if (returned is ApplicationError) {
        log:printInfo("Empty collection name validated successfully");
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Empty collection name validation Failure");
    }
}

@test:Config {
    dependsOn: ["testGetCollection"],
    groups: ["mongodb"]
}
public function testInsertData() returns Error? {
    log:printInfo("------------------ Inserting Data ------------------");
    map<json> insertDocument = {name: "The Lion King", year: "2019", rating: 8};
    map<json> insertDocument2 = {name: "Black Panther", year: "2018", rating: 7};

    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    Collection mongoCollection = check mongoDatabase->getCollection(COLLECTION_NAME);
    var returned = mongoCollection->insert(insertDocument);
    if (returned is DatabaseError) {
        log:printInfo(returned.toString());
        test:assertFail("Inserting data failed!");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }

    returned = mongoCollection->insert(insertDocument2);
    if (returned is DatabaseError) {
        log:printInfo(returned.toString());
        test:assertFail("Inserting data failed!");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }
}

@test:Config {
    dependsOn: ["testInsertData"],
    groups: ["mongodb"]
}
public function testCountDocuments() returns Error? {
    log:printInfo("----------------- Count Documents------------------");
    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    Collection mongoCollection = check mongoDatabase->getCollection(COLLECTION_NAME);

    var returned = mongoCollection->countDocuments(());
    if (returned is int) {
        log:printInfo("Documents counted successfully '" + returned.toString() + "'");
        test:assertEquals(2, returned);
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Count Failure");
    }

    returned = mongoCollection->countDocuments({
        year: "2018"
    });
    if (returned is int) {
        log:printInfo("Documents counted successfully '" + returned.toString() + "'");
        test:assertEquals(1, returned);
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Count Failure");
    }
}

@test:Config {
    dependsOn: ["testCountDocuments"],
    groups: ["mongodb"]
}
public function testListIndices() returns Error? {
    log:printInfo("----------------- Count Documents------------------");
    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    Collection mongoCollection = check mongoDatabase->getCollection(COLLECTION_NAME);
    var returned = mongoCollection->listIndices();
    if (returned is map<json>[]) {
        log:printInfo("Indices returned successfully '" + returned.toString() + "'");
        test:assertEquals(1, returned.length());
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Indices List Failure");
    }
}

@test:Config {
    dependsOn: ["testListIndices"],
    groups: ["mongodb"]
}
public function testFindData() returns Error? {
    log:printInfo("----------------- Querying Data ----------------");

    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    Collection mongoCollection = check mongoDatabase->getCollection(COLLECTION_NAME);

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
        log:printInfo(returned.toString());
        test:assertFail("Finding data failed");
    }

    map<json> sortDoc = {name: 1};
    returned = mongoCollection->find(filter = findDoc, sort = sortDoc);
    if (returned is map<json>[]) {
        log:printInfo(returned.toString());
        test:assertEquals(returned.length(), 2, "Querying year 2019 sort data failed");
        test:assertEquals(returned[0].name, "Joker");
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Finding data sort failed");
    }

    returned = mongoCollection->find(findDoc, sortDoc, 1);
    if (returned is map<json>[]) {
        log:printInfo(returned.toString());
        test:assertEquals(returned.length(), 1, "Querying filtered sort and limit failed");
        test:assertEquals(returned[0].name, "Joker");
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Finding data limit failed");
    }

}

@test:Config {
    dependsOn: ["testFindData"],
    groups: ["mongodb"]
}
function testUpdateDocument() returns Error? {
    log:printInfo("------------------ Updating Data -------------------");
    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    Collection mongoCollection = check mongoDatabase->getCollection(COLLECTION_NAME);

    map<json> replaceFilter = {name: "The Lion King"};
    map<json> replaceDoc = {name: "The Lion King", year: "2019", rating: 6};

    var modifiedCount = mongoCollection->update(replaceDoc, replaceFilter, false);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 1, "Document modification failed");
    } else {
        log:printInfo(modifiedCount.toString());
        test:assertFail("Document modification failed");
    }

    replaceFilter = {rating: 7};
    replaceDoc = {rating: 9};

    modifiedCount = mongoCollection->update(replaceDoc, replaceFilter, true);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 3, "Document modification multiple failed");
    } else {
        log:printInfo(modifiedCount.toString());
        test:assertFail("Document modification multiple failed");
    }
}

@test:Config {
    dependsOn: ["testUpdateDocument"],
    groups: ["mongodb"]
}
function testUpdateDocumentUpsertTrue() returns Error? {
    log:printInfo("------------------ Updating Data (Upsert) -------------------");
    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    Collection mongoCollection = check mongoDatabase->getCollection(COLLECTION_NAME);

    map<json> replaceFilter = {name: "The Lion King 2"};
    map<json> replaceDoc = {name: "The Lion King 2", year: "2019", rating: 7};

    var modifiedCount = mongoCollection->update(replaceDoc, replaceFilter, true, true);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 0, "Document modification failed");

        map<json> findOneDoc = {name: "The Lion King 2"};
        var returned = mongoCollection->find(filter = findOneDoc);
        if (returned is json) {
            log:printInfo("Queried data " + returned.toString());
            test:assertNotEquals(returned.toString(), "null", "Querying one data failed");
        } else {
            log:printInfo(returned.toString());
            test:assertFail("Finding data failed");
        }

    } else {
        log:printInfo(modifiedCount.toString());
        test:assertFail("Replacing data failed");
    }
}

@test:Config {
    dependsOn: ["testUpdateDocumentUpsertTrue"],
    groups: ["mongodb"]
}
function testDelete() returns Error? {
    log:printInfo("------------------ Deleting Data -------------------");
    Database mongoDatabase = check mongoClient->getDatabase(DATABASE_NAME);
    Collection mongoCollection = check mongoDatabase->getCollection(COLLECTION_NAME);

    map<json> deleteFilter = {"rating": 9};

    var deleteRet = mongoCollection->delete(deleteFilter, true);
    if (deleteRet is int) {
        log:printInfo("Deleted count: " + deleteRet.toString());
        test:assertEquals(deleteRet, 3, msg = "Document deletion multiple failed");
    } else {
        log:printInfo(deleteRet.toString());
        test:assertFail("Deleting filter multiple failed");
    }

    deleteRet = mongoCollection->delete((), true);
    if (deleteRet is int) {
        log:printInfo("Deleted count: " + deleteRet.toString());
        test:assertEquals(deleteRet, 2, msg = "Document deletion failed");
    } else {
        log:printInfo(deleteRet.toString());
        test:assertFail("Deleting data failed");
    }

    mongoClient->close();
}
