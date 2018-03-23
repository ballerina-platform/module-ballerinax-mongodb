import ballerina/data.mongodb;

const string cassandraHost = "127.0.0.1";

function testConnectorInitWithDirectUrl() returns (json) {
    endpoint mongodb:Client conn {
        host: "",
        dbName: "studentdb",
        username: "",
        password: "",
        options: {url: "mongodb://" + cassandraHost + ":27017/?sslEnabled=false&serverSelectionTimeout=500"}
    };

    json queryString = {"name":"Jim", "age":"21"};
    json result = conn -> find("students", queryString);
    conn -> close();
    return result;
}

function testConnectorInitWithConnectionPoolProperties() returns (json) {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled:false,
                    serverSelectionTimeout:500, maxPoolSize:1, maxIdleTime:60000, maxLifeTime:1800000,
                    minPoolSize:1, waitQueueMultiple:1, waitQueueTimeout:150}
    };
    json queryString = {"name":"Jim", "age":"21"};
    json result = conn -> find("students", queryString);
    conn -> close();
    return result;
}

function testConnectorInitWithInvalidAuthMechanism() {
    endpoint mongodb:Client conn {
        host:cassandraHost,
        dbName:"studentdb",
        username:"",
        password:"",
        options:{sslEnabled: false,
                    serverSelectionTimeout: 500, authMechanism: "invalid-auth-mechanism" }
    };
}