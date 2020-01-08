// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# Holds the details of an MongoDB error
#
# + message - Specific error message for the error
# + cause - Cause of the error
# + detail - Error detail
public type ErrorDetail record {
    string message;
    error cause?;
    string detail?;
};

// Error reasons
public const SERVER_ERROR_REASON = "{wso2/mongodb}ServerError";
public const CLIENT_ERROR_REASON = "{wso2/mongodb}ClientError";

public type ServerError error<SERVER_ERROR_REASON, ErrorDetail>;
public type ClientError error<CLIENT_ERROR_REASON, ErrorDetail>;

public type ConnectorError ClientError|ServerError;
