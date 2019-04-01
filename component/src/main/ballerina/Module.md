## Module overview

This module provides the functionality required to access and manipulate data stored in an MongoDB datasource.

### Client

To access a MongoDB datasource, you must first create a `client` object. Create a `client` object of the MongoDB client type (i.e., `mongodb:Client`) and provide the necessary connection parameters. This will create a pool of connections to the given MongoDB database. A sample for creating a MongoDB client can be found below.

### Database operations

Once the client is created, database operations can be executed through that client. This module provides support for updating data/schema and select data.

## Samples

### Creating a Client
```ballerina
mongodb:Client conn = new({
    host: "localhost",
    dbName: "testballerina",
    username: "",
    password: "",
    options: { sslEnabled: false, serverSelectionTimeout: 500 }
});
```
For the full list of available configuration options refer the API docs of the client.

### Insert data

The insert operation inserts a document to a given collection
```ballerina

json doc1 = { "name": "ballerina", "type": "src" };
var ret = conn->insert("projects", doc1);
if (ret is json) {
    io:print("insert data success:");
    io:println(io:sprintf("%s", ret));
} else {
    io:println("find failed: " + ret.reason());
}
```

### Find data

The find operation selects a document from a given collection
```ballerina

json queryString = { "name": "ballerina" };
var jsonRet = conn->find("projects", queryString);
if (jsonRet is json) {
    io:print("find query result:");
    io:println(io:sprintf("%s", jsonRet));
} else {
    io:println("find failed: " + jsonRet.reason());
}
```

### Find the first match of the data

The findOne operaton selects the first document match with the query.

```ballerina
json queryString = { "name": "ballerina" };
var jsonRet = conn->findOne("projects", queryString);
if (jsonRet is json) {
    io:print("findOne query result:");
    io:println(io:sprintf("%s", jsonRet));
} else {
    io:println("find failed: " + jsonRet.reason());
}
```

### Delete data

The delete operation deletes documents that match the given filter.

```ballerina
json filter = { "type": "src" };
var deleteRet = conn->delete("projects", filter, true);
if (deleteRet is int) {
    io:println("deleted count: " + deleteRet);
} else {
    io:println("delete failed: " + deleteRet.reason());
}
```

### Update data

The update operation updates documents that matches to given filter.

```ballerina
json filter = { "age": "28" };
json document = { "$set": { "age": "27" } };
var result = conn->update("students", filter, document, true, false);
if (result is int) {
    io:println("updated count:: " + result);
} else {
    io:println("update failed: " + result.reason());
}
```

### Batch update data

The batchUpdate operation inserts an array of documents to the given collection.

```ballerina
json docs = [{ name: "Jessie", age: "18" }, { name: "Rose", age: "17" }, { name: "Anne", age: "15" }];
var returned = conn->batchInsert("students", docs);
if (returned is int) {
    io:println("updated count:: " + returned);
} else {
    io:println("update failed: " + returned.reason());
}
```