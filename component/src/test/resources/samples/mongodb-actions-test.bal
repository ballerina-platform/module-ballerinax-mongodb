import wso2/mongodb;
import ballerina/io;

@final string mongodbHost = "127.0.0.1";

function insert() {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };

    json document = { "name": "Tom", "age": "20" };
    _ = conn->insert("students", document);
    conn.stop();
}

function find() returns (json) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };
    json queryString = { "age": "21" };
    json result = check conn->find("students", queryString);
    io:println(result);
    conn.stop();
    return result;
}

function findWithNilQuery() returns (json) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };
    json result = check conn->find("students", ());
    io:println(result);
    conn.stop();
    return result;
}

function findOne() returns (json) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };
    json queryString = { "name": "Jim", "age": "21" };
    json result = check conn->findOne("students", queryString);
    io:println(result);
    conn.stop();
    return result;
}

function findOneWithNilQuery() returns (json) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };

    json result = check conn->findOne("students", ());
    io:println(result);
    conn.stop();
    return result;
}

function deleteMultipleRecords() returns (int) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };

    json filter = { "age": "25" };
    int result = check conn->delete("students", filter, true);
    conn.stop();
    return result;
}

function deleteSingleRecord() returns (int) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };

    json filter = { "age": "13" };
    int result = check conn->delete("students", filter, false);
    conn.stop();
    return result;
}

function updateMultipleRecords() returns (int) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };

    json filter = { "age": "28" };
    json document = { "$set": { "age": "27" } };
    int result = check conn->update("students", filter, document, true, false);
    conn.stop();
    return result;
}

function updateSingleRecord() returns (int) {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };

    json filter = { "age": "30" };
    json document = { "$set": { "age": "32" } };
    int result = check conn->update("students", filter, document, false, false);
    conn.stop();
    return result;
}

function batchInsert() {
    endpoint mongodb:Client conn {
        host: mongodbHost,
        dbName: "studentdb",
        username: "",
        password: "",
        options: { sslEnabled: false,
            serverSelectionTimeout: 500 }
    };

    json docs = [{ name: "Jessie", age: "18" }, { name: "Rose", age: "17" }, { name: "Anne", age: "15" }];
    _ = conn->batchInsert("students", docs);
    conn.stop();
}
