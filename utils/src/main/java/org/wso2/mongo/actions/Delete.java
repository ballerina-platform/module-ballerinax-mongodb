package org.wso2.mongo.actions;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.jvm.values.HandleValue;
import org.wso2.mongo.MongoDBDataSource;

public class Delete extends AbstractMongoDBAction {
     private static Log log = LogFactory.getLog(Insert.class);

    public static long deleteData(HandleValue datasource, String collectionName, Object filter, boolean isMultiple) {

        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();

        try {
            long deletedCount = delete(mongoDataSource, collectionName, filter, isMultiple);
            log.info("Successfully retrieved data");
            return deletedCount;
        } catch (Throwable e) {
            log.info("Error occured while retrieving data");
            //throw BallerinaErrors.createError("{wso2/mongo}InsertError", "Failed to insert the data: " + e. getMessage());
            // context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
        }
        return 0;
    }
}