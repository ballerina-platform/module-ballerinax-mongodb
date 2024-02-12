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
import com.mongodb.client.AggregateIterable;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.UpdateOptions;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BHandle;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import org.ballerinalang.mongodb.exceptions.BallerinaErrorGenerator;
import org.bson.Document;

import java.util.ArrayList;
import java.util.List;

import static org.ballerinalang.mongodb.MongoDBConstants.EMPTY_JSON;

/**
 * Java implementation for Ballerina MongoDB Collection.
 */
public class MongoDBCollectionUtil {

    public static Object countDocuments(BHandle collection, Object filter, BArray pipeline) {
        MongoCollection<Document> mongoCollection = (MongoCollection<Document>) collection.getValue();
        try {
            long pipelineLength = pipeline.getLength();
            if (pipelineLength != 0) {
                List<Document> pipelineDoc = new ArrayList<>();
                for (int i = 0; i < pipelineLength; i++) {
                    pipelineDoc.add(Document.parse(pipeline.get(i).toString()));
                }
                Document groupDoc = new Document();
                Document countDoc = new Document();
                countDoc.put("_id", null);
                countDoc.put("count", new Document("$sum", 1));
                groupDoc.put("$group", countDoc);
                pipelineDoc.add(groupDoc);
                MongoCursor<Document> cursor = mongoCollection.aggregate(pipelineDoc).cursor();
                if (cursor.hasNext()) {
                    return cursor.next().get("count");
                }
            }
            if (filter != null) {
                Document filterDoc = Document.parse(filter.toString());
                return mongoCollection.countDocuments(filterDoc);
            }
            return mongoCollection.countDocuments();
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
                    MongoDBConstants.RESULT_ITERATOR_OBJECT, null, ValueCreator.createObjectValue(
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

    public static Object insert(BHandle collection, String document) {
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
                              Object filter, Object projection, Object sort, long limit, long skip,
                              BTypedesc recordType) {
        if (filter == null) {
            filter = EMPTY_JSON;
        }
        Document filterDoc = Document.parse(filter.toString());

        if (projection == null) {
            projection = EMPTY_JSON;
        }
        Document projectionDoc = Document.parse(projection.toString());

        if (sort == null) {
            sort = EMPTY_JSON;
        }
        Document sortDoc = Document.parse(sort.toString());
        try {
            MongoDatabase mongoDatabase = MongoDBDatabaseUtil.getCurrentDatabase(env, client, databaseName);
            MongoCollection<Document> mongoCollection = mongoDatabase.getCollection(collectionName.getValue());
            FindIterable<Document> results = mongoCollection.find(filterDoc).projection(projectionDoc).sort(sortDoc);
            if (limit != -1) {
                results = results.limit((int) limit);
            }
            if (skip != -1) {
                results = results.skip((int) skip);
            }
            MongoCursor<Document> resultIterate = results.iterator();

            Type streamConstraint = recordType.getDescribingType();

            BObject bObject = ValueCreator.createObjectValue(ModuleUtils.getModule(),
                    MongoDBConstants.RESULT_ITERATOR_OBJECT, null, ValueCreator.createObjectValue(
                            ModuleUtils.getModule(), MongoDBConstants.MONGO_RESULT_ITERATOR_OBJECT));
            bObject.addNativeData(MongoDBConstants.RESULT_SET_NATIVE_DATA_FIELD, resultIterate);
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

    public static Object delete(BHandle collection, Object filter, boolean isMultiple) {
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

    public static Object update(BHandle collection, String update, Object filter, boolean isMultiple,
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

    public static Object distinct(Environment env, BObject client, BString collectionName, BString field,
                                  Object databaseName, Object filter, BTypedesc anyDataType) {
        if (filter == null) {
            filter = EMPTY_JSON;
        }

        Document filterDoc = Document.parse(filter.toString());

        try {
            MongoDatabase mongoDatabase = MongoDBDatabaseUtil.getCurrentDatabase(env, client, databaseName);
            MongoCollection<Document> mongoCollection = mongoDatabase.getCollection(collectionName.getValue());
            MongoCursor<String> results;
            results = mongoCollection.distinct(field.getValue(), filterDoc, String.class).iterator();

            Type streamConstraint =  anyDataType.getDescribingType();

            BObject bObject = ValueCreator.createObjectValue(
                    ModuleUtils.getModule(),
                    MongoDBConstants.PLAIN_RESULT_ITERATOR_OBJECT,
            null, ValueCreator.createObjectValue(
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

    static Object aggregate(Environment env, BObject client, BString collectionName,
                                   Object databaseName, List<Document> stages, BTypedesc recordType) {
        // Add $toString stage to convert _id to string UUID
        stages.add(new Document("$set", new Document("_id", new Document("$toString", "$_id"))));

        try {
            MongoDatabase mongoDatabase = MongoDBDatabaseUtil.getCurrentDatabase(env, client, databaseName);
            MongoCollection<Document> mongoCollection = mongoDatabase.getCollection(collectionName.getValue());
            AggregateIterable<Document> results = mongoCollection.aggregate(stages, Document.class);
            MongoCursor<Document> resultIterate = results.iterator();
            Type streamConstraint = recordType.getDescribingType();
            BObject bObject = ValueCreator.createObjectValue(ModuleUtils.getModule(),
                    MongoDBConstants.RESULT_ITERATOR_OBJECT, null, ValueCreator.createObjectValue(
                            ModuleUtils.getModule(), MongoDBConstants.MONGO_RESULT_ITERATOR_OBJECT));
            bObject.addNativeData(MongoDBConstants.RESULT_SET_NATIVE_DATA_FIELD, resultIterate);
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

    public static Object aggregate(Environment env, BObject client, BString collectionName,
                                   Object databaseName, BArray pipeline, BTypedesc recordType) {
        List<Document> pipelineDoc = new ArrayList<>();
        if (pipeline != null) {
            long pipelineLength = pipeline.getLength();
            for (int i = 0; i < pipelineLength; i++) {
                pipelineDoc.add(Document.parse(pipeline.get(i).toString()));
            }
        }
        return aggregate(env, client, collectionName, databaseName, pipelineDoc, recordType);
    }
}
