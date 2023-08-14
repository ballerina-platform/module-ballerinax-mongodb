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

import ballerina/file;
import ballerina/log;
import ballerina/test;

string jksFilePath = check file:getAbsolutePath("ballerina/tests/resources/mongodb-client.jks");

X509Credential x509Credential = {
    username: testUser
};

ConnectionConfig mongoConfigInvalid = {
    connection: {
        host: testHostName,
        auth: x509Credential,
        options: {
            sslEnabled: true
        }
    }
};

ConnectionConfig sslMongoConfig = {
    connection: {
        host: testHostName,
        auth: x509Credential,
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
                },
                protocol:"TLS"
            }
        }
    },
    databaseName: "admin"
};

@test:Config {
   groups: ["mongodb-ssl"]
}
public function initializeInValidConfig() {
   log:printInfo("Start initialization test failure");
   Client|Error mongoClient = new (mongoConfigInvalid);
   if (mongoClient is ApplicationError) {
       log:printInfo("Creating client failed '" + mongoClient.message() + "'.");
   } else {
       test:assertFail("Error expected when url is invalid.");
   }
}

@test:Config {
   dependsOn: [ initializeInValidConfig ],
   groups: ["mongodb-ssl"]
}
public function testSSLConnection() returns error? {
   log:printInfo("------------------ Inserting Data on SSL Connection ------------------");
   map<json> document = {name: "The Lion King", year: "2019", rating: 8};

   Client mongoClient = check new (sslMongoConfig);
   check mongoClient->insert(document, "test");
}
