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

package org.wso2.mongo;

import org.ballerinalang.jvm.BallerinaErrors;
import org.ballerinalang.jvm.BallerinaValues;
import org.ballerinalang.jvm.types.BPackage;
import org.ballerinalang.jvm.values.ErrorValue;
import org.ballerinalang.jvm.values.MapValue;

import static org.wso2.mongo.MongoDBConstants.APPLICATION_ERROR_REASON;
import static org.wso2.mongo.MongoDBConstants.DATABASE_ERROR_REASON;
import static org.wso2.mongo.MongoDBConstants.ERROR_DETAIL_RECORD_TYPE_NAME;
import static org.wso2.mongo.MongoDBConstants.MODULE_NAME;
import static org.wso2.mongo.MongoDBConstants.MODULE_VERSION;
import static org.wso2.mongo.MongoDBConstants.ORGANIZATION_NAME;

/**
 * Util class.
 */
public class MongoDBUtils {
    public static ErrorValue createBallerinaDatabaseError(BallerinaMongoDbException e) {
        MapValue record = createRecordValue(e);
        return BallerinaErrors.createError(DATABASE_ERROR_REASON, record);
    }

    public static ErrorValue createBallerinaApplicationError(BallerinaMongoDbException e) {
        MapValue record = createRecordValue(e);
        return BallerinaErrors.createError(APPLICATION_ERROR_REASON, record);
    }

    private static MapValue createRecordValue(BallerinaMongoDbException e) {
        BPackage bpackage = new BPackage(ORGANIZATION_NAME, MODULE_NAME, MODULE_VERSION);
        MapValue recordValue = BallerinaValues.createRecordValue(bpackage, ERROR_DETAIL_RECORD_TYPE_NAME);
        return BallerinaValues.createRecord(recordValue, e.getMessage(), e.getCause(), e.getDetail());
    }
}
