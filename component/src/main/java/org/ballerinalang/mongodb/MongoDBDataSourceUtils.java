/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.mongodb;

import org.ballerinalang.bre.Context;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BString;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.util.codegen.PackageInfo;
import org.ballerinalang.util.codegen.StructureTypeInfo;

/**
 * This class contains util methods for MongoDB package.
 */
public class MongoDBDataSourceUtils {
    public static BMap<String, BValue> getMongoDBConnectorError(Context context, Throwable throwable) {
        PackageInfo mongoDBPackageInfo = context.getProgramFile().getPackageInfo(Constants.BUILTIN_PACKAGE_PATH);
        StructureTypeInfo errorStructInfo = mongoDBPackageInfo.getStructInfo(Constants.MONGODB_CONNECTOR_ERROR);
        BMap<String, BValue> mongoDBConnectorError = new BMap<>(errorStructInfo.getType());
        if (throwable.getMessage() == null) {
            mongoDBConnectorError.put(Constants.ERROR_MESSAGE_FIELD, new BString(Constants.MONGODB_EXCEPTION_OCCURED));
        } else {
            mongoDBConnectorError.put(Constants.ERROR_MESSAGE_FIELD, new BString(throwable.getMessage()));
        }
        return mongoDBConnectorError;
    }
}
