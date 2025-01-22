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
import java.util.List;
import java.util.Map;

import static io.ballerina.lib.mongodb.ModuleUtils.getModule;

/**
 * Utility methods for the Ballerina MongoDB connector.
 */
public final class Utils {

    private Utils() {
    }

    static final String RESULT_ITERATOR_OBJECT_NAME = "ResultIterator";
    static final String MONGO_CURSOR = "mongo.cursor";
    static final String RECORD_TYPE = "record.type";
    static final String MONGO_CLIENT = "mongo.native.client";
    static final String MONGO_DATABASE = "mongo.native.database";
    static final String MONGO_COLLECTION = "mongo.native.collection";
    static final String DATABASE_ERROR_DETAIL = "DatabaseErrorDetail";
    private static final String MONGO_ID_FIELD = "_id";

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
        resultIterator.addNativeData(RECORD_TYPE, targetType.getDescribingType());
        Type completionType = TypeCreator.createUnionType(PredefinedTypes.TYPE_ERROR, PredefinedTypes.TYPE_NULL);
        StreamType streamType = TypeCreator.createStreamType(targetType.getDescribingType(), completionType);
        return ValueCreator.createStreamValue(streamType, resultIterator);
    }

    static Class getResultClass(BTypedesc targetType) {
        if (DISTINCT_TYPE_MAP.containsKey(targetType.getDescribingType().getTag())) {
            return DISTINCT_TYPE_MAP.get(targetType.getDescribingType().getTag());
        }
        return null;
    }

    static List<Document> getPipeline(BArray pipeline, Type targetType) {
        List<Document> documents = new ArrayList<>();
        boolean projectionPresent = false;
        if (pipeline != null) {
            for (int i = 0; i < pipeline.size(); i++) {
                if (pipeline.get(i) instanceof BMap) {
                    BMap<BString, Object> stage = (BMap<BString, Object>) pipeline.get(i);
                    if (stage.containsKey(StringUtils.fromString("$project"))) {
                        projectionPresent = true;
                    }
                }
                documents.add(Document.parse(pipeline.get(i).toString()));
            }
        }
        if (!projectionPresent) {
            Document projection = new Document("$project", Document.parse(getProjectionDocument(targetType)));
            documents.add(projection);
        }
        return documents;
    }

    static String getProjection(Object projectionInput, BTypedesc targetType) {
        if (projectionInput == null) {
            return getProjectionDocument(targetType.getDescribingType());
        } else {
            return projectionInput.toString();
        }
    }

    static String getProjectionDocument(Type type) {
        StringBuilder projectionBuilder = new StringBuilder();
        projectionBuilder.append("{");
        getProjectionForFieldType(type, projectionBuilder, "");
        projectionBuilder.append("}");
        return projectionBuilder.toString();
    }

    private static void getProjectionForFieldType(Type type, StringBuilder projectionBuilder, String parent) {
        Type impliedType = TypeUtils.getImpliedType(type);
        int tag = impliedType.getTag();
        if (tag == TypeTags.RECORD_TYPE_TAG) {
            RecordType recordType = (RecordType) TypeUtils.getImpliedType(type);
            getProjectionForFieldType(recordType, projectionBuilder, parent);
        } else if (tag == TypeTags.ARRAY_TAG) {
            ArrayType arrayType = (ArrayType) type;
            getProjectionForFieldType(arrayType, projectionBuilder, parent);
        } else if (TypeUtils.isValueType(type)) {
            projectionBuilder.append(parent).append("\": 1, ");
        } else if (tag == TypeTags.UNION_TAG) {
            List<Type> memberTypes = ((UnionType) type).getMemberTypes();
            for (Type memberType : memberTypes) {
                if (memberType.getTag() == TypeTags.ERROR_TAG || memberType.getTag() == TypeTags.NULL_TAG) {
                    continue;
                }
                getProjectionForFieldType(memberType, projectionBuilder, parent);
            }
        } else {
            throw createError(ErrorType.APPLICATION_ERROR, "Unsupported type: " + type.getName());
        }
    }

    private static void getProjectionForFieldType(RecordType recordType, StringBuilder projectionBuilder,
                                                  String parent) {
        Map<String, Field> fields = recordType.getFields();
        if ("".equals(parent)) {
            // Remove the _id field from the result when not specified by the user
            if (!fields.containsKey(MONGO_ID_FIELD)) {
                projectionBuilder.append("_id: 0, ");
            }
        }
        for (Map.Entry<String, Field> field : fields.entrySet()) {
            String fieldName = field.getKey();
            if (parent.isEmpty() && MONGO_ID_FIELD.equals(fieldName)) {
                continue;
            }
            String parentValue = parent.isEmpty() ? "\"" + fieldName : parent + "." + fieldName;
            getProjectionForFieldType(field.getValue().getFieldType(), projectionBuilder, parentValue);
        }
    }

    private static void getProjectionForFieldType(ArrayType arrayType, StringBuilder projectionBuilder, String parent) {
        Type elementType = TypeUtils.getImpliedType(arrayType.getElementType());
        if (elementType.getTag() == TypeTags.RECORD_TYPE_TAG) {
            RecordType recordType = (RecordType) elementType;
            getProjectionForFieldType(recordType, projectionBuilder, parent);
        } else {
            projectionBuilder.append("\": 1, ");
        }
    }
}
