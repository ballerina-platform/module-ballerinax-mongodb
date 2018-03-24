package ballerina.data.mongodb;

public struct ConnectionProperties {
    string url;
    string readConcern;
    string writeConcern;
    string readPreference;
    string authSource;
    string authMechanism;
    string gssapiServiceName;
    boolean sslEnabled;
    boolean sslInvalidHostNameAllowed;
    int socketTimeout;
    int connectionTimeout;
    int maxPoolSize;
    int serverSelectionTimeout;
    int maxIdleTime;
    int maxLifeTime;
    int minPoolSize;
    int waitQueueMultiple;
    int waitQueueTimeout;
    int localThreshold;
    int heartbeatFrequency;
}

@Description {value:"Initialize the ConnectionProperties with default values"}
public function <ConnectionProperties cp> ConnectionProperties () {
    cp.url = "";
    cp.readConcern = "";
    cp.writeConcern = "";
    cp.readPreference = "";
    cp.authSource = "";
    cp.authMechanism = "";
    cp.gssapiServiceName = "";
    cp.sslEnabled = false;
    cp.sslInvalidHostNameAllowed = false;
    cp.socketTimeout = -1;
    cp.connectionTimeout = -1;
    cp.maxPoolSize = -1;
    cp.serverSelectionTimeout = -1;
    cp.maxIdleTime = -1;
    cp.maxLifeTime = -1;
    cp.minPoolSize = -1;
    cp.waitQueueMultiple = -1;
    cp.waitQueueTimeout = -1;
    cp.localThreshold = -1;
    cp.heartbeatFrequency = -1;
}

@Description { value:"MongoDB client connector."}
@Field { value:"host:Host addresses of MongoDB" }
@Field { value:"dbName:The name of the database" }
@Field { value:"options: Optional properties for MongoDB connection" }
public struct ClientConnector {
    string host = "";
    string dbName = "";
    string username = "";
    string password = "";
    ConnectionProperties options;
}

@Description {value:"Initialize the ClientConnector with default values"}
public function <ClientConnector c> ClientConnector () {
    c.host = "";
    c.dbName = "";
    c.username = "";
    c.password = "";
    c.options = {};
}

@Description {value:"The find action implementation which selects a document in a given collection."}
@Param {value:"collectionName: The name of the collection to be queried"}
@Param {value:"queryString: Query to use to select data"}
@Return {value:"Result returned from the findOne action" }
public native function <ClientConnector client> find (string collectionName, json queryString)
returns (json|MongoDBConnectorError);

@Description {value:"The findOne action implementation which selects the first document match with the query."}
@Param {value:"collectionName: The name of the collection to be queried"}
@Param {value:"queryString: Query to use to select data"}
@Return {value:"Result returned from the findOne action" }
public native function <ClientConnector client> findOne (string collectionName, json queryString)
returns (json | MongoDBConnectorError );

@Description {value:"The insert action implementation which insert document to a collection."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"document: The document to be inserted"}
public native function <ClientConnector client> insert (string collectionName, json document)
returns (MongoDBConnectorError| null);

@Description {value:"The delete action implementation which deletes documents that matches the given filter."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"filter: The criteria used to delete the documents"}
@Param {value:"multi: Specifies whether to delete multiple documents or not"}
@Return {value:"Updated count during the update action" }
public native function <ClientConnector client> delete (string collectionName, json filter, boolean multi) returns
(int | MongoDBConnectorError);

@Description {value:"The update action implementation which update documents that matches to given filter."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"filter: The criteria used to update the documents"}
@Param {value:"multi: Specifies whether to update multiple documents or not"}
@Param {value:"upsert: Specifies whether to create a new document when no document matches the filter"}
@Return {value:"Updated count during the update action" }
public native function <ClientConnector client> update (string collectionName, json filter, json document, boolean
multi, boolean upsert) returns (int | MongoDBConnectorError);

@Description {value:"The insert action implementation which inserts an array of documents to a collection."}
@Param {value:"collectionName: The name of the collection"}
@Param {value:"documents: The document array to be inserted"}
public native function <ClientConnector client> batchInsert (string collectionName, json documents)
returns (MongoDBConnectorError| null);

@Description {value:"The close action implementation which closes the MongoDB connection pool."}
public native function <ClientConnector client> close () returns (MongoDBConnectorError| null);

@Description {value:"MongoDBConnectorError struct represents an error occured during the MongoDB client invocation"}
@Field {value:"message:  An error message explaining about the error"}
@Field {value:"cause: The error(s) that caused MongoDBConnectorError to get thrown"}
public struct MongoDBConnectorError {
    string message;
    error[] cause;
}
///////////////////////////////
// MongoDB Client Endpoint
/////////////////////////   //////

public struct Client {
    string epName;
    ClientEndpointConfiguration clientEndpointConfig;
}

public struct ClientEndpointConfiguration {
    string host = "";
    string dbName = "";
    string username = "";
    string password = "";
    ConnectionProperties options;
}

public function <ClientEndpointConfiguration c> ClientEndpointConfiguration () {
    c.options = {};
}

@Description {value:"Gets called when the endpoint is being initialize during package init time"}
@Param {value:"epName: The endpoint name"}
@Param {value:"config: The ClientEndpointConfiguration of the endpoint"}
public function <Client ep> init (ClientEndpointConfiguration config) {
    ep.clientEndpointConfig = config;
    ep.initEndpoint();
}

@Description {value:"Initialize the endpoint"}
public native function <Client ep> initEndpoint ();

@Description {value:"Returns the connector that client code uses"}
@Return {value:"The connector that client code uses"}
public native function <Client ep> getClient () returns (ClientConnector);
