/*
 * Copyright (c) 2024, WSO2 LLC. (http://www.wso2.org)
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

import com.mongodb.client.MongoCursor;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import org.bson.Document;

import static io.ballerina.lib.mongodb.Collection.STREAM_COMPLETION_TYPE;
import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * Utility functions for Ballerina MongoDB result iterator object.
 *
 * @since 5.0.0
 */
public final class IteratorUtils {
    private IteratorUtils() {
    }

    public static Object nextResult(BObject iterator) {
        MongoCursor cursor = (MongoCursor) iterator.getNativeData(Utils.MONGO_CURSOR);
        Type completionType = (Type) iterator.getNativeData(STREAM_COMPLETION_TYPE);
        if (cursor.hasNext()) {
            Object next = cursor.next();
            String result;
            if (next instanceof Document) {
                result = ((Document) next).toJson();
            } else if (next instanceof String) {
                return fromString((String) next);
            } else {
                result = next.toString();
            }
            try {
                UnionType nextValueType = TypeCreator.createUnionType(completionType, PredefinedTypes.TYPE_ERROR,
                        PredefinedTypes.TYPE_NULL);
                return ValueUtils.convert(JsonUtils.parse(result), nextValueType);
            } catch (BError e) {
                String errorMessage = "Conversion error. Expected type: " + completionType + ", but found: " + result;
                return ErrorCreator.createError(fromString(errorMessage), e);
            } catch (Exception e) {
                return ErrorCreator.createError(fromString("Error while iterating elements"), e);
            }
        }
        return null;
    }

    public static BError close(BObject iterator) {
        try {
            MongoCursor cursor = (MongoCursor) iterator.getNativeData(Utils.MONGO_CURSOR);
            cursor.close();
            return null;
        } catch (Exception e) {
            return Utils.createError(ErrorType.APPLICATION_ERROR, e.getMessage());
        }
    }
}
