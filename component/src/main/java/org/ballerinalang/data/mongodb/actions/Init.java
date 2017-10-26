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
package org.ballerinalang.data.mongodb.actions;

import org.ballerinalang.bre.Context;
import org.ballerinalang.connector.api.ConnectorFuture;
import org.ballerinalang.data.mongodb.Constants;
import org.ballerinalang.data.mongodb.MongoDBDataSource;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BConnector;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BString;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaAction;

/**
 * {@code Init} action initializes the MongoDB Connector.
 */
@BallerinaAction(
            packageName = "ballerina.data.mongodb",
            actionName = "<init>",
            connectorName = Constants.CONNECTOR_NAME,
            args = { @Argument(name = "c", type = TypeKind.CONNECTOR) }
        )
public class Init extends AbstractMongoDBAction {

    @Override
    public ConnectorFuture execute(Context context) {
        BConnector bConnector = (BConnector) getRefArgument(context, 0);
        String host = bConnector.getStringField(0);
        String dbName = bConnector.getStringField(1);
        BMap connectorOptions = (BMap) bConnector.getRefField(0);
        BMap sharedMap = (BMap) bConnector.getRefField(1);
        if (sharedMap.get(new BString(Constants.DATASOURCE_KEY)) == null) {
            MongoDBDataSource datasource = new MongoDBDataSource();
            datasource.init(host, dbName, connectorOptions);
            sharedMap.put(new BString(Constants.DATASOURCE_KEY), datasource);
        }
        return getConnectorFuture();
    }

}
