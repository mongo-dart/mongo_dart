
# Authentication

**Updated for Mongodb ver 4.4 and mongo_dart version 0.5.0**
Authentication requires the creation of users in the nmongodb instance.
Provided that we have a three members replica set: replica0, replica1 and replica2 with
no authentication we have to perform the steps listed in [this tutorial](https://docs.mongodb.com/manual/tutorial/enable-authentication/).

Once that the user have been created you have to activate authentication for the server.
This is possible in two ways:

- adding the --auth parameter to the mongod command line (Ex. "mongod --auth --port 27017 --dbpath /var/lib/mongodb")
- enabling the authentication on the mongod.conf file (in linux normally it is under the etc folder)

  ```yaml
  security:
    authorization: enabled
  ```

Now that the server requires authentication you have to provide your user name and password
You can do it in two ways:

```dart
 var db = Db('mongodb://<user>:<password>@replica0:27017/myDb');
```

or asking for autentication after that the connection is open

```dart
var db = Db('mongodb://replica0:27017/myDb');
await db.open();
await db.authenticate(<user>, <password>);
```

[Prev doc.](simple_connection_no_auth.md) - [Next doc.](tls_connection_no_auth.md)
