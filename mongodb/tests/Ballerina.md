# Compatibility

| Ballerina Language Version  | MongoDB Version |
| ----------------------------| -------------------------------|
|  Swan Lake Beta 3           |   4.2.0                        |

## Running Tests in Docker Containers

The MongoDB functionality are tested with the docker base test framework. The test framework initializes the docker container according to the given profile before executing the test suite.

1. Install and run docker in daemon mode.

    * Installing docker on Linux,
      Note:
      These commands retrieve content from get.docker.com web in a quiet output-document mode and install.Then we need to stop docker service as it needs to restart docker in daemon mode. After that, we need to export docker daemon host.

            wget -qO- https://get.docker.com/ | sh
            sudo service docker stop
            export DOCKER_HOST=tcp://172.17.0.1:4326
            sudo dockerd -H tcp://172.17.0.1:4326

    * On installing docker on Mac, see [Get started with Docker for Mac](https://docs.docker.com/docker-for-mac/)

    * On installing docker on Windows, see [Get started with Docker for Windows](https://docs.docker.com/docker-for-windows/)

2. Export following options to build module under `ballerinax` organisation.

        export JAVA_OPTS="-DBALLERINA_DEV_COMPILE_BALLERINA_ORG=true"

3. To run the integration tests, issue the following commands.

    * MongoDB 4.2 with basic authentication

            mvn verify -P mongodb -Ddocker.removeVolumes=true

    * MongoDB 3.2 with SSL Enabled
    
            mvn verify -P mongodb-ssl -Ddocker.removeVolumes=true