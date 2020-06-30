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
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.UpdateOptions;
import org.ballerinalang.jvm.values.HandleValue;
import org.ballerinalang.jvm.values.api.BValueCreator;
import org.bson.Document;
import org.wso2.mongo.exceptions.BallerinaErrorGenerator;

import static org.wso2.mongo.MongoDBConstants.EMPTY_JSON;

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

    public static Object listIndices(HandleValue collection) {
        MongoCollection<Document> mongoCollection = (MongoCollection<Document>) collection.getValue();
        try {
            MongoCursor<Document> iterator = mongoCollection.listIndexes().iterator();
            return BValueCreator.createStreamingJsonValue(new MongoDBIterator(iterator));
        } catch (MongoException e) {
            return BallerinaErrorGenerator.createBallerinaDatabaseError(e);
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

    public static Object find(HandleValue collection, Object filter, Object sort, long limit) {

        if (filter == null) {
            filter = EMPTY_JSON;
        }
        Document filterDoc = Document.parse(filter.toString());

        if (sort == null) {
            sort = EMPTY_JSON;
        }
        Document sortDoc = Document.parse(sort.toString());

        MongoCollection<Document> mongoCollection = (MongoCollection<Document>) collection.getValue();
        MongoCursor<Document> results;
        try {
            if (limit != -1) {
                results = mongoCollection.find(filterDoc).sort(sortDoc).limit((int) limit).iterator();
            } else {
                results = mongoCollection.find(filterDoc).sort(sortDoc).iterator();
            }
            return BValueCreator.createStreamingJsonValue(new MongoDBIterator(results));
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

        Document updateDoc = new Document();
        updateDoc.put("$set", Document.parse(update));

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
