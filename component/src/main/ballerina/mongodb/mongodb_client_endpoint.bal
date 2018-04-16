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
package ballerina.mongodb;

///////////////////////////////
// MongoDB Client Endpoint
///////////////////////////////

@Description {value:"Represents MongoDB client endpoint"}
@Field {value:"epName: The name of the endpoint"}
@Field {value:"config: The configurations associated with the endpoint"}
public type Client object {
    public {
        string epName;
        ClientEndpointConfiguration clientEndpointConfig;
        MongoDBClient mongodbClient;
    }

    @Description {value:"Gets called when the endpoint is being initialized during the package initialization."}
    public function init(ClientEndpointConfiguration clientEndpointConfig);

    public function register(typedesc serviceType) {
    }

    public function start() {
    }

    @Description {value:"Returns the connector that client code uses"}
    @Return {value:"The connector that client code uses"}
    public function getClient() returns MongoDBClient {
        return self.mongodbClient;
    }

    @Description {value:"Stops the registered service"}
    @Return {value:"Error occured during registration"}
    public function stop() {
    }
};

public native function createMongoDBClient(ClientEndpointConfiguration clientEndpointConfig) returns MongoDBClient;

public function Client::init(ClientEndpointConfiguration clientEndpointConfig) {
    self.mongodbClient = createMongoDBClient(clientEndpointConfig);
}

public type ClientEndpointConfiguration {
    string host,
    string dbName,
    string username,
    string password,
    ConnectionProperties options,
};

public type ConnectionProperties {
    string url,
    string readConcern,
    string writeConcern,
    string readPreference,
    string authSource,
    string authMechanism,
    string gssapiServiceName,
    boolean sslEnabled,
    boolean sslInvalidHostNameAllowed,
    int socketTimeout = -1,
    int connectionTimeout = -1,
    int maxPoolSize = -1,
    int serverSelectionTimeout = -1,
    int maxIdleTime = -1,
    int maxLifeTime = -1,
    int minPoolSize = -1,
    int waitQueueMultiple = -1,
    int waitQueueTimeout = -1,
    int localThreshold = -1,
    int heartbeatFrequency = -1,
};


