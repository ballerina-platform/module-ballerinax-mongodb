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

import ballerina/log;
import ballerina/test;
import ballerina/random;

@test:AfterSuite
function shutDown() returns error? {
    check mongoClient->close();
    log:printInfo("**** MongoDB client closed ****");
}

final ConnectionConfig clientConfig = {
    connection: {
        auth: <ScramSha256AuthCredential>{
            username,
            password,
            database: "admin"
        }
    },
    options: {
        sslEnabled: false
    }
};

final ConnectionConfig invalidConfig = {
    connection: "invalidDB"
};

final ConnectionConfig replicaSetConfig = {
    connection: {
        serverAddress: [
            {
                host: "localhost",
                port: 20000
            },
            {
                host: "localhost",
                port: 20001
            },
            {
                host: "localhost",
                port: 20002
            }
        ],
        auth: <ScramSha256AuthCredential>{
            username,
            password,
            database: "admin"
        }
    }
};

final Client mongoClient = check new (clientConfig);

isolated function getRandomString(int length) returns string|error {
    string[] chars = [
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    ];
    string result = "";
    int i = 0;
    while i < length {
        int randomIndex = check random:createIntInRange(0, chars.length() - 1);
        result += chars[randomIndex];
        i += 1;
    }
    return result;
}

isolated function createAndDropDatabase(string dbName) returns error? {
    Database database = check mongoClient->getDatabase(dbName);
    check database->createCollection("tempCollection");
    string[] collections = check database->listCollectionNames();
    test:assertTrue(collections.length() > 0);
    check database->drop();
}

isolated function updateCounter(Collection collection) returns UpdateResult|Error {
    return collection->updateOne({name: "Concurrent"}, {inc: {counter: 1}});
}
