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

package org.wso2.mongo.endpoint;

import org.ballerinalang.jvm.values.HandleValue;
import org.ballerinalang.jvm.values.MapValue;
import org.wso2.mongo.BallerinaMongoDbException;
import org.wso2.mongo.MongoDBDataSource;
import org.wso2.mongo.MongoDBUtils;

/**
 * {@code InitMongoDbClient} creates a MongoDbClient with provided configuration.
 */

public class InitMongoDbClient {
    public static Object initClient(MapValue config) {
        String host = config.getStringValue("host");
        String dbName = config.getStringValue("dbName");
        String username = config.getStringValue("userName");
        String password = config.getStringValue("password");
        MapValue options = config.getMapValue("options");

        MongoDBDataSource dataSource = new MongoDBDataSource();
        try {
            dataSource.init(host, dbName, username, password, options);
            return new HandleValue(dataSource);
        } catch (BallerinaMongoDbException e) {
            return MongoDBUtils.createBallerinaClientError(e);
        }
    }
}

