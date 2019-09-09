package org.wso2.mongo.endpoint;

import org.ballerinalang.jvm.values.HandleValue;
import org.ballerinalang.jvm.values.MapValue;
import org.wso2.mongo.MongoDBDataSource;
import com.mongodb.client.MongoDatabase;

public class InitMongoDbClient {
    public static HandleValue initClient(MapValue config) {

        String host = config.getStringValue("host");
        String dbName = config.getStringValue("dbName");
        String username = config.getStringValue("userName");
        String password = config.getStringValue("password");
        MapValue options = config.getMapValue("option");

        MongoDBDataSource dataSource = new MongoDBDataSource();
        dataSource.init(host, dbName, username, password, options);

        return new HandleValue(dataSource);
    }
}
