import ballerina/io;
import ballerina/test;

# Before Suite Function

ClientEndpointConfig mongoConfig = {
    host: "localhost",
    dbName: "projectsTest",
    username: "",
    password: "",
    options: {sslEnabled: false, serverSelectionTimeout: 500}
};

Client mongoClient = check new (mongoConfig);

json doc11 = {"name": "ballerina", "type": "src"};
json doc21 = {"name": "connectors", "type": "artifacts"};
json doc31 = {"name": "docerina", "type": "src"};
json doc41 = {"name": "test", "type": "artifacts"};

json filter1 = {"type": "src"};
json replaceFilter1 = {"type": "artifacts"};

@test:Config {}

function testFunction() {
    io:println("-------- Executing MongoDB Tests! -----------");

    var ret = mongoClient->insert("projectsTest", doc11);
    //handleInsert(ret, "Insert to projects");
    ret = mongoClient->insert("projectsTest", doc21);
    //handleInsert(ret, "Insert to projects");
    ret = mongoClient->insert("projectsTest", doc31);
   // handleInsert(ret, "Insert to projects");


    // test:assertEquals("Success");

}

function handleInsert(json|error returned, string message) {
    if (returned is json) {
        io:println(message + " success ");
    } else {
        io:println(message + " failed: " , returned.reason());
    }
}

# After test function

function afterFunc() {
    io:println("I'm the after function!");
}




