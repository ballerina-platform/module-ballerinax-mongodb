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
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * Utility methods for the Ballerina MongoDB connector.
 */
public final class Utils {

    static final String MONGO_CLIENT = "mongo.native.client";
    static final String MONGO_DATABASE = "mongo.native.database";
    static final String MONGO_COLLECTION = "mongo.native.collection";
    static final String DATABASE_ERROR_DETAIL = "DatabaseErrorDetail";

    private Utils() {
    }

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
}
