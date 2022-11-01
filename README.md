# Ballerina MongoDB Connector

[![Build Status](https://github.com/ballerina-platform/module-ballerinax-mongodb/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-mongodb.svg)](https://github.com/ballerina-platform/module-ballerinax-mongodb/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[MongoDB](https://docs.mongodb.com/v4.2/) is a general purpose, document-based, distributed database built for modern application developers and for the cloud era. MongoDB offers both a Community and an Enterprise version of the database.

MongoDB connector connects to MongoDB from [Ballerina](https://ballerina.io/). This connector provides the capability to perform the MongoDB CRUD operations.

For more information, go to the module(s).

- [`mongodb`](mongodb/Module.md)

## Building from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle JDK](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).

    > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed
    JDK.
 
2. Download and install [Ballerina Swan Lake](https://ballerina.io/)

3. Download and install Gradle.

4. Export Github Personal access token with read package permissions as follows,

    ```
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Building the source

Execute the commands below to build from the source.

1. To build Java dependency
    ```
    ./gradlew clean build
    ```

2. * To build the package:
        ```shell script
            bal pack ./mongodb
        ```
   * To test the connector:
   
        Follow the instructions given in https://github.com/ballerina-platform/module-ballerinax-mongodb/blob/master/mongodb/tests/Ballerina.md

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
