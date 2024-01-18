/*
 * Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org)
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.mongodb;

import com.mongodb.MongoCredential;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import static io.ballerina.lib.mongodb.Utils.createError;

/**
 * This class contains the utility methods for authentication configurations in MongoDB client.
 *
 * @since 5.0.0
 */
final class AuthUtils {
    private static final String SERVICE_NAME = "SERVICE_NAME";

    private AuthUtils() {
    }

    static MongoCredential getMongoCredential(BMap<BString, Object> auth) {
        String authMechanism = auth.getStringValue(Client.RecordField.AUTH_MECHANISM).getValue();
        switch (AuthMechanism.valueOf(authMechanism)) {
            case SCRAM_SHA_1:
                return getScramSha1Credential(auth);
            case SCRAM_SHA_256:
                return getScramSha256Credential(auth);
            case MONGODB_X509:
                return getMongoX509Credential(auth);
            case GSSAPI:
                return getGssapiCredential(auth);
            case PLAIN:
                return getPlainCredential(auth);
            default:
                throw createError(ErrorType.APPLICATION_ERROR,
                        "Unsupported authentication mechanism: " + authMechanism);
        }
    }

    private static MongoCredential getPlainCredential(BMap<BString, Object> auth) {
        String username = auth.getStringValue(RecordField.USERNAME.getFieldName()).getValue();
        char[] password = auth.getStringValue(RecordField.PASSWORD.getFieldName()).getValue().toCharArray();
        String source = auth.getStringValue(RecordField.DATABASE.getFieldName()).getValue();
        return MongoCredential.createPlainCredential(username, source, password);
    }

    private static MongoCredential getScramSha1Credential(BMap<BString, Object> auth) {
        String username = auth.getStringValue(RecordField.USERNAME.getFieldName()).getValue();
        char[] password = auth.getStringValue(RecordField.PASSWORD.getFieldName()).getValue().toCharArray();
        String source = auth.getStringValue(RecordField.DATABASE.getFieldName()).getValue();
        return MongoCredential.createScramSha1Credential(username, source, password);
    }

    private static MongoCredential getScramSha256Credential(BMap<BString, Object> auth) {
        String username = auth.getStringValue(RecordField.USERNAME.getFieldName()).getValue();
        char[] password = auth.getStringValue(RecordField.PASSWORD.getFieldName()).getValue().toCharArray();
        String source = auth.getStringValue(RecordField.DATABASE.getFieldName()).getValue();
        return MongoCredential.createScramSha256Credential(username, source, password);
    }

    private static MongoCredential getMongoX509Credential(BMap<BString, Object> auth) {
        if (auth.getStringValue(RecordField.USERNAME.getFieldName()) == null) {
            return MongoCredential.createMongoX509Credential();
        }
        String username = auth.getStringValue(RecordField.USERNAME.getFieldName()).getValue();
        return MongoCredential.createMongoX509Credential(username);
    }

    private static MongoCredential getGssapiCredential(BMap<BString, Object> auth) {
        String username = auth.getStringValue(RecordField.USERNAME.getFieldName()).getValue();
        BString serviceName = auth.getStringValue(RecordField.SERVICE_NAME.getFieldName());
        if (serviceName != null) {
            return MongoCredential.createGSSAPICredential(username)
                    .withMechanismProperty(SERVICE_NAME, serviceName.getValue());
        }
        return MongoCredential.createGSSAPICredential(username);
    }

    enum AuthMechanism {
        SCRAM_SHA_1("SCRAM-SHA-1"),
        SCRAM_SHA_256("SCRAM-SHA-256"),
        MONGODB_X509("MONGODB-X509"),
        GSSAPI("GSSAPI"),
        PLAIN("PLAIN"),
        AWS("AWS"),
        MONGODB_CR("MONGODB-CR");

        private final String mechanism;

        AuthMechanism(String mechanism) {
            this.mechanism = mechanism;
        }

        public String getMechanism() {
            return mechanism;
        }
    }

    enum RecordField {
        USERNAME("username"),
        PASSWORD("password"),
        DATABASE("database"),
        SERVICE_NAME("serviceName");

        private final BString fieldName;

        RecordField(String fieldName) {
            this.fieldName = StringUtils.fromString(fieldName);
        }

        public BString getFieldName() {
            return fieldName;
        }
    }
}
