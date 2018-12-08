import wso2/mongodb;
import ballerina/io;

final string mongodbHost = "127.0.0.1";

function testConnectorInitWithDirectUrl() returns (json) {
    mongodb:Client conn = new({
        host: "",
        dbName: "studentdb",
        username: "",
        password: "",
        options: { url: "mongodb://" + mongodbHost + ":27017/?sslEnabled=false&serverSelectionTimeout=500" }
    });

    json queryString = { "name": "Jim", "age": "21" };
    var result = conn->find("students", queryString);
    json j;
    if (result is json) {
        io:println(result);
        j = result;
    } else if (result is error) {
        j = { "Error" : result.reason() };
    } else {
        j = { "Error" : "Unreachable Code" };
    }
    conn.stop();
    return j;
}

function testConnectorInitWithConnectionPoolProperties() returns (json) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500, maxPoolSize: 1, maxIdleTime: 60000, maxLifeTime: 1800000,
            minPoolSize: 1, waitQueueMultiple: 1, waitQueueTimeout: 150 }
    });
    json queryString = { "name": "Jim", "age": "21" };
    var result = conn->find("students", queryString);
    json j;
    if (result is json) {
        io:println(result);
        j = result;
    } else if (result is error) {
        j = { "Error" : result.reason() };
    } else {
        j = { "Error" : "Unreachable Code" };
    }
    conn.stop();
    return j;
}

function testConnectorInitWithInvalidAuthMechanism() {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500, authMechanism: "invalid-auth-mechanism" }
    });
}
