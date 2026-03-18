// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

# MongoDB collection that can be used to perform operations on the collection.
@display {
    label: "MongoDB Collection"
}
public isolated client class Collection {

    private final string collectionName;

    isolated function init(Database database, string collectionName) returns Error? {
        self.collectionName = collectionName;
        check initCollection(self, database, collectionName);
    }

    # Returns the name of the collection.
    #
    # + return - The name of the collection
    public isolated function name() returns string {
        return self.collectionName;
    }

    # Inserts a single document into the collection.
    #
    # + document - The document to be inserted into the collection
    # + options - The options to apply to the insert operation
    # + return - An `mongodb:Error` if the operation failed, otherwise nil
    isolated remote function insertOne(record {|anydata...;|} document, InsertOneOptions options = {}) returns Error? {
        string documentString = document.toJsonString();
        return check insertOne(self, documentString, options);
    }

    # Inserts multiple documents into the collection.
    #
    # + documents - The documents to be inserted into the collection
    # + options - The options to apply to the insert operation
    # + return - An `mongodb:Error` if the operation failed, otherwise nil
    isolated remote function insertMany(record {|anydata...;|}[] documents, InsertManyOptions options = {}) returns Error? {
        string[] documentString = documents.'map((doc) => doc.toJsonString());
        return check insertMany(self, documentString, options);
    }

    # Finds documents from the collection.
    #
    # + filter - The query filter to apply when retrieving documents
    # + findOptions - The additional options to apply to the find operation
    # + projection - The projection to apply to the find operation. If not provided, the projection will be generated
    # based on the targetType
    # + targetType - The type of the returned documents
    # + return - A stream of documents which match the provided filter, or an `mongodb:Error` if the operation failed.
    #               Close the resulted stream once the operation is completed.
    isolated remote function find(map<json> filter = {}, FindOptions findOptions = {}, map<json>? projection = (),
    typedesc<record {|anydata...;|}> targetType = <>) returns stream<targetType, error?>|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Finds a single document from the collection.
    #
    # + filter - The query filter to apply when retrieving documents
    # + findOptions - The additional options to apply to the find operation
    # + projection - The projection to apply to the find operation. If not provided, the projection will be generated
    # based on the targetType
    # + targetType - The type of the returned document
    # + return - The document which matches the provided filter, or an `mongodb:Error` if the operation failed
    isolated remote function findOne(map<json> filter = {}, FindOptions findOptions = {}, map<json>? projection = (),
    typedesc<record {|anydata...;|}> targetType = <>) returns targetType|Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Counts the number of documents in the collection.
    #
    # + filter - The query filter to apply when counting documents
    # + options - The additional options to apply to the count operation
    # + return - The number of documents in the collection, or an `mongodb:Error` if the operation failed
    isolated remote function countDocuments(map<json> filter = {}, CountOptions options = {}) returns int|Error =
    @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Creates an index on the collection.
    #
    # + keys - The keys to index
    # + options - The options to apply to the index
    # + return - An `mongodb:Error` if the operation failed, otherwise nil
    isolated remote function createIndex(map<json> keys, CreateIndexOptions options = {}) returns Error? =
    @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Lists the indexes of the collection.
    #
    # + return - A stream of indexes, or an `mongodb:Error` if the operation failed.
    #            Close the resulted stream once the operation is completed.
    isolated remote function listIndexes() returns stream<Index, error?>|Error =
    @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Drops an index from the collection.
    #
    # + indexName - The name of the index to drop
    # + return - An `mongodb:Error` if the operation failed, otherwise nil
    isolated remote function dropIndex(string indexName) returns Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Drops all the indexes from the collection.
    #
    # + return - An `mongodb:Error` if the operation failed, otherwise nil
    isolated remote function dropIndexes() returns Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Drops the collection.
    #
    # + return - An `mongodb:Error` if the operation failed, otherwise nil
    isolated remote function drop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Updates a single document in the collection.
    #
    # + filter - The query filter to apply when updating documents
    # + update - The update operations to apply to the documents
    # + options - The options to apply to the update operation
    # + return - A `mongodb:UpdateResult` if the operation succeeded, otherwise an `mongodb:Error`
    isolated remote function updateOne(map<json> filter, Update update, UpdateOptions options = {})
            returns UpdateResult|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Updates multiple documents in the collection.
    #
    # + filter - The query filter to apply when updating documents
    # + update - The update operations to apply to the documents
    # + options - The options to apply to the update operation
    # + return - A `mongodb:UpdateResult` if the operation succeeded, otherwise an `mongodb:Error`
    isolated remote function updateMany(map<json> filter, Update update, UpdateOptions options = {})
    returns UpdateResult|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Retrieves the distinct values for a specified field across a collection.
    #
    # > **Note:** Close the resulted stream once the operation is completed.
    #
    # + fieldName - The field for which to return distinct values
    # + filter - The query filter to apply when retrieving distinct values
    # + targetType - The type of the returned distinct values
    # + return - A stream of distinct values, or an `mongodb:Error` if the operation failed
    isolated remote function 'distinct(string fieldName, map<json> filter = {}, typedesc<anydata> targetType = <>)
    returns stream<targetType, error?>|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Deletes a single document from the collection.
    #
    # + filter - The query filter to apply when deleting documents
    # + return - A `mongodb:DeleteResult` if the operation succeeded, otherwise an `mongodb:Error`
    isolated remote function deleteOne(map<json> filter) returns DeleteResult|Error =
    @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Deletes multiple documents from the collection.
    #
    # + filter - The query filter to apply when deleting documents
    # + return - A `mongodb:DeleteResult` if the operation succeeded, otherwise an `mongodb:Error`
    isolated remote function deleteMany(string|map<json> filter) returns DeleteResult|Error =
    @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;

    # Aggregates documents according to the specified aggregation pipeline.
    #
    # > **Note:** Close the resulted stream once the operation is completed.
    #
    # + pipeline - The aggregation pipeline
    # + targetType - The type of the returned documents
    # + return - A stream of documents which match the provided pipeline, or an `mongodb:Error` if the operation failed
    isolated remote function aggregate(map<json>[] pipeline, typedesc<anydata> targetType = <>)
            returns stream<targetType, error?>|Error = @java:Method {
        'class: "io.ballerina.lib.mongodb.Collection"
    } external;
}

isolated function initCollection(Collection collection, Database database, string collectionName) returns Error? =
@java:Method {
    'class: "io.ballerina.lib.mongodb.Collection"
} external;

isolated function insertOne(Collection collection, string document, InsertOneOptions options) returns Error? =
@java:Method {
    'class: "io.ballerina.lib.mongodb.Collection"
} external;

isolated function insertMany(Collection collection, string[] documents, InsertManyOptions options) returns Error? =
@java:Method {
    'class: "io.ballerina.lib.mongodb.Collection"
} external;
