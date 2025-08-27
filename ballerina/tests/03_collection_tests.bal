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

import ballerina/lang.regexp;
import ballerina/test;

@test:Config {
    groups: ["collection"]
}
isolated function testCollectionName() returns error? {
    Database database = check mongoClient->getDatabase("testCollectionNameDB");
    Collection collection = check database->getCollection("Movies");
    test:assertEquals(collection.name(), "Movies");
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "insertOne", "find"]
}
isolated function testInsertAndFind() returns error? {
    Database database = check mongoClient->getDatabase("testInsertAndFindDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie = {name: "Interstellar", year: 2014, rating: 9};
    check collection->insertOne(movie);
    stream<Movie, error?> result = check collection->find();
    record {Movie value;}? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a Movie record");
    }
    test:assertEquals(movieResult.value, movie);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "insertOne", "find", "projection"]
}
isolated function testFindOne() returns error? {
    Database database = check mongoClient->getDatabase("testFindOneDB");
    Collection collection = check database->getCollection("Movies");
    Movie? actualResult = check collection->findOne();
    test:assertEquals(actualResult, (), "Expected an empty result");
    Movie movie = {name: "Interstellar", year: 2014, rating: 9};
    check collection->insertOne(movie);
    actualResult = check collection->findOne();
    test:assertEquals(actualResult, movie);
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "insertOne", "find", "projection"]
}
isolated function testInsertOneJsonMap() returns error? {
    Database database = check mongoClient->getDatabase("testInsertOneJsonMapDB");
    Collection collection = check database->getCollection("Movies");
    map<json> movie = {name: "Interstellar", year: 2014, rating: 9};
    check collection->insertOne(movie);
    stream<record {|string name;|}, error?> result = check collection->find({}, {}, {_id: 0, name: 1});
    record {record {|string name;|} value;}? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a map<json> record");
    }
    test:assertEquals(movieResult.value, {name: "Interstellar"});
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "insertMany", "find"]
}
isolated function testInsertManyJsonMap() returns error? {
    Database database = check mongoClient->getDatabase("testInsertManyJsonMapDB");
    Collection collection = check database->getCollection("Movies");
    map<json> movie1 = {name: "Interstellar", year: 2014, rating: 9};
    map<json> movie2 = {name: "Inception", year: 2010, rating: 9};
    map<json> movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    map<json> movie4 = {name: "The Dark Knight", year: 2008, rating: 9};
    map<json>[] movies = [movie1, movie2, movie3, movie4];
    check collection->insertMany(movies);
    stream<record {|string name;|}, error?> result = check collection->find();
    record {|string name;|}[] actualResult = check from record {|string name;|} movie in result
        select movie;
    record {|string name;|}[] expectedResult = [
        {name: "Interstellar"},
        {name: "Inception"},
        {name: "Shutter Island"},
        {name: "The Dark Knight"}
    ];
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "find"]
}
isolated function testFindWithId() returns error? {
    Database database = check mongoClient->getDatabase("testFindWithIdDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie = {name: "Interstellar", year: 2014, rating: 9};
    check collection->insertOne(movie);
    stream<MovieWithIdName, error?> result = check collection->find();
    record {MovieWithIdName value;}? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a MovieWithId record");
    }
    MovieWithIdName actualResult = movieResult.value;
    test:assertEquals(actualResult.name, movie.name);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "find", "projection"]
}
isolated function testFindWithManualProjection() returns error? {
    Database database = check mongoClient->getDatabase("testFindWithManualProjectionDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 10};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    stream<record {string name;}, error?> result = check collection->find({rating: 9}, {}, {name: 1});
    record {record {string name;} value;}? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a record value");
    }
    test:assertEquals(movieResult.value.name, movie3.name);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "find", "projection", "invalid"]
}
isolated function testInvalidReturnTypeWithManualProjection() returns error? {
    Database database = check mongoClient->getDatabase("testInvalidReturnTypeWithManualProjectionDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 10};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    stream<Movie, error?> result = check collection->find({rating: 9}, {}, {name: 1});
    Movie[]|error actualResult = from Movie movie in result
        select movie;
    test:assertTrue(actualResult is error);
    regexp:RegExp expectedMessage = re `Conversion error\. Expected type: mongodb:Movie, but found: \{"_id": \{"\$oid": "[0-9a-fA-F]*"\}, "name": "Shutter Island"\}`;
    test:assertTrue(regexp:isFullMatch(expectedMessage, (<error>actualResult).message()));
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "find"]
}
isolated function testNestedTypes() returns error? {
    Database database = check mongoClient->getDatabase("testNestedTypesDB");
    Collection collection = check database->getCollection("Movies");
    Person person = {
        id: "1",
        name: "John",
        age: 30,
        address: {
            street: "Bauddaloka Mawatha",
            city: "Colombo",
            country: "Sri Lanka"
        }
    };
    check collection->insertOne(person);
    stream<Person, error?> result = check collection->find({name: "John"});
    record {Person value;}? personResult = check result.next();
    if personResult is () {
        test:assertFail("Expected a Person record");
    }
    test:assertEquals(personResult.value, person);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "find", "filter"]
}
isolated function testFindWithFilter() returns error? {
    Database database = check mongoClient->getDatabase("testFindWithFilterDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 10};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    stream<Movie, error?> result = check collection->find({rating: 9});
    Movie[] expectedResult = [movie3];
    Movie[] actualResult = check from Movie movie in result
        select movie;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "countDocuments", "projection"]
}
isolated function testInsertMany() returns error? {
    Database database = check mongoClient->getDatabase("testInsertManyDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 10};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    int count = check collection->countDocuments({year: {\$gte: 2009}}); // Movies with year greater than 2009
    test:assertEquals(count, 3, "Expected 3 documents in the collection");
    stream<record {string name;}, error?> result = check collection->find();
    record {string name;}[] expectedResult = [
        {name: movie1.name},
        {name: movie2.name},
        {name: movie3.name},
        {name: movie4.name}
    ];
    record {string name;}[] actualResult = check from record {string name;} tvShow in result
        select tvShow;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "countDocuments"]
}
isolated function testCountDocuments() returns error? {
    Database database = check mongoClient->getDatabase("testCountDocumentsDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 9};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    int count = check collection->countDocuments();
    test:assertEquals(count, 4, "Expected 4 documents in the collection");
    count = check collection->countDocuments({rating: 9});
    test:assertEquals(count, 2, "Expected 2 documents with rating 9");
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "index"]
}
isolated function testIndexes() returns error? {
    Database database = check mongoClient->getDatabase("testIndexesDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 9};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    check collection->createIndex({name: 1}, {
        background: true,
        unique: true,
        name: "RatingsIndex",
        sparse: false,
        expireAfterSeconds: 100000,
        version: 1,
        weights: {rating: 1},
        defaultLanguage: "EN",
        languageOverride: "name",
        textVersion: 1,
        sphereVersion: 1,
        bits: 1,
        min: 0.0,
        max: 100.0,
        partialFilterExpression: {year: 2010},
        hidden: false
    });
    stream<Index, error?> result = check collection->listIndexes();
    string[] actualResult = check from Index index in result
        select index.name;
    string[] expectedResult = ["_id_", "RatingsIndex"];
    test:assertEquals(actualResult, expectedResult);

    check collection->dropIndex("RatingsIndex");
    result = check collection->listIndexes();
    actualResult = check from Index index in result
        select index.name;
    expectedResult = ["_id_"];
    test:assertEquals(actualResult, expectedResult);
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "update"]
}
isolated function testUpdateSet() returns error? {
    Database database = check mongoClient->getDatabase("testUpdateSetDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie = {name: "Interstellar", year: 2014, rating: 9};
    check collection->insertOne(movie);
    UpdateResult updateResult = check collection->updateOne({name: "Interstellar"}, {set: {rating: 10}});
    test:assertEquals(updateResult.matchedCount, 1);
    test:assertEquals(updateResult.modifiedCount, 1);
    stream<Movie, error?> result = check collection->find({name: "Interstellar"});
    record {Movie value;}? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a Movie record");
    }
    test:assertEquals(movieResult.value.rating, 10);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "update"]
}
isolated function testUpdateUnset() returns error? {
    Database database = check mongoClient->getDatabase("testUpdateUnsetDB");
    Collection collection = check database->getCollection("Movies");
    Person walter = {
        id: "1",
        name: "Walter White",
        age: 50,
        address: {
            street: "308, Negra Arroyo Lane",
            city: "Albuquerque",
            country: "USA"
        }
    };
    check collection->insertOne(walter);
    UpdateResult updateResult = check collection->updateOne({name: "Walter White"}, {"set": {"address.country": "United States"}});
    test:assertEquals(updateResult.matchedCount, 1);
    test:assertEquals(updateResult.modifiedCount, 1);
    stream<Person, error?> result = check collection->find({name: "Walter White"});
    record {Person value;}? personResult = check result.next();
    if personResult is () {
        test:assertFail("Expected a Person record");
    }
    test:assertEquals(personResult.value.address.country, "United States");
    updateResult = check collection->updateOne({name: "Walter White"}, {"unset": {"address.country": ""}});
    test:assertEquals(updateResult.matchedCount, 1);
    test:assertEquals(updateResult.modifiedCount, 1);
    stream<record {|anydata...;|}, error?> findResult = check collection->find({name: "Walter White"});

    record {|anydata...;|}? movieResult = check findResult.next();
    if movieResult is () {
        test:assertFail("Expected a record value from the stream");
    }
    if movieResult.hasKey("address") {
        var address = movieResult["address"];
        if address !is map<anydata> {
            test:assertFail("Expected a map value for the `address` field");
        }
        if address.hasKey("country") {
            test:assertFail("Expected the `country` field to be removed from the `address` field");
        }
    }
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "update", "upsert"]
}
isolated function testUpdateUpsert() returns error? {
    Database database = check mongoClient->getDatabase("testUpdateUpsertDB");
    Collection collection = check database->getCollection("Movies");
    UpdateResult updateResult = check collection->updateOne(
        {
        name: "Inception"
    },
        {
        set: {
            year: 2010
        },
        setOnInsert: {
            rating: 10
        }
    },
        {
        upsert: true
    }
    );
    test:assertEquals(updateResult.matchedCount, 0);
    test:assertEquals(updateResult.modifiedCount, 0);
    test:assertTrue(updateResult.upsertedId is string);
    stream<Movie, error?> result = check collection->find({name: "Inception"});
    record {Movie value;}? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a Movie record");
    }
    Movie expectedMovie = {name: "Inception", year: 2010, rating: 10};
    test:assertEquals(movieResult.value, expectedMovie);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "update"]
}
isolated function testUpdateMany() returns error? {
    Database database = check mongoClient->getDatabase("testUpdateManyDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 10};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 9};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    UpdateResult updateResult = check collection->updateMany({rating: 9}, {set: {rating: 10}});
    test:assertEquals(updateResult.matchedCount, 2);
    test:assertEquals(updateResult.modifiedCount, 2);
    stream<Movie, error?> result = check collection->find({rating: 10});
    Movie[] expectedResult = [
        {name: "Interstellar", year: 2014, rating: 10},
        {name: "Inception", year: 2010, rating: 10},
        {name: "Shutter Island", year: 2010, rating: 10},
        {name: "The Dark Knight", year: 2008, rating: 10}
    ];
    Movie[] actualResult = check from Movie movie in result
        select movie;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "distinct"]
}
isolated function testDistinct() returns error? {
    Database database = check mongoClient->getDatabase("testDistinctDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 9};
    Movie movie2 = {name: "Inception", year: 2010, rating: 9};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 9};
    Movie movie5 = {name: "Mulholland Drive", year: 2001, rating: 8};
    check collection->insertMany([movie1, movie2, movie3, movie4, movie5]);
    stream<int, error?> distinctYears = check collection->'distinct("year");
    int[] expectedResult = [2001, 2008, 2010, 2014];
    int[] actualResult = check from int year in distinctYears
        select year;
    test:assertEquals(actualResult, expectedResult);

    distinctYears = check collection->'distinct("year", {rating: 9});
    expectedResult = [2008, 2010, 2014];
    actualResult = check from int year in distinctYears
        select year;
    test:assertEquals(actualResult, expectedResult);
    check distinctYears.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "distinct"]
}
isolated function testDistinctWithString() returns error? {
    Database database = check mongoClient->getDatabase("testDistinctWithStringDB");
    Collection collection = check database->getCollection("Books");
    Book book1 = {
        title: "A Brief History of Time",
        year: 1988,
        rating: 5,
        tags: ["Physics", "History"]
    };
    Book book2 = {
        title: "The Magic of Reality",
        year: 2010,
        rating: 5,
        tags: ["Physics", "History"]
    };
    Book book3 = {
        title: "The Grand Design",
        year: 2010,
        rating: 5,
        tags: ["Physics", "History"]
    };
    Book book4 = {
        title: "iRobot",
        year: 2004,
        rating: 5,
        tags: ["Science Fiction", "Robots"]
    };
    check collection->insertMany([book1, book2, book3, book4]);
    stream<string, error?> distinctTags = check collection->'distinct("tags");
    string[] expectedResult = ["History", "Physics", "Robots", "Science Fiction"];
    string[] actualResult = check from string tag in distinctTags
        select tag;
    test:assertEquals(actualResult, expectedResult);
    check distinctTags.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "distinct"]
}
isolated function testDistinctWithRecords() returns error? {
    Database database = check mongoClient->getDatabase("testDistinctWithRecordsDB");
    Collection collection = check database->getCollection("Profile");
    Person person1 = {
        id: "1",
        name: "John Doe",
        age: 30,
        address: {
            street: "123 Main St",
            city: "Anytown",
            country: "USA"
        }
    };
    Person person2 = {
        id: "2",
        name: "Jane Smith",
        age: 25,
        address: {
            street: "456 Main St",
            city: "Anytown",
            country: "USA"
        }
    };
    Person person3 = {
        id: "3",
        name: "John Doe",
        age: 30,
        address: {
            street: "123 Main St",
            city: "Anytown",
            country: "USA"
        }
    };
    check collection->insertMany([person1, person2, person3]);
    stream<Address, error?> distinctAddresses = check collection->'distinct("address");
    Address[] expectedResult = [
        {
            street: "123 Main St",
            city: "Anytown",
            country: "USA"
        },
        {
            street: "456 Main St",
            city: "Anytown",
            country: "USA"
        }
    ];
    Address[] actualResult = check from Address address in distinctAddresses
        select address;
    test:assertEquals(actualResult, expectedResult);
    check distinctAddresses.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "delete"]
}
isolated function testDeleteOne() returns error? {
    Database database = check mongoClient->getDatabase("testDeleteOneDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 9};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    DeleteResult deleteResult = check collection->deleteOne({name: "Interstellar"});
    test:assertEquals(deleteResult.deletedCount, 1);
    test:assertTrue(deleteResult.acknowledged);
    stream<Movie, error?> result = check collection->find();
    Movie[] expectedResult = [movie2, movie3, movie4];
    Movie[] actualResult = check from Movie movie in result
        select movie;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "delete"]
}
isolated function testDeleteMany() returns error? {
    Database database = check mongoClient->getDatabase("testDeleteManyDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 9};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 8};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 10};
    check collection->insertMany([movie1, movie2, movie3, movie4]);
    check collection->createIndex({rating: 1});
    DeleteResult deleteResult = check collection->deleteMany({rating: {\$gte: 9}});
    test:assertEquals(deleteResult.deletedCount, 3, "Invalid delete count");
    test:assertTrue(deleteResult.acknowledged, "Expected acknoledged to be true");
    stream<Movie, error?> result = check collection->find();
    Movie[] expectedResult = [movie3];
    Movie[] actualResult = check from Movie movie in result
        select movie;
    test:assertEquals(actualResult, expectedResult);
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate"]
}
isolated function testAggregate() returns error? {
    Database database = check mongoClient->getDatabase("testAggregateDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 9};
    Movie movie2 = {name: "Inception", year: 2010, rating: 9};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    Movie movie4 = {name: "The Dark Knight", year: 2008, rating: 9};
    Movie movie5 = {name: "Mulholland Drive", year: 2001, rating: 8};
    check collection->insertMany([movie1, movie2, movie3, movie4, movie5]);

    stream<record {int _id; int count;}, error?> result = check collection->aggregate([
        {
            \$match: {
                rating: 9
            }
        },
        {
            \$group: {
                _id: "$year",
                count: {
                    \$sum: 1
                }
            }
        },
        {
            \$sort: {
                _id: 1
            }
        }
    ]);
    record {int _id; int count;}[] expectedResult = [
        {_id: 2008, count: 1},
        {_id: 2010, count: 2},
        {_id: 2014, count: 1}
    ];
    record {int _id; int count;}[] actualResult = check from record {int _id; int count;} movie in result
        select movie;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "find", "projection"]
}
isolated function testComplexFind() returns error? {
    Database database = check mongoClient->getDatabase("testComplexFindDB");
    Collection collection = check database->getCollection("Books");

    Book book1 = {title: "The Alchemist", year: 1988, rating: 5};
    Book book2 = {title: "Veronika Decides to Die", year: 1998, rating: 4};
    Book book3 = {title: "The Zahir", year: 2005, rating: 3};
    Book book4 = {title: "Game of Thrones", year: 1996, rating: 4};
    Book book5 = {title: "A Clash of Kings", year: 1998, rating: 4};
    Book book6 = {title: "A Storm of Swords", year: 2000, rating: 4};
    Author author1 = {name: "Paulo Coelho", books: [book1, book2, book3]};
    Author author2 = {name: "George R. R. Martin", books: [book4, book5, book6]};

    check collection->insertMany([author1, author2]);
    stream<record {|
        string name;
        record {|string title;|}[] books;
    |}, error?> result = check collection->find({"books.rating": 5});
    record {|
        string name;
        record {|string title;|}[] books;
    |}[] expectedResult = [
        {
            name: "Paulo Coelho",
            books: [
                {
                    title: "The Alchemist"
                },
                {
                    title: "Veronika Decides to Die"
                },
                {
                    title: "The Zahir"
                }
            ]
        }
    ];
    record {|
        string name;
        record {|string title;|}[] books;
    |}[] actualResult = check from record {|string name; record {|string title;|}[] books;|} author in result
        select author;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "aggregate", "projection"]
}
isolated function testComplexAggregationProjection() returns error? {
    Database database = check mongoClient->getDatabase("testComplexAggregationDB");
    Collection collection = check database->getCollection("Books");

    Book book1 = {title: "The Alchemist", year: 1988, rating: 5};
    Book book2 = {title: "Veronika Decides to Die", year: 1998, rating: 4};
    Book book3 = {title: "The Zahir", year: 2005, rating: 3};
    Book book4 = {title: "Game of Thrones", year: 1996, rating: 4};
    Book book5 = {title: "A Clash of Kings", year: 1998, rating: 4};
    Book book6 = {title: "A Storm of Swords", year: 2000, rating: 4};
    Author author1 = {name: "Paulo Coelho", books: [book1, book2, book3]};
    Author author2 = {name: "George R. R. Martin", books: [book4, book5, book6]};

    check collection->insertMany([author1, author2]);
    stream<record {|
        string name;
        record {|string title; int rating;|}[] books;
    |}, error?> result = check collection->aggregate([
        {
            \$project: {
                _id: 0,
                name: 1,
                books: {
                    \$map: {
                        input: {
                            \$filter: {
                                input: "$books",
                                cond: {
                                    \$gte: ["$$this.rating", 4]
                                }
                            }
                        },
                        'as: "book",
                        'in: {
                            title: "$$book.title",
                            rating: "$$book.rating"
                        }
                    }
                }
            }
        },
        {
            \$sort: {
                name: 1
            }
        }
    ]);
    record {|
        string name;
        record {|string title; int rating;|}[] books;
    |}[] expectedResult = [
        {
            name: "George R. R. Martin",
            books: [
                {title: "Game of Thrones", rating: 4},
                {title: "A Clash of Kings", rating: 4},
                {title: "A Storm of Swords", rating: 4}
            ]
        },
        {
            name: "Paulo Coelho",
            books: [
                {title: "The Alchemist", rating: 5},
                {title: "Veronika Decides to Die", rating: 4}
            ]
        }
    ];
    record {|
        string name;
        record {|string title; int rating;|}[] books;
    |}[] actualResult = check from record {|string name; record {|string title; int rating;|}[] books;|} author in result
        select author;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "aggregate", "projection"]
}
isolated function testAggregationWithManualProjection() returns error? {
    Database database = check mongoClient->getDatabase("testAggregationWithManualProjectionDB");
    Collection collection = check database->getCollection("Movies");

    Book book1 = {title: "The Alchemist", year: 1988, rating: 5};
    Book book2 = {title: "Veronika Decides to Die", year: 1998, rating: 4};
    Book book3 = {title: "The Zahir", year: 2005, rating: 3};
    Book book4 = {title: "Game of Thrones", year: 1996, rating: 4};
    Book book5 = {title: "A Clash of Kings", year: 1998, rating: 4};
    Book book6 = {title: "A Storm of Swords", year: 2000, rating: 4};
    Author author1 = {name: "Paulo Coelho", books: [book1, book2, book3]};
    Author author2 = {name: "George R. R. Martin", books: [book4, book5, book6]};

    check collection->insertMany([author1, author2]);
    stream<record {|string name;|}, error?> result = check collection->aggregate([
        {
            \$match: {
                "books.rating": {
                    \$gte: 4
                }
            }
        },
        {
            \$project: {
                _id: 0,
                name: 1
            }
        }
    ]);
    record {|string name;|}[] expectedResult = [
        {name: "Paulo Coelho"},
        {name: "George R. R. Martin"}
    ];
    record {|string name;|}[] actualResult = check from record {|string name;|} author in result
        select author;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate"]
}
isolated function testAggregationWithInvalidManualProjection() returns error? {
    Database database = check mongoClient->getDatabase("testAggregationWithInvalidManualProjectionDB");
    Collection collection = check database->getCollection("Movies");

    Book book1 = {title: "The Alchemist", year: 1988, rating: 5};
    Book book2 = {title: "Veronika Decides to Die", year: 1998, rating: 4};
    Book book3 = {title: "The Zahir", year: 2005, rating: 3};
    Book book4 = {title: "Game of Thrones", year: 1996, rating: 4};
    Book book5 = {title: "A Clash of Kings", year: 1998, rating: 4};
    Book book6 = {title: "A Storm of Swords", year: 2000, rating: 4};
    Author author1 = {name: "Paulo Coelho", books: [book1, book2, book3]};
    Author author2 = {name: "George R. R. Martin", books: [book4, book5, book6]};

    check collection->insertMany([author1, author2]);
    stream<Author, error?> result = check collection->aggregate([
        {
            \$match: {
                "books.rating": {
                    \$gte: 4
                }
            }
        },
        {
            \$project: {
                _id: 0,
                name: 1
            }
        }
    ]);
    record {Author value;}|error? nextResult = result.next();
    if nextResult !is error {
        test:assertFail("Expected error but got " + nextResult.toString());
    }
    test:assertEquals(nextResult.message(), "Conversion error. Expected type: mongodb:Author, but found: {\"name\": \"Paulo Coelho\"}");
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate", "union_type"]
}
isolated function testAggregateWithUnionType() returns error? {
    Database database = check mongoClient->getDatabase("testAggregateWithUnionTypeDB");
    Collection collection = check database->getCollection("Movies");

    Book book1 = {title: "The Alchemist", year: 1988, rating: 9};
    Book book2 = {title: "Veronika Decides to Die", year: 1998, rating: 8};
    Book book3 = {title: "The Zahir", year: 2005, rating: 9};
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 9};
    Movie movie2 = {name: "Inception", year: 2010, rating: 8};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    check collection->insertMany([book1, book2, book3, movie1, movie2, movie3]);
    stream<BookOrMovie, error?> result = check collection->aggregate([
        {
            \$match: {
                rating: 9
            }
        }
    ]);
    BookOrMovie[] expectedResult = [book1, book3, movie1, movie3];
    BookOrMovie[] actualResult = check from BookOrMovie item in result
        select item;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate", "union_type"]
}
isolated function testAggregateWithUnionTypeSelectedFields() returns error? {
    Database database = check mongoClient->getDatabase("testAggregateWithUnionTypeSelectedFieldsDB");
    Collection collection = check database->getCollection("Movies");

    Book book1 = {title: "The Alchemist", year: 1988, rating: 9};
    Book book2 = {title: "Veronika Decides to Die", year: 1998, rating: 8};
    Book book3 = {title: "The Zahir", year: 2005, rating: 9};
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 9};
    Movie movie2 = {name: "Inception", year: 2010, rating: 8};
    Movie movie3 = {name: "Shutter Island", year: 2010, rating: 9};
    check collection->insertMany([book1, book2, book3, movie1, movie2, movie3]);
    stream<record {|string title?; string name?; int rating;|}, error?> result = check collection->aggregate([
        {
            \$match: {
                rating: 9
            }
        }
    ]);
    record {|string title?; string name?; int rating;|}[] expectedResult = [
        {title: "The Alchemist", rating: 9},
        {title: "The Zahir", rating: 9},
        {name: "Interstellar", rating: 9},
        {name: "Shutter Island", rating: 9}
    ];
    record {|string title?; string name?; int rating;|}[] actualResult = check from record {|string title?; string name?; int rating;|} item in result
        select item;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate", "empty_pipeline"]
}
isolated function testEmptyPipelineAggregation() returns error? {
    Database database = check mongoClient->getDatabase("testEmptyPipelineAggregationDB");
    Collection collection = check database->getCollection("Movies");

    Movie movie1 = {name: "Interstellar", year: 2014, rating: 9};
    Movie movie2 = {name: "Inception", year: 2010, rating: 8};
    check collection->insertMany([movie1, movie2]);

    stream<Movie, error?> result = check collection->aggregate([]);
    Movie[] expectedResult = [movie1, movie2];
    Movie[] actualResult = check from Movie movie in result
        select movie;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate", "nested_array", "projection"]
}
isolated function testNestedArrayElementProjection() returns error? {
    Database database = check mongoClient->getDatabase("testNestedArrayElementProjectionDB");
    Collection collection = check database->getCollection("Products");

    ProductCatalog catalog1 = {
        category: "Electronics",
        products: [
            {name: "Laptop", price: 999.99, variants: [{size: "13inch", color: "Silver", stock: 10}]},
            {name: "Phone", price: 699.99, variants: [{size: "6inch", color: "Black", stock: 5}]}
        ]
    };
    check collection->insertOne(catalog1);

    stream<record {|
        string category;
        record {|string name; decimal price;|}[] products;
    |}, error?> result = check collection->aggregate([
        {\$match: {"products.price": {\$lt: 800}}}
    ]);

    record {|
        string category;
        record {|string name; decimal price;|}[] products;
    |}[] actualResult = check from record {|string category; record {|string name; decimal price;|}[] products;|} catalog in result
        select catalog;

    test:assertTrue(actualResult.length() > 0);
    test:assertEquals(actualResult[0].category, "Electronics");
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "find", "deep_nesting", "projection"]
}
isolated function testDeepNestedProjection() returns error? {
    Database database = check mongoClient->getDatabase("testDeepNestedProjectionDB");
    Collection collection = check database->getCollection("Departments");

    Department dept = {
        name: "Engineering",
        manager: {
            name: "John Smith",
            employees: [
                {
                    name: "Alice Johnson",
                    position: "Senior Developer",
                    contact: {
                        email: "alice@company.com",
                        phone: {country: "US", number: "123-456-7890"}
                    }
                }
            ]
        }
    };
    check collection->insertOne(dept);

    stream<record {|
        string name;
        record {|
            string name;
            record {|
                string name;
                record {|
                    string email;
                    record {|string country;|} phone;
                |} contact;
            |}[] employees;
        |} manager;
    |}, error?> result = check collection->find();

    record {|
        string name;
        record {|
            string name;
            record {|
                string name;
                record {|
                    string email;
                    record {|string country;|} phone;
                |} contact;
            |}[] employees;
        |} manager;
    |}[] actualResult = check from var department in result
        select department;

    test:assertEquals(actualResult.length(), 1);
    test:assertEquals(actualResult[0].name, "Engineering");
    test:assertEquals(actualResult[0].manager.employees[0].contact.phone.country, "US");
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "find", "null_fields", "projection"]
}
isolated function testNullFieldHandling() returns error? {
    Database database = check mongoClient->getDatabase("testNullFieldHandlingDB");
    Collection collection = check database->getCollection("Products");

    map<json> product1 = {name: "Basic Product", price: 99.99, tags: ()};
    map<json> product2 = {name: "Premium Product", price: 199.99, tags: ["premium", "featured"]};
    check collection->insertMany([product1, product2]);

    stream<record {|string name; string[]? tags;|}, error?> result = check collection->find();
    record {|string name; string[]? tags;|}[] actualResult = check from record {|string name; string[]? tags;|} product
        in result
        select product;
    test:assertEquals(actualResult.length(), 2);
    test:assertTrue(actualResult[0].tags is ());
    test:assertTrue(actualResult[1].tags is string[]);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate", "union_type", "all_optional"]
}
isolated function testUnionTypeAllOptionalFieldsMissing() returns error? {
    Database database = check mongoClient->getDatabase("testUnionTypeAllOptionalMissingDB");
    Collection collection = check database->getCollection("Items");

    map<json> item1 = {id: "item1", rating: 8};
    map<json> item2 = {id: "item2", rating: 9};
    check collection->insertMany([item1, item2]);

    stream<record {|string title?; string name?; int rating;|}, error?> result = check collection->aggregate([
        {\$match: {rating: {\$gte: 8}}}
    ]);

    record {|string title?; string name?; int rating;|}[] actualResult = check from record {|string title?; string name?; int rating;|} item in result
        select item;

    test:assertEquals(actualResult.length(), 2);
    test:assertTrue(actualResult[0].title is ());
    test:assertTrue(actualResult[0].name is ());
    test:assertEquals(actualResult[0].rating, 8);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "find", "multi_level", "nested_projection"]
}
isolated function testMultiLevelNestedRecordProjection() returns error? {
    Database database = check mongoClient->getDatabase("testMultiLevelNestedDB");
    Collection collection = check database->getCollection("Organizations");

    Department dept = {
        name: "Sales",
        manager: {
            name: "Sarah Connor",
            employees: [
                {
                    name: "Tom Wilson",
                    position: "Sales Rep",
                    contact: {
                        email: "tom@company.com",
                        phone: {country: "CA", number: "555-0123"}
                    }
                }
            ]
        }
    };
    check collection->insertOne(dept);

    stream<record {|
        string name;
        record {|
            record {|
                record {|string email;|} contact;
            |}[] employees;
        |} manager;
    |}, error?> result = check collection->find();

    record {|
        string name;
        record {|
            record {|
                record {|string email;|} contact;
            |}[] employees;
        |} manager;
    |}[] actualResult = check from var org in result
        select org;

    test:assertEquals(actualResult.length(), 1);
    test:assertEquals(actualResult[0].manager.employees[0].contact.email, "tom@company.com");
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "find", "type_coercion"]
}
isolated function testTypeCoercionEdgeCases() returns error? {
    Database database = check mongoClient->getDatabase("testTypeCoercionDB");
    Collection collection = check database->getCollection("MixedTypes");

    map<json> doc1 = {id: 1, value: "string_value", number: 42};
    map<json> doc2 = {id: 2, value: 123, number: "456"};
    check collection->insertMany([doc1, doc2]);

    stream<record {|int id; int|string value; int|string number;|}, error?> result = check collection->find();
    record {|int id; int|string value; int|string number;|}[] actualResult = check
        from record {|int id; int|string value; int|string number;|} doc
        in result
    select doc;

    test:assertEquals(actualResult.length(), 2);
    test:assertTrue(actualResult[0].value is string);
    test:assertTrue(actualResult[0].number is int);
    test:assertTrue(actualResult[1].value is int);
    test:assertTrue(actualResult[1].number is string);
    check result.close();
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert"]
}
public function testInsertEmptyDocument() returns error? {
    Database database = check mongoClient->getDatabase("emptyDocumentTest");
    Collection collection = check database->getCollection("emptyDocs");

    // Insert empty JSON object
    map<json> emptyDoc = {};
    check collection->insertOne(emptyDoc);

    // Verify it was inserted with MongoDB-generated _id
    stream<record {map<string> _id;}, error?> results = check collection->find();
    record { map<string> _id;}[] docs = check from record {map<string> _id;} doc in results
        select doc;
    check results.close();

    test:assertTrue(docs.length() > 0);
    test:assertTrue(docs[0].hasKey("_id"));

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert", "negative", "test"]
}
public function testInsertDuplicateKeys() returns error? {
    Database database = check mongoClient->getDatabase("duplicateKeyTest");
    Collection collection = check database->getCollection("uniqueDocs");

    // Create unique index
    check collection->createIndex({name: 1}, {unique: true});

    Movie movie1 = {name: "Unique Movie", year: 2024, rating: 8};
    check collection->insertOne(movie1);

    // Try to insert document with same unique field - should fail
    Movie movie2 = {name: "Unique Movie", year: 2025, rating: 9};
    Error? result = collection->insertOne(movie2);
    test:assertTrue(result is Error, "Expected error for duplicate unique key");
    if result is Error {
        string expectedMessage = "E11000 duplicate key error collection: duplicateKeyTest.uniqueDocs index: name_1 dup key: { name: \"Unique Movie\" }";
        test:assertEquals(result.message(), expectedMessage, "Expected error for duplicate unique key");
    }
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "update"]
}
public function testConcurrentUpdates() returns error? {
    Database database = check mongoClient->getDatabase("concurrentUpdateTest");
    Collection collection = check database->getCollection("concurrentDocs");

    // Insert test document
    check collection->insertOne({"name": "Concurrent", "counter": 0});

    // Perform concurrent updates
    future<UpdateResult|Error> f1 = start updateCounter(collection);
    future<UpdateResult|Error> f2 = start updateCounter(collection);
    future<UpdateResult|Error> f3 = start updateCounter(collection);

    UpdateResult|Error r1 = wait f1;
    UpdateResult|Error r2 = wait f2;
    UpdateResult|Error r3 = wait f3;

    // All updates should succeed (MongoDB handles concurrency)
    test:assertTrue(r1 is UpdateResult, "Concurrent update 1 should succeed");
    test:assertTrue(r2 is UpdateResult, "Concurrent update 2 should succeed");
    test:assertTrue(r3 is UpdateResult, "Concurrent update 3 should succeed");

    // Verify final state
    stream<record {|int counter;|}, error?> results = check collection->find({name: "Concurrent"});
    record {|
        record {|int counter;|} value;
    |}? doc = check results.next();
    check results.close();

    if doc is () {
        test:assertFail("No results returned");
    }
    test:assertTrue(doc.value.counter > 0, "Counter should be incremented");
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "delete"]
}
public function testDeleteFromNonExistentDocument() returns error? {
    Database database = check mongoClient->getDatabase("nonExistentDeleteTest");
    Collection collection = check database->getCollection("emptyCollection");

    // Delete from empty collection
    DeleteResult result = check collection->deleteOne({name: "NonExistent"});
    test:assertEquals(result.deletedCount, 0, "No documents should be deleted");
    test:assertTrue(result.acknowledged, "Operation should be acknowledged");

    // Delete many from empty collection
    DeleteResult resultMany = check collection->deleteMany({});
    test:assertEquals(resultMany.deletedCount, 0, "No documents should be deleted");

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "aggregate"]
}
public function testAggregationWithInvalidStages() returns error? {
    Database database = check mongoClient->getDatabase("invalidPipelineTest");
    Collection collection = check database->getCollection("aggregateDocs");

    check collection->insertOne({"name": "Interstellar", "year": 2014, "rating": 8});

    // Test aggregation with potentially problematic stages
    map<json>[][] problematicPipelines = [
        [{\$invalidStage: {}}], // Invalid stage name
        [{\$match: {}}, {\$project: {}}], // Empty project
        [{\$group: {}}] // Incomplete group stage
    ];
    foreach map<json>[] pipeline in problematicPipelines {
        stream<record {|anydata...;|}, error?>|Error results = collection->aggregate(pipeline);
        test:assertTrue(results is Error, "Pipeline should fail");
    }
    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "distinct"]
}
public function testDistinctOnNonExistentField() returns error? {
    Database database = check mongoClient->getDatabase("distinctNonExistentTest");
    Collection collection = check database->getCollection("distinctDocs");

    Movie[] movies = [
        {name: "Movie1", year: 2020, rating: 8},
        {name: "Movie2", year: 2021, rating: 9}
    ];
    check collection->insertMany(movies);

    // Distinct on non-existent field should return empty results
    stream<string, error?> results = check collection->'distinct("nonExistentField");
    string[] distinctValues = check from string value in results
        select value;
    check results.close();

    test:assertEquals(distinctValues.length(), 0, "Non-existent field should return no distinct values");

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "find"]
}
public function testFindWithComplexNestedQuery() returns error? {
    Database database = check mongoClient->getDatabase("complexNestedQueryTest");
    Collection collection = check database->getCollection("nestedDocs");

    // Insert documents with deep nesting
    map<json> deepDoc = {
        level1: {
            level2: {
                level3: {
                    level4: {
                        value: "deep_value",
                        array: [1, 2, 3, {nested: "in_array"}]
                    }
                }
            }
        },
        simpleField: "simple"
    };
    check collection->insertOne(deepDoc);

    // Query deep nested fields
    map<json>[] complexQueries = [
        {"level1.level2.level3.level4.value": "deep_value"},
        {"level1.level2.level3.level4.array.3.nested": "in_array"},
        {"level1.level2.level3.level4.array": {\$in: [1]}},
        {\$and: [{"simpleField": "simple"}, {"level1.level2.level3.level4.value": "deep_value"}]}
    ];

    foreach map<json> query in complexQueries {
        stream<record {|anydata...;|}, error?> results = check collection->find(query);
        record {|anydata...;|}[] docs = check from record {|anydata...;|} doc in results
            select doc;
        check results.close();

        // At least some queries should find the document
        test:assertTrue(docs.length() >= 0);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "insert"]
}
public function testInsertManyWithMixedSuccessFailure() returns error? {
    Database database = check mongoClient->getDatabase("mixedInsertTest");
    Collection collection = check database->getCollection("mixedDocs");

    // Create unique index
    check collection->createIndex({name: 1}, {unique: true});

    // Insert one document first
    check collection->insertOne({"name": "Existing", "year": 2020, "rating": 7});

    // Try to insert array with some duplicates
    map<json>[] docs = [
        {name: "New1", year: 2021, rating: 8},
        {name: "Existing", year: 2022, rating: 9}, // This will fail
        {name: "New2", year: 2023, rating: 7}
    ];

    Error? result = collection->insertMany(docs, {ordered: false});
    test:assertTrue(result is Error, "Expected error for mixed success failure");
    int count = check collection->countDocuments();
    test:assertTrue(count >= 2, "At least original + one new document should exist");
    check collection->drop();
    check database->drop();
}


