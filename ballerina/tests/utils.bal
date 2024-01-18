final ConnectionConfig clientConfig = {
    connection: {
        auth: <ScramSha256AuthCredential>{
            username: testUser,
            password: testPass,
            database: "admin"
        }
    },
    options: {
        sslEnabled: false
    }
};

final ConnectionConfig invalidConfig = {
    connection: "invalidDB"
};

final ConnectionConfig replicasetConfig = {
    connection: {
        serverAddress: [
            {
                host: "localhost",
                port: 20000
            },
            {
                host: "localhost",
                port: 20001
            },
            {
                host: "localhost",
                port: 20002
            }
        ],
        auth: <ScramSha256AuthCredential>{
            username: testUser,
            password: testPass,
            database: "admin"
        }
    }
};

final Client mongoClient = check new (clientConfig);
