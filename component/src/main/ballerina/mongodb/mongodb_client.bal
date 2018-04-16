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
package ballerina.mongodb;

public type MongoDBClient object {

@Description {value:"The find action implementation which selects a document in a given collection."}
@Param {value:"collectionName: The name of the collection to be queried"}
@Param {value:"queryString: Query to use to select data"}
@Return {value:"Result returned from the findOne action" }
public native function find (string collectionName, json|() queryString)
returns (json|error);

@Description {value:"The findOne action implementation which selects the first document match with the query."}
@Param {value:"collectionName: The name of the collection to be queried"}
@Param {value:"queryString: Query to use to select data"}
@Return {value:"Result returned from the findOne action" }
public native function findOne (string collectionName, json|() queryString)
returns (json | error);

@Description {value:"The insert action implementation which insert document to a collection."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"document: The document to be inserted"}
public native function insert (string collectionName, json document)
returns (error|());

@Description {value:"The delete action implementation which deletes documents that matches the given filter."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"filter: The criteria used to delete the documents"}
@Param {value:"multi: Specifies whether to delete multiple documents or not"}
@Return {value:"Updated count during the update action" }
public native function delete (string collectionName, json filter, boolean multi) returns
(int | error);

@Description {value:"The update action implementation which update documents that matches to given filter."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"filter: The criteria used to update the documents"}
@Param {value:"multi: Specifies whether to update multiple documents or not"}
@Param {value:"upsert: Specifies whether to create a new document when no document matches the filter"}
@Return {value:"Updated count during the update action" }
public native function update (string collectionName, json filter, json document, boolean
multi, boolean upsert) returns (int | error);

@Description {value:"The insert action implementation which inserts an array of documents to a collection."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"documents: The document array to be inserted"}
public native function batchInsert (string collectionName, json documents)
returns (error|());

@Description {value:"The close action implementation which closes the MongoDB connection pool."}
public native function close () returns (error|());

};





