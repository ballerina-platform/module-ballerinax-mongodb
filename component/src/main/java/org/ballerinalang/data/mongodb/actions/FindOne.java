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
import org.ballerinalang.model.values.BJSON;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaAction;
import org.ballerinalang.natives.annotations.ReturnType;
/**
 * {@code FindOne} action selects the first document that satisfies the given query criteria.
 */
@BallerinaAction(
            packageName = "ballerina.data.mongodb",
            actionName = "findOne",
            connectorName = Constants.CONNECTOR_NAME,
            args = {@Argument(name = "c", type = TypeKind.CONNECTOR),
                    @Argument(name = "collectionName", type = TypeKind.STRING),
                    @Argument(name = "query", type = TypeKind.JSON)
            },
            returnType = { @ReturnType(type = TypeKind.JSON) }
        )
public class FindOne extends AbstractMongoDBAction {

    @Override
    public ConnectorFuture execute(Context context) {
        BConnector bConnector = (BConnector) getRefArgument(context, 0);
        String collectionName = getStringArgument(context, 0);
        BJSON query = (BJSON) getRefArgument(context, 1);
        MongoDBDataSource datasource = getDataSource(bConnector);
        BJSON result = findOne(datasource, collectionName, query);
        context.getControlStackNew().getCurrentFrame().returnValues[0] = result;
        return getConnectorFuture();
    }
}
