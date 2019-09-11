package org.wso2.mongo.actions;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.jvm.values.ArrayValue;
import org.ballerinalang.jvm.values.HandleValue;
import org.wso2.mongo.MongoDBDataSource;

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

//
//public void execute(Context context) {
//        BMap<String, BValue> bConnector = (BMap<String, BValue>) context.getRefArgument(0);
//        String collectionName = context.getStringArgument(0);
//        BValueArray documents = (BValueArray) context.getRefArgument(1);
//        MongoDBDataSource datasource = (MongoDBDataSource) bConnector.getNativeData(Constants.CLIENT);
//        try {
//            batchInsert(datasource, collectionName, documents);
//        } catch (Throwable e) {
//            context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
//        }
//    }