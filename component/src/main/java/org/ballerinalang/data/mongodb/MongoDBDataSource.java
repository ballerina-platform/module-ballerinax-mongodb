/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.data.mongodb;

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
import org.ballerinalang.model.types.BType;
import org.ballerinalang.model.util.JsonGenerator;
import org.ballerinalang.model.util.JsonParser;
import org.ballerinalang.model.values.BJSON;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.util.exceptions.BallerinaException;
import org.bson.Document;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * {@code MongoDBDataSource} util class for MongoDB connector initialization.
 *
 * @since 0.95.0
 */
public class MongoDBDataSource implements BValue {
    private MongoDatabase db;
    private MongoClient client;

    private static final String DEFAULT_USER_DB = "admin";


    public MongoDBDataSource() {
    }

    public MongoDatabase getMongoDatabase() {
        return db;
    }

    public MongoClient getMongoClient() {
        return client;
    }

    public boolean init(String host, String dbName, String username, String password, BStruct options) {
        if (options != null) {
            String directURL = options.getStringField(ConnectionParam.URL.getIndex());
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
     * @param host The host MongoDB is running on
     * @param options BStruct containing options for MongoClient creation
     * @return MongoClient
     */
    private MongoClient createMongoClient(String host, BStruct options) {
        return new MongoClient(this.createServerAddresses(host), this.createOptions(options));
    }

    /**
     * Creates and returns a MongoClient provided the host, options and MongoCredentials.
     *
     * @param host he host MongoDB is running on
     * @param options BStruct containing options for MongoClient creation
     * @param mongoCredential MongoCredential object created with desired auth-mechanism
     * @return MongoClient
     */
    private MongoClient createMongoClient(String host, BStruct options, MongoCredential mongoCredential) {
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
            throw new BallerinaException(url + " is not a valid MongoDB connection URI");
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
    private MongoCredential createCredentials(String username, String password, BStruct options) {
        String authSource = options.getStringField(ConnectionParam.AUTHSOURCE.getIndex());
        if (authSource.isEmpty()) {
            authSource = DEFAULT_USER_DB;
        }
        String authMechanismString = options.getStringField(ConnectionParam.AUTHMECHANISM.getIndex());
        MongoCredential mongoCredential = null;
        if (!authMechanismString.isEmpty()) {
            AuthenticationMechanism authMechanism = retrieveAuthMechanism(authMechanismString);
            switch (authMechanism) {
            case PLAIN:
                mongoCredential = MongoCredential.createPlainCredential(username, authSource, password.toCharArray());
                break;
            case SCRAM_SHA_1:
                mongoCredential = MongoCredential
                        .createScramSha1Credential(username, authSource, password.toCharArray());
                break;
            case MONGODB_CR:
                mongoCredential = MongoCredential.createMongoCRCredential(username, authSource, password.toCharArray());
                break;
            case MONGODB_X509:
                if (!username.isEmpty()) {
                    mongoCredential = MongoCredential.createMongoX509Credential(username);
                } else {
                    mongoCredential = MongoCredential.createMongoX509Credential();
                }
                break;
            case GSSAPI:
                String gssApiServiceName = options.getStringField(ConnectionParam.GSSAPI_SERVICE_NAME.getIndex());
                mongoCredential = MongoCredential.createGSSAPICredential(username);
                if (!gssApiServiceName.isEmpty()) {
                    mongoCredential = mongoCredential.withMechanismProperty("SERVICE_NAME", gssApiServiceName);
                }
                break;
            default:
                throw new UnsupportedOperationException(
                        "Functionality for \"" + authMechanism + "\" authentication mechanism is not implemented yet");
            }
        } else if (!username.isEmpty() && !password.isEmpty()) {
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
            return AuthenticationMechanism
                    .fromMechanismName(authMechanismParam.toUpperCase(Locale.ENGLISH));
        } catch (IllegalArgumentException e) {
            throw new BallerinaException("Invalid authentication mechanism: " + authMechanismParam);
        }
    }

    private MongoClientOptions createOptions(BStruct options) {
        MongoClientOptions.Builder builder = MongoClientOptions.builder();
        boolean sslEnabled = options.getBooleanField(ConnectionParam.SSL_ENABLED.getIndex()) != 0;
        if (sslEnabled) {
            builder = builder.sslEnabled(true);
        }
        boolean sslInvalidHostNameAllowed = options.getBooleanField(ConnectionParam
                .SSL_INVALID_HOSTNAME_ALLOWED.getIndex()) != 0;
        if (sslInvalidHostNameAllowed) {
            builder.sslInvalidHostNameAllowed(true);
        }
        String readConcern = options.getStringField(ConnectionParam.READ_CONCERN.getIndex());
        if (!readConcern.isEmpty()) {
            builder = builder.readConcern(new ReadConcern(ReadConcernLevel.valueOf(readConcern)));
        }
        String writeConsern = options.getStringField(ConnectionParam.WRITE_CONCERN.getIndex());
        if (!writeConsern.isEmpty()) {
            builder = builder.writeConcern(WriteConcern.valueOf(writeConsern));
        }
        String readPreference = options.getStringField(ConnectionParam.READ_PREFERENCE.getIndex());
        if (!readPreference.isEmpty()) {
            builder = builder.readPreference((ReadPreference.valueOf(readPreference)));
        }
        int socketTimeout = (int) options.getIntField(ConnectionParam.SOCKET_TIMEOUT.getIndex());
        if (socketTimeout != -1) {
            builder = builder.socketTimeout(socketTimeout);
        }
        int connectionTimeout = (int) options.getIntField(ConnectionParam.CONNECTION_TIMEOUT.getIndex());
        if (connectionTimeout != -1) {
            builder = builder.connectTimeout(connectionTimeout);
        }
        int maxPoolSize = (int) options.getIntField(ConnectionParam.MAX_POOL_SIZE.getIndex());
        if (maxPoolSize != -1) {
            builder = builder.connectionsPerHost(maxPoolSize);
        }
        int serverSelectionTimeout = (int) options.getIntField(ConnectionParam.SERVER_SELECTION_TIMEOUT.getIndex());
        if (serverSelectionTimeout != -1) {
            builder = builder.serverSelectionTimeout(serverSelectionTimeout);
        }
        int maxIdleTime = (int) options.getIntField(ConnectionParam.MAX_IDLE_TIME.getIndex());
        if (maxIdleTime != -1) {
            builder = builder.maxConnectionIdleTime(maxIdleTime);
        }
        int maxLifeTime = (int) options.getIntField(ConnectionParam.MAX_LIFE_TIME.getIndex());
        if (maxLifeTime != -1) {
            builder = builder.maxConnectionLifeTime(maxLifeTime);
        }
        int minPoolSize = (int) options.getIntField(ConnectionParam.MIN_POOL_SIZE.getIndex());
        if (maxPoolSize != -1) {
            builder = builder.minConnectionsPerHost(minPoolSize);
        }
        int waitQueueMultiple = (int) options.getIntField(ConnectionParam.WAIT_QUEUE_MULTIPLE.getIndex());
        if (waitQueueMultiple != -1) {
            builder = builder.threadsAllowedToBlockForConnectionMultiplier(waitQueueMultiple);
        }
        int waitQueueTimeout = (int) options.getIntField(ConnectionParam.WAIT_QUEUE_TIMEOUT.getIndex());
        if (waitQueueTimeout != -1) {
            builder = builder.maxWaitTime(waitQueueTimeout);
        }
        int localThreshold = (int) options.getIntField(ConnectionParam.LOCAL_THRESHOLD.getIndex());
        if (localThreshold != -1) {
            builder = builder.localThreshold(localThreshold);
        }
        int heartbeatFrequency = (int) options.getIntField(ConnectionParam.HEART_BEAT_FREQUENCY.getIndex());
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
                port = Integer.parseInt(hostPort[2]);
            } catch (NumberFormatException e) {
                throw new BallerinaException("the port of the host string must be an integer: " + hostStr, e);
            }
        } else {
            port = ServerAddress.defaultPort();
        }
        return new ServerAddress(host, port);
    }

    @Override
    public String stringValue() {
        return null;
    }

    @Override
    public BType getType() {
        return null;
    }

    @Override
    public BValue copy() {
        return null;
    }

    /**
     * MongoDB result cursor implementation of {@link BJSON}.
     */
    public static class MongoJSONDataSource implements BJSON.JSONDataSource {

        private MongoCursor<Document> mc;

        public MongoJSONDataSource(MongoCursor<Document> mc) {
            this.mc = mc;
        }

        @Override
        public void serialize(JsonGenerator jsonGenerator) throws IOException {
            jsonGenerator.writeStartArray();
            while (this.mc.hasNext()) {
                JsonParser.parse(this.mc.next().toJson()).serialize(jsonGenerator);
            }
            jsonGenerator.writeEndArray();
        }
    }

    /**
     * Enum for connection parameter indices.
     */
    private enum ConnectionParam {
        // String Params
        URL(0),
        READ_CONCERN(1),
        WRITE_CONCERN(2),
        READ_PREFERENCE(3),
        AUTHSOURCE(4),
        AUTHMECHANISM(5),
        GSSAPI_SERVICE_NAME(6),

        // boolean params
        SSL_ENABLED(0),
        SSL_INVALID_HOSTNAME_ALLOWED(1),

        // int params
        SOCKET_TIMEOUT(0),
        CONNECTION_TIMEOUT(1),
        MAX_POOL_SIZE(2),
        SERVER_SELECTION_TIMEOUT(3),
        MAX_IDLE_TIME(4),
        MAX_LIFE_TIME(5),
        MIN_POOL_SIZE(6),
        WAIT_QUEUE_MULTIPLE(7),
        WAIT_QUEUE_TIMEOUT(8),
        LOCAL_THRESHOLD(9),
        HEART_BEAT_FREQUENCY(10);

        private int index;

        ConnectionParam(int index) {
            this.index = index;
        }

        private int getIndex() {
            return index;
        }
    }
}
