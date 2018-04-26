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
package org.ballerinalang.mongodb.endpoint;

import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.BlockingNativeCallableUnit;
import org.ballerinalang.connector.api.BLangConnectorSPIUtil;
import org.ballerinalang.connector.api.Struct;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BStruct;
import org.ballerinalang.mongodb.Constants;
import org.ballerinalang.mongodb.MongoDBDataSource;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;

/**
 * Creates MongoDB Client.
 *
 * @since 0.5.3
 */
@BallerinaFunction(orgName = "ballerina",
                   packageName = "mongodb",
                   functionName = "createClient",
                   args = {
                           @Argument(name = "clientEndpointConfig",
                                     type = TypeKind.STRUCT,
                                     structType = "ClientEndpointConfiguration")
                   },
                   isPublic = true)
public class CreateMongoDBClient extends BlockingNativeCallableUnit {

    @Override
    public void execute(Context context) {
        BStruct configBStruct = (BStruct) context.getRefArgument(0);
        Struct clientEndpointConfig = BLangConnectorSPIUtil.toStruct(configBStruct);

        String host = clientEndpointConfig.getStringField(Constants.EndpointConfig.HOST);
        String dbName = clientEndpointConfig.getStringField(Constants.EndpointConfig.DBNAME);
        String username = clientEndpointConfig.getStringField(Constants.EndpointConfig.USERNAME);
        String password = clientEndpointConfig.getStringField(Constants.EndpointConfig.PASSWORD);
        Struct options = clientEndpointConfig.getStructField(Constants.EndpointConfig.OPTIONS);

        MongoDBDataSource dataSource = new MongoDBDataSource();
        dataSource.init(host, dbName, username, password, options);

        BStruct mongoDBClient = BLangConnectorSPIUtil
                .createBStruct(context.getProgramFile(), Constants.MONGODB_PACKAGE_PATH, Constants.CALLER_ACTIONS);
        mongoDBClient.addNativeData(Constants.CALLER_ACTIONS, dataSource);
        context.setReturnValues(mongoDBClient);
    }
}
