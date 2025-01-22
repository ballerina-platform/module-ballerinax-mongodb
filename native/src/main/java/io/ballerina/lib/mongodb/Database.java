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

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoIterable;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import static io.ballerina.lib.mongodb.Utils.MONGO_CLIENT;
import static io.ballerina.lib.mongodb.Utils.MONGO_DATABASE;
import static io.ballerina.lib.mongodb.Utils.createError;

/**
 * This class represents a MongoDB database in Ballerina MongoDB client.
 *
 * @since 5.0.0
 */
public final class Database {

    private Database() {
    }

    public static BError initDatabase(BObject database, BObject client, BString dbName) {
        try {
            MongoClient mongoClient = (MongoClient) client.getNativeData(MONGO_CLIENT);
            MongoDatabase mongoDatabase = mongoClient.getDatabase(dbName.getValue());
            database.addNativeData(MONGO_DATABASE, mongoDatabase);
            return null;
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object listCollectionNames(BObject database) {
        try {
            MongoDatabase mongoDatabase = (MongoDatabase) database.getNativeData(MONGO_DATABASE);
            MongoIterable<String> collectionNames = mongoDatabase.listCollectionNames();
            BArray result = ValueCreator.createArrayValue(TypeCreator.createArrayType(PredefinedTypes.TYPE_STRING));
            for (String collectionName : collectionNames) {
                result.append(StringUtils.fromString(collectionName));
            }
            return result;
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object createCollection(BObject database, BString collectionName) {
        try {
            MongoDatabase mongoDatabase = (MongoDatabase) database.getNativeData(MONGO_DATABASE);
            mongoDatabase.createCollection(collectionName.getValue());
            return null;
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object getCollection(BObject database, BString collectionName) {
        try {
            MongoDatabase mongoDatabase = (MongoDatabase) database.getNativeData(MONGO_DATABASE);
            mongoDatabase.getCollection(collectionName.getValue());
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static BError drop(BObject database) {
        try {
            MongoDatabase mongoDatabase = (MongoDatabase) database.getNativeData(MONGO_DATABASE);
            mongoDatabase.drop();
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }
}
