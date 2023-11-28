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

import ballerina/log;
import ballerina/test;

string keystorePath = "./tests/resources/docker/certs/mongodb-client.jks";
string x509Username = "C=LK,ST=Western,L=Colombo,O=WSO2,OU=Ballerina,CN=admin";

X509Credential x509Credential = {
    username: x509Username
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
        port: 27018,
        options: {
            socketTimeout: 10000,
            authMechanism: "MONGODB-X509",
            sslEnabled: true,
            secureSocket: {
                trustStore: {
                    path: keystorePath,
                    password: "123456"
                },
                keyStore: {
                    path: keystorePath,
                    password: "123456"
                },
                protocol: "TLS"
            }
        }
    },
    databaseName: "admin"
};

@test:Config {
    groups: ["mongodb-ssl"]
}
public function initializeInValidConfig() {
    Client|Error mongoClient = new (mongoConfigInvalid);
    if (mongoClient is ApplicationError) {
        log:printInfo("Creating client failed '" + mongoClient.message() + "'.");
    } else {
        test:assertFail("Expected an error for invalid client configurations");
    }
}

@test:Config {
    groups: ["mongodb-ssl"]
}
public function testSSLConnection() returns error? {
    map<json> document = {name: "The Lion King", year: "2019", rating: 8};
    Client|Error mongoClient = new (sslMongoConfig);
    if mongoClient is Error {
        return mongoClient;
    }
    check mongoClient->insert(document, "test");
}
