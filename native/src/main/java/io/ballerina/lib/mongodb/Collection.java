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

import com.mongodb.MongoQueryException;
import com.mongodb.MongoWriteException;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.CountOptions;
import com.mongodb.client.model.IndexOptions;
import com.mongodb.client.model.InsertManyOptions;
import com.mongodb.client.model.InsertOneOptions;
import com.mongodb.client.model.UpdateOptions;
import com.mongodb.client.result.DeleteResult;
import com.mongodb.client.result.UpdateResult;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.StreamType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import org.ballerinalang.langlib.value.FromJsonStringWithType;
import org.bson.BsonValue;
import org.bson.Document;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import static io.ballerina.lib.mongodb.ModuleUtils.getModule;
import static io.ballerina.lib.mongodb.Utils.createError;
import static io.ballerina.lib.mongodb.Utils.createStream;
import static io.ballerina.lib.mongodb.Utils.getPipeline;
import static io.ballerina.lib.mongodb.Utils.getProjection;
import static io.ballerina.lib.mongodb.Utils.getResultClass;
import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * This class represents a MongoDB collection in Ballerina MongoDB client.
 *
 * @since 5.0.0
 */
public final class Collection {

    private Collection() {
    }

    private static final BString BYPASS_DOCUMENT_VALIDATION = StringUtils.fromString("bypassDocumentValidation");
    private static final BString COMMENT = StringUtils.fromString("comment");
    private static final BString ORDERED = StringUtils.fromString("ordered");
    private static final BString LIMIT = StringUtils.fromString("limit");
    private static final BString SKIP = StringUtils.fromString("skip");
    private static final BString SORT = StringUtils.fromString("sort");
    private static final BString MAX_TIME_MS = StringUtils.fromString("maxTimeMS");
    private static final BString HINT = StringUtils.fromString("hint");
    private static final BString BACKGROUND = StringUtils.fromString("background");
    private static final BString UNIQUE = StringUtils.fromString("unique");
    private static final BString NAME = StringUtils.fromString("name");
    private static final BString SPARSE = StringUtils.fromString("sparse");
    private static final BString EXPIRE_AFTER_SECONDS = StringUtils.fromString("expireAfterSeconds");
    private static final BString VERSION = StringUtils.fromString("version");
    private static final BString WEIGHTS = StringUtils.fromString("weights");
    private static final BString DEFAULT_LANGUAGE = StringUtils.fromString("defaultLanguage");
    private static final BString LANGUAGE_OVERRIDE = StringUtils.fromString("languageOverride");
    private static final BString TEXT_VERSION = StringUtils.fromString("textVersion");
    private static final BString SPHERE_VERSION = StringUtils.fromString("sphereVersion");
    private static final BString BITS = StringUtils.fromString("bits");
    private static final BString MIN = StringUtils.fromString("min");
    private static final BString MAX = StringUtils.fromString("max");
    private static final BString PARTIAL_FILTER_EXPRESSION = StringUtils.fromString("partialFilterExpression");
    private static final BString HIDDEN = StringUtils.fromString("hidden");
    private static final BString UPSERT = StringUtils.fromString("upsert");
    private static final BString HINT_STRING = StringUtils.fromString("hintString");
    private static final BString MATCHED_COUNT = StringUtils.fromString("matchedCount");
    private static final BString MODIFIED_COUNT = StringUtils.fromString("modifiedCount");
    private static final BString UPSERTED_ID = StringUtils.fromString("upsertedId");
    private static final BString DELETED_COUNT = StringUtils.fromString("deletedCount");
    private static final BString ACKNOWLEDGED = StringUtils.fromString("acknowledged");

    private static final String EMPTY_JSON = "{}";
    private static final String UPDATE_RESULT_TYPE = "UpdateResult";
    private static final String DELETE_RESULT_TYPE = "DeleteResult";
    private static final String INDEX_TYPE = "Index";
    static final String STREAM_COMPLETION_TYPE = "stream.completion.type";

