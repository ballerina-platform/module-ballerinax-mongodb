package org.wso2.mongo.actions;

import com.mongodb.client.ClientSession;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.UpdateOptions;
import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.UpdateResult;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.jvm.values.ObjectValue;
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

    protected static long delete(MongoDBDataSource dbDataSource, String collectionName, Object filter, boolean isMultiple) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        DeleteResult res;
        if (isMultiple) {
            res = collection.deleteMany(jsonToDoc(filter));
        } else {
            res = collection.deleteOne(jsonToDoc(filter));
        }
        return res.getDeletedCount();
    }

    protected static long update(MongoDBDataSource dbDataSource, String collectionName, Object filter, Object document, boolean isMultiple, boolean upsert) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        UpdateOptions options = new UpdateOptions();
        options.upsert(upsert);
        UpdateResult res;
        if (isMultiple) {
            res = collection.updateMany(jsonToDoc(filter.toString()), jsonToDoc(document), options);
        } else {
            res = collection.updateOne(jsonToDoc(filter.toString()), jsonToDoc(document), options);
        }
        return res.getModifiedCount();
    }

    protected static long replaceOne(MongoDBDataSource dbDataSource, String collectionName, Object filter, Object document, boolean upsert) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        UpdateResult res = collection.replaceOne(jsonToDoc(filter), jsonToDoc(document));
        return res.getModifiedCount();
    }

    protected static void batchInsert(MongoDBDataSource dbDataSource, String collectionName, ArrayValue documents) {
        MongoCollection<Document> collection = getCollection(dbDataSource, collectionName);
        long count = documents.size();
        List<Document> docList = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            docList.add(Document.parse(documents.get(i).toString()));
        }
        collection.insertMany(docList);
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
