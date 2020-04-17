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

package org.wso2.mongo;

import com.mongodb.AuthenticationMechanism;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientOptions;
import com.mongodb.MongoClientURI;
import com.mongodb.MongoCredential;
import com.mongodb.MongoException;
import com.mongodb.ReadConcern;
import com.mongodb.ReadConcernLevel;
import com.mongodb.ReadPreference;
import com.mongodb.ServerAddress;
import com.mongodb.WriteConcern;
import com.mongodb.client.MongoCursor;
import org.ballerinalang.jvm.values.HandleValue;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.jvm.values.api.BString;
import org.ballerinalang.jvm.values.api.BValueCreator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.mongo.exceptions.BallerinaErrorGenerator;
import org.wso2.mongo.exceptions.MongoDBClientException;

import java.util.ArrayList;
import java.util.Locale;

/**
 * Java implementation of MongoDB datasource.
 */
public class MongoDBDataSourceUtil {
    private static Logger log = LoggerFactory.getLogger(MongoDBDataSourceUtil.class);

    private MongoDBDataSourceUtil() {
    }

    public static Object initClient(MapValue config) {
        String host = config.getStringValue("host");
        long port = config.getIntValue("port");
        String username = config.getStringValue("userName");
        String password = config.getStringValue("password");
        MapValue options = config.getMapValue("options");

        try {
            return init(host, port, username, password, options);
        } catch (MongoDBClientException e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object getDatabasesNames(HandleValue datasource) {
        MongoClient mongoClient = (MongoClient) datasource.getValue();
        try {
            MongoCursor<String> databaseItr = mongoClient.listDatabaseNames().iterator();
            ArrayList<String> databaseNames = new ArrayList<>();
            while (databaseItr.hasNext()) {
                databaseNames.add(databaseItr.next());
            }
            return BValueCreator.createArrayValue(databaseNames.toArray(new String[0]));
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        }
    }

    public static Object getDatabase(HandleValue datasource, BString databaseName) {

        MongoClient mongoClient = (MongoClient) datasource.getValue();
        try {
            return mongoClient.getDatabase(databaseName.getValue());
        } catch (IllegalArgumentException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        }

    }

    public static void close(HandleValue datasource) {
        log.debug("Closing mongodb connection");
        MongoClient mongoClient = (MongoClient) datasource.getValue();
        mongoClient.close();
    }

    public static MongoClient init(String host, long port, String username, String password, MapValue options) {
        MongoCredential mongoCredential = createCredentials(username, password, options);
        String directURL = options.getStringValue(ConnectionParam.URL.getKey());

        //URL in options overrides host and port config
        if (!directURL.isEmpty()) {
            try {
                return new MongoClient(new MongoClientURI(directURL));
            } catch (IllegalArgumentException e) {
                throw new MongoDBClientException("'" + directURL + "' is not a valid MongoDB connection URI");
            }
        }

        ServerAddress serverAddress = new ServerAddress(host, (int) port);
        if (mongoCredential != null) {
            return new MongoClient(serverAddress, mongoCredential, createOptions(options));
        }
        return new MongoClient(serverAddress, createOptions(options));
    }

    /**
     * Creates and returns MongoCredential object provided the options.
     *
     * @param options BStruct containing options for MongoCredential creation
     * @return MongoCredential
     */
    private static MongoCredential createCredentials(String username, String password, MapValue options) {
        String authSource = options.getStringValue(ConnectionParam.AUTHSOURCE.getKey());

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
                case SCRAM_SHA_256:
                    mongoCredential = MongoCredential.createScramSha256Credential(username, authSource,
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
                    throw new MongoDBClientException("Functionality for \"" + authMechanism
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
    private static AuthenticationMechanism retrieveAuthMechanism(String authMechanismParam) {
        try {
            return AuthenticationMechanism.fromMechanismName(authMechanismParam.toUpperCase(Locale.ENGLISH));
        } catch (IllegalArgumentException e) {
            throw new MongoDBClientException("Invalid authentication mechanism: " + authMechanismParam);
        }
    }

    private static MongoClientOptions createOptions(MapValue options) {
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
        int serverSelectionTimeout = options.getIntValue(ConnectionParam.SERVER_SELECTION_TIMEOUT.getKey())
                .intValue();
        if (serverSelectionTimeout != -1) {
            builder = builder.serverSelectionTimeout(serverSelectionTimeout);
        }
        int maxIdleTime = options.getIntValue(ConnectionParam.MAX_IDLE_TIME.getKey()).intValue();
        if (maxIdleTime != -1) {
            builder = builder.maxConnectionIdleTime(maxIdleTime);
        }
        int maxLifeTime = options.getIntValue(ConnectionParam.MAX_LIFE_TIME.getKey()).intValue();
        if (maxLifeTime != -1) {
            builder = builder.maxConnectionLifeTime(maxLifeTime);
        }
        int minPoolSize = options.getIntValue(ConnectionParam.MIN_POOL_SIZE.getKey()).intValue();
        if (maxPoolSize != -1) {
            builder = builder.minConnectionsPerHost(minPoolSize);
        }
        int waitQueueMultiple = options.getIntValue(ConnectionParam.WAIT_QUEUE_MULTIPLE.getKey()).intValue();
        if (waitQueueMultiple != -1) {
            builder = builder.threadsAllowedToBlockForConnectionMultiplier(waitQueueMultiple);
        }
        int waitQueueTimeout = options.getIntValue(ConnectionParam.WAIT_QUEUE_TIMEOUT.getKey()).intValue();
        if (waitQueueTimeout != -1) {
            builder = builder.maxWaitTime(waitQueueTimeout);
        }
        int localThreshold = options.getIntValue(ConnectionParam.LOCAL_THRESHOLD.getKey()).intValue();
        if (localThreshold != -1) {
            builder = builder.localThreshold(localThreshold);
        }
        int heartbeatFrequency = options.getIntValue(ConnectionParam.HEART_BEAT_FREQUENCY.getKey()).intValue();
        if (heartbeatFrequency != -1) {
            builder = builder.heartbeatFrequency(heartbeatFrequency);
        }
        return builder.build();
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

