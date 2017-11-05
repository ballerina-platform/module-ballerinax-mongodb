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
import org.ballerinalang.model.values.BRefValueArray;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaAction;
import org.ballerinalang.natives.annotations.ReturnType;

/**
 * {@code BatchInsert} action to insert multiple documents into a collection.
 *
 * @since 0.95.0
 */
@BallerinaAction(
            packageName = "ballerina.data.mongodb",
            actionName = "batchInsert",
            connectorName = Constants.CONNECTOR_NAME,
            args = {@Argument(name = "c", type = TypeKind.CONNECTOR),
                    @Argument(name = "collectionName", type = TypeKind.STRING),
                    @Argument(name = "documents", type = TypeKind.ARRAY, elementType = TypeKind.JSON)
            },
            returnType = { @ReturnType(type = TypeKind.INT) }
        )
public class BatchInsert extends AbstractMongoDBAction {

    @Override
    public ConnectorFuture execute(Context context) {
        BConnector bConnector = (BConnector) getRefArgument(context, 0);
        String collectionName = getStringArgument(context, 0);
        BRefValueArray documents = (BRefValueArray) getRefArgument(context, 1);
        MongoDBDataSource datasource = getDataSource(bConnector);
        batchInsert(datasource, collectionName, documents);
        return getConnectorFuture();
    }
}
