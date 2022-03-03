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
import ballerina/os;
import ballerina/test;

string testHostName = os:getEnv("MONGODB_HOST") != "" ? os:getEnv("MONGODB_HOST") : "localhost";
string testUser = os:getEnv("MONGODB_USER") != "" ? os:getEnv("MONGODB_USER") : "";
string testPass = os:getEnv("MONGODB_PASSWORD") != "" ? os:getEnv("MONGODB_PASSWORD") : "";

ConnectionConfig mongoConfig = {
    host: testHostName,
    username: testUser,
    password: testPass,
    options: {sslEnabled: false, serverSelectionTimeout: 15000}
};

ConnectionConfig mongoConfigError = {
    options: {
        url: "asdakjdk"
    }
};

const DATABASE_NAME = "moviecollection";
const COLLECTION_NAME = "moviedetails";
Client mongoClient = check new (mongoConfig, DATABASE_NAME);

@test:Config {
        groups: ["mongodb"]
}
public function initializeInValidClient() {
    log:printInfo("Start initialization test failure");
    Client|Error mongoClient = new (mongoConfigError,"MyDb");
    if (mongoClient is ApplicationError) {
        log:printInfo("Creating client failed '" + mongoClient.message() + "'.");
    } else {
        test:assertFail("Error expected when url is invalid.");
    }
}

@test:Config {
    dependsOn: [ initializeInValidClient ],
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
    dependsOn: [ testListDatabaseNames ],
    groups: ["mongodb"]
}
public function testListCollections() returns Error? {
    log:printInfo("----------------- List Collections------------------");
    var returned = mongoClient->getCollectionNames("admin");

    if (returned is string[]) {
        log:printInfo("Collection Names " + returned.toString());
    } else {
        log:printInfo(returned.toString());
        test:assertFail("List collections failed!");
    }
}

@test:Config {
    dependsOn: [ testListCollections ],
    groups: ["mongodb"]
}
public function testInsertData() returns Error? {
    log:printInfo("------------------ Inserting Data ------------------");
    map<json> insertDocument = {name: "The Lion King", year: "2019", rating: 8};
    map<json> insertDocument2 = {name: "Black Panther", year: "2018", rating: 7};

    var returned = mongoClient->insert(insertDocument, COLLECTION_NAME);
    if (returned is Error) {
        log:printInfo(returned.toString());
        test:assertFail("Inserting data failed!");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }

    returned = mongoClient->insert(insertDocument2, COLLECTION_NAME);
    if (returned is Error) {
        log:printInfo(returned.toString());
        test:assertFail("Inserting data failed!");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }
}
@test:Config {
    dependsOn: [ testInsertData ],
    groups: ["mongodb"]
}
public function testInsertDataWithDbName() returns Error? {
    log:printInfo("------------------ Inserting Data With Second Database ------------------");
    map<json> insertDocument = {name: "The Lion King", year: "2019", rating: 8};
    map<json> insertDocument2 = {name: "Black Panther", year: "2018", rating: 7};

    var returned = mongoClient->insert(insertDocument, COLLECTION_NAME, "anothermoviecollection");
    if (returned is Error) {
        log:printInfo(returned.toString());
        test:assertFail("Inserting data failed!");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }

    returned = mongoClient->insert(insertDocument2, COLLECTION_NAME, "anothermoviecollection");
    if (returned is Error) {
        log:printInfo(returned.toString());
        test:assertFail("Inserting data failed!");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }
}

