import wso2/mongodb;
import ballerina/io;

final string mongodbHost = "127.0.0.1";

function insert() {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });

    json document = { "name": "Tom", "age": "20" };
    _ = conn->insert("students", document);
    conn.stop();
}

function find() returns (json) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });
    json queryString = { "age": "21" };
    var result = conn->find("students", queryString);
    json j = getJsonResult(result);
    conn.stop();
    return j;
}

function findWithNilQuery() returns (json) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });
    var result = conn->find("students", ());
    json j = getJsonResult(result);
    conn.stop();
    return j;
}

function findOne() returns (json) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });
    json queryString = { "name": "Jim", "age": "21" };
    var result = conn->findOne("students", queryString);
    json j = getJsonResult(result);
    conn.stop();
    return j;
}

function findOneWithNilQuery() returns (json) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });

    var result = conn->findOne("students", ());
    json j = getJsonResult(result);
    conn.stop();
    return j;
}

function deleteMultipleRecords() returns (int) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });

    json filter = { "age": "25" };
    var result = conn->delete("students", filter, true);
    int i = getIntResult(result);
    conn.stop();
    return i;
}

function deleteSingleRecord() returns (int) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });

    json filter = { "age": "13" };
    var result = conn->delete("students", filter, false);
    int i = getIntResult(result);
    conn.stop();
    return i;
}

function updateMultipleRecords() returns (int) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });

    json filter = { "age": "28" };
    json document = { "$set": { "age": "27" } };
    var result = conn->update("students", filter, document, true, false);
    int i = getIntResult(result);
    conn.stop();
    return i;
}

function updateSingleRecord() returns (int) {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });

    json filter = { "age": "30" };
    json document = { "$set": { "age": "32" } };
    var result = conn->update("students", filter, document, false, false);
    int i = getIntResult(result);
    conn.stop();
    return i;
}

function batchInsert() {
    mongodb:Client conn = new({
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    });

    json docs = [{ name: "Jessie", age: "18" }, { name: "Rose", age: "17" }, { name: "Anne", age: "15" }];
    _ = conn->batchInsert("students", docs);
    conn.stop();
}

function getJsonResult(json|error result) returns json {
    json j;
    if (result is json) {
        io:println(result);
        j = result;
    } else if (result is error) {
        j = { "Error" : result.reason() };
    } else {
        j = { "Error" : "Unreachable Code" };
    }
    return j;
}

function getIntResult(int|error result) returns int {
    int i = -1;
    if (result is int) {
        i = result;
    }
    return i;
}
