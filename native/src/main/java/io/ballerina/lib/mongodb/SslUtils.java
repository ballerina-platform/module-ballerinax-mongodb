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

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.security.GeneralSecurityException;
import java.security.KeyStore;

import javax.net.ssl.KeyManager;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;

import static io.ballerina.lib.mongodb.Utils.createError;

/**
 * This class contains the utility methods for SSL configurations in MongoDB client.
 *
 * @since 5.0.0
 */
public final class SslUtils {

    private SslUtils() {
    }

    @SuppressWarnings("unchecked")
    static SSLContext initializeSSLContext(BMap<BString, Object> secureSocket) {
        TrustManager[] trustManagers;
        KeyManager[] keyManagers;

        BMap<BString, Object> trustStore =
                (BMap<BString, Object>) secureSocket.getMapValue(RecordField.TRUST_STORE.getFieldName());
        String trustStoreFilePath = trustStore.getStringValue(RecordField.CERTIFICATE_PATH.getFieldName()).getValue();
        try (InputStream trustStream = new FileInputStream(trustStoreFilePath)) {
            char[] trustStorePass =
                    trustStore.getStringValue(RecordField.CERTIFICATE_PASSWORD.getFieldName()).getValue().toCharArray();
            KeyStore trustStoreJKS = KeyStore.getInstance(KeyStore.getDefaultType());
            trustStoreJKS.load(trustStream, trustStorePass);

            TrustManagerFactory trustFactory =
                    TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
            trustFactory.init(trustStoreJKS);
            trustManagers = trustFactory.getTrustManagers();
        } catch (FileNotFoundException e) {
            BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage());
            String message = "Trust store file not found for secure connections to MongoDB. Trust Store file path : " +
                    "'" + trustStoreFilePath + "'.";
            throw createError(ErrorType.APPLICATION_ERROR, message, cause);
        } catch (IOException e) {
            BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage());
            String message = "I/O Exception in creating trust store for secure connections to MongoDB. Trust Store " +
                    "file path : '" + trustStoreFilePath + "'.";
            throw createError(ErrorType.APPLICATION_ERROR, message, cause);
        } catch (GeneralSecurityException e) {
            BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage());
            String message = "Error in initializing certs for Trust Store.";
            throw createError(ErrorType.APPLICATION_ERROR, message, cause);
        }

        BMap<BString, Object> keyStore =
                (BMap<BString, Object>) secureSocket.getMapValue(RecordField.KEY_STORE.getFieldName());
        String keyStoreFilePath = keyStore.getStringValue(RecordField.CERTIFICATE_PATH.getFieldName()).getValue();
        try (InputStream keyStream = new FileInputStream(keyStoreFilePath)) {
            char[] keyStorePass =
                    keyStore.getStringValue(RecordField.CERTIFICATE_PASSWORD.fieldName).getValue().toCharArray();
            KeyStore keyStoreJKS = KeyStore.getInstance(KeyStore.getDefaultType());
            keyStoreJKS.load(keyStream, keyStorePass);
            KeyManagerFactory keyManagerFactory =
                    KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
            keyManagerFactory.init(keyStoreJKS, keyStorePass);
            keyManagers = keyManagerFactory.getKeyManagers();
        } catch (FileNotFoundException e) {
            BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage());
            String message = "Key store file not found for secure connections to MongoDB. Key Store file path : '" +
                    keyStoreFilePath + "'.";
            throw createError(ErrorType.APPLICATION_ERROR, message, cause);
        } catch (IOException e) {
            BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage());
            String message = "I/O Exception in creating key store for secure connections to MongoDB. Key Store " +
                    "file path : '" + keyStoreFilePath + "'.";
            throw createError(ErrorType.APPLICATION_ERROR, message, cause);
        } catch (GeneralSecurityException e) {
            BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage());
            String message = "Error in initializing certs for Key Store.";
            throw createError(ErrorType.APPLICATION_ERROR, message, cause);
        }

        try {
            String protocol = secureSocket.getStringValue(RecordField.PROTOCOL.getFieldName()).getValue();
            SSLContext sslContext = SSLContext.getInstance(protocol);
            sslContext.init(keyManagers, trustManagers, null);
            return sslContext;
        } catch (GeneralSecurityException e) {
            BError cause = createError(ErrorType.APPLICATION_ERROR, e.getMessage());
            String message = "Error in initializing SSL context with the key store/ trust store. Trust Store file " +
                    "path : '" + trustStoreFilePath + "'. Key Store file path : '" + keyStoreFilePath + "'.";
            throw createError(ErrorType.APPLICATION_ERROR, message, cause);
        }
    }

    private enum RecordField {
        KEY_STORE("keyStore"),
        TRUST_STORE("trustStore"),
        CERTIFICATE_PATH("path"),
        CERTIFICATE_PASSWORD("password"),
        PROTOCOL("protocol");

        private final BString fieldName;

        RecordField(String fieldName) {
            this.fieldName = StringUtils.fromString(fieldName);
        }

        public BString getFieldName() {
            return fieldName;
        }
    }
}
