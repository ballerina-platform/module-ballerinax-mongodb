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
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import de.flapdoodle.embed.mongo.MongodExecutable;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.ballerinalang.launcher.util.BCompileUtil;
import org.ballerinalang.launcher.util.BRunUtil;
import org.ballerinalang.launcher.util.CompileResult;
import org.ballerinalang.model.values.BInteger;
import org.ballerinalang.model.values.BMap;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.mongodb.utils.MongoDBTestUtils;
import org.bson.Document;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import java.io.IOException;

/**
 * This class includes tests for INSERT, FIND, FIND-ONE, DELETE, UPDATE, BATCH-INSERT actions on MongoDB.
 */
public class MongoDBActionsTest {
    private CompileResult result;
    private MongoClient mongoClient;
    private MongoCollection mongoCollection;
    private MongodExecutable mongodExecutable;
    private static Log log = LogFactory.getLog(MongoDBActionsTest.class);

    @BeforeClass
    public void setup() throws Exception {
        result = BCompileUtil.compile("samples/mongodb-actions-test.bal");
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

        String[] documentStringArray = {
                "{\"name\":\"Jim\", \"age\":\"21\"}", "{\"name\":\"Sam\", \"age\":\"25\"}",
                "{\"name\":\"Harry\", \"age\":\"25\"}", "{\"name\":\"Peter\", \"age\":\"21\"}",
                "{\"name\":\"Thomas\", \"age\":\"28\"}", "{\"name\":\"Newt\", \"age\":\"28\"}",
                "{\"name\":\"Philips\", \"age\":\"30\"}", "{\"name\":\"James\", \"age\":\"30\"}",
                "{\"name\":\"Lilly\", \"age\":\"13\"}", "{\"name\":\"Janet\", \"age\":\"13\"}",
                "{\"name\":\"Petter\", \"age\":\"35\"}", "{\"name\":\"John\", \"age\":\"35\"}"
        };
        for (String document : documentStringArray) {
            mongoCollection.insertOne(Document.parse(document));
        }
    }

    @Test(description = "Tests MongoDB insert action",
          dependsOnMethods = "testFindWithNilQuery")
    public void testInsert() throws Exception {
        BRunUtil.invoke(result, "insert");
        Document document = (Document) mongoCollection.find(Document.parse("{\"name\":\"Tom\", \"age\":\"20\"}"))
                .first();
        Assert.assertNotNull(document, "The document couldn't be found");
    }

