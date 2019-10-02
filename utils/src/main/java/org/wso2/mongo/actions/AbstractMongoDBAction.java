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

package org.wso2.mongo.actions;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.UpdateResult;
import org.ballerinalang.jvm.JSONParser;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.StreamingJsonValue;
import org.bson.Document;
import org.wso2.mongo.MongoDBDataSource;

import java.util.ArrayList;
import java.util.List;

/**
 * {@code AbstractMongoDBAction} is the base class for all MongoDB actions.
 *
 */

public class AbstractMongoDBAction {
    protected static StreamingJsonValue find(MongoDBDataSource dbDataSource, String collectionName, Object query) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        MongoCursor<Document> itr;
        if (query != null) {
            itr = (MongoCursor<Document>) collection.find(Document.parse(query.toString())).iterator();
        } else {
            itr = collection.find().iterator();
        }
        return new StreamingJsonValue(new MongoDBDataSource.MongoJSONDataSource(itr));
    }

    protected static String findOne(MongoDBDataSource dbDataSource, String collectionName, Object query) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        Document doc;
        if (query != null) {
            doc = collection.find(Document.parse(query.toString())).first();
        } else {
            doc = collection.find().first();
        }
        if (doc == null) {
            return null;
        } else {
            return JSONParser.parse(doc.toJson()).toString();
        }
    }

    protected static void insert(MongoDBDataSource dbDataSource, String collectionName, String document) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        collection.insertOne(Document.parse(document));
    }

    protected static long delete(MongoDBDataSource dbDataSource, String collectionName, Object filter,
                                                                                         boolean isMultiple) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        DeleteResult res;
        if (isMultiple) {
            res = collection.deleteMany(jsonToDoc(filter));
        } else {
            res = collection.deleteOne(jsonToDoc(filter));
        }
        return res.getDeletedCount();
    }

    protected static long replaceOne(MongoDBDataSource dbDataSource, String collectionName, Object filter,
                                                                                  Object document, boolean upsert) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        UpdateResult res = collection.replaceOne(jsonToDoc(filter), jsonToDoc(document));
        return res.getModifiedCount();
    }

    protected static void close(MongoDBDataSource dbDataSource) {
        dbDataSource.getMongoClient().close();
    }

    private static Document jsonToDoc(Object json) {
        return Document.parse(json.toString());
    }

    private static MongoCollection<Document> getCollection(MongoDBDataSource dbDataSource, String collectionName) {
        return dbDataSource.getMongoDatabase().getCollection(collectionName);
    }
}

