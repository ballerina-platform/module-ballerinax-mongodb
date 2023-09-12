// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package org.ballerinalang.mongodb;

/**
 * Constants used in the module-mongodb.
 */
public class MongoDBConstants {

    //Error reasons
    public static final String APPLICATION_ERROR = "ApplicationError";
    public static final String EMPTY_JSON = "{}";
    public static final String EMPTY_STRING = "";
    public static final String RESULT_ITERATOR_OBJECT = "ResultIterator";
    public static final String PLAIN_RESULT_ITERATOR_OBJECT = "PlainResultIterator";
    public static final String MONGO_RESULT_ITERATOR_OBJECT = "MongoResultIterator";
    public static final String RECORD_TYPE_DATA_FIELD = "recordType";
    public static final String RESULT_SET_NATIVE_DATA_FIELD = "MongoCursor";
    public static final String MONGO_CLIENT = "MongoClient";
    public static final String MONGO_DATABASE = "MongoDatabase";

    /**
     * Constants related to `mongodb:DatabaseError`.
     */
    public static final class DatabaseError {

        public static final String NAME = "DatabaseError";
        public static final String DETAIL_RECORD_NAME = "DatabaseErrorDetail";
        public static final String DETAIL_FIELD_MONGODB_EXCEPTION = "mongoDBExceptionType";
    }
}
