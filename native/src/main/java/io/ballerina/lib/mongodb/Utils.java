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

import com.mongodb.MongoClientException;
import com.mongodb.MongoCommandException;
import com.mongodb.MongoException;
import com.mongodb.client.MongoCursor;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.StreamType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import org.bson.Document;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static io.ballerina.lib.mongodb.Collection.STREAM_COMPLETION_TYPE;
import static io.ballerina.lib.mongodb.ModuleUtils.getModule;

/**
 * Utility methods for the Ballerina MongoDB connector.
 */
public final class Utils {

    private Utils() {
    }

    static final String RESULT_ITERATOR_OBJECT_NAME = "ResultIterator";
    static final String MONGO_CURSOR = "mongo.cursor";
    static final String MONGO_CLIENT = "mongo.native.client";
    static final String MONGO_DATABASE = "mongo.native.database";
    static final String MONGO_COLLECTION = "mongo.native.collection";
    static final String DATABASE_ERROR_DETAIL = "DatabaseErrorDetail";
    private static final String MONGO_ID_FIELD = "_id";
    private static final String PROJECT_FIELD = "$project";

    static final Map<Integer, Class> DISTINCT_TYPE_MAP = Map.of(
            TypeTags.STRING_TAG, String.class,
            TypeTags.INT_TAG, Long.class,
            TypeTags.FLOAT_TAG, Double.class,
            TypeTags.RECORD_TYPE_TAG, Document.class
    );

    static BError createError(Exception e) {
        return createError(ErrorType.APPLICATION_ERROR, e.getMessage(), null);
    }

