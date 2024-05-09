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

type Movie record {
    string name;
    int year;
    int rating;
};

type MovieWithIdName record {|
    map<string> _id;
    string name;
|};

type Person record {|
    string name;
    int age;
    Address address;
|};

type Address readonly & record {|
    string street;
    string city;
    string country;
|};

type Book readonly & record {|
    string title;
    int year;
    int rating;
|};

type Author readonly & record {|
    string name;
    Book[] books;
|};

type TvShow record {|
    string title;
    int year;
    string directorId;
|};

type Director record {|
    string id;
    string name;
|};
