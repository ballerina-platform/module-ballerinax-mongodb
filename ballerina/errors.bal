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

# Properties of a database error.
#
# + mongoDBExceptionType - Type of the returned MongoDB exception
public type DatabaseErrorDetail record {
    string mongoDBExceptionType;
};

# An error caused by issues related to database accessibility, erroneous queries, constraint violations,
# database resource clean-up, and similar scenarios.
public type DatabaseError distinct error<DatabaseErrorDetail>;

# An error originating from application-level causes.
public type ApplicationError distinct error;

# A database or application-level error returned from the MongoDB client remote functions.
public type Error DatabaseError|ApplicationError|error;
