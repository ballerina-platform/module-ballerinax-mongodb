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

package org.ballerinalang.mongodb;

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
import com.mongodb.client.MongoDatabase;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.ballerinalang.mongodb.exceptions.BallerinaErrorGenerator;
import org.ballerinalang.mongodb.exceptions.MongoDBClientException;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.util.ArrayList;
import java.util.Locale;
import javax.net.ssl.KeyManager;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * Java implementation of MongoDB datasource.
 */
public class MongoDBDataSourceUtil {
    private static final Logger log = LoggerFactory.getLogger(MongoDBDataSourceUtil.class);

    private static final BString HOST = fromString("host");
    private static final BString PORT = fromString("port");
    private static final BString USERNAME = fromString("username");
    private static final BString PASSWORD = fromString("password");
    private static final BString OPTIONS = fromString("options");

    private MongoDBDataSourceUtil() {
    }

    public static Object initClient(Environment env, BObject client, BMap<BString, BValue> config,
                                    Object databaseName) {
        String host = config.containsKey(HOST) ? config.getStringValue(HOST).getValue() : "";
        long port = config.containsKey(PORT) ? config.getIntValue(PORT) : 0;

        String username = config.containsKey(USERNAME) ? config.getStringValue(USERNAME).getValue() : "";
        String password = config.containsKey(PASSWORD) ? config.getStringValue(PASSWORD).getValue() : "";
        
        BMap options = config.containsKey(OPTIONS) ? config.getMapValue(OPTIONS) : null;

        try {
            MongoClient mongoClient = init(host, port, username, password, options);
            client.addNativeData(MongoDBConstants.MONGO_CLIENT, mongoClient);
            if (databaseName != null && !(MongoDBConstants.EMPTY_STRING.equals(databaseName.toString()))) {
                MongoDatabase database = mongoClient.getDatabase(databaseName.toString());
                client.addNativeData(MongoDBConstants.MONGO_DATABASE, database);
            }
            return null;
        } catch (MongoDBClientException e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object getDatabasesNames(Environment env, BObject client) {
        MongoClient mongoClient = (MongoClient) client.getNativeData(MongoDBConstants.MONGO_CLIENT);
        try {
            MongoCursor<String> databaseItr = mongoClient.listDatabaseNames().iterator();
            ArrayList<BString> databaseNames = new ArrayList<>();
            while (databaseItr.hasNext()) {
                databaseNames.add(fromString(databaseItr.next()));
            }
            return ValueCreator.createArrayValue(databaseNames.toArray(new BString[0]));
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        }
    }

    public static void close(Environment env, BObject client) {
        log.debug("Closing MongoDB connection");
        MongoClient mongoClient = (MongoClient) client.getNativeData(MongoDBConstants.MONGO_CLIENT);
        mongoClient.close();
    }

    public static MongoClient init(String host, long port, String username, String password, BMap options) {
        MongoCredential mongoCredential = createCredentials(username, password, options);
        if (options != null) {
            String directURL = options.containsKey(ConnectionParam.URL.getKey()) ?  
                               options.getStringValue(ConnectionParam.URL.getKey()).getValue() : "";
            //URL in options overrides host and port config
            if (!directURL.isEmpty()) {
                try {
                    return new MongoClient(new MongoClientURI(directURL));
                } catch (IllegalArgumentException e) {
                    throw new MongoDBClientException("'" + directURL + "' is not a valid MongoDB connection URI");
                }
            }
        }

        ServerAddress serverAddress;
        if (!host.isEmpty() && port > 0) {
            serverAddress = new ServerAddress(host, (int) port);
        } else if (!host.isEmpty()) {
            serverAddress = new ServerAddress(host);
        } else {
            serverAddress = new ServerAddress ();
        }    
            
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
    private static MongoCredential createCredentials(String username, String password, BMap options) {
        MongoCredential mongoCredential = null;
        String authSource = "admin";
        String authMechanismString = "";

        if (options != null) {
            authSource = options.containsKey(ConnectionParam.AUTHSOURCE.getKey()) ? 
                                options.getStringValue(ConnectionParam.AUTHSOURCE.getKey()).getValue() : "admin";
            authMechanismString = options.containsKey(ConnectionParam.AUTHMECHANISM.getKey()) ? 
                                          options.getStringValue(ConnectionParam.AUTHMECHANISM.getKey())
                                          .getValue() : ""; 
        }

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
                    mongoCredential = MongoCredential.createGSSAPICredential(username);
                    if (options.containsKey(ConnectionParam.GSSAPI_SERVICE_NAME.getKey())) {
                        mongoCredential = mongoCredential.withMechanismProperty("SERVICE_NAME", 
                                          options.getStringValue(ConnectionParam.GSSAPI_SERVICE_NAME.getKey())
                                          .getValue());
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

    private static MongoClientOptions createOptions(BMap options) {
        MongoClientOptions.Builder builder = MongoClientOptions.builder();
        if (options != null) {
            boolean sslEnabled = options.containsKey(ConnectionParam.SSL_ENABLED.getKey()) ? 
                                options.getBooleanValue(ConnectionParam.SSL_ENABLED.getKey()) : false;
            if (sslEnabled) {
                builder = builder.sslEnabled(true);
                boolean sslInvalidHostNameAllowed = options.containsKey(ConnectionParam.SSL_INVALID_HOSTNAME_ALLOWED
                                .getKey()) ? options.getBooleanValue(ConnectionParam.SSL_INVALID_HOSTNAME_ALLOWED
                                .getKey()) : false;
                if (sslInvalidHostNameAllowed) {
                    builder.sslInvalidHostNameAllowed(true);
                }
                builder.sslContext(initializeSSLContext(options));
            }
            if (options.containsKey(ConnectionParam.RETRY_WRITES.getKey())) {
                builder.retryWrites(options.getBooleanValue(ConnectionParam.RETRY_WRITES.getKey()));
            }
            if (options.containsKey(ConnectionParam.READ_CONCERN.getKey())) {
                String readConcern = options.getStringValue(ConnectionParam.READ_CONCERN.getKey()).getValue();
                if (!readConcern.isEmpty()) {
                    builder = builder.readConcern(new ReadConcern(ReadConcernLevel.valueOf(readConcern)));
                }            
            }
            if (options.containsKey(ConnectionParam.WRITE_CONCERN.getKey())) {
                String writeConcern = options.getStringValue(ConnectionParam.WRITE_CONCERN.getKey()).getValue();
                if (!writeConcern.isEmpty()) {
                    builder = builder.writeConcern(WriteConcern.valueOf(writeConcern));
                }
            }
            
            if (options.containsKey(ConnectionParam.READ_PREFERENCE.getKey())) {
                String readPreference = options.getStringValue(ConnectionParam.READ_PREFERENCE.getKey()).getValue();
                if (!readPreference.isEmpty()) {
                    builder = builder.readPreference((ReadPreference.valueOf(readPreference)));
                }
            }
            if (options.containsKey(ConnectionParam.REPLICA_SET.getKey())) {
                String replicaSet = options.getStringValue(ConnectionParam.REPLICA_SET.getKey()).getValue();
                if (!replicaSet.isEmpty()) {
                    builder = builder.requiredReplicaSetName(replicaSet);
                }
            }
            if (options.containsKey(ConnectionParam.SOCKET_TIMEOUT.getKey())) {
                builder = builder.socketTimeout(options.getIntValue(ConnectionParam.SOCKET_TIMEOUT.getKey())
                          .intValue());
            }
            if (options.containsKey(ConnectionParam.CONNECTION_TIMEOUT.getKey())) {
                builder = builder.connectTimeout(options.getIntValue(ConnectionParam.CONNECTION_TIMEOUT.getKey())
                        .intValue());
            }
            
            if (options.containsKey(ConnectionParam.MAX_POOL_SIZE.getKey())) {
                builder = builder.connectionsPerHost(options.getIntValue(ConnectionParam.MAX_POOL_SIZE.getKey())
                          .intValue());
            }
            
            if (options.containsKey(ConnectionParam.SERVER_SELECTION_TIMEOUT.getKey())) {
                builder = builder.serverSelectionTimeout(options.getIntValue(ConnectionParam.SERVER_SELECTION_TIMEOUT
                        .getKey()).intValue());
            }
            
            if (options.containsKey(ConnectionParam.MAX_IDLE_TIME.getKey())) {
                builder = builder.maxConnectionIdleTime(options.getIntValue(ConnectionParam.MAX_IDLE_TIME.getKey())
                        .intValue());
            }
            
            if (options.containsKey(ConnectionParam.MAX_LIFE_TIME.getKey())) {
                builder = builder.maxConnectionLifeTime(options.getIntValue(ConnectionParam.MAX_LIFE_TIME.getKey())
                        .intValue());
            }
            
            if (options.containsKey(ConnectionParam.MIN_POOL_SIZE.getKey())) {
                builder = builder.minConnectionsPerHost(options.getIntValue(ConnectionParam.MIN_POOL_SIZE.getKey())
                        .intValue());
            }
            
            if (options.containsKey(ConnectionParam.WAIT_QUEUE_MULTIPLE.getKey())) {
                builder = builder.threadsAllowedToBlockForConnectionMultiplier(options.getIntValue(
                        ConnectionParam.WAIT_QUEUE_MULTIPLE.getKey()).intValue());
            }
            
            if (options.containsKey(ConnectionParam.WAIT_QUEUE_TIMEOUT.getKey())) {
                builder = builder.maxWaitTime(options.getIntValue(ConnectionParam.WAIT_QUEUE_TIMEOUT.getKey())
                          .intValue());
            }
            
            if (options.containsKey(ConnectionParam.LOCAL_THRESHOLD.getKey())) {
                builder = builder.localThreshold(options.getIntValue(ConnectionParam.LOCAL_THRESHOLD.getKey())
                          .intValue());
            }
            
            if (options.containsKey(ConnectionParam.HEART_BEAT_FREQUENCY.getKey())) {
                builder = builder.heartbeatFrequency(options.getIntValue(ConnectionParam.HEART_BEAT_FREQUENCY.getKey())
                        .intValue());
            }
        }
        return builder.build();
    }

    private static SSLContext initializeSSLContext(BMap options) {
        TrustManager[] trustManagers;
        KeyManager[] keyManagers;

        BMap secureSocket = options.getMapValue(ConnectionParam.SECURE_SOCKET.getKey());

        BMap trustStore = secureSocket.getMapValue(ConnectionParam.TRUST_STORE.getKey());
        String trustStoreFilePath = trustStore.getStringValue(ConnectionParam.CERTIFICATE_PATH.getKey()).getValue();
        try (InputStream trustStream = new FileInputStream(trustStoreFilePath)) {
            char[] trustStorePass = trustStore.getStringValue(ConnectionParam.CERTIFICATE_PASSWORD.getKey()).getValue()
                    .toCharArray();
            KeyStore trustStoreJKS = KeyStore.getInstance(KeyStore.getDefaultType());
            trustStoreJKS.load(trustStream, trustStorePass);

            TrustManagerFactory trustFactory =
                    TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
            trustFactory.init(trustStoreJKS);
            trustManagers = trustFactory.getTrustManagers();
        } catch (FileNotFoundException e) {
            throw new MongoDBClientException("Trust store file not found for secure connections to MongoDB. " +
                    "Trust Store file path : '" + trustStoreFilePath + "'.", e);
        } catch (IOException e) {
            throw new MongoDBClientException("I/O Exception in creating trust store for secure connections to " +
                    "MongoDB. Trust Store file path : '" + trustStoreFilePath + "'.", e);
        } catch (GeneralSecurityException e) {
            throw new MongoDBClientException("Error in initializing certs for Trust Store : " +
                    e.getMessage(), e.getCause());
        }

        BMap keyStore = secureSocket.getMapValue(ConnectionParam.KEY_STORE.getKey());
        String keyStoreFilePath = keyStore.getStringValue(ConnectionParam.CERTIFICATE_PATH.getKey()).getValue();
        try (InputStream keyStream = new FileInputStream(keyStoreFilePath)) {
            char[] keyStorePass = keyStore.getStringValue(ConnectionParam.CERTIFICATE_PASSWORD.getKey()).getValue()
                    .toCharArray();
            KeyStore keyStoreJKS = KeyStore.getInstance(KeyStore.getDefaultType());
            keyStoreJKS.load(keyStream, keyStorePass);
            KeyManagerFactory keyManagerFactory =
                    KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
            keyManagerFactory.init(keyStoreJKS, keyStorePass);
            keyManagers = keyManagerFactory.getKeyManagers();
        } catch (FileNotFoundException e) {
            throw new MongoDBClientException("Key store file not found for secure connections to MongoDB. " +
                    "Key Store file path : '" + keyStoreFilePath + "'.", e);
        } catch (IOException e) {
            throw new MongoDBClientException("I/O Exception in creating trust store for secure connections to " +
                    "MongoDB. Key Store file path : '" + keyStoreFilePath + "'.", e);
        } catch (GeneralSecurityException e) {
            throw new MongoDBClientException("Error in initializing certs for Key Store : " +
                    e.getMessage(), e.getCause());
        }

        try {
            String protocol = secureSocket.getStringValue(ConnectionParam.SSL_PROTOCOL.getKey()).getValue();
            SSLContext sslContext = SSLContext.getInstance(protocol);
            sslContext.init(keyManagers, trustManagers, null);
            return sslContext;
        } catch (GeneralSecurityException e) {
            throw new MongoDBClientException("Error in initializing SSL context with the key store/ trust store. " +
                    "Trust Store file path : '" + trustStoreFilePath + "'. " +
                    "Key Store file path : '" + keyStoreFilePath + "'. " + e);
        }
    }

    /**
     * Enum for connection parameter indices.
     */
    private enum ConnectionParam {
        // String Params
        URL(fromString("url")), READ_CONCERN(fromString("readConcern")),
        WRITE_CONCERN(fromString("writeConcern")), READ_PREFERENCE(fromString("readPreference")),
        AUTHSOURCE(fromString("authSource")), AUTHMECHANISM(fromString("authMechanism")),
        GSSAPI_SERVICE_NAME(fromString("gssapiServiceName")), REPLICA_SET(fromString("replicaSet")),
        CERTIFICATE_PATH(fromString("path")), CERTIFICATE_PASSWORD(fromString("password")),
        SSL_PROTOCOL(fromString("protocol")),

        // boolean params
        SSL_ENABLED(fromString("sslEnabled")), SSL_INVALID_HOSTNAME_ALLOWED(fromString("sslInvalidHostNameAllowed")),
        RETRY_WRITES(fromString("retryWrites")),

        // int params
        SOCKET_TIMEOUT(fromString("socketTimeout")), CONNECTION_TIMEOUT(fromString("connectionTimeout")),
        MAX_POOL_SIZE(fromString("maxPoolSize")), SERVER_SELECTION_TIMEOUT(fromString("serverSelectionTimeout")),
        MAX_IDLE_TIME(fromString("maxIdleTime")), MAX_LIFE_TIME(fromString("maxLifeTime")),
        MIN_POOL_SIZE(fromString("minPoolSize")), WAIT_QUEUE_MULTIPLE(fromString("waitQueueMultiple")),
        WAIT_QUEUE_TIMEOUT(fromString("waitQueueTimeout")),
        LOCAL_THRESHOLD(fromString("localThreshold")), HEART_BEAT_FREQUENCY(fromString("heartbeatFrequency")),

        // Map Params
        SECURE_SOCKET(fromString("secureSocket")),
        TRUST_STORE(fromString("trustStore")), KEY_STORE(fromString("keyStore"));

        private final BString key;

        ConnectionParam(BString key) {
            this.key = key;
        }

        private BString getKey() {
            return key;
        }
    }
}

