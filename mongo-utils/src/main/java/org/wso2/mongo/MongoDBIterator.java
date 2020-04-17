/*
 * Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.mongo;

import com.mongodb.client.MongoCursor;
import org.ballerinalang.jvm.JSONDataSource;
import org.ballerinalang.jvm.JSONGenerator;
import org.ballerinalang.jvm.JSONParser;
import org.ballerinalang.jvm.types.BArrayType;
import org.ballerinalang.jvm.types.BMapType;
import org.ballerinalang.jvm.types.BTypes;
import org.ballerinalang.jvm.values.api.BArray;
import org.ballerinalang.jvm.values.api.BValueCreator;
import org.bson.Document;

import java.io.IOException;

/**
 * MongoDB result cursor implementation.
 */
public class MongoDBIterator implements JSONDataSource {

    private MongoCursor<Document> mc;

    public MongoDBIterator(MongoCursor<Document> mc) {
        this.mc = mc;
    }

    @Override
    public void serialize(JSONGenerator jsonGenerator) throws IOException {
        jsonGenerator.writeStartArray();
        while (this.hasNext()) {
            jsonGenerator.serialize(this.next());
        }
        jsonGenerator.writeEndArray();
    }

    @Override
    public boolean hasNext() {
        return mc.hasNext();
    }

    @Override
    public Object next() {
        return JSONParser.parse(this.mc.next().toJson());
    }

    @Override
    public Object build() {
        BArray values = BValueCreator
                .createArrayValue(new Object[]{}, new BArrayType(new BMapType(BTypes.typeMap)));
        while (this.hasNext()) {
            values.append(this.next());
        }
        return values;
    }
}
