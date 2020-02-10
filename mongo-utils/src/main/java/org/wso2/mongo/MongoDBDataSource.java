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

package org.wso2.mongo;

import com.mongodb.AuthenticationMechanism;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientOptions;
import com.mongodb.MongoClientURI;
import com.mongodb.MongoCredential;
import com.mongodb.ReadConcern;
import com.mongodb.ReadConcernLevel;
import com.mongodb.ReadPreference;
import com.mongodb.ServerAddress;
import com.mongodb.WriteConcern;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import org.ballerinalang.jvm.JSONDataSource;
import org.ballerinalang.jvm.JSONGenerator;
import org.ballerinalang.jvm.JSONParser;
import org.ballerinalang.jvm.types.BArrayType;
import org.ballerinalang.jvm.types.BMapType;
import org.ballerinalang.jvm.types.BTypes;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.jvm.values.api.BArray;
import org.ballerinalang.jvm.values.api.BValueCreator;
import org.bson.Document;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MongoDBDataSource {
    private MongoDatabase db;
    private MongoClient client;

    private static final String DEFAULT_USER_DB = "admin";

    public MongoDBDataSource() {}

    public MongoDatabase getMongoDatabase() {
        return db;
    }

    public MongoClient getMongoClient() {
        return client;
    }

    public boolean init(String host, String dbName, String username, String password, MapValue options) {
        if (options != null) {
            String directURL = options.getStringValue(ConnectionParam.URL.getKey());
            if (!directURL.isEmpty()) {
                client = createMongoClient(directURL);
            } else {
                MongoCredential mongoCredential = createCredentials(username, password, options);
                if (mongoCredential != null) {
                    this.client = createMongoClient(host, options, mongoCredential);
                } else {
                    this.client = createMongoClient(host, options);
                }
            }
        } else {
            ServerAddress serverAddress = this.createServerAddress(host);
            this.client = createMongoClient(serverAddress);
        }

        this.db = this.client.getDatabase(dbName);
        return true;
    }

    /**
     * Creates and returns a MongoClient provided the host and options.
     *
     * @param host    The host MongoDB is running on
     * @param options BStruct containing options for MongoClient creation
     * @return MongoClient
     */
    private MongoClient createMongoClient(String host, MapValue options) {
        return new MongoClient(this.createServerAddresses(host), this.createOptions(options));
    }

    /**
     * Creates and returns a MongoClient provided the host, options and MongoCredentials.
     *
     * @param host            he host MongoDB is running on
     * @param options         MapValue containing options for MongoClient creation
     * @param mongoCredential MongoCredential object created with desired auth-mechanism
     * @return MongoClient
     */
    private MongoClient createMongoClient(String host, MapValue options, MongoCredential mongoCredential) {
        List<MongoCredential> credentials = new ArrayList<>();
        credentials.add(mongoCredential);
        return new MongoClient(this.createServerAddresses(host), credentials, this.createOptions(options));
    }

    /**
     * Creates and returns a MongoClient provided the direct URL string.
     *
     * @param url Connection String
     * @return MongoClient
     */
    private MongoClient createMongoClient(String url) {
        try {
            return new MongoClient(new MongoClientURI(url));
        } catch (IllegalArgumentException e) {
            throw new BallerinaMongoDbException(url + " is not a valid MongoDB connection URI");
        }
    }

    /**
     * Creates and returns a MongoClient provided the server address.
     *
     * @param serverAddress ServerAddress object created using host(s), port(s)
     * @return
     */
    private MongoClient createMongoClient(ServerAddress serverAddress) {
        return new MongoClient(serverAddress);
    }

    /**
     * Creates and returns MongoCredential object provided the options.
     *
     * @param options BStruct containing options for MongoCredential creation
     * @return MongoCredential
     */
    private MongoCredential createCredentials(String username, String password, MapValue options) {
        String authSource = options.getStringValue(ConnectionParam.AUTHSOURCE.getKey());
        if (authSource.isEmpty()) {
            authSource = DEFAULT_USER_DB;
        }
        String authMechanismString = options.getStringValue(ConnectionParam.AUTHMECHANISM.getKey());
        MongoCredential mongoCredential = null;
        if (!authMechanismString.isEmpty()) {
            AuthenticationMechanism authMechanism = retrieveAuthMechanism(authMechanismString);
            switch (authMechanism) {
                case PLAIN:
                    mongoCredential = MongoCredential.createPlainCredential(username, authSource,
                                                                                         password.toCharArray());
                    break;
                case SCRAM_SHA_1:
                    mongoCredential = MongoCredential.createScramSha1Credential(username, authSource,
                                                                                         password.toCharArray());
                    break;
                case MONGODB_CR:
                    mongoCredential = MongoCredential.createMongoCRCredential(username, authSource,
                                                                                         password.toCharArray());
                    break;
                case MONGODB_X509:
                    if (!username.isEmpty()) {
                        mongoCredential = MongoCredential.createMongoX509Credential(username);
                    } else {
                        mongoCredential = MongoCredential.createMongoX509Credential();
                    }
                    break;
                case GSSAPI:
                    String gssApiServiceName = options.getStringValue(ConnectionParam.GSSAPI_SERVICE_NAME.getKey());
                    mongoCredential = MongoCredential.createGSSAPICredential(username);
                    if (!gssApiServiceName.isEmpty()) {
                        mongoCredential = mongoCredential.withMechanismProperty("SERVICE_NAME", gssApiServiceName);
                    }
                    break;
                default:
                    throw new UnsupportedOperationException("Functionality for \"" + authMechanism
                                                            + "\" authentication mechanism is not implemented yet");
            }
        } else if (username != null && !username.isEmpty() && password != null && !password.isEmpty()) {
            mongoCredential = MongoCredential.createCredential(username, authSource, password.toCharArray());
        }
        return mongoCredential;
    }

    /**
     * Retrieves the matching AuthenticationMechanism provided the authentication mechanism parameter.
     *
     * @param authMechanismParam authentication mechanism parameter string
     * @return AuthenticationMechanism
     */
    private AuthenticationMechanism retrieveAuthMechanism(String authMechanismParam) {
        try {
            return AuthenticationMechanism.fromMechanismName(authMechanismParam.toUpperCase(Locale.ENGLISH));
        } catch (IllegalArgumentException e) {
            throw new BallerinaMongoDbException("Invalid authentication mechanism: " + authMechanismParam);
        }
    }

    private MongoClientOptions createOptions(MapValue options) {
        MongoClientOptions.Builder builder = MongoClientOptions.builder();
        boolean sslEnabled = options.getBooleanValue(ConnectionParam.SSL_ENABLED.getKey());
        if (sslEnabled) {
            builder = builder.sslEnabled(true);
        }
        boolean sslInvalidHostNameAllowed = options.getBooleanValue(ConnectionParam.SSL_INVALID_HOSTNAME_ALLOWED
                                                                                                         .getKey());
        if (sslInvalidHostNameAllowed) {
            builder.sslInvalidHostNameAllowed(true);
        }
        builder.retryWrites(options.getBooleanValue(ConnectionParam.RETRY_WRITES.getKey()));
        String readConcern = options.getStringValue(ConnectionParam.READ_CONCERN.getKey());
        if (!readConcern.isEmpty()) {
            builder = builder.readConcern(new ReadConcern(ReadConcernLevel.valueOf(readConcern)));
        }
        String writeConsern = options.getStringValue(ConnectionParam.WRITE_CONCERN.getKey());
        if (!writeConsern.isEmpty()) {
            builder = builder.writeConcern(WriteConcern.valueOf(writeConsern));
        }
        String readPreference = options.getStringValue(ConnectionParam.READ_PREFERENCE.getKey());
        if (!readPreference.isEmpty()) {
            builder = builder.readPreference((ReadPreference.valueOf(readPreference)));
        }
        String replicaSet = options.getStringValue(ConnectionParam.REPLICA_SET.getKey());
        if (!replicaSet.isEmpty()) {
            builder = builder.requiredReplicaSetName(replicaSet);
        }
        int socketTimeout = options.getIntValue(ConnectionParam.SOCKET_TIMEOUT.getKey()).intValue();
        if (socketTimeout != -1) {
            builder = builder.socketTimeout(socketTimeout);
        }
        int connectionTimeout = options.getIntValue(ConnectionParam.CONNECTION_TIMEOUT.getKey()).intValue();
        if (connectionTimeout != -1) {
            builder = builder.connectTimeout(connectionTimeout);
        }
        int maxPoolSize = options.getIntValue(ConnectionParam.MAX_POOL_SIZE.getKey()).intValue();
        if (maxPoolSize != -1) {
            builder = builder.connectionsPerHost(maxPoolSize);
        }
        int serverSelectionTimeout = (int) options.getIntValue(ConnectionParam.SERVER_SELECTION_TIMEOUT.getKey())
                                                                                                        .intValue();
        if (serverSelectionTimeout != -1) {
            builder = builder.serverSelectionTimeout(serverSelectionTimeout);
        }
        int maxIdleTime = (int) options.getIntValue(ConnectionParam.MAX_IDLE_TIME.getKey()).intValue();
        if (maxIdleTime != -1) {
            builder = builder.maxConnectionIdleTime(maxIdleTime);
        }
        int maxLifeTime = (int) options.getIntValue(ConnectionParam.MAX_LIFE_TIME.getKey()).intValue();
        if (maxLifeTime != -1) {
            builder = builder.maxConnectionLifeTime(maxLifeTime);
        }
        int minPoolSize = (int) options.getIntValue(ConnectionParam.MIN_POOL_SIZE.getKey()).intValue();
        if (maxPoolSize != -1) {
            builder = builder.minConnectionsPerHost(minPoolSize);
        }
        int waitQueueMultiple = (int) options.getIntValue(ConnectionParam.WAIT_QUEUE_MULTIPLE.getKey()).intValue();
        if (waitQueueMultiple != -1) {
            builder = builder.threadsAllowedToBlockForConnectionMultiplier(waitQueueMultiple);
        }
        int waitQueueTimeout = (int) options.getIntValue(ConnectionParam.WAIT_QUEUE_TIMEOUT.getKey()).intValue();
        if (waitQueueTimeout != -1) {
            builder = builder.maxWaitTime(waitQueueTimeout);
        }
        int localThreshold = (int) options.getIntValue(ConnectionParam.LOCAL_THRESHOLD.getKey()).intValue();
        if (localThreshold != -1) {
            builder = builder.localThreshold(localThreshold);
        }
        int heartbeatFrequency = (int) options.getIntValue(ConnectionParam.HEART_BEAT_FREQUENCY.getKey()).intValue();
        if (heartbeatFrequency != -1) {
            builder = builder.heartbeatFrequency(heartbeatFrequency);
        }
        return builder.build();
    }

    private List<ServerAddress> createServerAddresses(String hostStr) {
        List<ServerAddress> result = new ArrayList<>();
        String[] hosts = hostStr.split(",");
        for (String host : hosts) {
            result.add(this.createServerAddress(host));
        }
        return result;
    }

    private ServerAddress createServerAddress(String hostStr) {
        String[] hostPort = hostStr.split(":");
        String host = hostPort[0];
        int port;
        if (hostPort.length > 1) {
            try {
                port = Integer.parseInt(hostPort[1]);
            } catch (NumberFormatException e) {
                throw new BallerinaMongoDbException("the port of the host string must be an integer: " + hostStr, e);
            }
        } else {
            port = ServerAddress.defaultPort();
        }
        return new ServerAddress(host, port);
    }

    /**
     * MongoDB result cursor implementation.
     */
    public static class MongoJSONDataSource implements JSONDataSource {

        private MongoCursor<Document> mc;

        public MongoJSONDataSource(MongoCursor<Document> mc) {
            this.mc = mc;
        }

        @Override
        public void serialize(JSONGenerator jsonGenerator) throws IOException {
            jsonGenerator.writeStartArray();
            while (this.hasNext()) {
                jsonGenerator.serialize(this.next());
            }
            jsonGenerator.writeEndArray();
        }

        @Override
        public boolean hasNext() {
            return mc.hasNext();
        }

        @Override
        public Object next() {
            return JSONParser.parse(this.mc.next().toJson());
        }

        @Override
        public Object build() {
            BArray values = BValueCreator.createArrayValue(new Object[]{},
                                                           new BArrayType(new BMapType(BTypes.typeJSON)));
            while (this.hasNext()) {
                values.append(this.next());
            }
            return values;
        }
    }

    /**
     * Enum for connection parameter indices.
     */
    private enum ConnectionParam {
        // String Params
        URL("url"), READ_CONCERN("readConcern"), WRITE_CONCERN("writeConcern"), READ_PREFERENCE("readPreference"),
        AUTHSOURCE("authSource"), AUTHMECHANISM("authMechanism"), GSSAPI_SERVICE_NAME("gssapiServiceName"),
                                                                                        REPLICA_SET("replicaSet"),

        // boolean params
        SSL_ENABLED("sslEnabled"), SSL_INVALID_HOSTNAME_ALLOWED("sslInvalidHostNameAllowed"),
                                                                                          RETRY_WRITES("retryWrites"),

        // int params
        SOCKET_TIMEOUT("socketTimeout"), CONNECTION_TIMEOUT("connectionTimeout"), MAX_POOL_SIZE("maxPoolSize"),
        SERVER_SELECTION_TIMEOUT("serverSelectionTimeout"), MAX_IDLE_TIME("maxIdleTime"), MAX_LIFE_TIME("maxLifeTime"),
        MIN_POOL_SIZE("minPoolSize"), WAIT_QUEUE_MULTIPLE("waitQueueMultiple"), WAIT_QUEUE_TIMEOUT("waitQueueTimeout"),
                                       LOCAL_THRESHOLD("localThreshold"), HEART_BEAT_FREQUENCY("heartbeatFrequency");

        private String key;

        ConnectionParam(String key) {
            this.key = key;
        }

        private String getKey() {
            return key;
        }
    }
}