    public static BError initCollection(BObject collection, BObject database, BString collectionName) {
        try {
            MongoDatabase mongoDatabase = (MongoDatabase) database.getNativeData(Utils.MONGO_DATABASE);
            MongoCollection<Document> mongoCollection = mongoDatabase.getCollection(collectionName.getValue());
            collection.addNativeData(Utils.MONGO_COLLECTION, mongoCollection);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static BError insertOne(BObject collection, BString entry, BMap<BString, Object> options) {
        try {
            MongoCollection<Document> mongoCollection =
                    (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
            InsertOneOptions insertOneOptions = getInsertOneOptions(options);
            mongoCollection.insertOne(Document.parse(entry.getValue()), insertOneOptions);
        } catch (MongoWriteException e) {
            return createError(ErrorType.DATABASE_ERROR, e.getError().getMessage());
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static BError insertMany(BObject collection, BArray entries, BMap<BString, Object> options) {
        try {
            MongoCollection<Document> mongoCollection =
                    (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
            InsertManyOptions insertManyOptions = getInsertManyOptions(options);
            List<Document> entryList = new ArrayList<>();
            for (String entry : entries.getStringArray()) {
                entryList.add(Document.parse(entry));
            }
            mongoCollection.insertMany(entryList, insertManyOptions);
        } catch (MongoWriteException e) {
            return createError(ErrorType.DATABASE_ERROR, e.getError().getMessage());
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static Object find(BObject collection, BMap<BString, Object> filter, BMap<BString, Object> options,
                              Object projectionInput, BTypedesc targetType) {
        try {
            Integer limit, batchSize, skip;
            String sort = options.get(SORT) != null ? options.get(SORT).toString() : EMPTY_JSON;
            limit = options.getIntValue(LIMIT) != null ? options.getIntValue(LIMIT).intValue() : null;
            batchSize = options.getIntValue(SKIP) != null ? options.getIntValue(SKIP).intValue() : null;
            skip = options.getIntValue(SKIP) != null ? options.getIntValue(SKIP).intValue() : null;

            Document projectionDocument = getProjection(projectionInput, targetType);
            Document filterDocument = Document.parse(filter.toString());
            Document sortDocument = Document.parse(sort);

            MongoCollection<Document> mongoCollection =
                    (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
            FindIterable<Document> result =
                    mongoCollection.find(filterDocument).projection(projectionDocument).sort(sortDocument);
            if (limit != null) {
                result.limit(limit);
            }
            if (batchSize != null) {
                result.batchSize(batchSize);
            }
            if (skip != null) {
                result.skip(skip);
            }
            MongoCursor<Document> cursor = result.iterator();
            return createStream(targetType, cursor);
        } catch (BError e) {
            return e;
        } catch (MongoQueryException e) {
            return createError(ErrorType.APPLICATION_ERROR, e.getErrorMessage(), e);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object findOne(BObject collection, BMap<BString, Object> filter, BMap<BString, Object> options,
                                 Object projectionInput, BTypedesc targetType) {
        try {
            String sort = options.get(SORT) != null ? options.get(SORT).toString() : EMPTY_JSON;

            Document filterDocument = Document.parse(filter.toString());
            Document projectionDocument = getProjection(projectionInput, targetType);
            Document sortDocument = Document.parse(sort);

            MongoCollection<Document> mongoCollection =
                    (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
            Document result = mongoCollection.find(filterDocument)
                    .projection(projectionDocument).sort(sortDocument).first();
            if (result == null) {
                return null;
            }
            return FromJsonStringWithType.fromJsonStringWithType(fromString(result.toJson()), targetType);
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object countDocuments(BObject collection, BMap<BString, Object> filter,
                                        BMap<BString, Object> options) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        CountOptions countOptions = getCountOptions(options);
        try {
            return mongoCollection.countDocuments(Document.parse(filter.toString()), countOptions);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static BError createIndex(BObject collection, BMap<BString, Object> keys, BMap<BString, Object> options) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            mongoCollection.createIndex(Document.parse(keys.toString()), getIndexOptions(options));
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static Object listIndexes(BObject collection) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            MongoCursor<Document> cursor = mongoCollection.listIndexes().iterator();
            BObject resultIterator = ValueCreator.createObjectValue(getModule(), Utils.RESULT_ITERATOR_OBJECT_NAME);
            resultIterator.addNativeData(Utils.MONGO_CURSOR, cursor);
            Type indexType = ValueCreator.createRecordValue(getModule(), INDEX_TYPE).getType();
            resultIterator.addNativeData(STREAM_COMPLETION_TYPE, indexType);
            Type completionType = TypeCreator.createUnionType(PredefinedTypes.TYPE_ERROR, PredefinedTypes.TYPE_NULL);
            StreamType streamType = TypeCreator.createStreamType(indexType, completionType);
            return ValueCreator.createStreamValue(streamType, resultIterator);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static BError dropIndex(BObject collection, BString indexName) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            mongoCollection.dropIndex(indexName.getValue());
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static BError dropIndexes(BObject collection) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            mongoCollection.dropIndexes();
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static BError drop(BObject collection) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            mongoCollection.drop();
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static Object updateOne(BObject collection, BMap<BString, Object> filter, BMap<BString, Object> update,
                                   BMap<BString, Object> options) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            UpdateResult updateResult = mongoCollection.updateOne(Document.parse(filter.toString()),
                    Document.parse(getUpdateOperators(update).toString()), getUpdateOptions(options));
            return getUpdateResult(updateResult);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object updateMany(BObject collection, BMap<BString, Object> filter, BMap<BString, Object> update,
                                    BMap<BString, Object> options) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            UpdateResult updateResult = mongoCollection.updateMany(Document.parse(filter.toString()),
                    Document.parse(getUpdateOperators(update).toString()), getUpdateOptions(options));
            return getUpdateResult(updateResult);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object distinct(BObject collection, BString fieldName, BMap<BString, Object> filter,
                                  BTypedesc targetType) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        Class resultClass = getResultClass(targetType);
        try {
            if (filter != null) {
                MongoCursor cursor = mongoCollection.distinct(fieldName.getValue(),
                        Document.parse(filter.toString()), resultClass).cursor();
                return createStream(targetType, cursor);
            }
            MongoCursor cursor = mongoCollection.distinct(fieldName.getValue(), resultClass).cursor();
            return createStream(targetType, cursor);
        } catch (Exception e) {
            BError cause = createError(ErrorType.DATABASE_ERROR, e.getMessage());
            return createError(ErrorType.DATABASE_ERROR, "Failed to retrieve distinct values", cause);
        }
    }

    public static Object deleteOne(BObject collection, BMap<BString, Object> filter) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            DeleteResult deleteResult = mongoCollection.deleteOne(Document.parse(filter.toString()));
            return getDeleteResult(deleteResult);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object deleteMany(BObject collection, Object filter) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        try {
            DeleteResult deleteResult = mongoCollection.deleteMany(Document.parse(filter.toString()));
            return getDeleteResult(deleteResult);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    public static Object aggregate(BObject collection, BArray pipeline, BTypedesc targetType) {
        MongoCollection<Document> mongoCollection =
                (MongoCollection<Document>) collection.getNativeData(Utils.MONGO_COLLECTION);
        List<Document> pipelineList = getPipeline(pipeline, targetType.getDescribingType());
        try {
            MongoCursor<Document> cursor = mongoCollection.aggregate(pipelineList).iterator();
            return createStream(targetType, cursor);
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
    }

    private static InsertOneOptions getInsertOneOptions(BMap<BString, Object> options) {
        InsertOneOptions insertOneOptions = new InsertOneOptions();
        insertOneOptions.bypassDocumentValidation(options.getBooleanValue(BYPASS_DOCUMENT_VALIDATION));
        if (options.containsKey(COMMENT)) {
            insertOneOptions.comment(options.getStringValue(COMMENT).getValue());
        }
        return insertOneOptions;
    }

    private static InsertManyOptions getInsertManyOptions(BMap<BString, Object> options) {
        InsertManyOptions insertManyOptions = new InsertManyOptions();
        insertManyOptions.ordered(options.getBooleanValue(ORDERED));
        insertManyOptions.bypassDocumentValidation(options.getBooleanValue(BYPASS_DOCUMENT_VALIDATION));
        if (options.containsKey(COMMENT)) {
            insertManyOptions.comment(options.getStringValue(COMMENT).getValue());
        }
        return insertManyOptions;
    }

    private static CountOptions getCountOptions(BMap<BString, Object> options) {
        CountOptions countOptions = new CountOptions();
        if (options.containsKey(LIMIT)) {
            countOptions.limit(options.getIntValue(LIMIT).intValue());
        }
        if (options.containsKey(SKIP)) {
            countOptions.skip(options.getIntValue(SKIP).intValue());
        }
        if (options.containsKey(MAX_TIME_MS)) {
            countOptions.maxTime(options.getIntValue(MAX_TIME_MS).intValue(), TimeUnit.MILLISECONDS);
        }
        if (options.containsKey(HINT)) {
            countOptions.hint(Document.parse(options.getStringValue(HINT).getValue()));
        }
        return countOptions;
    }

    private static IndexOptions getIndexOptions(BMap<BString, Object> options) {
        IndexOptions indexOptions = new IndexOptions();
        if (options.containsKey(BACKGROUND)) {
            indexOptions.background(options.getBooleanValue(BACKGROUND));
        }
        if (options.containsKey(UNIQUE)) {
            indexOptions.unique(options.getBooleanValue(UNIQUE));
        }
        if (options.containsKey(NAME)) {
            indexOptions.name(options.getStringValue(NAME).getValue());
        }
        if (options.containsKey(SPARSE)) {
            indexOptions.sparse(options.getBooleanValue(SPARSE));
        }
        if (options.containsKey(EXPIRE_AFTER_SECONDS)) {
            indexOptions.expireAfter(options.getIntValue(EXPIRE_AFTER_SECONDS), TimeUnit.SECONDS);
        }
        if (options.containsKey(VERSION)) {
            indexOptions.version(options.getIntValue(VERSION).intValue());
        }
        if (options.containsKey(WEIGHTS)) {
            indexOptions.weights(Document.parse(options.getMapValue(WEIGHTS).toString()));
        }
        if (options.containsKey(DEFAULT_LANGUAGE)) {
            indexOptions.defaultLanguage(options.getStringValue(DEFAULT_LANGUAGE).getValue());
        }
        if (options.containsKey(LANGUAGE_OVERRIDE)) {
            indexOptions.languageOverride(options.getStringValue(LANGUAGE_OVERRIDE).getValue());
        }
        if (options.containsKey(TEXT_VERSION)) {
            indexOptions.textVersion(options.getIntValue(TEXT_VERSION).intValue());
        }
        if (options.containsKey(SPHERE_VERSION)) {
            indexOptions.sphereVersion(options.getIntValue(SPHERE_VERSION).intValue());
        }
        if (options.containsKey(BITS)) {
            indexOptions.bits(options.getIntValue(BITS).intValue());
        }
        if (options.containsKey(MIN)) {
            indexOptions.min(options.getFloatValue(MIN));
        }
        if (options.containsKey(MAX)) {
            indexOptions.max(options.getFloatValue(MAX));
        }
        if (options.containsKey(PARTIAL_FILTER_EXPRESSION)) {
            indexOptions.partialFilterExpression(Document.parse(
                    options.getMapValue(PARTIAL_FILTER_EXPRESSION).toString()));
        }
        if (options.containsKey(HIDDEN)) {
            indexOptions.hidden(options.getBooleanValue(HIDDEN));
        }
        return indexOptions;
    }

    private static UpdateOptions getUpdateOptions(BMap<BString, Object> options) {
        UpdateOptions updateOptions = new UpdateOptions();
        updateOptions.upsert(options.getBooleanValue(UPSERT));
        updateOptions.bypassDocumentValidation(options.getBooleanValue(BYPASS_DOCUMENT_VALIDATION));
        if (options.containsKey(HINT)) {
            updateOptions.hint(Document.parse(options.getStringValue(HINT).getValue()));
        }
        if (options.containsKey(HINT_STRING)) {
            updateOptions.hintString(options.getStringValue(HINT_STRING).getValue());
        }
        if (options.containsKey(COMMENT)) {
            updateOptions.comment(options.getStringValue(COMMENT).getValue());
        }
        return updateOptions;
    }

    private static BMap<BString, Object> getUpdateOperators(BMap<BString, Object> update) {
        BMap<BString, Object> updateOperators = ValueCreator.createMapValue();
        for (Map.Entry<BString, Object> entry : update.entrySet()) {
            BString key = StringUtils.fromString("$").concat(entry.getKey());
            updateOperators.put(key, entry.getValue());
        }
        return updateOperators;
    }

    private static BMap<BString, Object> getUpdateResult(UpdateResult updateResult) {
        RecordType updateResultType =
                (RecordType) ValueCreator.createRecordValue(getModule(), UPDATE_RESULT_TYPE).getType();
        BMap<BString, Object> result = ValueCreator.createRecordValue(updateResultType);
        result.put(MATCHED_COUNT, updateResult.getMatchedCount());
        result.put(MODIFIED_COUNT, updateResult.getModifiedCount());
        BsonValue upsertedId = updateResult.getUpsertedId();
        if (upsertedId != null) {
            String upsertedIdString = upsertedId.asObjectId().getValue().toString();
            result.put(UPSERTED_ID, StringUtils.fromString(upsertedIdString));
        }
        return result;
    }

    private static BMap<BString, Object> getDeleteResult(DeleteResult deleteResult) {
        RecordType deleteResultType =
                (RecordType) ValueCreator.createRecordValue(getModule(), DELETE_RESULT_TYPE).getType();
        BMap<BString, Object> result = ValueCreator.createRecordValue(deleteResultType);
        result.put(DELETED_COUNT, deleteResult.getDeletedCount());
        result.put(ACKNOWLEDGED, deleteResult.wasAcknowledged());
        return result;
    }
}

