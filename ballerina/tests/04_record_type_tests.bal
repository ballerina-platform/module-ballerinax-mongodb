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

import ballerina/test;

@test:Config {
    groups: ["record", "map", "insert", "find"]
}
isolated function testRecordWithMapFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithMapFieldsDB");
    Collection collection = check database->getCollection("UserProfiles");

    UserProfile userProfile = {
        username: "john_doe",
        preferences: {
            "theme": "dark",
            "language": "en",
            "timezone": "UTC"
        },
        scores: {
            "level1": 100,
            "level2": 85,
            "level3": 92
        },
        metadata: {
            "created": "2024-01-01",
            "lastLogin": "2024-01-15",
            "isActive": true,
            "config": {
                "notifications": true
            }
        }
    };

    check collection->insertOne(userProfile);

    UserProfile? result = check collection->findOne();
    test:assertTrue(result is UserProfile, "Expected UserProfile record");
    if result is UserProfile {
        test:assertEquals(result.username, "john_doe");
        test:assertEquals(result.preferences["theme"], "dark");
        test:assertEquals(result.scores["level1"], 100);
        test:assertTrue(result.metadata["isActive"] is boolean);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "map", "nested", "insert", "find"]
}
isolated function testRecordWithNestedMapFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithNestedMapFieldsDB");
    Collection collection = check database->getCollection("ConfigData");

    ConfigData configData = {
        name: "app-config",
        nestedConfig: {
            "database": {
                "host": "localhost",
                "port": "27017",
                "name": "mydb"
            },
            "redis": {
                "host": "redis-server",
                "port": "6379"
            }
        },
        optionalMap: {
            "feature1": true,
            "feature2": false,
            "version": "1.0"
        }
    };

    check collection->insertOne(configData);

    ConfigData? result = check collection->findOne();
    test:assertTrue(result is ConfigData, "Expected ConfigData record");
    if result is ConfigData {
        test:assertEquals(result.name, "app-config");
        test:assertTrue(result.nestedConfig["database"] is map<string>);
        test:assertEquals(result.nestedConfig["database"]["host"], "localhost");
        test:assertTrue(result.optionalMap is map<json>);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "map", "complex", "insert", "find"]
}
isolated function testRecordWithComplexMapTypes() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithComplexMapTypesDB");
    Collection collection = check database->getCollection("UserSettings");

    UserSettings userSettings = {
        userId: "user123",
        featureFlags: {
            "darkMode": true,
            "notifications": false,
            "beta": true
        },
        limits: {
            "dailyQuota": 100.5,
            "monthlyQuota": 3000.0,
            "storageLimit": 50.25
        },
        categories: {
            "interests": ["technology", "science", "music"],
            "skills": ["java", "python", "ballerina"],
            "languages": ["en", "es", "fr"]
        }
    };

    check collection->insertOne(userSettings);

    UserSettings? result = check collection->findOne();
    test:assertTrue(result is UserSettings, "Expected UserSettings record");
    if result is UserSettings {
        test:assertEquals(result.userId, "user123");
        test:assertEquals(result.featureFlags["darkMode"], true);
        test:assertEquals(result.limits["dailyQuota"], 100.5d);
        test:assertTrue(result.categories["interests"] is string[]);
        string[] interests = check result.categories["interests"].ensureType();
        test:assertEquals(interests[0], "technology");
    }
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "intersection", "readonly", "insert", "find"]
}
isolated function testRecordWithIntersectionTypes() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithIntersectionTypesDB");
    Collection collection = check database->getCollection("ReadonlyUsers");

    ReadonlyUser readonlyUser = {
        name: "Alice",
        age: 30,
        email: "alice@example.com"
    };

    check collection->insertOne(readonlyUser);

    ReadonlyUser? result = check collection->findOne();
    test:assertTrue(result is ReadonlyUser, "Expected ReadonlyUser record");
    if result is ReadonlyUser {
        test:assertEquals(result.name, "Alice");
        test:assertEquals(result.age, 30);
        test:assertEquals(result.email, "alice@example.com");
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "intersection", "readonly", "map", "insert", "find"]
}
isolated function testRecordWithIntersectionAndMapTypes() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithIntersectionAndMapTypesDB");
    Collection collection = check database->getCollection("ImmutableConfigs");

    ImmutableConfig immutableConfig = {
        appName: "MyApp",
        settings: {
            "debug": "true",
            "logLevel": "INFO",
            "environment": "production"
        },
        version: 2
    };

    check collection->insertOne(immutableConfig);

    ImmutableConfig? result = check collection->findOne();
    test:assertTrue(result is ImmutableConfig, "Expected ImmutableConfig record");
    if result is ImmutableConfig {
        test:assertEquals(result.appName, "MyApp");
        test:assertEquals(result.settings["debug"], "true");
        test:assertEquals(result.version, 2);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "intersection", "composite", "insert", "find"]
}
isolated function testRecordWithCompositeIntersectionTypes() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithCompositeIntersectionTypesDB");
    Collection collection = check database->getCollection("UsersWithAddress");

    UserWithAddress userWithAddress = {
        id: "1",
        name: "Bob",
        age: 25,
        address: {
            street: "123 Main St",
            city: "New York",
            country: "USA"
        },
        phoneNumber: "+1-555-123-4567",
        hobbies: ["reading", "hiking", "programming"]
    };

    check collection->insertOne(userWithAddress);

    UserWithAddress? result = check collection->findOne();
    test:assertTrue(result is UserWithAddress, "Expected UserWithAddress record");
    if result is UserWithAddress {
        test:assertEquals(result.name, "Bob");
        test:assertEquals(result.age, 25);
        test:assertEquals(result.address.city, "New York");
        test:assertEquals(result.phoneNumber, "+1-555-123-4567");
        test:assertEquals(result.hobbies[0], "reading");
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "never", "insert", "find"]
}
isolated function testRecordWithNeverTypeFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithNeverTypeFieldsDB");
    Collection collection = check database->getCollection("RestrictedData");

    RestrictedData restrictedData = {
        publicField: "This is public",
        data: {
            "key1": "value1",
            "key2": 42,
            "key3": true
        }
    };

    check collection->insertOne(restrictedData);

    RestrictedData? result = check collection->findOne();
    test:assertTrue(result is RestrictedData, "Expected RestrictedData record");
    if result is RestrictedData {
        test:assertEquals(result.publicField, "This is public");
        test:assertEquals(result.data["key1"], "value1");
        test:assertEquals(result.data["key2"], 42);
        test:assertEquals(result.data["key3"], true);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "never", "map", "insert", "find"]
}
isolated function testRecordWithNeverAndMapFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithNeverAndMapFieldsDB");
    Collection collection = check database->getCollection("SystemConfigs");

    SystemConfig systemConfig = {
        name: "production-config",
        settings: {
            "maxConnections": "100",
            "timeout": "30",
            "retryAttempts": "3"
        }
    };

    check collection->insertOne(systemConfig);

    SystemConfig? result = check collection->findOne();
    test:assertTrue(result is SystemConfig, "Expected SystemConfig record");
    if result is SystemConfig {
        test:assertEquals(result.name, "production-config");
        test:assertEquals(result.settings["maxConnections"], "100");
        test:assertEquals(result.settings["timeout"], "30");
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "map", "batch", "insertMany", "find"]
}
isolated function testBatchOperationsWithMapFields() returns error? {
    Database database = check mongoClient->getDatabase("testBatchOperationsWithMapFieldsDB");
    Collection collection = check database->getCollection("BatchUserProfiles");

    UserProfile[] userProfiles = [
        {
            username: "user1",
            preferences: {"theme": "light", "lang": "en"},
            scores: {"game1": 95, "game2": 87},
            metadata: {"created": "2024-01-01", "active": true}
        },
        {
            username: "user2",
            preferences: {"theme": "dark", "lang": "es"},
            scores: {"game1": 78, "game2": 91},
            metadata: {"created": "2024-01-02", "active": false}
        },
        {
            username: "user3",
            preferences: {"theme": "auto", "lang": "fr"},
            scores: {"game1": 82, "game2": 94},
            metadata: {"created": "2024-01-03", "active": true}
        }
    ];

    check collection->insertMany(userProfiles);

    stream<UserProfile, error?> results = check collection->find();
    UserProfile[] actualResults = check from UserProfile profile in results
        select profile;

    test:assertEquals(actualResults.length(), 3);
    test:assertEquals(actualResults[0].username, "user1");
    test:assertEquals(actualResults[1].preferences["theme"], "dark");
    test:assertEquals(actualResults[2].scores["game2"], 94);

    check results.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "intersection", "batch", "insertMany", "find"]
}
isolated function testBatchOperationsWithIntersectionTypes() returns error? {
    Database database = check mongoClient->getDatabase("testBatchOperationsWithIntersectionTypesDB");
    Collection collection = check database->getCollection("BatchReadonlyUsers");

    ReadonlyUser[] users = [
        {name: "Alice", age: 25, email: "alice@example.com"},
        {name: "Bob", age: 30, email: "bob@example.com"},
        {name: "Charlie", age: 35, email: "charlie@example.com"}
    ];

    check collection->insertMany(users);

    stream<ReadonlyUser, error?> results = check collection->find();
    ReadonlyUser[] actualResults = check from ReadonlyUser user in results
        select user;

    test:assertEquals(actualResults.length(), 3);
    test:assertEquals(actualResults[0].name, "Alice");
    test:assertEquals(actualResults[1].age, 30);
    test:assertEquals(actualResults[2].email, "charlie@example.com");

    check results.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "xml", "insert", "find"]
}
isolated function testRecordWithXmlFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithXmlFieldsDB");
    Collection collection = check database->getCollection("XmlDocuments");

    xml xmlContent = xml `<book title="Ballerina Programming">
        <author>John Doe</author>
        <year>2024</year>
        <description>A comprehensive guide to Ballerina programming language</description>
    </book>`;

    XmlDocument xmlDocument = {
        name: "programming-guide",
        content: xmlContent,
        attributes: {
            "category": "programming",
            "language": "en",
            "format": "digital"
        }
    };

    check collection->insertOne(xmlDocument);

    XmlDocument? result = check collection->findOne();
    test:assertTrue(result is XmlDocument, "Expected XmlDocument record");
    if result is XmlDocument {
        test:assertEquals(result.name, "programming-guide");
        test:assertEquals(result.content, xmlContent);
        test:assertEquals(result.attributes["category"], "programming");
        test:assertEquals(result.attributes["language"], "en");
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "xml", "array", "insert", "find"]
}
isolated function testRecordWithXmlArrayFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithXmlArrayFieldsDB");
    Collection collection = check database->getCollection("XmlLibraries");

    xml doc1 = xml `<document id="1"><title>Document One</title></document>`;
    xml doc2 = xml `<document id="2"><title>Document Two</title></document>`;
    xml doc3 = xml `<document id="3"><title>Document Three</title></document>`;
    xml metadataXml = xml `<metadata><created>2024-01-01</created><version>1.0</version></metadata>`;

    XmlLibrary xmlLibrary = {
        libraryName: "Technical Documentation",
        documents: [doc1, doc2, doc3],
        metadata: metadataXml
    };

    check collection->insertOne(xmlLibrary);

    XmlLibrary? result = check collection->findOne();
    test:assertTrue(result is XmlLibrary, "Expected XmlLibrary record");
    if result is XmlLibrary {
        test:assertEquals(result.libraryName, "Technical Documentation");
        test:assertEquals(result.documents, [doc1, doc2, doc3]);
        test:assertEquals(result.metadata, metadataXml);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "numeric", "float", "decimal", "byte", "insert", "find"]
}
isolated function testRecordWithNumericTypes() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithNumericTypesDB");
    Collection collection = check database->getCollection("NumericData");

    NumericData numericData = {
        name: "sensor-reading",
        floatValue: 3.14159,
        decimalValue: 99.99d,
        byteValue: 255
    };

    check collection->insertOne(numericData);

    NumericData? result = check collection->findOne();
    test:assertTrue(result is NumericData, "Expected NumericData record");
    if result is NumericData {
        test:assertEquals(result.name, "sensor-reading");
        test:assertEquals(result.floatValue, 3.14159);
        test:assertEquals(result.decimalValue, 99.99d);
        test:assertEquals(result.byteValue, 255);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "table", "insert", "find"]
}
isolated function testRecordWithTableFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithTableFieldsDB");
    Collection collection = check database->getCollection("TableData");

    table<Person> key (id) dataTable = table [
        {"id": "1", "name": "Alice", "age": 25, address: {street: "123 Main St", city: "New York", country: "USA"}},
        {"id": "2", "name": "Bob", "age": 30, address: {street: "456 Elm St", city: "Los Angeles", country: "USA"}},
        {"id": "3", "name": "Charlie", "age": 35, address: {street: "789 Oak St", city: "Chicago", country: "USA"}}
    ];

    TableData tableData = {
        tableName: "users-table",
        dataTable
    };

    check collection->insertOne(tableData);

    TableData? result = check collection->findOne();
    test:assertTrue(result is TableData, "Expected TableData record");
    if result is TableData {
        test:assertEquals(result.tableName, "users-table");
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "xml", "numeric", "batch", "insertMany", "find", "test"]
}
isolated function testBatchOperationsWithXmlAndNumericFields() returns error? {
    Database database = check mongoClient->getDatabase("testBatchOperationsWithXmlAndNumericFieldsDB");
    Collection collection = check database->getCollection("BatchXmlDocuments");

    xml xml1 = xml `<config><setting name="timeout">30</setting></config>`;
    xml xml2 = xml `<config><setting name="retries">5</setting></config>`;
    xml xml3 = xml `<config><setting name="buffer">1024</setting></config>`;

    XmlDocument[] xmlDocuments = [
        {
            name: "timeout-config",
            content: xml1,
            attributes: {"type": "system", "priority": "high"}
        },
        {
            name: "retry-config",
            content: xml2,
            attributes: {"type": "network", "priority": "medium"}
        },
        {
            name: "buffer-config",
            content: xml3,
            attributes: {"type": "memory", "priority": "low"}
        }
    ];

    check collection->insertMany(xmlDocuments);

    stream<XmlDocument, error?> results = check collection->find();
    XmlDocument[] actualResults = check from XmlDocument doc in results
        select doc;

    test:assertEquals(actualResults.length(), 3);
    test:assertEquals(actualResults[0].name, "timeout-config");
    test:assertEquals(actualResults[0].content, xml1);
    test:assertEquals(actualResults[1].attributes["type"], "network");
    test:assertEquals(actualResults[2].attributes["priority"], "low");

    check results.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["anydata", "insert", "find"]
}
isolated function testRecordWithAnyDataFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithAnyDataFieldsDB");
    Collection collection = check database->getCollection("AnyData");

    record {|anydata...;|} anyData = {
        "name": "data-example",
        "data": {
            "value1": 100,
            "value2": "Hello",
            "value3": true
        }
    };

    check collection->insertOne(anyData);
    record {|anydata...;|}? result = check collection->findOne();
    test:assertTrue(result is record {|anydata...;|}, "Expected record {|anydata...;|}");
    if result is record {|anydata...;|} {
        test:assertEquals(result["name"], "data-example");
        anydata data = result["data"];
        if data is map<anydata> {
            test:assertEquals(data["value1"], 100);
            test:assertEquals(data["value2"], "Hello");
            test:assertEquals(data["value3"], true);
        } else {
            test:assertFail("Expected map<anydata>");
        }
    }
    check collection->drop();
    check database->drop();
}
