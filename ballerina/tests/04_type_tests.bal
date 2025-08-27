// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
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

    table<Person> key(id) dataTable = table [
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
    groups: ["record", "xml", "numeric", "batch", "insertMany", "find"]
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

@test:Config {
    groups: ["record", "tuple", "insert", "find"]
}
isolated function testRecordWithTupleFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithTupleFieldsDB");
    Collection collection = check database->getCollection("TupleData");

    TupleData tupleData = {
        name: "tuple-example",
        basicTuple: ["hello", 42, true],
        complexTuple: [
            "complex",
            100,
            3.14,
            {
                street: "123 Tuple St",
                city: "Tuple City",
                country: "TupleCountry"
            }
        ],
        tupleArray: [
            ["first", 1],
            ["second", 2],
            ["third", 3]
        ]
    };

    check collection->insertOne(tupleData);

    TupleData? result = check collection->findOne();
    test:assertTrue(result is TupleData, "Expected TupleData record");
    if result is TupleData {
        test:assertEquals(result.name, "tuple-example");
        test:assertEquals(result.basicTuple[0], "hello");
        test:assertEquals(result.basicTuple[1], 42);
        test:assertEquals(result.basicTuple[2], true);
        test:assertEquals(result.complexTuple[0], "complex");
        test:assertEquals(result.complexTuple[1], 100);
        test:assertEquals(result.complexTuple[2], 3.14);
        test:assertEquals(result.complexTuple[3].street, "123 Tuple St");
        test:assertEquals(result.tupleArray.length(), 3);
        test:assertEquals(result.tupleArray[0][0], "first");
        test:assertEquals(result.tupleArray[0][1], 1);
        test:assertEquals(result.tupleArray[2][0], "third");
        test:assertEquals(result.tupleArray[2][1], 3);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["record", "enum", "insert", "find"]
}
isolated function testRecordWithEnumFields() returns error? {
    Database database = check mongoClient->getDatabase("testRecordWithEnumFieldsDB");
    Collection collection = check database->getCollection("ColorData");

    ColorData[] colorData = [
        {
            color: RED,
            hexCode: "#FF0000",
            rgb: [255, 0, 0]
        },
        {
            color: GREEN,
            hexCode: "#00FF00",
            rgb: [0, 255, 0]
        },
        {
            color: BLUE,
            hexCode: "#0000FF",
            rgb: [0, 0, 255]
        }
    ];

    check collection->insertMany(colorData);

    stream<ColorData, error?> results = check collection->find();
    ColorData[] actualResults = check from ColorData data in results
        select data;

    test:assertEquals(actualResults.length(), 3);
    test:assertEquals(actualResults[0].color, RED);
    test:assertEquals(actualResults[1].color, GREEN);
    test:assertEquals(actualResults[2].color, BLUE);

    check results.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["type_system", "union"]
}
public function testComplexUnionTypes() returns error? {
    Database database = check mongoClient->getDatabase("complexUnionTest");
    Collection collection = check database->getCollection("unionDocs");

    // Insert documents with different union type values
    map<json>[] unionDocs = [
        {id: "1", value: 42},
        {id: "2", value: 99.99},
        {id: "3", value: "string_value"},
        {id: "4", value: true},
        {id: "5", value: ()}
    ];

    check collection->insertMany(unionDocs);

    // Query and verify type handling
    stream<record {|string id; ComplexUnion? value;|}, error?> results =
        check collection->find();

    record {|string id; ComplexUnion? value;|}[] docs =
        check from record {|string id; ComplexUnion? value;|} doc in results
        select doc;
    check results.close();

    test:assertEquals(docs.length(), 5);

    // Verify different union member types are handled correctly
    foreach var doc in docs {
        match doc.id {
            "1" => {
                test:assertTrue(doc.value is int, "Should be int");
            }
            "2" => {
                test:assertTrue(doc.value is decimal, "Should be decimal");
            }
            "3" => {
                test:assertTrue(doc.value is string, "Should be string");
            }
            "4" => {
                test:assertTrue(doc.value is boolean, "Should be boolean");
            }
            "5" => {
                test:assertTrue(doc.value is (), "Should be null");
            }
        }
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["type_system", "optional"]
}
public function testNestedOptionalFields() returns error? {
    Database database = check mongoClient->getDatabase("nestedOptionalTest");
    Collection collection = check database->getCollection("optionalDocs");

    // Insert documents with varying optional field patterns
    NestedOptional[] optionalDocs = [
        {
            name: "Complete",
            age: 30,
            address: {street: "123 St", city: "City", country: "Country"},
            hobbies: ["reading", "coding"]
        },
        {
            name: "Partial",
            age: 25
        },
        {
            name: "OnlyName"
        }
    ];

    check collection->insertMany(optionalDocs);

    stream<NestedOptional, error?> results = check collection->find();
    NestedOptional[] docs = check from NestedOptional doc in results
        select doc;
    check results.close();

    test:assertEquals(docs.length(), 3);

    test:assertTrue(docs[0].age is int);
    test:assertTrue(docs[0].address is Address);
    test:assertTrue(docs[0].hobbies is string[]);

    test:assertTrue(docs[1].age is int);
    test:assertTrue(docs[1].address is ());
    test:assertTrue(docs[1].hobbies is ());

    test:assertTrue(docs[2].age is ());
    test:assertTrue(docs[2].address is ());
    test:assertTrue(docs[2].hobbies is ());

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["type_system", "array"]
}
public function testHeterogeneousArrays() returns error? {
    Database database = check mongoClient->getDatabase("heterogeneousArrayTest");
    Collection collection = check database->getCollection("arrayDocs");

    MixedArray mixedDoc = {
        mixedData: [1, "string", true, 3.14, (), {nested: "object"}],
        unionArray: ["text", 42, "more text", 100],
        tupleArray: [
            ["first", 1, true, 1.1],
            ["second", 2, false, 2.2],
            ["third", 3, true, 3.3]
        ]
    };

    check collection->insertOne(mixedDoc);

    MixedArray? result = check collection->findOne();
    test:assertTrue(result is MixedArray, "Should retrieve MixedArray");

    if result is MixedArray {
        test:assertEquals(result.mixedData.length(), 6);
        test:assertEquals(result.unionArray.length(), 4);
        test:assertEquals(result.tupleArray.length(), 3);

        // Verify array element types
        test:assertTrue(result.mixedData[0] is int);
        test:assertTrue(result.mixedData[1] is string);
        test:assertTrue(result.mixedData[2] is boolean);
        test:assertTrue(result.mixedData[3] is decimal);
        test:assertTrue(result.mixedData[4] is ());

        // Verify union array types
        test:assertTrue(result.unionArray[0] is string);
        test:assertTrue(result.unionArray[1] is int);

        // Verify tuple structure
        test:assertEquals(result.tupleArray[0][0], "first");
        test:assertEquals(result.tupleArray[0][1], 1);
        test:assertEquals(result.tupleArray[0][2], true);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["type_system", "circular"]
}
public function testCircularReferenceHandling() returns error? {
    Database database = check mongoClient->getDatabase("circularRefTest");
    Collection collection = check database->getCollection("circularDocs");

    CircularReference parentDoc = {
        name: "Parent",
        parent: (),
        children: [
            {name: "Child1", parent: (), children: []},
            {name: "Child2", parent: (), children: []}
        ]
    };

    check collection->insertOne(parentDoc);

    CircularReference? result = check collection->findOne();
    test:assertTrue(result is CircularReference, "Should handle complex nested structure");

    if result is CircularReference {
        test:assertEquals(result.name, "Parent");
        test:assertTrue(result.parent is ());
        test:assertEquals(result.children.length(), 2);
        test:assertEquals(result.children[0].name, "Child1");
        test:assertEquals(result.children[1].name, "Child2");
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["type_system", "schema_evolution"]
}
public function testSchemaEvolution() returns error? {
    Database database = check mongoClient->getDatabase("schemaEvolutionTest");
    Collection collection = check database->getCollection("evolutionDocs");

    map<json> oldSchemaDoc = {
        name: "Old Schema",
        version: 1,
        data: "simple_string"
    };
    check collection->insertOne(oldSchemaDoc);

    map<json> newSchemaDoc = {
        name: "New Schema",
        version: 2,
        data: {
            content: "complex_object",
            metadata: {
                created: "2024-01-01",
                updated: "2024-01-02"
            }
        },
        newField: "additional_data"
    };
    check collection->insertOne(newSchemaDoc);

    stream<record {string name; int version; anydata data;}, error?> results = check collection->find();

    record {string name; int version; anydata data;}[] docs = check
        from record {string name; int version; anydata data;} doc
        in results
    select doc;
    check results.close();

    test:assertEquals(docs.length(), 2);
    test:assertTrue(docs[0].data is string);
    test:assertTrue(docs[1].data is map<anydata>);

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["type_system", "null_handling"]
}
public function testNullVsMissingFields() returns error? {
    Database database = check mongoClient->getDatabase("nullVsMissingTest");
    Collection collection = check database->getCollection("nullDocs");

    map<json>[] nullDocs = [
        {name: "Explicit Null", value: (), description: "has_null"},
        {name: "Missing Field", description: "no_value"},
        {name: "Empty String", value: "", description: "empty_string"}
    ];

    check collection->insertMany(nullDocs);

    stream<record {|string name; anydata value?; string description?;|}, error?> results =
        check collection->find();

    record {|string name; anydata value?; string description?;|}[] docs =
        check from record {|string name; anydata value?; string description?;|} doc in results
        select doc;
    check results.close();

    test:assertEquals(docs.length(), 3);

    foreach var doc in docs {
        match doc.description {
            "has_null" => {
                test:assertTrue(doc?.value is (), "Should be explicit null");
            }
            "no_value" => {
                test:assertTrue(doc?.value is (), "Missing field should be null");
            }
            "empty_string" => {
                test:assertTrue(doc?.value is string, "Should be empty string, not null");
                test:assertEquals(doc?.value, "");
            }
        }
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["type_system", "binary"]
}
public function testBinaryDataHandling() returns error? {
    Database database = check mongoClient->getDatabase("binaryDataTest");
    Collection collection = check database->getCollection("binaryDocs");

    // Create binary data using byte arrays
    byte[] smallBinary = [1, 2, 3, 4, 5];
    byte[] largeBinary = [];

    // Create larger binary data
    foreach int i in 0 ... 999 {
        largeBinary.push(<byte>(i % 256));
    }

    record {|string name; byte[] smallData; byte[] largeData;|} binaryDoc = {
        name: "Binary Document",
        smallData: smallBinary,
        largeData: largeBinary
    };

    check collection->insertOne(binaryDoc);

    stream<record {|string name; byte[] smallData; byte[] largeData;|}, error?> results =
        check collection->find();

    record {|
        record {|
            string name;
            byte[] smallData;
            byte[] largeData;
        |} value;
    |}? doc = check results.next();
    check results.close();

    if doc is () {
        test:assertFail("No results returned");
    }
    test:assertEquals(doc.value.name, "Binary Document");
    test:assertEquals(doc.value.smallData, smallBinary);
    test:assertEquals(doc.value.largeData, largeBinary);

    check collection->drop();
    check database->drop();
}