@test:Config {
    dependsOn: [ testInsertDataWithDbName ],
    groups: ["mongodb"]
}
public function testCountDocuments() returns Error? {
    log:printInfo("----------------- Count Documents------------------");

    var returned = mongoClient->countDocuments(COLLECTION_NAME, (),());
    if (returned is int) {
        log:printInfo("Documents counted successfully '" + returned.toString() + "'");
        test:assertEquals(2, returned);
    } else {
        log:printInfo(returned.toString());
        test:assertFail("Count Failure");
    }

    returned = mongoClient->countDocuments(COLLECTION_NAME,() , {
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
    dependsOn: [ testCountDocuments ],
    groups: ["mongodb"]
}
public function testListIndices() returns error? {
    log:printInfo("----------------- List Indices------------------");
    stream<Index, error?> returned = check mongoClient->listIndices(COLLECTION_NAME);
    check returned.forEach(function(Index data){
        log:printInfo(data.ns);
    });
    log:printInfo("Indices returned successfully '");
}

@test:Config {
    dependsOn: [ testListIndices ],
    groups: ["mongodb"]
}
public function testFindData() returns error? {
    log:printInfo("----------------- Querying Data ----------------");

    map<json> insertDocument1 = {name: "Joker", year: "2019", rating: 7};
    map<json> insertDocument2 = {name: "Black Panther", year: "2018", rating: 7};

    check mongoClient->insert(insertDocument1, COLLECTION_NAME);
    check mongoClient->insert(insertDocument2, COLLECTION_NAME);

    map<json> findDoc = {year: "2019"};
    stream<Movie, error?> returned = check mongoClient->find(COLLECTION_NAME,filter = findDoc);
    check returned.forEach(function(Movie data){
        log:printInfo(data.year.toString());
        test:assertEquals(data.year,"2019","Querying year 2019 filter failed");
    });
    log:printInfo("Querying year 2019 filter tested successfully");

    map<json> sortDoc = {name: 1};
    returned = check mongoClient->find(COLLECTION_NAME, filter = findDoc, sort = sortDoc);
    check returned.forEach(function(Movie data){
        log:printInfo(data.name);
    });
    log:printInfo("Querying year 2019 sort data tested successfully");

    returned = check mongoClient->find(COLLECTION_NAME, filter=findDoc, sort=sortDoc, 'limit=1);
    int count = 0;
    check returned.forEach(function(Movie data){
        count = count+1;
        log:printInfo(data.name);
    });
    test:assertEquals(count, 1, "Querying filtered sort and limit failed");
    log:printInfo("Querying filtered sort and limit tested successfully");

}

@test:Config {
    dependsOn: [ testFindData ],
    groups: ["mongodb"]
}
function testUpdateDocument() returns Error? {
    log:printInfo("------------------ Updating Data -------------------");

    map<json> replaceFilter = {name: "The Lion King"};
    map<json> replaceDoc = { "$set": {name: "The Lion King", year: "2019", rating: 6}};

    var modifiedCount = mongoClient->update(replaceDoc, COLLECTION_NAME, (), replaceFilter, false);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 1, "Document modification failed");
    } else {
        log:printInfo(modifiedCount.toString());
        test:assertFail("Document modification failed");
    }

    replaceFilter = {rating: 7};
    replaceDoc = { "$inc": {rating: 2}};

    modifiedCount = mongoClient->update(replaceDoc, COLLECTION_NAME, (), replaceFilter, true);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 3, "Document modification multiple failed");
    } else {
        log:printInfo(modifiedCount.toString());
        test:assertFail("Document modification multiple failed");
    }
}

@test:Config {
    dependsOn: [ testUpdateDocument ],
    groups: ["mongodb"]
}
function testUpdateDocumentUpsertTrue() returns Error? {
    log:printInfo("------------------ Updating Data (Upsert) -------------------");

    map<json> replaceFilter = {name: "The Lion King 2"};
    map<json> replaceDoc = { "$set": {name: "The Lion King 2", year: "2019", rating: 7}};

    var modifiedCount = mongoClient->update(replaceDoc, COLLECTION_NAME, (), replaceFilter, true, true);
    if (modifiedCount is int) {
        log:printInfo("Modified count: " + modifiedCount.toString());
        test:assertEquals(modifiedCount, 0, "Document modification failed");
    } else {
        log:printInfo(modifiedCount.toString());
        test:assertFail("Replacing data failed");
    }
}

@test:Config {
    dependsOn: [ testUpdateDocumentUpsertTrue ],
    groups: ["mongodb"]
}
function testDelete() returns Error? {
    log:printInfo("------------------ Deleting Data -------------------");

    map<json> deleteFilter = {"rating": 9};

    var deleteRet = mongoClient->delete(COLLECTION_NAME, (), deleteFilter, true);
    if (deleteRet is int) {
        log:printInfo("Deleted count: " + deleteRet.toString());
        test:assertEquals(deleteRet, 3, msg = "Document deletion multiple failed");
    } else {
        log:printInfo(deleteRet.toString());
        test:assertFail("Deleting filter multiple failed");
    }

    deleteRet = mongoClient->delete(COLLECTION_NAME, (), (), true);
    if (deleteRet is int) {
        log:printInfo("Deleted count: " + deleteRet.toString());
        test:assertEquals(deleteRet, 2, msg = "Document deletion failed");
    } else {
        log:printInfo(deleteRet.toString());
        test:assertFail("Deleting data failed");
    }

    log:printInfo("------------------ Deleting Data From Second Database-------------------");
    deleteRet = mongoClient->delete(COLLECTION_NAME, "anothermoviecollection", (), true);
    if (deleteRet is int) {
        log:printInfo("Deleted count: " + deleteRet.toString());
        test:assertEquals(deleteRet, 2, msg = "Document deletion failed");
    } else {
        log:printInfo(deleteRet.toString());
        test:assertFail("Deleting data failed");
    }

    mongoClient->close();
}

type Movie record {
    string name;
    string year;
    int rating;
};

type Index record {
    int v;
    json key;
    string name;
    string ns;
};
