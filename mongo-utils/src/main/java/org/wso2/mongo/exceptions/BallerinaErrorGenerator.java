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
import org.ballerinalang.jvm.values.ErrorValue;
import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.jvm.values.api.BString;

import java.util.HashMap;
import java.util.Map;

import static org.wso2.mongo.MongoDBConstants.APPLICATION_ERROR;
import static org.wso2.mongo.MongoDBConstants.BAL_PACKAGE;
import static org.wso2.mongo.MongoDBConstants.DatabaseError.DETAIL_FIELD_MONGODB_EXCEPTION;
import static org.wso2.mongo.MongoDBConstants.DatabaseError.DETAIL_RECORD_NAME;
import static org.wso2.mongo.MongoDBConstants.DatabaseError.NAME;

/**
 * Map Java Exception to Ballerina MongoDB Error.
 */
public class BallerinaErrorGenerator {

    public static ErrorValue createBallerinaDatabaseError(Exception e) {
        Map<String, Object> valueMap = new HashMap<>();
        valueMap.put(DETAIL_FIELD_MONGODB_EXCEPTION, e.getClass().getSimpleName());
        MapValue<BString, Object> recordValue = BallerinaValues
                .createRecordValue(BAL_PACKAGE, DETAIL_RECORD_NAME, valueMap);

        return BallerinaErrors.createDistinctError(NAME, BAL_PACKAGE,  e.getMessage(), recordValue);
    }

    public static ErrorValue createBallerinaApplicationError(Exception e) {
        return BallerinaErrors.createDistinctError(APPLICATION_ERROR, BAL_PACKAGE, e.getMessage());
    }

}
