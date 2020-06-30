# Compatibility

| Ballerina Language Version  | MongoDB Version |
| ----------------------------| -------------------------------|
|  Swan Lake Preview1         |   4.2.0

## Prerequisites

1. A MongoDB 4.2.0 running instance

## Running the tests

1. Configure the `mongoConfig` in the `main_test.bal` file to add the credentials and server address of the running MongoDB node. By default, tests are configured for an instance running in localhost:27017 without enabling authentication. If only hostname is changed, hostname can be exposed through `MONGODB_HOST` environment variable.

2. Execute the following commands inside the root folder of the GitHub repo.

    ```cmd
    export JAVA_OPTS="-DBALLERINA_DEV_COMPILE_BALLERINA_ORG=true"
    mvn clean install  
    ```
