// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;

# Ballerina MongoDB connector provides the capability to perform the MongoDB CRUD operations.
# The connector let you to interact with MongoDB from Ballerina.
@display {label: "MongoDB", iconPath: "icon.png"}
public isolated client class Client {

    # Initialises the `Client` object with the provided `ConnectionConfig` properties.
    #
    # + config - The connection configurations for connecting to a MongoDB server
    # + return - A `mongodb:Error` if the provided configurations are invalid. `()` otherwise.
    public isolated function init(ConnectionConfig config) returns Error? {
        ConnectionProperties? options = config.options;
        if options is ConnectionProperties {
            boolean? sslEnabled = options?.sslEnabled;
            if sslEnabled is boolean && sslEnabled {
                if options.secureSocket is () {
                    return error ApplicationError(
                        "The connection property `secureSocket` is mandatory when ssl is enabled for connection.");
                }
            }
        }
        return initClient(self, config.connection, options);
    }

    # Lists the database names in the MongoDB server.
    #
    # + return - An array of database names on success or else a `mongodb:DatabaseError` if unable to reach the DB
    @display {label: "List Database Names"}
    isolated remote function listDatabaseNames()
    returns @display {label: "Database Names"} string[]|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Client"
    } external;

    # Retrieves a database from the MongoDB server.
    #
    # + databaseName - Name of the database
    # + return - A `mongodb:Database` object on success or else a `mongodb:DatabaseError` if unable to reach the DB
    @display {label: "Get Database"}
    isolated remote function getDatabase(@display {label: "Database Name"} string databaseName) returns Database|Error {
        return new Database(self, databaseName);
    }

    // # Lists the indices associated with the collection.
    // #
    // # + collectionName - Name of the collection
    // # + databaseName - Name of the database
    // # + rowType - The `typedesc` of the record that should be returned as a result.
    // # + return - A A stream<rowType, error?> with indices on success or else a `mongodb:Error` if unable to reach the DB
    // @display {label: "List Indices"}
    // remote isolated function listIndices(@display {label: "Collection Name"} string collectionName,
    //                                      @display {label: "Database Name"} string? databaseName = (),
    //                                      @display {label: "Record Type"} typedesc<record {}> rowType = <>)
    //                                      returns stream<rowType, error?>|Error = @java:Method {
    //     'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
    // } external;

    // # Updates a document based on a condition.
    // #
    // # + updateStatement - Document for the update condition. Eg: { "$set": { <field1>: <value1>, ... } } ,
    // #                     { "$push": { <field>: { "$each": [ <value1>, <value2> ... ] } } }.
    // # + collectionName - Name of the collection
    // # + databaseName - Name of the database
    // # + filter - Filter for the query. Eg: { <field1>: <value1>, ... }.
    // # + isMultiple - Whether to update multiple documents
    // # + upsert - Whether to insert if update cannot be achieved
    // # + return - The number of updated documents or else a `mongodb:Error` if unable to reach the DB
    // @display {label: "Update Document"}
    // remote isolated function update(@display {label: "Document to Update"} map<json> updateStatement,
    //                                 @display {label: "Collection Name"} string collectionName,
    //                                 @display {label: "Database Name"} string? databaseName = (),
    //                                 @display {label: "Filter for Query"} map<json>? filter = (),
    //                                 @display {label: "Is Multiple Documents"} boolean isMultiple = false,
    //                                 @display {label: "Is Upsert"} boolean upsert = false)
    //                                 returns @display {label: "Number of Updated Documents"} int|Error {
    //     handle collection = check getCollection(self, collectionName, databaseName);
    //     string updateDoc = updateStatement.toJsonString();
    //     if (filter is ()) {
    //         return update(collection, java:fromString(updateDoc), (), isMultiple, upsert);
    //     }
    //     string filterStr = filter.toJsonString();
    //     return update(collection, java:fromString(updateDoc), java:fromString(filterStr), isMultiple, upsert);
    // }

    // # Deletes a document based on a condition.
    // #
    // # + collectionName - Name of the collection
    // # + databaseName - Name of the database
    // # + filter - Filter for the query
    // # + isMultiple - Delete multiple documents if the condition is matched
    // # + return - The number of deleted documents or else a `mongodb:Error` if unable to reach the DB
    // @display {label: "Delete Document"}
    // remote isolated function delete(@display {label: "Collection Name"} string collectionName,
    //                        @display {label: "Database Name"} string? databaseName = (),
    //                        @display {label: "Filter"} map<json>? filter = (),
    //                        @display {label: "Is Multiple Documents"} boolean isMultiple = false)
    //                        returns @display {label: "Number of Deleted Documents"} int|Error {
    //     handle collection = check getCollection(self, collectionName, databaseName);
    //     if (filter is ()) {
    //         return delete(collection, (), isMultiple);
    //     }
    //     string filterStr = filter.toJsonString();
    //     return delete(collection, java:fromString(filterStr), isMultiple);
    // }

    // remote isolated function 'distinct(@display {label: "Collection Name"} string collectionName,
    //                                   @display {label: "Field Name"} string 'field,
    //                                   @display {label: "Database Name"} string? databaseName = (),
    //                                   @display {label: "Filter"} map<json>? filter = (),
    //                                   @display {label: "Return Type"} typedesc<anydata> rowType = <>)
    //                               returns stream<rowType, error?>|Error = @java:Method {
    //     'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
    // } external;

    # Closes the client.
    #
    # + return - A `mongodb:Error` if the client is already closed or failed to close the client. `()` otherwise.
    @display {label: "Close the Client"}
    remote isolated function close() returns Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Client"
    } external;
}

// isolated function update(handle collection, handle update, handle? filter, boolean isMultiple, boolean upsert)
//                 returns int|Error = @java:Method {
//     'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
// } external;

// isolated function delete(handle collection, handle? filter, boolean isMultiple) returns int|DatabaseError = @java:Method {
//     'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
// } external;

isolated function initClient(Client 'client, ConnectionParameters|string connection, ConnectionProperties? options)
returns Error? = @java:Method {
    'class: "io.ballerina.lib.mongodb.Client"
} external;
