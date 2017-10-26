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

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.node.BaseJsonNode;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientOptions;
import com.mongodb.ReadConcern;
import com.mongodb.ReadConcernLevel;
import com.mongodb.ReadPreference;
import com.mongodb.ServerAddress;
import com.mongodb.WriteConcern;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import org.ballerinalang.model.types.BType;
import org.ballerinalang.model.values.BJSON;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BString;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.util.exceptions.BallerinaException;
import org.bson.Document;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * {@code MongoDBDataSource} util class for MongoDB connector initialization.
 */
public class MongoDBDataSource implements BValue {
    private MongoDatabase db;
    private MongoClient client;

    public MongoDBDataSource() {}

    public MongoDatabase getMongoDatabase() {
        return db;
    }

    public MongoClient getMongoClient() {
        return client;
    }


    public boolean init(String host, String dbName, BMap mapProperties) {
        if (!mapProperties.isEmpty()) {
            this.client = new MongoClient(this.createServerAddresses(host), this.createOptions(mapProperties));
        } else {
            this.client = new MongoClient(this.createServerAddresses(host));
        }
        this.db = this.client.getDatabase(dbName);
        return true;
    }

    private MongoClientOptions createOptions(BMap<BString, BValue> options) {
        MongoClientOptions.Builder builder = MongoClientOptions.builder();
        BValue value = options.get(new BString(Constants.SSL_ENABLED));
        if (value != null) {
            builder = builder.sslEnabled(Boolean.parseBoolean(value.stringValue()));
        }
        value = options.get(new BString(Constants.READ_CONCERN));
        if (value != null) {
            builder = builder.readConcern(new ReadConcern(ReadConcernLevel.valueOf(value.stringValue())));
        }
        value = options.get(new BString(Constants.WRITE_CONCERN));
        if (value != null) {
            builder = builder.writeConcern(WriteConcern.valueOf(value.stringValue()));
        }
        value = options.get(new BString(Constants.READ_PREFERENCE));
        if (value != null) {
            builder = builder.readPreference((ReadPreference.valueOf(value.stringValue())));
        }
        value = options.get(new BString(Constants.SOCKET_TIMEOUT));
        if (value != null) {
            try {
                builder = builder.socketTimeout(Integer.parseInt(value.stringValue()));
            } catch (NumberFormatException e) {
                throw new BallerinaException("the socket timeout must be an integer value: " +
                        value.stringValue(), e);
            }
        }
        value = options.get(new BString(Constants.CONNECTION_TIMEOUT));
        if (value != null) {
            try {
                builder = builder.connectTimeout(Integer.parseInt(value.stringValue()));
            } catch (NumberFormatException e) {
                throw new BallerinaException("the connection timeout must be an integer value: " +
                        value.stringValue(), e);
            }
        }
        value = options.get(new BString(Constants.CONNECTIONS_PER_HOST));
        if (value != null) {
            try {
                builder = builder.connectionsPerHost(Integer.parseInt(value.stringValue()));
            } catch (NumberFormatException e) {
                throw new BallerinaException("connections per host must be an integer value: " +
                        value.stringValue(), e);
            }
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
        public void serialize(JsonGenerator jsonGenerator, SerializerProvider serializerProvider) throws IOException {
            jsonGenerator.writeStartArray();
            ObjectMapper mapper = new ObjectMapper();
            while (this.mc.hasNext()) {
                ((BaseJsonNode) mapper.readTree(this.mc.next().toJson())).serialize(jsonGenerator, serializerProvider);
            }
            jsonGenerator.writeEndArray();
        }
    }
}
