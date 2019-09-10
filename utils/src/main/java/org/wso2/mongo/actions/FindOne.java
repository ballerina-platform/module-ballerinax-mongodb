package org.wso2.mongo.actions;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.HandleValue;
import org.ballerinalang.jvm.values.ObjectValue;
import org.ballerinalang.jvm.values.StreamingJsonValue;
import org.wso2.mongo.MongoDBDataSource;

public class FindOne extends AbstractMongoDBAction {
    private static Log log = LogFactory.getLog(Insert.class);

    public static String queryOne(HandleValue datasource, String collectionName, Object queryString) {

        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();

        try {
            String result = findOne(mongoDataSource, collectionName, queryString);
            log.info("Successfully retrieved data");
            return result;
        } catch (Throwable e) {
            log.info("Error occured while retrieving data");
            //throw BallerinaErrors.createError("{wso2/mongo}InsertError", "Failed to insert the data: " + e. getMessage());
            // context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
        }
        return null;
    }
}


