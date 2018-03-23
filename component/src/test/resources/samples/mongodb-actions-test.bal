import ballerina/data.mongodb;

const string cassandraHost = "127.0.0.1";

function insert() {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json document = {"name":"Tom", "age":"20"};
    _ = conn -> insert("students", document);
    _ = conn -> close();
}

function find() returns (json) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };
    json queryString = {"age":"21"};
    json result =? conn -> find("students", queryString);
    _ = conn -> close();
    return result;
}

function findWithNullQuery() returns (json) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };
    json queryString = null;
    json result =? conn -> find("students", queryString);
    _ = conn -> close();
    return result;
}

function findOne() returns (json) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };
    json queryString = {"name":"Jim", "age":"21"};
    json result =? conn -> findOne("students", queryString);
    _ = conn -> close();
    return result;
}

function findOneWithNullQuery() returns (json) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json queryString = null;
    json result =? conn -> findOne("students", queryString);
    _ = conn -> close();
    return result;
}

function deleteMultipleRecords() returns (int) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json filter = {"age":"25"};
    int result =? conn -> delete("students", filter, true);
    _ = conn -> close();
    return result;
}

function deleteSingleRecord() returns (int) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json filter = {"age":"13"};
    int result =? conn -> delete("students", filter, false);
    _ = conn -> close();
    return result;
}

function updateMultipleRecords() returns (int) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json filter = {"age":"28"};
    json document = {"$set": {"age":"27"}};
    int result =? conn -> update("students", filter, document, true, false);
    _ = conn -> close();
    return result;
}

function updateSingleRecord() returns (int) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json filter = {"age":"30"};
    json document = {"$set": {"age":"32"}};
    int result =? conn -> update("students", filter, document, false, false);
    _ = conn -> close();
    return result;
}

function batchInsert() {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json docs = [{name:"Jessie",age:"18"}, {name:"Rose",age:"17"}, {name:"Anne",age:"15"}];
    _ = conn -> batchInsert("students", docs);
    _ = conn -> close();
}
