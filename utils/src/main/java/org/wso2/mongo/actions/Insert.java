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
 * {@code Insert} action insert a document or documents into a collection.
 *
 */

public class Insert extends AbstractMongoDBAction {
    private static Log log = LogFactory.getLog(Insert.class);

    public static void insertData(HandleValue datasource, String collectionName, String document) {
        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();
        try {
            insert(mongoDataSource, collectionName, document);
            log.info("Successfully inserted data");
        } catch (Throwable e) {
            log.error("Error occured while inserting data", e);
        }
    }
}

