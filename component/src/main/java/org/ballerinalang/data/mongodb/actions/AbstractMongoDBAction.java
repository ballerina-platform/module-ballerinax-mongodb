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
package org.ballerinalang.data.mongodb.actions;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.UpdateOptions;
import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.UpdateResult;
import org.ballerinalang.bre.Context;
import org.ballerinalang.connector.api.AbstractNativeAction;
import org.ballerinalang.connector.api.ConnectorFuture;
import org.ballerinalang.data.mongodb.Constants;
import org.ballerinalang.data.mongodb.MongoDBDataSource;
import org.ballerinalang.model.values.BConnector;
import org.ballerinalang.model.values.BJSON;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BRefValueArray;
import org.ballerinalang.model.values.BString;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.nativeimpl.actions.ClientConnectorFuture;
import org.ballerinalang.natives.exceptions.ArgumentOutOfRangeException;
import org.ballerinalang.util.exceptions.BallerinaException;
import org.bson.Document;

import java.util.ArrayList;
import java.util.List;

/**
 * {@code AbstractMongoDBAction} is the base class for all MongoDB actions.
 *
 */
public abstract class AbstractMongoDBAction extends AbstractNativeAction {

    @Override
    public BValue getRefArgument(Context context, int index) {
        if (index > -1) {
            return context.getControlStack().getCurrentFrame().getRefRegs()[index];
        }
        throw new ArgumentOutOfRangeException(index);
    }

    protected BJSON find(MongoDBDataSource dbDataSource, String collectionName, BJSON query) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        MongoCursor<Document> itr;
        if (query != null) {
            itr = collection.find(Document.parse(query.stringValue())).iterator();
        } else {
            itr = collection.find().iterator();
        }
        return new BJSON(new MongoDBDataSource.MongoJSONDataSource(itr));
    }

    protected BJSON findOne(MongoDBDataSource dbDataSource, String collectionName, BJSON query) {
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
            return new BJSON(doc.toJson());
        }
    }

    protected void insert(MongoDBDataSource dbDataSource, String collectionName, BJSON document) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        collection.insertOne(Document.parse(document.stringValue()));
    }

    protected long delete(MongoDBDataSource dbDataSource, String collectionName, BJSON filter, boolean isMultiple) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        DeleteResult res;
        if (isMultiple) {
            res = collection.deleteMany(this.jsonToDoc(filter));
        } else {
            res = collection.deleteOne(this.jsonToDoc(filter));
        }
        return res.getDeletedCount();
    }

    protected long update(MongoDBDataSource dbDataSource, String collectionName, BJSON filter, BJSON document,
            boolean isMultiple, boolean upsert) {
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
        int count = (int) documents.size();
        List<Document> docList = new ArrayList<Document>(count);
        for (int i = 0; i < count; i++) {
            docList.add(Document.parse(documents.get(i).stringValue()));
        }
        collection.insertMany(docList);
    }

    protected void close(MongoDBDataSource dbDataSource) {
        dbDataSource.getMongoClient().close();
    }

    protected MongoDBDataSource getDataSource(BConnector bConnector) {
        MongoDBDataSource datasource = null;
        BMap sharedMap = (BMap) bConnector.getRefField(1);
        if (sharedMap.get(new BString(Constants.DATASOURCE_KEY)) != null) {
            BValue value = sharedMap.get(new BString(Constants.DATASOURCE_KEY));
            if (value instanceof MongoDBDataSource) {
                datasource = (MongoDBDataSource) value;
            }
        } else {
            throw new BallerinaException("datasource not initialized properly");
        }
        return datasource;
    }

    protected ConnectorFuture getConnectorFuture() {
        ClientConnectorFuture future = new ClientConnectorFuture();
        future.notifySuccess();
        return future;
    }

    private Document jsonToDoc(BJSON json) {
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
