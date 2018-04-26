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

documentation {
    The Caller Actions for MongoDB databases.
}
public type CallerActions object {
    documentation {
        The find action implementation which selects a document in a given collection.

        P{{collectionName}} The name of the collection to be queried
        P{{queryString}} Query to use to select data
        R{{}} `json` result from the find action or `error` if an error occurs
    }
    public native function find(string collectionName, json? queryString) returns (json|error);

    documentation {
        The findOne action implementation which selects the first document match with the query.

        P{{collectionName}} The name of the collection to be queried
        P{{queryString}} Query to use to select data
        R{{}} `json` result from the findOne action or `error` if an error occurs
    }
    public native function findOne(string collectionName, json? queryString) returns (json|error);

    documentation {
        The insert action implementation which inserts a document to a collection.

        P{{collectionName}} The name of the collection
        P{{document}} The document to be inserted
        R{{}} `nil` or `error` if an error occurs
    }
    public native function insert(string collectionName, json document)
        returns (error?);

    documentation {
        The delete action implementation which deletes documents that match the given filter.

        P{{collectionName}} The name of the collection
        P{{filter}} The criteria used to delete the documents
        P{{multi}} Specifies whether to delete multiple documents or not
        R{{}} `int` deleted count or `error` if an error occurs
    }
    public native function delete(string collectionName, json filter, boolean multi) returns (int|error);

    documentation {
        The update action implementation which updates documents that matches to given filter.

        P{{collectionName}} The name of the collection
        P{{filter}} The criteria used to update the documents
        P{{multi}} Specifies whether to update multiple documents or not
        P{{upsert}} Specifies whether to create a new document when no document matches the filter
        R{{}} `int` updated count or `error` if an error occurs
    }
    public native function update(string collectionName, json filter, json document, boolean
    multi, boolean upsert) returns (int|error);

    documentation {
        The insert action implementation which inserts an array of documents to a collection.

        P{{collectionName}} The name of the collection
        P{{documents}} The document array to be inserted
        R{{}} `nil` or `error` if an error occurs
    }
    public native function batchInsert(string collectionName, json documents) returns (error?);
};


documentation {
    The close action implementation which closes the MongoDB connection pool.
}
public native function close(CallerActions callerActions);
