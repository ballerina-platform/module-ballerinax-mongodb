package org.wso2.mongo.actions;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.HandleValue;
import org.wso2.mongo.MongoDBDataSource;

/**
 * {@code BatchInsert} action to insert multiple documents into a collection.
 *
 * @since 0.5.4
 */

public class BatchInsert extends AbstractMongoDBAction {

    private static Log log = LogFactory.getLog(Insert.class);

    public static void insertBatchData(HandleValue datasource, String collectionName, ArrayValue documents) {
        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();
        try {
            batchInsert(mongoDataSource, collectionName, documents);
            log.info("Successfully inserted data");
        } catch (Throwable e) {
            log.info("Error occured while inserting data");
            //throw BallerinaErrors.createError("{wso2/mongo}InsertError", "Failed to insert the data: " + e. getMessage());
            // context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
        }
        //return null;
    }
}

