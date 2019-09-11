package org.wso2.mongo.actions;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.jvm.BallerinaErrors;
import org.ballerinalang.jvm.values.ErrorValue;
import org.ballerinalang.jvm.values.HandleValue;
import org.wso2.mongo.MongoDBDataSource;


public class Insert extends AbstractMongoDBAction {
    private static Log log = LogFactory.getLog(Insert.class);

    public static void insertData(HandleValue datasource, String collectionName, String document) {
         MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();
        try {
            insert(mongoDataSource, collectionName, document);
            log.info("Successfully inserted data");
        } catch (Throwable e) {
            log.info("Error occured while inserting data");
            throw BallerinaErrors.createError("{wso2/mongo}InsertError", "Failed to insert the data: " + e. getMessage());
           // context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
        }
        //return null;

    }
}
