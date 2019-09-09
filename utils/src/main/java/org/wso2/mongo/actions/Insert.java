package org.wso2.mongo.actions;

import org.ballerinalang.jvm.values.MapValue;
import org.ballerinalang.jvm.values.ObjectValue;
import org.ballerinalang.jvm.values.StreamingJsonValue;
import org.wso2.mongo.MongoDBDataSource;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


public class Insert extends AbstractMongoDBAction {
    private static Log log = LogFactory.getLog(Insert.class);

    public static void insertData(MongoDBDataSource datasource, String collectionName, Object document) {
         MongoDBDataSource mongoDataSource = datasource;
        try {
            insert(mongoDataSource, collectionName, (MapValue) document);
            log.info("Successfully inserted data");
        } catch (Throwable e) {
            log.info("Error occured while inserting data");
           // context.setReturnValues(MongoDBDataSourceUtils.getMongoDBConnectorError(context, e));
        }

    }

}
