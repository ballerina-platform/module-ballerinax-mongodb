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

import ballerina/filepath;
import ballerina/log;
import ballerina/test;

string jksFilePath = check filepath:absolute("src/mongodb/tests/resources/mongodb-client.jks");

ClientConfig mongoConfigInvalid = {
    host: testHostName,
    username: testUser,
    options: {
        sslEnabled: true
    }
};

ClientConfig sslMongoConfig = {
    host: testHostName,
    port: testPort,
    username: testUser,
    options: {
        socketTimeout: 10000,
        authMechanism: "MONGODB-X509",
        sslEnabled: true,
        sslInvalidHostNameAllowed: true,
        secureSocket: {
            trustStore: {
                path: jksFilePath,
                password: "123456"
            },
            keyStore: {
                path: jksFilePath,
                password: "123456"
            }
        }
    }
};

@test:Config {
    groups: ["mongodb-ssl"]
}
public function initializeInValidConfig() {
    log:printInfo("Start initialization test failure");
    Client|ApplicationError mongoClient = new (mongoConfigInvalid);
    if (mongoClient is ApplicationError) {
        log:printInfo("Creating client failed '" + mongoClient.message() + "'.");
    } else {
        test:assertFail("Error expected when url is invalid.");
    }
}

@test:Config {
    dependsOn: ["initializeInValidConfig"],
    groups: ["mongodb-ssl"]
}
public function testSSLConnection() returns Error? {

    log:printInfo("------------------ Inserting Data on SSL Connection ------------------");
    map<json> insertDocument = {name: "The Lion King", year: "2019", rating: 8};

    Client mongoClient = check new (sslMongoConfig);
    Database mongoDatabase = check mongoClient->getDatabase("admin");
    Collection mongoCollection = check mongoDatabase->getCollection("test");
    var returned = mongoCollection->insert(insertDocument);
    if (returned is DatabaseError) {
        log:printInfo(returned.toString());
        test:assertFail("Inserting data failed!");
    } else {
        log:printInfo("Successfully inserted document into collection");
    }
}
