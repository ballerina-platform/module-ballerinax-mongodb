/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package org.ballerinalang.mongodb;

import com.mongodb.MongoClient;
import com.mongodb.client.MongoCollection;
import de.flapdoodle.embed.mongo.MongodExecutable;
import org.ballerinalang.launcher.util.BCompileUtil;
import org.ballerinalang.launcher.util.BRunUtil;
import org.ballerinalang.launcher.util.CompileResult;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.mongodb.utils.MongoDBTestUtils;
import org.ballerinalang.util.exceptions.BLangRuntimeException;
import org.bson.Document;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import java.io.IOException;

/**
 * This class includes tests for MongoDB connection initialization.
 */
public class MongoDBConnectionInitTest {

    private CompileResult result;
    private MongoClient mongoClient;
    private MongoCollection mongoCollection;
    private MongodExecutable mongodExecutable;

    @BeforeClass
    public void setup() throws Exception {
        result = BCompileUtil.compile("samples/mongodb-connection-test.bal");
        setUpDatabase();
    }

    /**
     * This method sets up the MongoDB and the Mongo Client required for tests.
     *
     * @throws IOException if an issue occurs during the process of database startup
     */
    private void setUpDatabase() throws IOException {
        mongodExecutable = MongoDBTestUtils.getMongoExecutableWithoutAuth();
        mongodExecutable.start();
        mongoClient = new MongoClient(MongoDBTestUtils.MONGODB_HOST);
        mongoCollection = mongoClient.getDatabase("studentdb").getCollection("students");
        mongoCollection.insertOne(Document.parse("{\"name\":\"Jim\", \"age\":\"21\"}"));
    }

    @Test(description = "This method tests MongoDB connection initialization with direct URL")
    public void testConnectorInitWithDirectUrl() {
        BValue[] results = BRunUtil.invoke(result, "testConnectorInitWithDirectUrl");
        Assert.assertEquals(results.length, 1, "No data has been retrieved");

        Assert.assertEquals(results.length, 1, "Exactly one result should have been received");
    }

    @Test(description = "This method tests MongoDB connection initialization with connection pool parameters")
    public void testConnectorInitWithConnectionPoolProperties() {
        BValue[] results = BRunUtil.invoke(result, "testConnectorInitWithConnectionPoolProperties");
        Assert.assertEquals(results.length, 1, "No data has been retrieved");

        Assert.assertEquals(results.length, 1, "Exactly one result should have been received");
    }

    @Test(description = "This method tests MongoDB connection initialization with an invalid authentication "
            + "mechanism",
          expectedExceptions = { BLangRuntimeException.class },
          expectedExceptionsMessageRegExp = ".*invalid authentication mechanism: invalid-auth-mechanism.*")
    public void testConnectorInitWithInvalidAuthMechanism() {
        BRunUtil.invoke(result, "testConnectorInitWithInvalidAuthMechanism");
        Assert.fail("The test should have failed at this point");
    }

    @AfterClass(alwaysRun = true)
    public void cleanup() {
        MongoDBTestUtils.releaseResources(mongodExecutable, mongoClient);
    }
}
