package org.wso2.mongo;

import org.ballerinalang.jvm.util.exceptions.BallerinaException;

/**
 * Exception class for mongo
 */
public class BallerinaMongoDbException extends BallerinaException {
    public BallerinaMongoDbException(String message) {
        super(message);
    }

    public BallerinaMongoDbException(String message, Throwable cause) {
        super(message, cause);
    }
}
