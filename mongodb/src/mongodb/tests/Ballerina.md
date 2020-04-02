# Compatibility

| Ballerina Language Version  | MongoDB Version |
| ----------------------------| -------------------------------|
|  1.2.0                      |   4.2.0

## Prerequisites

1. A MongoDB 4.2.0 running instance

2. The 'moviecollection' database created in the MongoDB node.

## Running the tests

1. Configure the `mongoConfig` in the `main_test.bal` file to add the credentials and server address of the running MongoDB node.

2. Execute the following command.

    ```cmd
    mvn clean install  
    ```
