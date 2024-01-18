/*
 * Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org)
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.mongodb;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.ReadConcern;
import com.mongodb.ReadConcernLevel;
import com.mongodb.ReadPreference;
import com.mongodb.ServerAddress;
import com.mongodb.WriteConcern;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoIterable;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BValue;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.SSLContext;

import static io.ballerina.lib.mongodb.Utils.MONGO_CLIENT;
import static io.ballerina.lib.mongodb.Utils.createError;

/**
 * Native methods related to the Ballerina MongoDB client.
 */
public final class Client {

    private Client() {
    }

    @SuppressWarnings("unchecked")
    public static BError initClient(BObject client, Object connection, Object options) {
        try {
            MongoClientSettings.Builder settingsBuilder = MongoClientSettings.builder();
            if (options != null) {
                addSettings(settingsBuilder, (BMap<BString, Object>) options);
            }
            if (connection instanceof BString) {
                String url = ((BString) connection).getValue();
                settingsBuilder.applyConnectionString(new ConnectionString(url));
            } else {
                BMap<BString, Object> configs = (BMap<BString, Object>) connection;
                addAuthSettings(settingsBuilder, (BMap<BString, Object>) configs.getMapValue(RecordField.AUTH));
                addServerAddressSettings(settingsBuilder, (BValue) configs.get(RecordField.SERVER_ADDRESS));
            }
            MongoClient mongoClient = MongoClients.create(settingsBuilder.build());
            client.addNativeData(MONGO_CLIENT, mongoClient);
        } catch (Exception e) {
            String errorMessage = "Error occurred while initializing the MongoDB client.";
            return createError(e, errorMessage);
        }
        return null;
    }

    public static Object listDatabaseNames(BObject client) {
        MongoClient mongoClient = (MongoClient) client.getNativeData(MONGO_CLIENT);
        try {
            MongoIterable<String> databaseNames = mongoClient.listDatabaseNames();
            BArray result = ValueCreator.createArrayValue(TypeCreator.createArrayType(PredefinedTypes.TYPE_STRING));
            for (String databaseName : databaseNames) {
                result.append(StringUtils.fromString(databaseName));
            }
            return result;
        } catch (Exception e) {
            String errorMessage = "Error occurred while retrieving database names.";
            return createError(e, errorMessage);
        }
    }

    public static BError close(BObject client) {
        try {
            MongoClient mongoClient = (MongoClient) client.getNativeData(MONGO_CLIENT);
            mongoClient.close();
            return null;
        } catch (Exception e) {
            String errorMessage = "Error occurred while closing the MongoDB client.";
            return createError(e, errorMessage);
        }
    }

    @SuppressWarnings("unchecked")
    private static void addSettings(MongoClientSettings.Builder settingsBuilder, BMap<BString, Object> options) {
        if (options.getBooleanValue(RecordField.SSL_ENABLED)) {
            BMap<BString, Object> secureSocket =
                    (BMap<BString, Object>) options.getMapValue(RecordField.SECURE_SOCKET);
            SSLContext sslContext = SslUtils.initializeSSLContext(secureSocket);
            settingsBuilder.applyToSslSettings(builder -> builder.enabled(true).context(sslContext));
        }
        if (options.getStringValue(RecordField.READ_CONCERN) != null) {
            String readConcern = options.getStringValue(RecordField.READ_CONCERN).getValue();
            settingsBuilder.readConcern(new ReadConcern(ReadConcernLevel.fromString(readConcern)));
        }
        if (options.getStringValue(RecordField.WRITE_CONCERN) != null) {
            String writeConcern = options.getStringValue(RecordField.WRITE_CONCERN).getValue();
            settingsBuilder.writeConcern(new WriteConcern(writeConcern));
        }
        if (options.getStringValue(RecordField.READ_PREFERENCE) != null) {
            String readPreference = options.getStringValue(RecordField.READ_PREFERENCE).getValue();
            settingsBuilder.readPreference(ReadPreference.valueOf(readPreference));
        }
        if (options.getBooleanValue(RecordField.RETRY_WRITES) != null) {
            settingsBuilder.retryWrites(options.getBooleanValue(RecordField.RETRY_WRITES));
        }
        if (options.getIntValue(RecordField.SOCKET_TIMEOUT) != null) {
            int socketTimeout = options.getIntValue(RecordField.SOCKET_TIMEOUT).intValue();
            settingsBuilder.applyToSocketSettings(builder -> builder.connectTimeout(socketTimeout,
                    TimeUnit.MILLISECONDS));
        }
        if (options.getIntValue(RecordField.CONNECTION_TIMEOUT) != null) {
            int connectionTimeout = options.getIntValue(RecordField.CONNECTION_TIMEOUT).intValue();
            settingsBuilder.applyToSocketSettings(builder -> builder.connectTimeout(connectionTimeout,
                    TimeUnit.MILLISECONDS));
        }
        if (options.getIntValue(RecordField.LOCAL_THRESHOLD) != null) {
            int localThreshold = options.getIntValue(RecordField.LOCAL_THRESHOLD).intValue();
            settingsBuilder.applyToClusterSettings(builder -> builder.localThreshold(localThreshold,
                    TimeUnit.MILLISECONDS));
        }
        if (options.getStringValue(RecordField.REPLICA_SET) != null) {
            String replicaSet = options.getStringValue(RecordField.REPLICA_SET).getValue();
            settingsBuilder.applyToClusterSettings(builder -> builder.requiredReplicaSetName(replicaSet));
        }
        if (options.getIntValue(RecordField.HEART_BEAT_FREQUENCY) != null) {
            int heartbeatFrequency = options.getIntValue(RecordField.HEART_BEAT_FREQUENCY).intValue();
            settingsBuilder.applyToServerSettings(builder -> builder.heartbeatFrequency(heartbeatFrequency,
                    TimeUnit.MILLISECONDS));
        }
        if (options.getIntValue(RecordField.MAX_POOL_SIZE) != null) {
            int maxPoolSize = options.getIntValue(RecordField.MAX_POOL_SIZE).intValue();
            settingsBuilder.applyToConnectionPoolSettings(builder -> builder.maxSize(maxPoolSize));
        }
        if (options.getIntValue(RecordField.MAX_IDLE_TIME) != null) {
            int maxIdleTime = options.getIntValue(RecordField.MAX_IDLE_TIME).intValue();
            settingsBuilder.applyToConnectionPoolSettings(builder -> builder.maxConnectionIdleTime(maxIdleTime,
                    TimeUnit.MILLISECONDS));
        }
        if (options.getIntValue(RecordField.MAX_LIFE_TIME) != null) {
            int maxLifeTime = options.getIntValue(RecordField.MAX_LIFE_TIME).intValue();
            settingsBuilder.applyToConnectionPoolSettings(builder -> builder.maxConnectionLifeTime(maxLifeTime,
                    TimeUnit.MILLISECONDS));
        }
        if (options.getIntValue(RecordField.MIN_POOL_SIZE) != null) {
            int minPoolSize = options.getIntValue(RecordField.MIN_POOL_SIZE).intValue();
            settingsBuilder.applyToConnectionPoolSettings(builder -> builder.minSize(minPoolSize));
        }
    }

