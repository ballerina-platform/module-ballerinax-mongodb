db.createUser(
  {
    user: "admin",
    pwd: "admin",
    roles: [{ role: "userAdminAnyDatabase", db: "admin" }]
  }
)

db.getSiblingDB("$external").runCommand(
  {
    createUser: "C=LK,ST=Western,L=Colombo,O=WSO2,OU=Ballerina,CN=admin",
    roles: [
      { role: "root", db: "admin" },
      { role: "readWrite", db: "moviesDB" }
    ]
  }
);
