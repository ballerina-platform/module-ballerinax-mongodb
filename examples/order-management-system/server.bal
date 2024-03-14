// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/uuid;
import ballerinax/mongodb;

configurable string host = "localhost";
configurable int port = 27017;

configurable string username = ?;
configurable string password = ?;
configurable string database = ?;

final mongodb:Client mongoDb = check new ({
    connection: {
        serverAddress: {
            host,
            port
        },
        auth: <mongodb:ScramSha256AuthCredential>{
            username,
            password,
            database
        }
    }
});

service on new http:Listener(9090) {

    private final mongodb:Database db;

    function init() returns error? {
        self.db = check mongoDb->getDatabase("order_management");
    }

    resource function get customers() returns Customer[]|error {
        mongodb:Collection customersCollection = check self.db->getCollection("customers");
        stream<Customer, error?> resultStream = check customersCollection->aggregate([
            {
                \$lookup: {
                    'from: "orders",
                    localField: "id",
                    foreignField: "customerId",
                    'as: "orders"
                }
            }
        ]);
        return from Customer customer in resultStream select customer;
    }

    resource function post customers(CustomerInput input) returns error? {
        mongodb:Collection customersCollection = check self.db->getCollection("customers");
        string id = uuid:createType1AsString();
        Customer customer = {
            id,
            orders: [],
            ...input
        };
        check customersCollection->insertOne(customer);
    }

    resource function get customers/[string id]() returns Customer|error {
        mongodb:Collection customersCollection = check self.db->getCollection("customers");
        stream<Customer, error?> resultStream = check customersCollection->aggregate([
            {
                \$match: {
                    id: id
                }
            },
            {
                \$lookup: {
                    'from: "orders",
                    localField: "id",
                    foreignField: "customerId",
                    'as: "orders"
                }
            },
            {
                \$limit: 1
            },
            {
                \$project: {
                    id: 1,
                    name: 1,
                    email: 1,
                    address: 1,
                    contactNumber: 1,
                    orders: {
                        id: {"orders.id": 1},
                        customerId: {"orders.customerId": 1},
                        status: {"orders.status": 1},
                        quantity: {"orders.quantity": 1},
                        total: {"orders.total": 1}
                    }
                }
            }
        ]);
        record {Customer value;}|error? result = resultStream.next();
        if result is error? {
            return error(string `Cannot find the customer with id: ${id}`);
        }
        return result.value;
    }

    resource function post orders(OrderInput input) returns error? {
        mongodb:Collection ordersCollection = check self.db->getCollection("orders");
        string id = uuid:createType1AsString();
        Order 'order = {
            id,
            ...input
        };
        check ordersCollection->insertOne('order);
    }
}

type CustomerInput record {|
    string name;
    string email;
    string address;
    string contactNumber;
|};

type OrderInput record {|
    string customerId;
    string status;
    int quantity;
    decimal total;
|};

type Customer record {|
    string id;
    string name;
    string email;
    string address;
    string contactNumber;
    Order[] orders;
|};

type Order record {|
    string id;
    string customerId;
    string status;
    int quantity;
    decimal total;
|};
