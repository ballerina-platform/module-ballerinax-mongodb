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

import ballerina/jballerina.java;

# The result iterator object for the MongoDB query result.
isolated class ResultIterator {
    private boolean isClosed = false;

    public isolated function next() returns record {|anydata value;|}|Error? {
        boolean closed;
        lock {
            closed = self.isClosed;
        }
        if closed {
            return error ApplicationError("Cannot iterate over a closed stream");
        }
        anydata|Error? next = check nextResult(self);
        if next is Error {
            lock {
                check self.close();
            }
            return next;
        } else if next !is () {
            return {value: next};
        }
        return self.close();
    }

    public isolated function close() returns Error? {
        lock {
            self.isClosed = true;
        }
        return close(self);
    }
}

isolated function nextResult(ResultIterator resultIterator) returns anydata|Error? = @java:Method {
    'class: "io.ballerina.lib.mongodb.IteratorUtils"
} external;

isolated function close(ResultIterator resultIterator) returns Error? = @java:Method {
    'class: "io.ballerina.lib.mongodb.IteratorUtils"
} external;
