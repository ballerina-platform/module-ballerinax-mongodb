/*
 *  Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */
package org.ballerinalang.mongodb;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

import com.mongodb.client.MongoCursor;

import org.bson.Document;

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.internal.JsonParser;

/**
 * This class provides functionality for the `RecordIterator` to iterate through the MongoCursor.
 *
 * @since 3.0.0
 */
public class RecordIteratorUtils {
    public RecordIteratorUtils() {
    }

    public static Object nextResult(BObject recordIterator) {
        MongoCursor<Document> results = (MongoCursor<Document>) recordIterator.getNativeData(
                                         MongoDBConstants.RESULT_SET_NATIVE_DATA_FIELD);
        if (results.hasNext()) {
            return JsonParser.parse(results.next().toJson());
        } else {
            return null;
        }
    }

    public static Object closeResult(BObject recordIterator) {
        MongoCursor<Document> results = (MongoCursor<Document>) recordIterator.getNativeData(
                                         MongoDBConstants.RESULT_SET_NATIVE_DATA_FIELD);
        if (results != null) {
            try {
                results.close();
                recordIterator.addNativeData(MongoDBConstants.RESULT_SET_NATIVE_DATA_FIELD, null);
            } catch (Exception e) {
                return ErrorCreator.createError(fromString("Error while closing the result iterator. "), e);
            }
        }
        return null;
    }
}
