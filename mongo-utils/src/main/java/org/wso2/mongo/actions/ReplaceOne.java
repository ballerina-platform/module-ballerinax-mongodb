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

import org.ballerinalang.jvm.values.HandleValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.wso2.mongo.BallerinaMongoDbException;
import org.wso2.mongo.MongoDBDataSource;
import org.wso2.mongo.MongoDBUtils;

/**
 * {@code ReplaceOne} replaces a single document within the collection based on the filter..
 */

public class ReplaceOne extends AbstractMongoDBAction {
    private static Logger log = LoggerFactory.getLogger(Insert.class);

    /**
     * Replace a document in the collection according to the specified arguments.
     *
     * @param datasource datasource
     * @param collectionName name of the collection
     * @param filter the query filter to apply the the replace operation
     * @param replacement the replacement document
     * @return the result of the replace operation
     */
    public static Object replaceData(HandleValue datasource, String collectionName, Object filter, Object replacement,
                                     boolean upsert) {
        log.debug("Replacing data in collection " + collectionName);
        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();
        try {
            return replaceOne(mongoDataSource, collectionName, filter, replacement, upsert);
        } catch (BallerinaMongoDbException e) {
            return MongoDBUtils.createBallerinaDatabaseError(e);
        }
    }
}
