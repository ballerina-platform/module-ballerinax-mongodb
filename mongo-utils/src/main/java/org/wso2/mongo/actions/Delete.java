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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.ballerinalang.jvm.values.HandleValue;
import org.wso2.mongo.BallerinaMongoDbException;
import org.wso2.mongo.MongoDBDataSource;
import org.wso2.mongo.MongoDBUtils;

/**
 * {@code Delete} action to delete documents in a collection.
 */

public class Delete extends AbstractMongoDBAction {
    private static Logger log = LoggerFactory.getLogger(Insert.class);

    /**
     * Removes documents from the collection that match the given query filter.  If no documents match, the collection
     * is not modified.
     *
     * @param datasource datasource
     * @param collectionName name of the collection
     * @param filter the query filter to apply the the delete operation
     * @param isMultiple true if more than one document should be deleted else false
     * @return the result of the remove operation
     */
    public static Object deleteData(HandleValue datasource, String collectionName, Object filter, boolean isMultiple) {
        log.debug("Deleting documents in collection " + collectionName);
        MongoDBDataSource mongoDataSource = (MongoDBDataSource) datasource.getValue();
        try {
            return delete(mongoDataSource, collectionName, filter, isMultiple);
        } catch (BallerinaMongoDbException e) {
            return MongoDBUtils.createBallerinaServerError(e);
        }
    }
}
