/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package org.ballerinalang.data.mongodb.utils;

import com.mongodb.MongoClient;
import de.flapdoodle.embed.mongo.MongodExecutable;
import de.flapdoodle.embed.mongo.MongodStarter;
import de.flapdoodle.embed.mongo.config.IMongodConfig;
import de.flapdoodle.embed.mongo.config.MongodConfigBuilder;
import de.flapdoodle.embed.mongo.config.Net;
import de.flapdoodle.embed.mongo.distribution.Version;
import de.flapdoodle.embed.process.runtime.Network;

import java.io.IOException;

public class MongoDBTestUtils {

    public static final int MONGODB_PORT = 27017;
    // Cannot use "localhost" here due to
    // https://github.com/flapdoodle-oss/de.flapdoodle.embed.mongo/issues/230
    // This issue be fixed once mondodb.version is upgraded to 3.6.2
    public static final String MONGODB_HOST = "127.0.0.1";

    /**
     * This method sets up a MongoDB on localhost without authentication.
     *
     * @throws IOException thrown when an issue occurs during the process of starting up the database
     */
    public static MongodExecutable getMongoExecutableWithoutAuth() throws IOException {
        MongodStarter starter = MongodStarter.getDefaultInstance();
        String bindIp = MONGODB_HOST;
        int port = MONGODB_PORT;
        IMongodConfig mongodConfig = new MongodConfigBuilder().version(Version.Main.PRODUCTION)
                .net(new Net(bindIp, port, Network.localhostIsIPv6())).build();
        return starter.prepare(mongodConfig);

    }

    /**
     * This method terminates the database and the client.
     *
     * @param mongodExecutable
     * @param mongoClient
     */
    public static void releaseResources(MongodExecutable mongodExecutable, MongoClient mongoClient) {
        if (mongodExecutable != null) {
            mongodExecutable.stop();
        }
        if (mongoClient != null) {
            mongoClient.close();
        }
    }

}
