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

package org.wso2.mongo.exceptions;

import org.ballerinalang.jvm.BallerinaErrors;
import org.ballerinalang.jvm.BallerinaValues;
import org.ballerinalang.jvm.types.BPackage;
import org.ballerinalang.jvm.values.BmpStringValue;
import org.ballerinalang.jvm.values.ErrorValue;
import org.ballerinalang.jvm.values.MapValue;

import java.util.HashMap;
import java.util.Map;

import static org.wso2.mongo.MongoDBConstants.APPLICATION_ERROR_DETAIL_RECORD_NAME;
import static org.wso2.mongo.MongoDBConstants.APPLICATION_ERROR_REASON;
import static org.wso2.mongo.MongoDBConstants.DATABASE_ERROR_DETAIL_RECORD_NAME;
import static org.wso2.mongo.MongoDBConstants.DATABASE_ERROR_REASON;
import static org.wso2.mongo.MongoDBConstants.MODULE_NAME;
import static org.wso2.mongo.MongoDBConstants.ORGANIZATION_NAME;

/**
 * Map Java Exception to Ballerina MongoDB Error.
 */
public class BallerinaErrorGenerator {
    private static BPackage bpackage = new BPackage(ORGANIZATION_NAME, MODULE_NAME);

    public static ErrorValue createBallerinaDatabaseError(Exception e) {

        Map<String, Object> valueMap = new HashMap<>();
        valueMap.put("message", e.getMessage());
        valueMap.put("mongoDBExceptionType", e.getClass().getSimpleName());
        valueMap.put("cause", e.getCause());

        MapValue<String, Object> recordValue = BallerinaValues
                .createRecordValue(bpackage, DATABASE_ERROR_DETAIL_RECORD_NAME, valueMap);

        return BallerinaErrors.createError(new BmpStringValue(DATABASE_ERROR_REASON), recordValue);
    }

    public static ErrorValue createBallerinaApplicationError(Exception e) {
        Map<String, Object> valueMap = new HashMap<>();
        valueMap.put("message", e.getMessage());
        valueMap.put("cause", e.getCause());

        MapValue<String, Object> recordValue = BallerinaValues
                .createRecordValue(bpackage, APPLICATION_ERROR_DETAIL_RECORD_NAME, valueMap);
        return BallerinaErrors.createError(new BmpStringValue(APPLICATION_ERROR_REASON), recordValue);
    }

}
