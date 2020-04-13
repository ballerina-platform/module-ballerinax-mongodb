# Compatibility

| Ballerina Language Version  | MongoDB Version |
| ----------------------------| -------------------------------|
|  1.2.X                      |   4.2.0

## Prerequisites

1. A MongoDB 4.2.0 running instance

2. The 'moviecollection' database created in the MongoDB node.

## Running the tests

1. Configure the `mongoConfig` in the `main_test.bal` file to add the credentials and server address of the running MongoDB node.

2. Execute the following commands inside the repo root folder.

    ```cmd
    $ export JAVA_OPTS="-DBALLERINA_DEV_COMPILE_BALLERINA_ORG=true"
    $ mvn clean install  
    ```