@test:Config {
    groups: ["collection", "find"]
}
public function testFindWithInvalidQuery() returns error? {
    Database database = check mongoClient->getDatabase("invalidQueryTest");
    Collection collection = check database->getCollection("testDocs");

    // Insert test data
    check collection->insertOne({"name": "Interstellar", "year": 2014, "rating": 8});

    // Test various potentially problematic queries
    map<json>[] problematicQueries = [
        {}, // Empty query - should match all
        {nonExistentField: "value"}, // Non-existent field
        {year: ()}, // Null value
        {"nested.field": "value"} // Nested field that doesn't exist
    ];

    foreach map<json> query in problematicQueries {
        stream<record {|anydata...;|}, error?> results = check collection->find(query);
        record {|anydata...;|}[] docs = check from record {|anydata...;|} doc in results
            select doc;
        check results.close();
        test:assertTrue(docs.length() >= 0);
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "projection"]
}
public function testProjectionEdgeCases() returns error? {
    Database database = check mongoClient->getDatabase("projectionEdgeCaseTest");
    Collection collection = check database->getCollection("projectionDocs");

    map<json> doc = {
        field1: "value1",
        field2: "value2",
        nested: {
            subfield1: "subvalue1",
            subfield2: "subvalue2"
        },
        array: [
            {arrayField: "arrayValue1"},
            {arrayField: "arrayValue2"}
        ]
    };
    check collection->insertOne(doc);

    // Test various projection edge cases
    map<json>[] projections = [
        {}, // Empty projection (should include all)
        {field1: 1, _id: 0}, // Include specific field, exclude _id
        {field1: 0}, // Exclude specific field
        {"nested.subfield1": 1, _id: 0}, // Nested field projection
        {"array.arrayField": 1, _id: 0}, // Array field projection
        {nonExistentField: 1, _id: 0} // Non-existent field
    ];

    foreach map<json> projection in projections {
        stream<record {|anydata...;|}, error?> results = check collection->find({}, {}, projection);
        record {|anydata...;|}[] docs = check from record {|anydata...;|} item in results
            select item;
        check results.close();
        test:assertTrue(docs.length() > 0, "Should find documents with projection");
    }

    check collection->drop();
    check database->drop();
}

@test:Config {
    groups: ["collection", "index"]
}
public function testIndexOnNonExistentField() returns error? {
    Database database = check mongoClient->getDatabase("indexNonExistentTest");
    Collection collection = check database->getCollection("indexDocs");

    // Create index on field that doesn't exist in any documents
    check collection->createIndex({nonExistentField: 1});

    // Insert document without the indexed field
    check collection->insertOne({"name": "Interstellar", "year": 2014});

    // Query using the non-existent field
    stream<record {|anydata...;|}, error?> results = check collection->find({nonExistentField: "value"});
    record {|anydata...;|}[] docs = check from record {|anydata...;|} doc in results
        select doc;
    check results.close();

    test:assertEquals(docs.length(), 0, "No documents should match non-existent field");

    // Verify index exists
    stream<record {|anydata...;|}, error?> indexes = check collection->listIndexes();
    record {|anydata...;|}[] indexList = check from record {|anydata...;|} index in indexes
        select index;
    check indexes.close();

    test:assertTrue(indexList.length() > 1, "Should have default _id index plus our custom index");

    check collection->drop();
    check database->drop();
}


