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

import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.CountOptions;
import com.mongodb.client.model.InsertManyOptions;
import com.mongodb.client.model.InsertOneOptions;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.IntersectionType;
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
import org.bson.Document;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import static io.ballerina.lib.mongodb.Utils.createError;

/**
 * This class represents a MongoDB collection in Ballerina MongoDB client.
 */
public final class Collection {

    private static final BString BYPASS_DOCUMENT_VALIDATION = StringUtils.fromString("bypassDocumentValidation");
    private static final BString COMMENT = StringUtils.fromString("comment");
    private static final BString ORDERED = StringUtils.fromString("ordered");
    private static final BString LIMIT = StringUtils.fromString("limit");
    private static final BString SKIP = StringUtils.fromString("skip");
    private static final BString SORT = StringUtils.fromString("sort");
    private static final BString MAX_TIME_MS = StringUtils.fromString("maxTimeMS");
    private static final BString HINT = StringUtils.fromString("hint");

    private static final String EMPTY_JSON = "{}";
    private static final String MONGO_ID_FIELD = "_id";
    private static final String RESULT_ITERATOR_OBJECT_NAME = "ResultIterator";
    static final String MONGO_CURSOR = "mongo.cursor";
    static final String RECORD_TYPE = "record.type";

    private Collection() {
    }

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
        } catch (Exception e) {
            return createError(ErrorType.DATABASE_ERROR, e.getMessage());
        }
        return null;
    }

    public static Object find(BObject collection, BMap<BString, Object> filter, BMap<BString, Object> options,
                              BTypedesc targetType) {
        Integer limit, batchSize, skip;
        String projection = getProjectionDocument(targetType.getDescribingType());
        String sort = options.get(SORT) != null ? options.get(SORT).toString() : EMPTY_JSON;
        limit = options.getIntValue(LIMIT) != null ? options.getIntValue(LIMIT).intValue() : null;
        batchSize = options.getIntValue(SKIP) != null ? options.getIntValue(SKIP).intValue() : null;
        skip = options.getIntValue(SKIP) != null ? options.getIntValue(SKIP).intValue() : null;

        Document filterDocument = Document.parse(filter.toString());
        Document projectionDocument = Document.parse(projection);
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
        BObject resultIterator = ValueCreator.createObjectValue(ModuleUtils.getModule(), RESULT_ITERATOR_OBJECT_NAME);
        resultIterator.addNativeData(MONGO_CURSOR, cursor);
        resultIterator.addNativeData(RECORD_TYPE, targetType.getDescribingType());
        Type completionType = TypeCreator.createUnionType(PredefinedTypes.TYPE_ERROR, PredefinedTypes.TYPE_NULL);
        StreamType streamType = TypeCreator.createStreamType(targetType.getDescribingType(), completionType);
        return ValueCreator.createStreamValue(streamType, resultIterator);
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

    private static String getProjectionDocument(Type targetType) {
        String projectionDocument = "{ ";
        projectionDocument += addProjectionFields(targetType, "");
        projectionDocument += " }";
        return projectionDocument;
    }

    private static String addProjectionFields(RecordType recordType, String parent) {
        StringBuilder resultBuilder = new StringBuilder();
        Map<String, Field> fields = recordType.getFields();
        if ("".equals(parent)) {
            // Remove the _id field from the result when not specified by the user
            if (!fields.containsKey(MONGO_ID_FIELD)) {
                resultBuilder.append("_id: 0, ");
            }
        }
        for (Field field : fields.values()) {
            if (MONGO_ID_FIELD.equals(field.getFieldName())) {
                continue;
            }
            String fieldName = field.getFieldName();
            Type fieldType = field.getFieldType();
            String projectionField = parent + fieldName;
            if (fieldType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                resultBuilder.append(addProjectionFields((RecordType) fieldType, projectionField + "."));
            } else if (fieldType.getTag() == TypeTags.ARRAY_TAG) {
                resultBuilder.append(addProjectionFields((ArrayType) fieldType, projectionField + "."));
            } else {
                resultBuilder.append(projectionField).append(": 1");
            }
            resultBuilder.append(", ");
        }
        return resultBuilder.toString();
    }

    private static String addProjectionFields(ArrayType arrayType, String parent) {
        Type elementType = arrayType.getElementType();
        return addProjectionFields(elementType, parent);
    }

    private static String addProjectionFields(Type type, String parent) {
        if (type.getTag() == TypeTags.RECORD_TYPE_TAG) {
            return addProjectionFields((RecordType) type, parent);
        } else if (type.getTag() == TypeTags.ARRAY_TAG) {
            return addProjectionFields((ArrayType) type, parent);
        } else if (type.getTag() == TypeTags.INTERSECTION_TAG) {
            IntersectionType intersectionType = (IntersectionType) type;
            return addProjectionFields(intersectionType.getEffectiveType(), parent);
        } else {
            return parent + ": 1";
        }
    }
}

