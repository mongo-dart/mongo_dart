
# Connection

Please note, these documents have been tested on a linux platform, ubuntu flavor.
Most of the examples can be ported easily, but there are some parts that can be different on you platform.
Unfortunately it takes a lot of time for testing on all platforms/versions, so I apologize, but I will only test this procedure on Ubuntu 20.04, mongodb 4.4, mongo_Dart 0.5.0.

**Updated for Mongodb ver 4.4 and mongo_dart version 0.5.0**
In order to connect to a mongodb server with this driver you have to provide the correct connection string.
We will talk about connection to a Replica set, but the same concepts should be applicable to Standalone, Sharded clusters and Cloud Clusters (Atlas).

Let's assume that we have a three members replica set: replica0, replica1 and replica2
Replica0 is the primary.

You have to use the following connection String: `mongodb://replica0:27017/myDb`

```dart
 var db = Db('mongodb://replica0:27017/myDb');
```

Once you have a Db instance you are not connected yet, you have still to open the database:

```dart
await db.open();
```

Once you have done your operations on the database, you have to close it.

```dart
await db.close();
```

So a typical mongo_dart session is structured as follows:

```dart
 var db = Db('mongodb://replica0:27017/myDb');
 await db.open();
// work on documents
await db.close();
```

Let's analyze this operations in detail:

- connection string. This is a mongodb standard and it can have two formats:
  - Standard format
  - DNS Seed List format

  More info about connections string in [mongodb documentation](https://docs.mongodb.com/manual/reference/connection-string/)
  There are some point to evidentiate
  - the host part (replica0 in the above example) must be (or contain) the name of the primary. So, in a replica set, it is better to define all hosts (in our example the connection string would be `mongodb://replica0, replica1, replica2:27017/myDb`). At present the driver connects only to the hosts defined in the connection string, and requires the primary to be one of them. This differs from other drivers where the connection string is used to connect to the cluster, but, after that, the connection to all members is done querying the internal topology.
  - if any connection problem occurs or a differnt primary is elected, the driver is no more able to work properly and you have to manually close and open again the database. This behavior also differs from other drivers where changes in the topology (server availabilty and typology) are monitored, so that the driver itself can reconnect and direct the operations to the correct hosts.

  [Next doc.](simple_connection_auth.md)
