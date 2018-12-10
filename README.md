[![Build Status](https://travis-ci.org/wso2-ballerina/module-mongodb.svg?branch=master)](https://travis-ci.org/wso2-ballerina/module-mongodb)

# Ballerina MongoDB Client

Ballerina MongoDB Client is used to connect Ballerina with MongoDB data source. With the Ballerina MongoDB client following operations are supported.

1. insert - To insert document to a given collection
2. find - To select document from a given collection according to given query.
3. findOne - To select the first document match with the query.
4. update - To update documents that matches to the given filter.
5. delete - To delete documents that matches to the given filter.

Steps to Configure
==================================

Extract wso2-mongodb-<version>.zip and  Run the install.sh script to install the module.
You can uninstall the module by running uninstall.sh.

Building From the Source
==================================
If you want to build Ballerina MongoDB client from the source code:

1. Get a clone or download the source from this repository:
    https://github.com/wso2-ballerina/module-mongodb
2. Run the following Maven command from the ballerina directory: 
    mvn clean install
3. Extract the distribution created at `/component/target/wso2-mongodb-<version>.zip`. Run the install.{sh/bat} script to install the module.
You can uninstall the module by running uninstall.{sh/bat}.

Sample
==================================

```ballerina
import wso2/mongodb;
import ballerina/io;

public function main() {
    mongodb:Client conn = new({
        host: "localhost",
        dbName: "testballerina",
        username: "",
        password: "",
        options: { sslEnabled: false, serverSelectionTimeout: 500 }
    });

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
    handleFind(jsonRet);

    json queryString = { "name": "ballerina" };
    jsonRet = conn->find("projects", queryString);
    handleFind(jsonRet);

    jsonRet = conn->findOne("projects", queryString);
    handleFind(jsonRet);

    json filter = { "type": "src" };
    var deleteRet = conn->delete("projects", filter, true);
    if (deleteRet is int) {
        io:println("deleted count: " + deleteRet);
    } else {
        io:println("delete failed: " + deleteRet.reason());
    }

    conn.stop();
}

function handleInsert(()|error returned, string message) {
    if (returned is ()) {
        io:println(message + " success ");
    } else {
        io:println(message + " failed: " + returned.reason());
    }
}

function handleFind(json|error returned) {
    if (returned is json) {
        io:print("initial data:");
        io:println(io:sprintf("%s", returned));
    } else {
        io:println("find failed: " + returned.reason());
    }
}
```   
    
