# Ballerina MongoDB Client Endpoint

Ballerina MongoDB Client Endpoint is used to connect Ballerina with MongoDB data source. With the Ballerina MongoDB client endpoint following actions are supported.

1. insert - To insert document to a given collection
2. find - To select document from a given collection according to given query.
3. findOne - To select the first document match with the query.
4. update - To update documents that matches to the given filter.
5. delete - To delete documents that matches to the given filter.

Steps to Configure
==================================

Extract wso2-mongodb-package-<version>.zip and copy containing jars in to <BRE_HOME>/bre/lib/

Building From the Source
==================================
If you want to build Ballerina MongoDB client endpoint from the source code:

1. Get a clone or download the source from this repository:
    https://github.com/wso2-ballerina/package-mongodb
2. Run the following Maven command from the ballerina directory: 
    mvn clean install
3. Copy and extract the distribution created at `/component/target/wso2-mongodb-package-<version>.zip`  into <BRE_HOME>/bre/lib/.

Sample
==================================

```ballerina
import wso2/mongodb;
import ballerina/io;

function main(string... args) {
    endpoint mongodb:Client conn {
        host: "localhost",
        dbName: "testballerina",
        username: "",
        password: "",
        options: { sslEnabled: false, serverSelectionTimeout: 500 }
    };

    json doc1 = { "name": "ballerina", "type": "src" };
    json doc2 = { "name": "connectors", "type": "artifacts" };
    json doc3 = { "name": "docerina", "type": "src" };

    var ret = conn->insert("projects", doc1);
    handleInsert(ret, "Insert to projects");
    ret = conn->insert("projects", doc2);
    handleInsert(ret, "Insert to projects");
    ret = conn->insert("projects", doc3);
    handleInsert(ret, "Insert to projects");

    var jsonRet = conn->find("projects", ());
    match jsonRet {
        json j => {
            io:print("initial data:");
            io:println(io:sprintf("%s", j));
        }
        error e => io:println("find failed: " + e.message);
    }

    json queryString = { "name": "ballerina" };
    jsonRet = conn->find("projects", queryString);
    match jsonRet {
        json j => {
            io:print("query result:");
            io:println(io:sprintf("%s", j));
        }
        error e => io:println("find failed: " + e.message);
    }

    jsonRet = conn->findOne("projects", queryString);
    match jsonRet {
        json j => {
            io:print("findOne query result:");
            io:println(io:sprintf("%s", j));
        }
        error e => io:println("find failed: " + e.message);
    }

    json filter = { "type": "src" };
    var deleteRet = conn->delete("projects", filter, true);
    match deleteRet {
        int i => io:println("deleted count: " + i);
        error e => io:println("delete failed: " + e.message);
    }

    conn.stop();
}

function handleInsert(()|error returned, string message) {
    match returned {
        () => io:println(message + " success ");
        error e => io:println(message + " failed: " + e.message);
    }
}
```   
    
