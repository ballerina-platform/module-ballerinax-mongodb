package org.wso2.mongo.actions;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.UpdateOptions;
import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.UpdateResult;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.jvm.values.StreamingJsonValue;

import org.ballerinalang.jvm.JSONParser;
import org.bson.Document;
import org.wso2.mongo.MongoDBDataSource;

import java.util.ArrayList;
import java.util.List;

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

    protected Object findOne(MongoDBDataSource dbDataSource, String collectionName, MapValue query) {
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
            return JSONParser.parse(doc.toJson());
        }
    }

    protected static void insert(MongoDBDataSource dbDataSource, String collectionName, String document) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        collection.insertOne(Document.parse(document));
    }

    protected long delete(MongoDBDataSource dbDataSource, String collectionName, MapValue filter,
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

    protected long update(MongoDBDataSource dbDataSource, String collectionName, MapValue filter,
            MapValue document, boolean isMultiple, boolean upsert) {
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

    protected long replaceOne(MongoDBDataSource dbDataSource, String collectionName, MapValue filter, MapValue document) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        UpdateResult res = collection.replaceOne(this.jsonToDoc(filter), this.jsonToDoc(document));
        return res.getModifiedCount();
    }

    protected void batchInsert(MongoDBDataSource dbDataSource, String collectionName, ArrayValue documents) {
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


    private Document jsonToDoc(MapValue json) {
        return Document.parse(json.stringValue());
    }

    private static MongoCollection<Document> getCollection(MongoDBDataSource dbDataSource, String collectionName) {
        return dbDataSource.getMongoDatabase().getCollection(collectionName);
    }
}
