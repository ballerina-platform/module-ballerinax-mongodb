/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.data.mongodb;

/**
 * Constants for MongoDB Connector.
 *
 * @since 0.95.0
 */
public final class Constants {
    public static final String B_CONNECTOR = "BConnector";
    public static final String CLIENT_ENDPOINT_CONFIG = "clientEndpointConfig";
    public static final String MONGODB_PACKAGE_PATH = "ballerina.data.mongodb";
    public static final String CLIENT_CONNECTOR = "ClientConnector";
    public static final String MONGODB_CONNECTOR_ERROR = "MongoDBConnectorError";
    public static final String MONGODB_EXCEPTION_OCCURED = "Exception Occurred while executing Mongo database";

    /**
     * Constants for EndpointConfiguration.
     */
    public static final class EndpointConfig {
        public static final String HOST = "host";
        public static final String DBNAME = "dbName";
        public static final String USERNAME = "username";
        public static final String PASSWORD = "password";
        public static final String OPTIONS = "options";
    }
}
