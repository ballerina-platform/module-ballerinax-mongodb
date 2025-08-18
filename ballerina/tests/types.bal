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
    readonly string id;
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
    string[] tags = [];
|};

type Author readonly & record {|
    string name;
    Book[] books;
|};

type BookOrMovie Book|Movie;

type Department record {|
    string name;
    Manager manager;
|};

type Manager record {|
    string name;
    Employee[] employees;
|};

type Employee record {|
    string name;
    string position;
    ContactInfo contact;
|};

type ContactInfo record {|
    string email;
    PhoneNumber phone;
|};

type PhoneNumber record {|
    string country;
    string number;
|};

type ProductCatalog record {|
    string category;
    Product[] products;
|};

type Product record {|
    string name;
    decimal price;
    string[] tags?;
    Variant[]? variants;
|};

type Variant record {|
    string size?;
    string color?;
    int stock;
|};

type UserProfile record {|
    string username;
    map<string> preferences;
    map<int> scores;
    map<json> metadata;
|};

type UserSettings record {|
    string userId;
    map<boolean> featureFlags;
    map<decimal> limits;
    map<string[]> categories;
|};

type ConfigData record {|
    string name;
    map<map<string>> nestedConfig;
    map<json>? optionalMap;
|};

type ReadonlyUser readonly & record {|
    string name;
    int age;
    string email;
|};

type ImmutableConfig readonly & record {|
    string appName;
    map<string> settings;
    int version;
|};

type UserWithAddress readonly & record {|
    *Person;
    string phoneNumber;
    string[] hobbies;
|};

type RestrictedData record {|
    string publicField;
    never secretField?;
    map<json> data;
|};

type SystemConfig record {|
    string name;
    never deprecatedField?;
    map<string> settings;
    never removedProperty?;
|};

type XmlDocument record {|
    string name;
    xml content;
    map<string> attributes?;
|};

type XmlLibrary record {|
    string libraryName;
    xml[] documents;
    xml metadata;
|};

type NumericData record {|
    string name;
    float floatValue;
    decimal decimalValue;
    byte byteValue;
|};

type TableData record {|
    string tableName;
    table<map<json>> dataTable;
|};
