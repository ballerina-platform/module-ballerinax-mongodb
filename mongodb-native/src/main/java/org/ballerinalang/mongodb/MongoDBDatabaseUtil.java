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

package org.ballerinalang.mongodb;

import com.mongodb.MongoClient;
import com.mongodb.MongoException;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.mongodb.exceptions.BallerinaErrorGenerator;

import java.util.ArrayList;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * Java implementation of MongoDB Database.
 */
public class MongoDBDatabaseUtil {

    public static Object getCollectionNames(Environment env, BObject client, Object databaseName) {
        try {
            MongoDatabase mongoDatabase = getCurrentDatabase(env, client, databaseName);
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
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object getCollection(Environment env, BObject client, BString collectionName, Object databaseName) {

        try {
            MongoDatabase mongoDatabase = getCurrentDatabase(env, client, databaseName);
            try {
                return mongoDatabase.getCollection(collectionName.getValue());
            } catch (MongoException e) {
                return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
            }
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static MongoDatabase getCurrentDatabase(Environment env, BObject client, Object databaseName) throws BError {
        if (databaseName == null) {
            Object database = client.getNativeData(MongoDBConstants.MONGO_DATABASE);
            if (database == null) {
                throw ErrorCreator.createError(fromString("Error while getting database object from client native " + 
                                                "data. There is no database object available."));
            }
            return (MongoDatabase) database;
        } else {
            if (MongoDBConstants.EMPTY_STRING.equals(databaseName.toString().trim())) {
                Object database = client.getNativeData(MongoDBConstants.MONGO_DATABASE);
                if (database == null) {
                    throw ErrorCreator.createError(fromString("Error while getting Database object from client " + 
                                                    "native data. There is no Database object available."));
                }
                return (MongoDatabase) database;
            } else {
                Object mongoClient = client.getNativeData(MongoDBConstants.MONGO_CLIENT);
                if (mongoClient == null) {
                    throw ErrorCreator.createError(fromString("Error while getting MongoClient object from client " + 
                                                    "native data. There is no MongoClient object available."));
                }
                return ((MongoClient) mongoClient).getDatabase(databaseName.toString().trim());
            }            
        }
    }
}
