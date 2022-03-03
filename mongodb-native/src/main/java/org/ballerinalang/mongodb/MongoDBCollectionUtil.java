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

import com.mongodb.MongoException;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.UpdateOptions;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.runtime.internal.values.HandleValue;
import org.bson.Document;
import org.ballerinalang.mongodb.exceptions.BallerinaErrorGenerator;

import static org.ballerinalang.mongodb.MongoDBConstants.EMPTY_JSON;

/**
 * Java implementation for Ballerina MongoDB Collection.
 */
public class MongoDBCollectionUtil {

    public static Object countDocuments(HandleValue collection, Object filter) {
        MongoCollection<Document> mongoCollection = (MongoCollection<Document>) collection.getValue();
        try {

            if (filter == null) {
                return mongoCollection.countDocuments();
            }

            Document filterDoc = Document.parse(filter.toString());
            return mongoCollection.countDocuments(filterDoc);
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object listIndices(Environment env, BObject client, BString collectionName, Object databaseName,
                                      BTypedesc recordType) {
        try {
            MongoDatabase mongoDatabase = MongoDBDatabaseUtil.getCurrentDatabase(env, client, databaseName);
            MongoCollection<Document> mongoCollection = mongoDatabase.getCollection(collectionName.getValue());
            MongoCursor<Document> iterator = mongoCollection.listIndexes().iterator();
            RecordType streamConstraint = (RecordType) recordType.getDescribingType();
            BObject bObject = ValueCreator.createObjectValue(ModuleUtils.getModule(), 
                            MongoDBConstants.RESULT_ITERATOR_OBJECT,null, ValueCreator.createObjectValue(
                            ModuleUtils.getModule(), MongoDBConstants.MONGO_RESULT_ITERATOR_OBJECT));
            bObject.addNativeData(MongoDBConstants.RESULT_SET_NATIVE_DATA_FIELD, iterator);
            bObject.addNativeData(MongoDBConstants.RECORD_TYPE_DATA_FIELD, streamConstraint);
            
            BStream bStreamValue = ValueCreator.createStreamValue(TypeCreator.createStreamType(streamConstraint,
                                PredefinedTypes.TYPE_NULL), bObject);
            return bStreamValue;
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object insert(HandleValue collection, String document) {
        MongoCollection<Document> mongoCollection = (MongoCollection<Document>) collection.getValue();
        try {

            Document insertDoc = Document.parse(document);
            mongoCollection.insertOne(insertDoc);
            return null;
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object find(Environment env, BObject client, BString collectionName, Object databaseName,
                               Object filter, Object sort, long limit , BTypedesc recordType) {
        if (filter == null) {
            filter = EMPTY_JSON;
        }
        Document filterDoc = Document.parse(filter.toString());

        if (sort == null) {
            sort = EMPTY_JSON;
        }
        Document sortDoc = Document.parse(sort.toString());
        try {
            MongoDatabase mongoDatabase = MongoDBDatabaseUtil.getCurrentDatabase(env, client, databaseName);
            MongoCollection<Document> mongoCollection = mongoDatabase.getCollection(collectionName.getValue());
            MongoCursor<Document> results;
            if (limit != -1) {
                results = mongoCollection.find(filterDoc).sort(sortDoc).limit((int) limit).iterator();
            } else {
                results = mongoCollection.find(filterDoc).sort(sortDoc).iterator();
            }
            RecordType streamConstraint = (RecordType) recordType.getDescribingType();
            BObject bObject = ValueCreator.createObjectValue(ModuleUtils.getModule(), 
                              MongoDBConstants.RESULT_ITERATOR_OBJECT,null, ValueCreator.createObjectValue(
                            ModuleUtils.getModule(), MongoDBConstants.MONGO_RESULT_ITERATOR_OBJECT));
            bObject.addNativeData(MongoDBConstants.RESULT_SET_NATIVE_DATA_FIELD, results);
            bObject.addNativeData(MongoDBConstants.RECORD_TYPE_DATA_FIELD, streamConstraint);
            
            BStream bStreamValue = ValueCreator.createStreamValue(TypeCreator.createStreamType(streamConstraint,
                                   PredefinedTypes.TYPE_NULL), bObject);
            return bStreamValue;
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object delete(HandleValue collection, Object filter, boolean isMultiple) {
        MongoCollection<Document> mongoCollection = (MongoCollection<Document>) collection.getValue();

        if (filter == null) {
            filter = EMPTY_JSON;
        }
        Document filterDoc = Document.parse(filter.toString());

        try {
            if (isMultiple) {
                return mongoCollection.deleteMany(filterDoc).getDeletedCount();
            }
            return mongoCollection.deleteOne(filterDoc).getDeletedCount();

        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }

    public static Object update(HandleValue collection, String update, Object filter, boolean isMultiple,
                                boolean upsert) {
        MongoCollection<Document> mongoCollection = (MongoCollection<Document>) collection.getValue();

        if (filter == null) {
            filter = EMPTY_JSON;
        }
        Document filterDoc = Document.parse(filter.toString());

        Document updateDoc = Document.parse(update);

        UpdateOptions updateOptions = new UpdateOptions().upsert(upsert);

        try {
            if (isMultiple) {
                return mongoCollection.updateMany(filterDoc, updateDoc, updateOptions).getModifiedCount();
            }
            return mongoCollection.updateOne(filterDoc, updateDoc, updateOptions).getModifiedCount();

        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
        } catch (Exception e) {
            return BallerinaErrorGenerator.createBallerinaApplicationError(e);
        }
    }
}
