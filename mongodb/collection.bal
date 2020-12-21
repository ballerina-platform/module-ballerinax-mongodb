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

import ballerina/java;

public client class Collection {
    handle collection;

    # Initializes the `Collection` object.
    public isolated function init(handle collection) {
        self.collection = collection;
    }

    # Counts the documents based on the filter. When the filter is (), it counts all the documents in the collection.
    # ```ballerina
    # int|mongodb:DatabaseError returned = mongoCollection->countDocuments(());
    # ```
    #
    # + filter - Filter for the count ($where & $near can be used)
    # + return - Count of the documents in the collection or else `mongodb:DatabaseError` if unable to reach the DB
    remote function countDocuments(map<json>? filter = ()) returns int|DatabaseError {
        if (filter is ()) {
            return countDocuments(self.collection, ());
        }
        string filterString = filter.toJsonString();
        return countDocuments(self.collection, java:fromString(filterString));
    }

    # Lists the indices associated with the collection.
    # ```ballerina
    # map<json>[]|mongodb:DatabaseError returned = mongoCollection->listIndices();
    # ```
    #
    # + return - a JSON object with indices on success or else a `mongodb:DatabaseError` if unable to reach the DB
    remote function listIndices() returns map<json>[]|DatabaseError {
        return listIndices(self.collection);
    }


    # Inserts one document.
    # ```ballerina
    # mongodb:DatabaseError? error = mongoCollection->insert(insertDocument);
    # ```
    #
    # + document - Document to be inserted
    # + return - `()` on success or else a `mongodb:DatabaseError` if unable to reach the DB
    remote function insert(map<json> document) returns DatabaseError? {
        string documentStr = document.toJsonString();
        return insert(self.collection, java:fromString(documentStr));
    }

    # The queries collection for documents, which sorts and limits the returned results.
    # ```ballerina
    # map<json>[]|mongodb:DatabaseError returned = mongoCollection->find(filter = findDoc);
    # ```
    #
    # + filter - Filter for the query
    # + sort - Sort options for the query
    # + limit - Limit options for the query results. No limit is applied for -1
    # + return - JSON array of the documents in the collection or else a `mongodb:DatabaseError` if unable to reach the DB
    remote function find(map<json>? filter = (), map<json>? sort = (), int 'limit = -1)
    returns map<json>[]|DatabaseError {
        if (filter is ()) {
            if (sort is ()) {
                return find(self.collection, (), (), 'limit);
            }
            string sortString = sort.toJsonString();
            return find(self.collection, (), java:fromString(sortString), 'limit);
        }
        string filterStr = filter.toJsonString();
        if (sort is ()) {
            return find(self.collection, java:fromString(filterStr), (), 'limit);
        }
        string sortString = sort.toJsonString();
        return find(self.collection, java:fromString(filterStr), java:fromString(sortString), 'limit);
    }

    # Updates a document based on a condition.
    # ```ballerina
    # int|mongodb:DatabaseError modifiedCount = mongoCollection->update(replaceDoc, replaceFilter, false);
    # ```
    #
    # + set - Document for the update condition
    # + filter - Filter for the query
    # + isMultiple - Whether to update multiple documents
    # + upsert - Whether to insert if update cannot be achieved
    # + return - JSON array of the documents in the collection or else a `mongodb:DatabaseError` if unable to reach the DB
    remote function update(map<json> set, map<json>? filter = (), boolean isMultiple = false,
        boolean upsert = false)
    returns int|DatabaseError {
        string updateDoc = set.toJsonString();
        if (filter is ()) {
            return update(self.collection, java:fromString(updateDoc), (), isMultiple, upsert);
        }
        string filterStr = filter.toJsonString();
        return update(self.collection, java:fromString(updateDoc), java:fromString(filterStr), isMultiple, upsert);
    }

    # Deletes a document based on a condition.
    # ```ballerina
    # int:mongodb:DatabaseError deleteRet = mongoCollection->delete(deleteFilter, true);
    # ```
    #
    # + filter - Filter for the query
    # + isMultiple - Delete multiple documents if the condition is matched
    # + return - The number of deleted documents or else a `mongodb:DatabaseError` if unable to reach the DB
    remote function delete(map<json>? filter = (), boolean isMultiple = false) returns int|DatabaseError {
        if (filter is ()) {
            return delete(self.collection, (), isMultiple);
        }
        string filterStr = filter.toJsonString();
        return delete(self.collection, java:fromString(filterStr), isMultiple);
    }

}

function countDocuments(handle collection, handle? filter) returns int|DatabaseError = @java:Method {
    'class: "org.wso2.mongo.MongoDBCollectionUtil"
} external;

function listIndices(handle collection) returns map<json>[]|DatabaseError = @java:Method {
    'class: "org.wso2.mongo.MongoDBCollectionUtil"
} external;

function insert(handle collection, handle document) returns DatabaseError? = @java:Method {
    'class: "org.wso2.mongo.MongoDBCollectionUtil"
} external;

function find(handle collection, handle? filter, handle? sort, int 'limit)
returns map<json>[]|DatabaseError = @java:Method {
    'class: "org.wso2.mongo.MongoDBCollectionUtil"
} external;

function update(handle collection, handle update, handle? filter, boolean isMultiple, boolean upsert)
returns int|DatabaseError = @java:Method {
    'class: "org.wso2.mongo.MongoDBCollectionUtil"
} external;


function delete(handle collection, handle? filter, boolean isMultiple) returns int|DatabaseError = @java:Method {
    'class: "org.wso2.mongo.MongoDBCollectionUtil"
} external;
