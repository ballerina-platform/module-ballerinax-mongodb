// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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
    groups: ["collection", "list"]
}
isolated function testCollectionName() returns error? {
    Database database = check mongoClient->getDatabase("MoviesDB");
    Collection collection = check database->getCollection("Movies");
    test:assertEquals(collection.name(), "Movies");
}

@test:Config {
    groups: ["database", "collection", "list"]
}
isolated function testInvalidCollectionName() returns error? {
    Database database = check mongoClient->getDatabase("MoviesDB");
    Collection collection = check database->getCollection("Movies");
    test:assertEquals(collection.name(), "Movies");
}

@test:Config {
    groups: ["collection", "insert", "find"]
}
isolated function testInsertAndFind() returns error? {
    Database database = check mongoClient->getDatabase("MoviesDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie = {name: "Interstellar", year: 2014, rating: 10};
    check collection->insertOne(movie);
    stream<Movie, error?> result = check collection->find();
    record { Movie value; }? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a Movie record");
    }
    test:assertEquals(movieResult.value, movie);
    check result.close();
}

@test:Config {
    groups: ["collection", "insert", "find"]
}
isolated function testFindWithId() returns error? {
    Database database = check mongoClient->getDatabase("MoviesDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie = {name: "Interstellar", year: 2014, rating: 10};
    check collection->insertOne(movie);
    stream<MovieWithId, error?> result = check collection->find();
    record {MovieWithId value;}? movieResult = check result.next();
    if movieResult is () {
        test:assertFail("Expected a MovieWithId record");
    }
    test:assertEquals(movieResult.value.name, movie.name);
    check result.close();
}

@test:Config {
    groups: ["collection", "insert", "find"]
}
isolated function testNestedTypes() returns error? {
    Database database = check mongoClient->getDatabase("MoviesDB");
    Collection collection = check database->getCollection("Profile");
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
}

@test:Config {
    groups: ["collection", "insert", "find", "filter"]
}
isolated function testFindWithFilter() returns error? {
    Database database = check mongoClient->getDatabase("MoviesDB");
    Collection collection = check database->getCollection("Movies");
    Movie movie1 = {name: "Interstellar", year: 2014, rating: 10};
    Movie movie2 = {name: "Inception", year: 2010, rating: 9};
    Movie movie3 = {name: "The Dark Knight", year: 2008, rating: 9};
    check collection->insertMany([movie1, movie2, movie3]);
    stream<Movie, error?> result = check collection->find({rating: 9});
    Movie[] expectedResult = [movie2, movie3];
    Movie[] actualResult = check from Movie movie in result select movie;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
}

@test:Config {
    groups: ["collection", "insert", "find"]
}
isolated function testInsertMany() returns error? {
    Database database = check mongoClient->getDatabase("MoviesDB");
    Collection collection = check database->getCollection("TVShows");
    TvShow tvShow1 = {name: "Breaking Bad", year: 2008, rating: 9.5};
    TvShow tvShow2 = {name: "Game of Thrones", year: 2011, rating: 9.3};
    TvShow tvShow3 = {name: "Chernobyl", year: 2019, rating: 9.4};
    TvShow tvShow4 = {name: "The Wire", year: 2002, rating: 9.3};
    check collection->insertMany([tvShow1, tvShow2, tvShow3, tvShow4]);

    int count = check collection->countDocuments();
    test:assertEquals(count, 4, "Expected 4 documents in the collection");

    stream<record {string name;}, error?> result = check collection->find();
    record { string name;}[] expectedResult = [
        {name: "Breaking Bad"},
        {name: "Game of Thrones"},
        {name: "Chernobyl"},
        {name: "The Wire"}
    ];
    record { string name;}[] actualResult = check from record {string name;} tvShow in result select tvShow;
    test:assertEquals(actualResult, expectedResult);
    check result.close();
}
