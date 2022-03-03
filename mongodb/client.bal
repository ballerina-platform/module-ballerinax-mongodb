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
    # + config - `ConnectionConfig` properties. Even though all fields are optional, in order to authenticate the database, 
    #             relavent fields should be given in config record. Following are some examples :
    #             (1) Username, Password
    #             (2) URL - Connection URL
    #             (3) Username, secureSocket, authMechanism etc.
    #             
    # + databaseName - Database name to connect. This is optional in init. You can pass the database name in each
    #                  remote function as well.The precedence will be given to the database name which is passed
    #                  in the remote function. 
    # + return - A `mongodb:Error` if there is any error in the provided configurations or database name
    public isolated function init(ConnectionConfig config, @display {label: "Database Name"} string? databaseName = ())
                                  returns Error? {
        final ConnectionProperties? configOptions = config?.options;
        if (configOptions is ConnectionProperties) {
            final boolean? sslEnabled = configOptions?.sslEnabled;
            if (sslEnabled is boolean) {
                if (sslEnabled && configOptions?.secureSocket is ()) {
                    return error ApplicationError("The connection property `secureSocket` is mandatory " +
                    "when ssl is enabled for connection.");
                }
            }
        }
        check initClient(self, config, databaseName);        
    }

    //Database management operations
    # Lists the database names in the MongoDB server.
    #
    # + return - An array of database names on success or else a `mongodb:DatabaseError` if unable to reach the DB 
    @display {label: "Get Database Names"}
    remote isolated function getDatabasesNames() returns @display {label: "Database Names"} string[]|DatabaseError {
        return getDatabasesNames(self);
    }

    //Collection management operations 
    # Lists the collection names in the MongoDB database.
    #
    # + databaseName - Name of the database 
    # + return - An array of collection names on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Get Collection Names"}
    remote isolated function getCollectionNames(string? databaseName = ()) returns string[]|Error = @java:Method {
        'class: "org.ballerinalang.mongodb.MongoDBDatabaseUtil"
    } external;

    // Collection service operations
    # Counts the documents based on the filter. When the filter is (), it counts all the documents in the collection.
    #
    # + collectionName - Name of the collection
    # + databaseName - Name of the database
    # + filter - Filter for the count ($where & $near can be used)
    # + return - Count of the documents in the collection or else `mongodb:Error` if unable to reach the DB
    @display {label: "Count Documents"}
    remote isolated function countDocuments(@display {label: "Collection Name"} string collectionName, 
                                   @display {label: "Database Name"} string? databaseName = (), 
                                   @display {label: "Filter"} map<json>? filter = ()) 
                                   returns @display {label: "Number of Documents"} int|Error {
        handle collection = check getCollection(self, collectionName, databaseName);
        if (filter is ()) {
            return countDocuments(collection, ());
        }
        string filterString = filter.toJsonString();
        return countDocuments(collection, java:fromString(filterString));
    }

    # Lists the indices associated with the collection.
    #
    # + collectionName - Name of the collection  
    # + databaseName - Name of the database  
    # + rowType - The `typedesc` of the record that should be returned as a result.
    # + return - A A stream<rowType, error?> with indices on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "List Indices"}
    remote isolated function listIndices(@display {label: "Collection Name"} string collectionName,
                                         @display {label: "Database Name"} string? databaseName = (),
                                         @display {label: "Record Type"} typedesc<record {}> rowType = <>)
                                         returns stream<rowType, error?>|Error = @java:Method {
        'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
    } external;

    # Inserts a document.
    # 
    # + document - Document to be inserted as a JSON map
    # + collectionName - Name of the collection
    # + databaseName - Name of the database 
    # + return - `()` on success or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Insert Document"}
    remote isolated function insert(@display {label: "Document"} map<json> document, 
                           @display {label: "Collection Name"} string collectionName, 
                           @display {label: "Database Name"} string? databaseName = ()) returns Error? {
        handle collection = check getCollection(self, collectionName, databaseName);
        string documentStr = document.toJsonString();
        return insert(collection, java:fromString(documentStr));
    }

    # Queries collection for documents, which sorts and limits the returned results.
    #
    # + collectionName - Name of the collection  
    # + databaseName - Name of the database  
    # + filter - Filter for the query  
    # + sort - Sort options for the query  
    # + 'limit - The limit of documents that should be returned. If the limit is -1, all the documents in the result
    #            will be returned.
    # + rowType - The `typedesc` of the record that should be returned as a result.
    # + return - A stream<rowType, error?> of the documents in the collection or else a `mongodb:Error` 
    #            if unable to reach the DB
    @display {label: "Query for Documents"}
    remote isolated function find(@display {label: "Collection Name"} string collectionName,
                                  @display {label: "Database Name"} string? databaseName = (),
                                  @display {label: "Filter for Query"} map<json>? filter = (),
                                  @display {label: "Sort Options"} map<json>? sort = (),
                                  @display {label: "Limit"} int 'limit = -1,
                                  @display {label: "Record Type"} typedesc<record {}> rowType = <>) 
                                  returns stream<rowType, error?>|Error = @java:Method {
        'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
    } external;
    
    # Updates a document based on a condition.
    #
    # + updateStatement - Document for the update condition. Eg: { "$set": { <field1>: <value1>, ... } } , 
    #                     { "$push": { <field>: { "$each": [ <value1>, <value2> ... ] } } }.
    # + collectionName - Name of the collection
    # + databaseName - Name of the database
    # + filter - Filter for the query. Eg: { <field1>: <value1>, ... }.
    # + isMultiple - Whether to update multiple documents
    # + upsert - Whether to insert if update cannot be achieved
    # + return - JSON array of the documents in the collection or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Update Document"}
    remote isolated function update(@display {label: "Document to Update"} map<json> updateStatement, 
                                    @display {label: "Collection Name"} string collectionName, 
                                    @display {label: "Database Name"} string? databaseName = (),
                                    @display {label: "Filter for Query"} map<json>? filter = (), 
                                    @display {label: "Is Multiple Documents"} boolean isMultiple = false,
                                    @display {label: "Is Upsert"} boolean upsert = false) 
                                    returns @display {label: "Number of Updated Documents"} int|Error {
        handle collection = check getCollection(self, collectionName, databaseName);
        string updateDoc = updateStatement.toJsonString();
        if (filter is ()) {
            return update(collection, java:fromString(updateDoc), (), isMultiple, upsert);
        }
        string filterStr = filter.toJsonString();
        return update(collection, java:fromString(updateDoc), java:fromString(filterStr), isMultiple, upsert);
    }

    # Deletes a document based on a condition.
    # 
    # + collectionName - Name of the collection
    # + databaseName - Name of the database 
    # + filter - Filter for the query
    # + isMultiple - Delete multiple documents if the condition is matched
    # + return - The number of deleted documents or else a `mongodb:Error` if unable to reach the DB
    @display {label: "Delete Document"}
    remote isolated function delete(@display {label: "Collection Name"} string collectionName, 
                           @display {label: "Database Name"} string? databaseName = (),
                           @display {label: "Filter"} map<json>? filter = (), 
                           @display {label: "Is Multiple Documents"} boolean isMultiple = false) 
                           returns @display {label: "Number of Deleted Documents"} int|Error {
        handle collection = check getCollection(self, collectionName, databaseName);
        if (filter is ()) {
            return delete(collection, (), isMultiple);
        }
        string filterStr = filter.toJsonString();
        return delete(collection, java:fromString(filterStr), isMultiple);
    }

    # Closes the client.
    @display {label: "Close the Client"}
    remote isolated function close() {
        close(self);
    }
}

isolated function initClient(Client mongoClient, ConnectionConfig config, string? databaseName = ())
                             returns ApplicationError? = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

isolated function getDatabasesNames(Client mongoClient) returns string[]|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

isolated function close(Client mongoClient) = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDataSourceUtil"
} external;

//Database Client Java 
isolated function getCollection(Client mongoClient, string collectionName, string? databaseName)
                                returns handle|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBDatabaseUtil"
} external;

// Collection Client Java
isolated function countDocuments(handle collection, handle? filter) returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

isolated function insert(handle collection, handle document) returns DatabaseError? = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

isolated function update(handle collection, handle update, handle? filter, boolean isMultiple, boolean upsert)
                returns int|Error = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;

isolated function delete(handle collection, handle? filter, boolean isMultiple) returns int|DatabaseError = @java:Method {
    'class: "org.ballerinalang.mongodb.MongoDBCollectionUtil"
} external;
