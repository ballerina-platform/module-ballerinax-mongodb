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
    conn -> insert("students", document);
    conn -> close();
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
    json result = conn -> find("students", queryString);
    conn -> close();
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
    json result = conn -> find("students", queryString);
    conn -> close();
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
    json result = conn -> findOne("students", queryString);
    conn -> close();
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
    json result = conn -> findOne("students", queryString);
    conn -> close();
    return result;
}

function deleteMultipleRecords() returns (json) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json filter = {"age":"25"};
    json result = conn -> delete("students", filter, true);
    conn -> close();
    return result;
}

function deleteSingleRecord() returns (json) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500}
    };

    json filter = {"age":"13"};
    json result = conn -> delete("students", filter, false);
    conn -> close();
    return result;
}

function updateMultipleRecords() returns (json) {
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
    json result = conn -> update("students", filter, document, true, false);
    conn -> close();
    return result;
}

function updateSingleRecord() returns (json) {
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
    json result = conn -> update("students", filter, document, false, false);
    conn -> close();
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
    conn -> batchInsert("students", docs);
    conn -> close();
}
