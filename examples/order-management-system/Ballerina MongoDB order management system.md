# Order Management System

This example demonstrates an implementation of sample order management system using Ballerina and the Ballerina MongoDB connector. It exposes an HTTP service with resources to add, retrieve, update, and delete orders from a MongoDB database. Additionally, this example includes an aggregation operation to retrieve the orders of a given customer.

## Prerequisites

### 1. Setup MongoDB Server

Ensure you have download and running a MongoDB server. (Alternatively, [provided docker-compose-file](https://github.com/ballerina-platform/module-ballerinax-mongodb/tree/master/examples/resources/docker/docker-compose.yml) can be used to run the MongoDB server).

### 2. Configuration

Create a `Config.toml` file inside the Ballerina project root directory with your MongoDB server configuration. Here's an example of how your `Config.toml` file should look:

```toml
host = "localhost"
port = 27017

username = "admin"
password = "admin"
database = "admin"
```

## Run the example

To run the example, execute the following command.

```bash
bal run
```

This will start an HTTP server at `http://localhost:9090/`.
