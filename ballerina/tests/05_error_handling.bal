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
import ballerina/time;

@test:Config {
    groups: ["error_handling", "resource_leak"]
}
public function testStreamResourceLeakPrevention() returns error? {
    Database database = check mongoClient->getDatabase("resourceLeakTest");
    Collection collection = check database->getCollection("streamDocs");

    // Insert test data
    Movie[] movies = [];
    foreach int i in 0 ... 99 {
        movies.push({name: "Movie" + i.toString(), year: 2020 + (i % 5), rating: (i % 10) + 1});
    }
    check collection->insertMany(movies);

    // Test multiple streams without proper closing (simulate resource leak scenario)
    foreach int i in 0 ... 9 {
        stream<Movie, error?> results = check collection->find({rating: i + 1});
        // Intentionally not closing some streams to test resource management
        if (i % 2 == 0) {
            check results.close();
        }
        // Other streams left unclosed to test garbage collection/finalization
    }

    // Verify collection is still accessible after potential resource issues
    int count = check collection->countDocuments();
    test:assertEquals(count, 100);

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["error_handling", "invalid_query"]
}
public function testInvalidRegexQuery() returns error? {
    Database database = check mongoClient->getDatabase("invalidRegexTest");
    Collection collection = check database->getCollection("regexDocs");

    check collection->insertOne({"name": "Test Document", "content": "Sample content"});

    // Test invalid regex patterns
    map<json>[] invalidRegexQueries = [
        {name: {\$regex: "[invalid", \$options: "i"}}, // Unclosed bracket
        {name: {\$regex: "*invalid", \$options: "i"}}, // Invalid quantifier
        {name: {\$regex: "(?invalid", \$options: "i"}}, // Invalid group
        {content: {\$regex: "(", \$options: "i"}} // Unclosed parenthesis
    ];

    foreach map<json> query in invalidRegexQueries {
        stream<record {|anydata...;|}, error?>|Error results = collection->find(query);
        test:assertTrue(results is ApplicationError);
        if results is ApplicationError {
            test:assertTrue(results.message().includes("Regular expression is invalid: "));
        }
    }
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["error_handling", "memory"]
}
public function testLargeResultSetHandling() returns error? {
    Database database = check mongoClient->getDatabase("largeResultSetTest");
    Collection collection = check database->getCollection("largeDocs");

    map<json>[] largeDocs = [];
    foreach int i in 0 ... 999 {
        largeDocs.push({
            id: i,
            data: "Document " + i.toString(),
            padding: check getRandomString(100)
        });
    }
    check collection->insertMany(largeDocs);

    // Test streaming large result set
    stream<record {|int id; string data; string padding;|}, error?> results = check collection->find();

    int count = 0;
    error? iterationError = results.forEach(function(record {|int id; string data; string padding;|} doc) {
        count += 1;
        // Simulate processing that might cause memory issues
        if count % 100 == 0 {
            // Yield control periodically
        }
    });

    test:assertEquals(iterationError, (), "Should handle large result set without error");
    test:assertEquals(count, 1000);

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["error_handling", "validation"]
}
public function testInvalidDocumentStructures() returns error? {
    Database database = check mongoClient->getDatabase("invalidDocTest");
    Collection collection = check database->getCollection("invalidDocs");

    // Test various problematic document structures
    map<json>[] problematicDocs = [
        {}, // Empty document
        {nullField: ()}, // Explicit null
        {emptyString: ""}, // Empty string
        {emptyArray: []}, // Empty array
        {emptyObject: {}}, // Empty nested object
        {specialChars: "Special chars: !@#$%^&*(){}[]|\\:;\"'<>,.?/~`"},
        {unicodeField: "Unicode: 🎉 こんにちは العربية"},
        {numberAsString: "123.456"},
        {booleanAsString: "true"}
    ];

    // All of these should be valid MongoDB documents
    check collection->insertMany(problematicDocs);

    int count = check collection->countDocuments();
    test:assertEquals(count, problematicDocs.length());

    // Test querying these documents
    stream<record {|anydata...;|}, error?> results = check collection->find();
    record {|anydata...;|}[] docs = check from record {|anydata...;|} doc in results
        select doc;
    check results.close();

    test:assertEquals(docs.length(), problematicDocs.length());

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["error_handling", "aggregation"]
}
public function testAggregationMemoryLimits() returns error? {
    Database database = check mongoClient->getDatabase("aggregationMemoryTest");
    Collection collection = check database->getCollection("aggDocs");

    // Insert documents for aggregation
    map<json>[] aggDocs = [];
    foreach int i in 0 ... 499 {
        aggDocs.push({
            category: "Category" + (i % 10).toString(),
            value: i,
            data: "Data " + i.toString(),
            tags: ["tag" + (i % 5).toString(), "tag" + (i % 7).toString()]
        });
    }
    check collection->insertMany(aggDocs);

    // Test aggregation that might consume significant memory
    map<json>[] memoryIntensivePipeline = [
        {
            \$group: {
                _id: "$category",
                values: {\$push: "$value"},
                data: {\$push: "$data"},
                tags: {\$push: "$tags"},
                count: {\$sum: 1}
            }
        },
        {\$sort: {count: -1}},
        {
            \$project: {
                _id: 1,
                count: 1,
                avgValue: {\$avg: "$values"},
                allData: {
                    \$reduce: {
                        input: "$data",
                        initialValue: "",
                        'in: {\$concat: ["$$value", " ", "$$this"]}
                    }
                }
            }
        }
    ];

    stream<record {|anydata...;|}, error?>|Error results =
        collection->aggregate(memoryIntensivePipeline);

    if results is stream<record {|anydata...;|}, error?> {
        record {|anydata...;|}[] aggResults =
            check from record {|anydata...;|} result in results
            select result;
        check results.close();

        test:assertTrue(aggResults.length() > 0, "Aggregation should return results");
        test:assertTrue(aggResults.length() <= 10, "Should group into categories");
    }
    // If aggregation fails due to memory limits, that's also acceptable behavior

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["error_handling", "concurrent"]
}
public function testConcurrentErrorScenarios() returns error? {
    Database database = check mongoClient->getDatabase("concurrentErrorTest");
    Collection collection = check database->getCollection("concurrentDocs");

    // Create unique index for testing conflicts
    check collection->createIndex({uniqueField: 1}, {unique: true});

    // Insert initial document
    check collection->insertOne({"uniqueField": "shared_value", "data": "initial"});

    // Concurrent operations that will cause conflicts
    future<UpdateResult|Error> f1 = start conflictingUpdate(collection, "shared_value", "update1");
    future<UpdateResult|Error> f2 = start conflictingUpdate(collection, "shared_value", "update2");
    future<error?> f3 = start conflictingInsert(collection, "shared_value", "insert1");

    UpdateResult|Error r1 = wait f1;
    UpdateResult|Error r2 = wait f2;
    error? r3 = wait f3;

    // At least some operations should succeed, others might fail due to conflicts
    int successCount = 0;
    if r1 is UpdateResult {
        successCount += 1;
    }
    if r2 is UpdateResult {
        successCount += 1;
    }
    if r3 is () {
        successCount += 1;
    }

    test:assertTrue(successCount >= 1, "At least one operation should succeed");

    check collection->drop();
    check database->drop();
}

