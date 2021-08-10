# Compatibility

| Ballerina Language Version  | MongoDB Version |
| ----------------------------| ----------------|
|  Swan Lake Beta2            |   4.2.0         |

## Running tests using Docker image of MongoDB

1. [Install Docker on your machine.](https://docs.docker.com/get-docker/)

2. Execute the following command

```shell script
    docker run -d --name mongodb-test -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=admin mongo:4.2.0
```

3. In the main_test.bal, change the following configurations.
```ballerina
        string testUser = "admin"
        string testPass = "admin"
```

4. Within the mongodb directory, execute the following command
```shell script
        bal test --groups mongodb
```
