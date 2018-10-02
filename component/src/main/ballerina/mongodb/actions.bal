// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# The Caller Actions for MongoDB databases.
public type CallerActions object {

    # The find operation implementation which selects a document in a given collection.
    #
    # + collectionName - The name of the collection to be queried
    # + queryString - Query to use to select data
    # + return - `json` result from the find operation or `error` if an error occurs
    public extern function find(string collectionName, json? queryString) returns (json|error);

    # The findOne operation implementation which selects the first document match with the query.

    # + collectionName - The name of the collection to be queried
    # + queryString - Query to use to select data
    # + return - `json` The result from the findOne operation or `error` if an error occurs
    public extern function findOne(string collectionName, json? queryString) returns (json|error);

    # The insert operation implementation which inserts a document to a collection.
    #
    # + collectionName - The name of the collection
    # + document - The document to be inserted
    # + return - `nil` or `error` if an error occurs
    public extern function insert(string collectionName, json document) returns (error?);

    # The delete operation implementation which deletes documents that match the given filter.
    #
    # + collectionName - The name of the collection
    # + filter - The criteria used to delete the documents
    # + multi - Specifies whether to delete multiple documents or not
    # + return - `int` deleted count or `error` if an error occurs
    public extern function delete(string collectionName, json filter, boolean multi) returns (int|error);

    # The update operation implementation which updates documents that matches to given filter.
    #
    # + collectionName - The name of the collection
    # + filter - The criteria used to update the documents
    # + multi - Specifies whether to update multiple documents or not
    # + upsert - Specifies whether to create a new document when no document matches the filter
    # + return - `int` The updated count or `error` if an error occurs
    public extern function update(string collectionName, json filter, json document, boolean multi, boolean upsert)
        returns (int|error);

    # The batchInsert operation implementation which inserts an array of documents to the given collection.
    #
    # + collectionName - The name of the collection
    # + documents - The document array to be inserted
    # + return - `nil` or `error` if an error occurs
    public extern function batchInsert(string collectionName, json documents) returns (error?);
};


# An internal function used by clients to shutdown the connection pool.
extern function close(CallerActions callerActions);
