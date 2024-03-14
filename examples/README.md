# Examples

The `ballerinax/mongodb` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples), covering use cases like movie database, order management service, and more.

1. [Movie Database](https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples/mmovie-database) - Implement a movie database using MongoDB.

2. [Order Management System](https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples/order-management-system) - Use MongoDB to manage orders in an online store.

## Prerequisites

1. Ensure you have MongoDB server installed and running locally or on a server accessible by your application. Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/mongodb/latest#setup-guide) to set up the Redis server locally.

    Alternatively, you can use the docker-compose file provided in the `https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples/resources/docker` directory to start a MongoDB server as a Docker container.

2. For each example, create a `Config.toml` file with your MongoDB server configuration. Here's an example of how your `Config.toml` file should look:

    ```toml
    host="localhost"
    port=27017
    ```

    > **Note:** This can be used with the docker-compose file provided.

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```
