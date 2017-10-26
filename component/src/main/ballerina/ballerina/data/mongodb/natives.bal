package ballerina.data.mongodb;

import ballerina.doc;

public connector ClientConnector (string host, string dbName, map properties) {

    map sharedMap = {};

    @doc:Description {value:"The find action implementation which selects a document in a given collection."}
    @doc:Param {value:"collectionName: The name of the collection to be queried"}
    @doc:Param {value:"query: Query to use to select data"}
    native action find (string collectionName, json query) (json);

    @doc:Description {value:"The findOne action implementation which selects the first document match with the query."}
    @doc:Param {value:"collectionName: The name of the collection to be queried"}
    @doc:Param {value:"query: Query to use to select data"}
    native action findOne (string collectionName, json query) (json);

    @doc:Description {value:"The insert action implementation which insert document to a collection."}
    @doc:Param {value:"collectionName: The name of the collection"}
    @doc:Param {value:"document: The document to be inserted"}
    native action insert (string collectionName, json document);

    @doc:Description {value:"The delete action implementation which delete documents that matches to given filter."}
    @doc:Param {value:"collectionName: The name of the collection"}
    @doc:Param {value:"filter: The criteria used to delete the documents"}
    @doc:Param {value:"multi: Specifies whether to delete multiple documents or not"}
    native action delete (string collectionName, json filter, boolean multi) (int);

    @doc:Description {value:"The updae action implementation which update documents that matches to given filter."}
    @doc:Param {value:"collectionName: The name of the collection"}
    @doc:Param {value:"filter: The criteria used to updae the documents"}
    @doc:Param {value:"multi: Specifies whether to update multiple documents or not"}
    @doc:Param {value:"multi: Specifies whether to create a new document when no document matches the filter"}
    native action update (string collectionName, json filter, json document, boolean multi, boolean upsert) (int);

    @doc:Description {value:"The close action implementation which closes the MongoDB connection pool."}
    native action close ();


 }
