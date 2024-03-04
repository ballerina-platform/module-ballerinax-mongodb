// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

final ConnectionConfig replicasetConfig = {
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
