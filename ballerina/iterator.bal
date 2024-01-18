// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

// import ballerina/jballerina.java;

// # Represents ResultIterator.
// public class ResultIterator {
//     private boolean isClosed = false;
//     private Error? err;

//     public isolated function init(Error? err = ()) {
//         self.err = err;
//     }

//     public isolated function next() returns record {|record {} value;|}|Error? {
//         if (self.isClosed) {
//             return closedStreamInvocationError();
//         }
//         if (self.err is Error) {
//             return self.err;
//         } else {
//             record {}|Error? result;
//             result = nextResult(self);
//             if (result is record {}) {
//                 record {|
//                     record {} value;
//                 |} streamRecord = {value: result};
//                 return streamRecord;
//             } else if (result is Error) {
//                 self.err = result;
//                 check self.close();
//                 return self.err;
//             } else {
//                 check self.close();
//                 return result;
//             }
//         }
//     }

//     public isolated function close() returns Error? {
//         if (!self.isClosed) {
//             if (self.err is ()) {
//                 Error? e = closeResult(self);
//                 if (e is ()) {
//                     self.isClosed = true;
//                 }
//                 return e;
//             }
//         }
//     }
// }

// isolated function closedStreamInvocationError() returns Error {
//     return error ApplicationError("Stream is closed. Therefore, no operations are allowed further on the stream.");
// }

// isolated function nextResult(ResultIterator iterator) returns record {}|Error? = @java:Method {
//     'class: "org.ballerinalang.mongodb.RecordIteratorUtils"
// } external;

// isolated function closeResult(ResultIterator iterator) returns Error? = @java:Method {
//     'class: "org.ballerinalang.mongodb.RecordIteratorUtils"
// } external;

// # Represents MongoResultIterator.
// public class MongoResultIterator {
//     public isolated function nextResult(ResultIterator iterator) returns record {}|Error? = @java:Method {
//         'class: "org.ballerinalang.mongodb.RecordIteratorUtils"
//     } external;
// }

// public class PlainResultIterator {
//     private boolean isClosed = false;
//     private Error? err;

//     public isolated function init(Error? err = ()) {
//         self.err = err;
//     }

//     public isolated function next() returns record {|anydata value;|}|Error? {
//         if (self.isClosed) {
//             return closedStreamInvocationError();
//         }
//         if (self.err is Error) {
//             return self.err;
//         } else {
//             anydata|Error? result;
//             result = nextPlainResult(self);
//             if (result is anydata) {
//                 if result is () {
//                     check self.close();
//                     return result;
//                 }
//                 record {|
//                     anydata value;
//                 |} streamRecord = {value: result};
//                 return streamRecord;
//             } else {
//                 self.err = result;
//                 check self.close();
//                 return self.err;
//             }
//         }
//     }

//     public isolated function close() returns Error? {
//         if (!self.isClosed) {
//             if (self.err is ()) {
//                 Error? e = closePlainResult(self);
//                 if (e is ()) {
//                     self.isClosed = true;
//                 }
//                 return e;
//             }
//         }
//     }
// }

// isolated function nextPlainResult(PlainResultIterator iterator) returns anydata|Error? = @java:Method {
//     'class: "org.ballerinalang.mongodb.RecordIteratorUtils"
// } external;

// isolated function closePlainResult(PlainResultIterator iterator) returns Error? = @java:Method {
//     'class: "org.ballerinalang.mongodb.RecordIteratorUtils"
// } external;