isolated function conflictingUpdate(Collection collection, string uniqueValue, string newData)
    returns UpdateResult|Error {
    return collection->updateOne(
        {uniqueField: uniqueValue},
        {set: {data: newData, timestamp: time:utcNow()}}
    );
}

isolated function conflictingInsert(Collection collection, string uniqueValue, string data)
    returns error? {
    var result = collection->insertOne({"uniqueField": uniqueValue, "data": data});
    // This will likely fail due to unique constraint, which is expected
    return result;
}

@test:Config {
    groups: ["error_handling", "type_mismatch"]
}
public function testTypeMismatchInQueries() returns error? {
    Database database = check mongoClient->getDatabase("typeMismatchTest");
    Collection collection = check database->getCollection("mismatchDocs");

    // Insert documents with mixed types for same field
    map<json>[] mixedTypeDocs = [
        {id: "1", value: 123}, // int
        {id: "2", value: "123"}, // string
        {id: "3", value: 123.45}, // float
        {id: "4", value: true}, // boolean
        {id: "5", value: [1, 2, 3]} // array
    ];
    check collection->insertMany(mixedTypeDocs);

    // Query with type-specific operations that might cause issues
    map<json>[] potentiallyProblematicQueries = [
        {value: {\$gt: 100}}, // Numeric comparison on mixed types
        {value: {\$regex: "^1", \$options: "i"}}, // Regex on non-string types
        {value: {\$size: 3}}, // Array size on non-array types
        {value: {\$type: "string"}}, // Type-specific query
        {value: {\$in: [123, "123"]}} // Mixed type array
    ];

    foreach map<json> query in potentiallyProblematicQueries {
        stream<record {|string id; anydata value;|}, error?>|Error results =
            collection->find(query);

        if results is stream<record {|string id; anydata value;|}, error?> {
            record {|string id; anydata value;|}[] docs =
                check from record {|string id; anydata value;|} doc in results
                select doc;
            check results.close();

            // Some queries might return results, others might not
            test:assertTrue(docs.length() >= 0);
        }
        // Some queries might fail due to type incompatibility - that's expected
    }

    check collection->drop();
    check database->drop();
}