    private static void addAuthSettings(MongoClientSettings.Builder settingsBuilder, BMap<BString, Object> auth) {
        if (auth == null) {
            return;
        }
        settingsBuilder.credential(AuthUtils.getMongoCredential(auth));
    }

    private static void addServerAddressSettings(MongoClientSettings.Builder settingsBuilder, BValue addressConfig) {
        List<ServerAddress> serverAddressList = new ArrayList<>();
        if (addressConfig.getType().getTag() == TypeTags.ARRAY_TAG) {
            BArray serverAddresses = (BArray) addressConfig;
            for (int i = 0; i < serverAddresses.size(); i++) {
                BMap<BString, Object> server = (BMap<BString, Object>) serverAddresses.get(i);
                serverAddressList.add(getServerAddress(server));
            }
        } else {
            BMap<BString, Object> serverAddress = (BMap<BString, Object>) addressConfig;
            serverAddressList.add(getServerAddress(serverAddress));
        }
        settingsBuilder.applyToClusterSettings(builder -> builder.hosts(serverAddressList));
    }

    private static ServerAddress getServerAddress(BMap<BString, Object> serverAddress) {
        String host = serverAddress.getStringValue(RecordField.HOST).getValue();
        int port = serverAddress.getIntValue(RecordField.PORT).intValue();
        return new ServerAddress(host, port);
    }

    /**
     * Constants related to MongoDB client configs.
     */
    static class RecordField {
        static final BString SERVER_ADDRESS = StringUtils.fromString("serverAddress");
        static final BString AUTH = StringUtils.fromString("auth");
        static final BString HOST = StringUtils.fromString("host");
        static final BString PORT = StringUtils.fromString("port");
        static final BString MONGODB_EXCEPTION_TYPE = StringUtils.fromString("mongoDBExceptionType");
        static final BString AUTH_MECHANISM = StringUtils.fromString("authMechanism");
        static final BString SSL_ENABLED = StringUtils.fromString("sslEnabled");
        static final BString SECURE_SOCKET = StringUtils.fromString("secureSocket");
        static final BString READ_CONCERN = StringUtils.fromString("readConcern");
        static final BString WRITE_CONCERN = StringUtils.fromString("writeConcern");
        static final BString READ_PREFERENCE = StringUtils.fromString("readPreference");
        static final BString REPLICA_SET = StringUtils.fromString("replicaSet");
        static final BString RETRY_WRITES = StringUtils.fromString("retryWrites");
        static final BString SOCKET_TIMEOUT = StringUtils.fromString("socketTimeout");
        static final BString CONNECTION_TIMEOUT = StringUtils.fromString("connectionTimeout");
        static final BString MAX_POOL_SIZE = StringUtils.fromString("maxPoolSize");
        static final BString MAX_IDLE_TIME = StringUtils.fromString("maxIdleTime");
        static final BString MAX_LIFE_TIME = StringUtils.fromString("maxLifeTime");
        static final BString MIN_POOL_SIZE = StringUtils.fromString("minPoolSize");
        static final BString LOCAL_THRESHOLD = StringUtils.fromString("localThreshold");
        static final BString HEART_BEAT_FREQUENCY = StringUtils.fromString("heartbeatFrequency");
    }
}
