package org.wso2.mongo.actions;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.jvm.values.HandleValue;
import org.wso2.mongo.MongoDBDataSource;

public class Close extends AbstractMongoDBAction {
    private static Log log = LogFactory.getLog(Insert.class);
        public static void closeConnection(HandleValue datasource) {

        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();

        try {
            close(mongoDataSource);
            log.info("Successfully closed connection");
        } catch (Throwable e) {
            log.info("Error occured while closing connection");
            //throw BallerinaErrors.createError("{wso2/mongo}InsertError", "Failed to insert the data: " + e. getMessage());
            // context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
        }
    }
}