    static BError createError(Exception e, String message) {
        BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage(), null);
        return createError(ErrorType.APPLICATION_ERROR, message, cause);
    }

    static BError createError(MongoClientException e) {
        return createError(ErrorType.APPLICATION_ERROR, e.getMessage(), null);
    }

    static BError createError(MongoClientException e, String message) {
        BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage(), null);
        return createError(ErrorType.APPLICATION_ERROR, message, cause);
    }

    static BError createError(MongoException e) {
        return createError(ErrorType.APPLICATION_ERROR, e.getMessage(), null);
    }

    static BError createError(MongoException e, String message) {
        BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage(), null);
        return createError(ErrorType.APPLICATION_ERROR, message, cause);
    }

    static BError createError(MongoCommandException e) {
        BMap<BString, Object> details = ValueCreator.createRecordValue(ModuleUtils.getModule(), DATABASE_ERROR_DETAIL);
        details.put(Client.RecordField.MONGODB_EXCEPTION_TYPE, StringUtils.fromString(e.getErrorCodeName()));
        return createError(ErrorType.DATABASE_ERROR, e.getErrorMessage(), null, details);
    }

    static BError createError(ErrorType errorType, String message) {
        return createError(errorType, message, null, null);
    }

    static BError createError(ErrorType errorType, String message, Throwable e) {
        BError cause = ErrorCreator.createError(StringUtils.fromString(e.getMessage()), e);
        return createError(errorType, message, createError(cause));
    }

    static BError createError(ErrorType errorType, String message, BError cause) {
        return createError(errorType, message, cause, null);
    }

    static BError createError(ErrorType errorType, String errorMessage, BError cause, BMap<BString, Object> details) {
        BString message = StringUtils.fromString(errorMessage);
        return ErrorCreator.createError(ModuleUtils.getModule(), errorType.getErrorType(), message, cause, details);
    }

    static BStream createStream(BTypedesc targetType, MongoCursor cursor) {
        BObject resultIterator = ValueCreator.createObjectValue(getModule(), RESULT_ITERATOR_OBJECT_NAME);
        resultIterator.addNativeData(MONGO_CURSOR, cursor);
        resultIterator.addNativeData(STREAM_COMPLETION_TYPE, targetType.getDescribingType());
        Type completionType = TypeCreator.createUnionType(PredefinedTypes.TYPE_ERROR, PredefinedTypes.TYPE_NULL);
        StreamType streamType = TypeCreator.createStreamType(targetType.getDescribingType(), completionType);
        return ValueCreator.createStreamValue(streamType, resultIterator);
    }

    static Class getResultClass(BTypedesc targetType) {
        if (DISTINCT_TYPE_MAP.containsKey(targetType.getDescribingType().getTag())) {
            return DISTINCT_TYPE_MAP.get(targetType.getDescribingType().getTag());
        }
        return DISTINCT_TYPE_MAP.get(TypeTags.RECORD_TYPE_TAG);
    }

    static List<Document> getPipeline(BArray pipeline, Type targetType) {
        List<Document> documents = new ArrayList<>();
        boolean projectionPresent = false;
        if (pipeline != null) {
            for (int i = 0; i < pipeline.size(); i++) {
                if (pipeline.get(i) instanceof BMap) {
                    BMap<BString, Object> stage = (BMap<BString, Object>) pipeline.get(i);
                    if (stage.containsKey(StringUtils.fromString(PROJECT_FIELD))) {
                        projectionPresent = true;
                    }
                }
                documents.add(Document.parse(pipeline.get(i).toString()));
            }
        }
        if (!projectionPresent) {
            Document projection = new Document(PROJECT_FIELD, getProjectionDocument(new Document(), targetType, "",
                    null));
            documents.add(projection);
        }
        return documents;
    }

    static Document getProjection(Object projectionInput, BTypedesc targetType) {
        if (projectionInput == null) {
            return getProjectionDocument(new Document(), targetType.getDescribingType(), "", null);
        } else {
            return Document.parse(projectionInput.toString());
        }
    }

    static Document getProjectionDocument(Document document, Type type, String key, Set<Type> visitedTypes) {
        Type impliedType = TypeUtils.getImpliedType(type);
        if (visitedTypes == null) {
            visitedTypes = new HashSet<>();
        }
        if (visitedTypes.contains(impliedType)) {
            document.append(key, 1);
            return document;
        }
        visitedTypes.add(impliedType);
        int typeTag = impliedType.getTag();
        return switch (typeTag) {
            case TypeTags.INT_TAG, TypeTags.BYTE_TAG, TypeTags.FLOAT_TAG, TypeTags.DECIMAL_TAG, TypeTags.STRING_TAG,
                 TypeTags.BOOLEAN_TAG, TypeTags.SIGNED8_INT_TAG, TypeTags.UNSIGNED8_INT_TAG, TypeTags.SIGNED16_INT_TAG,
                 TypeTags.UNSIGNED16_INT_TAG, TypeTags.SIGNED32_INT_TAG, TypeTags.UNSIGNED32_INT_TAG,
                 TypeTags.CHAR_STRING_TAG, TypeTags.NULL_TAG, TypeTags.JSON_TAG, TypeTags.XML_TAG, TypeTags.TABLE_TAG,
                 TypeTags.XML_ELEMENT_TAG, TypeTags.XML_PI_TAG, TypeTags.XML_COMMENT_TAG, TypeTags.XML_TEXT_TAG,
                 TypeTags.ANYDATA_TAG, TypeTags.MAP_TAG, TypeTags.TUPLE_TAG, TypeTags.FINITE_TYPE_TAG -> {
                document.append(key, 1);
                yield document;
            }
            case TypeTags.RECORD_TYPE_TAG -> getProjectionDocumentForType(document, (RecordType) impliedType, key,
                    visitedTypes);
            case TypeTags.ARRAY_TAG -> getProjectionDocumentForType(document, (ArrayType) impliedType, key,
                    visitedTypes);
            case TypeTags.UNION_TAG -> getProjectionDocumentForType(document, (UnionType) impliedType, key,
                    visitedTypes);
            case TypeTags.NEVER_TAG -> document;
            default -> throw createError(ErrorType.APPLICATION_ERROR, "Unsupported type: " + type.getName());
        };
    }

    private static Document getProjectionDocumentForType(Document document, RecordType recordType, String key,
                                                         Set<Type> visitedTypes) {
        Map<String, Field> recordFields = recordType.getFields();
        if (!recordFields.containsKey(MONGO_ID_FIELD) && key.isEmpty()) {
            // Remove the _id field from the result when not specified by the user
            document.append(MONGO_ID_FIELD, 0);
        }
        for (Map.Entry<String, Field> field : recordFields.entrySet()) {
            String fieldName = field.getKey();
            if (MONGO_ID_FIELD.equals(fieldName)) {
                continue;
            }
            Type fieldType = field.getValue().getFieldType();
            String parentKey = key.isEmpty() ? fieldName : key + "." + fieldName;
            if (TypeUtils.isValueType(fieldType)) {
                document.append(parentKey, 1);
                continue;
            }
            getProjectionDocument(document, fieldType, parentKey, visitedTypes);
        }
        return document;
    }

    private static Document getProjectionDocumentForType(Document document, ArrayType arrayType, String key,
                                                         Set<Type> visitedTypes) {
        Type elementType = TypeUtils.getImpliedType(arrayType.getElementType());
        if (elementType instanceof RecordType recordType) {
            return getProjectionDocumentForType(document, recordType, key, visitedTypes);
        } else {
            return getProjectionDocument(document, elementType, key, visitedTypes);
        }
    }

    private static Document getProjectionDocumentForType(Document document, UnionType unionType, String key,
                                                         Set<Type> visitedTypes) {
        for (Type memberType : unionType.getMemberTypes()) {
            if (memberType.getTag() == TypeTags.ERROR_TAG || memberType.getTag() == TypeTags.NULL_TAG) {
                continue;
            }
            getProjectionDocument(document, memberType, key, visitedTypes);
        }
        return document;
    }
}
