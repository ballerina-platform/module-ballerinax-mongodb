package org.wso2.mongo.actions;

import org.ballerinalang.jvm.values.*;
import org.wso2.mongo.MongoDBDataSource;

public class Find extends AbstractMongoDBAction {

    public static StreamingJsonValue queryData(HandleValue datasource, String collectionName, Object queryString) {
        MongoDBDataSource mongoDataClient = (MongoDBDataSource) datasource.getValue();
//         mongoDataClient.
//        BMap<String, Object> bConnector = (BMap<String, Object>) context.getRefArgument(0);
//        String collectionName = context.getStringArgument(0);
//        BValue queryInput =  context.getNullableRefArgument(1);
//        if (!(queryInput instanceof BMap)) {
//            context.setReturnValues(MongoDBDataSourceUtils
//                    .getMongoDBConnectorError(context, "query parameter should be a JSON object"));
//        }
//        BMap query = (BMap) context.getNullableRefArgument(1);
        StreamingJsonValue result = find(mongoDataClient, collectionName, (MapValue)queryString);
        return result;

    }
}