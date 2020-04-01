# Compatibility

| Ballerina Language Version  | MongoDB Version |
| ----------------------------| -------------------------------|
|  1.2.0                      |   4.2.0

## Prerequisites

1. MongoDB 4.2.0 running instance

2. Create 'moviecollection' database in the MongoDB node.

## Running the tests

1. Configure `mongoConfig` in main_test.bal to add credentials and server address of the running MongoDB node

2. Run the following command

    ```cmd
    mvn clean install  
    ```