    @Test(description = "Tests MongoDB find action")
    public void testFind() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "find");
        Assert.assertEquals(results.length, 2, "Two results should have been received");
        String[] names = { "Jim", "Peter" };
        for (int i = 0; i < 2; i++) {
            Assert.assertEquals(((BMap) results[i]).getMap().get("name").toString(), names[i],
                    "Retrieved data is incorrect");
            Assert.assertEquals(((BMap) results[i]).getMap().get("age").toString(), "21",
                    "Retrieved data is incorrect");
        }
    }

    @Test(description = "Tests MongoDB find-one action")
    public void testFindOne() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "findOne");
        Assert.assertEquals(results.length, 1, "Exactly one result should have been received");
        Assert.assertEquals(((BMap) results[0]).getMap().get("name").toString(), "Jim",
                "Retrieved data is incorrect");
        Assert.assertEquals(((BMap) results[0]).getMap().get("age").toString(), "21", "Retrieved data is incorrect");
    }

    @Test(description = "Tests MongoDB find-one action with nill query")
    public void testFindOneWithNilQuery() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "findOneWithNilQuery");
        Assert.assertEquals(results.length, 1, "Exactly one result should have been received");
        Assert.assertEquals(((BMap) results[0]).getMap().get("name").toString(), "Jim",
                "Retrieved data is incorrect");
        Assert.assertEquals(((BMap) results[0]).getMap().get("age").toString(), "21", "Retrieved data is incorrect");
    }

    @Test(description = "Tests MongoDB find action with nil query",
          dependsOnMethods = "testFindOneWithNilQuery")
    public void testFindWithNilQuery() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "findWithNilQuery");
        Assert.assertEquals(results.length, 12, "12 records should have been received");
    }

    @Test(description = "Tests MongoDB delete action for multiple records",
          dependsOnMethods = "testFindWithNilQuery")
    public void testDeleteMultipleRecords() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "deleteMultipleRecords");
        Assert.assertEquals(((BInteger) results[0]).intValue(), 2, "Exactly 2 records should have been deleted");
        FindIterable iterable = mongoCollection.find(Document.parse("{\"age\":\"25\"}"));
        int size = 0;
        for (Object value : iterable) {
            size++;
        }
        Assert.assertEquals(size, 0, "0 records with the filter { \"age\":\"25\"} should be in the database");
    }

    @Test(description = "Tests MongoDB delete action for single record",
          dependsOnMethods = "testFindWithNilQuery")
    public void testDeleteSingleRecord() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "deleteSingleRecord");
        Assert.assertEquals(((BInteger) results[0]).intValue(), 1,
                "Exactly 1 records should have been " + "deleted");
        FindIterable iterable = mongoCollection.find(Document.parse("{\"age\":\"13\"}"));
        int size = 0;
        for (Object value : iterable) {
            size++;
        }
        Assert.assertEquals(size, 1, "1 record with the filter {\"age\":\"13\"} should be in the database");
        Document document = (Document) mongoCollection.find(Document.parse("{\"name\":\"Janet\",\"age\":\"13\"}"))
                .first();
        Assert.assertEquals(document.getString("name"), "Janet", "The deleted entry may not be the expected one");
        Assert.assertEquals(document.getString("age"), "13", "The deleted entry may not be the expected one");
    }

    @Test(description = "Tests MongoDB update action for multiple records")
    public void testUpdateMultipleRecords() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "updateMultipleRecords");
        Assert.assertEquals(((BInteger) results[0]).intValue(), 2,
                "Exactly 2 records " + "should have been updated");
        Document[] documentsArray = new Document[2];
        documentsArray[0] = (Document) mongoCollection.find(Document.parse("{\"name\":\"Thomas\"}")).first();
        documentsArray[1] = (Document) mongoCollection.find(Document.parse("{\"name\":\"Newt\"}")).first();
        for (Document document : documentsArray) {
            Assert.assertEquals(document.getString("age"), "27", "Document has not been updated correctly");
        }
    }

    @Test(description = "Tests MongoDB update action for single record")
    public void testUpdateSingleRecord() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "updateSingleRecord");
        //Assert.assertEquals(((BJSON) results[0]).value().longValue(), 1, "Only 1 record should have been updated");
        Assert.assertEquals(((BInteger) results[0]).intValue(), 1, "Only 1 record should have been updated");
        Document document1 = (Document) mongoCollection.find(Document.parse("{\"name\":\"Philips\"}")).first();
        Document document2 = (Document) mongoCollection.find(Document.parse("{\"name\":\"James\"}")).first();

        log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        log.info(document1.getString("name"));
        log.info(document1.toJson());
        log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        Assert.assertEquals(document1.getString("age"), "32", "Document has not been updated correctly");
        Assert.assertEquals(document2.getString("age"), "30", "More than one document have been updated");
    }

    @Test(description = "Tests MongoDB batch insert action",
          dependsOnMethods = "testFindWithNilQuery")
    public void testBatchInsert() throws Exception {
        BRunUtil.invoke(result, "batchInsert");
        Document[] documentsArray = new Document[3];
        documentsArray[0] = (Document) mongoCollection.find(Document.parse("{\"name\":\"Jessie\", \"age\":\"18\"}"))
                .first();
        documentsArray[1] = (Document) mongoCollection.find(Document.parse("{\"name\":\"Rose\", \"age\":\"17\"}"))
                .first();
        documentsArray[2] = (Document) mongoCollection.find(Document.parse("{\"name\":\"Anne\", \"age\":\"15\"}"))
                .first();
        for (Document document : documentsArray) {
            Assert.assertNotNull(document, "The document may have not been inserted");
        }
    }

    @Test(description = "Tests MongoDB replaces a single document.")
    public void testReplaceOne() throws Exception {
        BValue[] results = BRunUtil.invoke(result, "replaceOne");
        Assert.assertEquals(((BInteger) results[0]).intValue(), 1,
                "Only 1 record should have been updated");
        Document document1 = (Document) mongoCollection.find(Document.parse("{\"age\":\"35\"}")).first();
        FindIterable iterable = mongoCollection.find(Document.parse("{\"age\":\"35\"}"));
        int size = 0;
        for (Object value : iterable) {
            size++;
        }
        Assert.assertEquals(size, 2, "Only 2 records should have been received");
        Assert.assertEquals(document1.getString("name"), "Esther",
                "Document has not been updated correctly");
    }

    @AfterClass(alwaysRun = true)
    public void cleanup() {
        MongoDBTestUtils.releaseResources(mongodExecutable, mongoClient);
    }
}
