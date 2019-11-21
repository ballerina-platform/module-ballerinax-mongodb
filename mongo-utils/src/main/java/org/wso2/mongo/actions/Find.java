// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

package org.wso2.mongo.actions;

import org.ballerinalang.jvm.values.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.mongo.MongoDBDataSource;

/**
 * {@code Find} action select documents in a collection.
 */

public class Find extends AbstractMongoDBAction {
    private static Logger log = LoggerFactory.getLogger(Insert.class);

    public static ArrayValue queryData(HandleValue datasource, String collectionName, Object queryString) {
        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();
        try {
            StreamingJsonValue result = find(mongoDataSource, collectionName, queryString);
            log.info("Successfully retrieved data");
            return result;
        } catch (Throwable e) {
            log.info("Error occured while retrieving data", e);
        }
        return null;
    }
}

