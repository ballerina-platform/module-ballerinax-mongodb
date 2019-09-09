//import ballerina/io;
//import ballerina/test;
//
//# Before Suite Function
//
//mongodb:Client conn = new ({
//    host: "localhost",
//    dbName: "Hospital",
//    username: "",
//    password: "",
//    options: {sslEnabled: false, serverSelectionTimeout: 500}
//});
//
//
//json doc11 = {"name": "ballerina", "type": "src"};
//json doc21 = {"name": "connectors", "type": "artifacts"};
//json doc31 = {"name": "docerina", "type": "src"};
//json doc41 = {"name": "test", "type": "artifacts"};
//json filter1 = {"type": "src"};
//json replaceFilter1 = {"type": "artifacts"};
//
//@test:Config {
//    before: "beforeFunc",
//    after: "afterFunc"
//}
//function testFunction() {
//    io:println("I'm in test function!");
//    test:assertTrue(true, msg = "Failed!");
//}
//
//# After test function
//
//function afterFunc() {
//    io:println("I'm the after function!");
//}


