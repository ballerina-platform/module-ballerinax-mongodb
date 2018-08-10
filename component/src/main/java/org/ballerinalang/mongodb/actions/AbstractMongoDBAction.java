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
package org.ballerinalang.mongodb.actions;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.UpdateOptions;
import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.UpdateResult;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.model.util.JsonParser;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BRefValueArray;
import org.ballerinalang.model.values.BStreamingJSON;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.mongodb.MongoDBDataSource;
import org.ballerinalang.util.exceptions.BallerinaException;
import org.bson.Document;

import java.util.ArrayList;
import java.util.List;

/**
 * {@code AbstractMongoDBAction} is the base class for all MongoDB actions.
 *
 */
public abstract class AbstractMongoDBAction extends BlockingNativeCallableUnit {

    protected BStreamingJSON find(MongoDBDataSource dbDataSource, String collectionName, BMap query) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        MongoCursor<Document> itr;
        if (query != null) {
            itr = collection.find(Document.parse(query.stringValue())).iterator();
        } else {
            itr = collection.find().iterator();
        }
        return new BStreamingJSON(new MongoDBDataSource.MongoJSONDataSource(itr));
    }

    protected BValue findOne(MongoDBDataSource dbDataSource, String collectionName, BMap query) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        Document doc;
        if (query != null) {
            doc = collection.find(Document.parse(query.stringValue())).first();
        } else {
            doc = collection.find().first();
        }
        if (doc == null) {
            return null;
        } else {
            return JsonParser.parse(doc.toJson());
        }
    }

    protected void insert(MongoDBDataSource dbDataSource, String collectionName, BMap document) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        collection.insertOne(Document.parse(document.stringValue()));
    }

    protected long delete(MongoDBDataSource dbDataSource, String collectionName, BMap filter,
            boolean isMultiple) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        DeleteResult res;
        if (isMultiple) {
            res = collection.deleteMany(this.jsonToDoc(filter));
        } else {
            res = collection.deleteOne(this.jsonToDoc(filter));
        }
        return res.getDeletedCount();
    }

    protected long update(MongoDBDataSource dbDataSource, String collectionName, BMap filter,
            BMap document, boolean isMultiple, boolean upsert) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        UpdateOptions options = new UpdateOptions();
        options.upsert(upsert);
        UpdateResult res;
        if (isMultiple) {
            res = collection.updateMany(this.jsonToDoc(filter), this.jsonToDoc(document), options);
        } else {
            res = collection.updateOne(this.jsonToDoc(filter), this.jsonToDoc(document), options);
        }
        return res.getModifiedCount();
    }

    protected void batchInsert(MongoDBDataSource dbDataSource, String collectionName, BRefValueArray documents) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        long count =  documents.size();
        List<Document> docList = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            docList.add(Document.parse(documents.get(i).toString()));
        }
        collection.insertMany(docList);
    }

    protected void close(MongoDBDataSource dbDataSource) {
        dbDataSource.getMongoClient().close();
    }


    private Document jsonToDoc(BMap json) {
        return Document.parse(json.stringValue());
    }

    private MongoCollection<Document> getCollection(MongoDBDataSource dbDataSource, String collectionName) {
        MongoCollection<Document> collection = dbDataSource.getMongoDatabase().getCollection(collectionName);
        if (collection == null) {
            throw new BallerinaException("invalid collection name: " + collectionName);
        }
        return collection;
    }
}
