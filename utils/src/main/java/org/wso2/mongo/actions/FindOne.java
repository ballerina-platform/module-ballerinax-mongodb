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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.jvm.values.HandleValue;
import org.wso2.mongo.MongoDBDataSource;

/**
 * {@code FindOne} action selects the first document that satisfies the given query criteria.
 *
 */

public class FindOne extends AbstractMongoDBAction {
    private static Log log = LogFactory.getLog(Insert.class);

    public static String queryOne(HandleValue datasource, String collectionName, Object queryString) {
        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();
        try {
            String result = findOne(mongoDataSource, collectionName, queryString);
            log.info("Successfully retrieved data");
            return result;
        } catch (Throwable e) {
            log.info("Error occured while retrieving data", e);
        }
        return null;
    }
}

