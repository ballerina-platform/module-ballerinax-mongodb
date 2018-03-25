# Ballerina MongoDB Connector

Ballerina MongoDB Connector is used to connect Ballerina with MongoDB data source. With the Ballerina MongoDB connector following actions are supported.

1. insert - To insert document to a given collection
2. find - To select document from a given collection according to given query.
3. findOne - To select the first document match with the query.
4. update - To update documents that matches to the given filter.
5. delete - To delete documents that matches to the given filter.
6. close - To close the MongoDB connection.



Steps to Configure
==================================

Extract ballerina-mongodb-connector-<version>.zip and copy containing jars in to <BRE_HOME>/bre/lib/

Building From the Source
==================================
If you want to build Ballerina MongoDB connector from the source code:

1. Get a clone or download the source from this repository:
    https://github.com/ballerinalang/connector-mongodb
2. Run the following Maven command from the ballerina directory: 
    mvn clean install
3. Copy and extract the distribution created at `/component/target/target/ballerina-mongodb-connector-<version>.zip`  into <BRE_HOME>/bre/lib/.



Sample
==================================

```ballerina
import ballerina/data.mongodb;
import ballerina/io;

function main (string[] args) {
    endpoint mongodb:Client conn {
        host:"localhost",
        dbName:"testballerina",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json doc1 = {"name":"ballerina", "type":"src"};
    json doc2 = {"name":"connectors", "type":"artifacts"};
    json doc3 = {"name":"docerina", "type":"src"};
    _ = conn -> insert("projects", doc1);
    _ = conn -> insert("projects", doc2);
    _ = conn -> insert("projects", doc3);

    json j0 =? conn -> find("projects", null);
    io:println("initial data:");
    io:println(j0);
    
    json queryString = {"name":"ballerina"};
    json j1 =? conn -> find("projects", queryString);
    io:println("query result:");
    io:println(j1);

    json j2 =? conn -> findOne("projects", queryString);
    io:println("findOne query result:");
    io:println(j2);
    
    json filter = {"type":"src"};
    int deleted =? conn -> delete("projects", filter,true);
    io:println(deleted);     
       
    _ = conn -> close();
}
```   
    
