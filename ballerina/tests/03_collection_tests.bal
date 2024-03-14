// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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
    groups: ["collection", "insert", "insertOne", "find", "projection", "test"]
}
isolated function testFindOne() returns error? {
    Database database = check mongoClient->getDatabase("testFindOneDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie = {name: "Interstellar", year: 2014, rating: 9};
    check collection->insertOne(movie);
    Movie? actualResult = check collection->findOne();
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
    test:assertEquals((<error>actualResult).message(), "{ballerina/lang.value}ConversionError");
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
    result = check collection->find({name: "Walter White"});

    // Trapping the type conversion error and checking for the relevant error message.
    // This is to confirm the field is removed from the document.
    record {Person value;}|error? movieResult = trap result.next();
    if movieResult !is error {
        test:assertFail("Expected an error");
    }
    var detail = movieResult.detail();
    if detail !is anydata {
        test:assertFail("Expected anydata type for error detail");
    }
    string message = detail["message"].toString();
    test:assertTrue(message.includes("missing required field 'address.country' of type 'string'"));
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
    Database database = check mongoClient->getDatabase("testComplexAggregationDB");
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
    stream<record {|
        string name;
        record {|string title;|}[] books;
    |}, error?> result = check collection->aggregate([
        {
            \$match: {
                "books.rating": {
                    \$gte: 4
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
        record {|string title;|}[] books;
    |}[] expectedResult = [
        {
            name: "George R. R. Martin",
            books: [
                {title: "Game of Thrones"},
                {title: "A Clash of Kings"},
                {title: "A Storm of Swords"}
            ]
        },
        {
            name: "Paulo Coelho",
            books: [
                {title: "The Alchemist"},
                {title: "Veronika Decides to Die"},
                {title: "The Zahir"}
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
