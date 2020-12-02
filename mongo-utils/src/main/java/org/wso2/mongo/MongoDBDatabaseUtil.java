/*
 * Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.mongo;

import com.mongodb.MongoException;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import io.ballerina.runtime.api.ValueCreator;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.values.HandleValue;
import org.wso2.mongo.exceptions.BallerinaErrorGenerator;

import java.util.ArrayList;

import static io.ballerina.runtime.api.StringUtils.fromString;

/**
 * Java implementation of MongoDB Database.
 */
public class MongoDBDatabaseUtil {

    public static Object getCollectionNames(HandleValue database) {
        MongoDatabase mongoDatabase = (MongoDatabase) database.getValue();
        try {
            MongoCursor<String> iterator = mongoDatabase.listCollectionNames().iterator();
            ArrayList<BString> collectionNames = new ArrayList<>();
            while (iterator.hasNext()) {
                collectionNames.add(fromString(iterator.next()));
            }
            return ValueCreator.createArrayValue(collectionNames.toArray(new BString[0]));
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        }
    }

    public static Object getCollection(HandleValue database, BString collectionName) {

        try {
            MongoDatabase mongoDatabase = (MongoDatabase) database.getValue();
            return mongoDatabase.getCollection(collectionName.getValue());
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        }
    }
}
