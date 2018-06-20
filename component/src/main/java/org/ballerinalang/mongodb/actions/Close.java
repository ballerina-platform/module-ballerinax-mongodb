/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package org.ballerinalang.mongodb.actions;

import org.ballerinalang.bre.Context;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.mongodb.Constants;
import org.ballerinalang.mongodb.MongoDBDataSource;
import org.ballerinalang.mongodb.MongoDBDataSourceUtils;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;

/**
 * {@code Close} action is used to close the MongoDB connection pool.
 *
 * @since 0.95.0
 */
@BallerinaFunction(
            orgName = "wso2",
            packageName = "mongodb:0.0.0",
            functionName = "close",
            args = {
                    @Argument(name = "parameters", type = TypeKind.OBJECT, structType = Constants.CALLER_ACTIONS,
                              structPackage = "ballerina.mongodb")}
        )
public class Close extends AbstractMongoDBAction {

    @Override
    public void execute(Context context) {
        BStruct bConnector = (BStruct) context.getRefArgument(0);
        MongoDBDataSource datasource = (MongoDBDataSource) bConnector.getNativeData(Constants.CALLER_ACTIONS);
        try {
            close(datasource);
        } catch (Throwable e) {
            context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
        }
    }
}
