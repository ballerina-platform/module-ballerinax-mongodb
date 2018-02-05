import ballerina.data.mongodb;

function insert() {
    endpoint<mongodb:ClientConnector> conn {
                create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
serverSelectionTimeout:500});
    }
    json document = {"name":"Tom", "age":"20"};
    conn.insert("students", document);
    conn.close();
}

function find() (json) {
    endpoint<mongodb:ClientConnector> conn {
                    create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
    serverSelectionTimeout:500});
    }
    json query = {"age":"21"};
    json result = conn.find("students", query);
    conn.close();
    return result;
}

function findWithNullQuery() (json) {
    endpoint<mongodb:ClientConnector> conn {
                    create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
    serverSelectionTimeout:500});
    }
    json query = null;
    json result = conn.find("students", query);
    conn.close();
    return result;
}

function findOne() (json) {
    endpoint<mongodb:ClientConnector> conn {
                    create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
    serverSelectionTimeout:500});
    }
    json query = {"name":"Jim", "age":"21"};
    json result = conn.findOne("students", query);
    conn.close();
    return result;
}

function findOneWithNullQuery() (json) {
    endpoint<mongodb:ClientConnector> conn {
                    create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
    serverSelectionTimeout:500});
    }
    json query = null;
    json result = conn.findOne("students", query);
    conn.close();
    return result;
}

function deleteMultipleRecords() (json) {
    endpoint<mongodb:ClientConnector> conn {
                        create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
        serverSelectionTimeout:500});
    }
    json filter = {"age":"25"};
    json result = conn.delete("students", filter, true);
    conn.close();
    return result;
}

function deleteSingleRecord() (json) {
    endpoint<mongodb:ClientConnector> conn {
                        create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
        serverSelectionTimeout:500});
    }
    json filter = {"age":"13"};
    json result = conn.delete("students", filter, false);
    conn.close();
    return result;
}

function updateMultipleRecords() (json) {
    endpoint<mongodb:ClientConnector> conn {
                            create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
            serverSelectionTimeout:500});
    }
    json filter = {"age":"28"};
    json document = {"$set": {"age":"27"}};
    json result = conn.update("students", filter, document, true, false);
    conn.close();
    return result;
}

function updateSingleRecord() (json) {
    endpoint<mongodb:ClientConnector> conn {
                            create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
            serverSelectionTimeout:500});
    }
    json filter = {"age":"30"};
    json document = {"$set": {"age":"32"}};
    json result = conn.update("students", filter, document, false, false);
    conn.close();
    return result;
}

function batchInsert() {
    endpoint<mongodb:ClientConnector> conn {
                                create mongodb:ClientConnector("localhost", "studentdb", {sslEnabled:false,
                serverSelectionTimeout:500});
    }
    json docs = [{name:"Jessie",age:"18"}, {name:"Rose",age:"17"}, {name:"Anne",age:"15"}];
    conn.batchInsert("students", docs);
    conn.close();
}
