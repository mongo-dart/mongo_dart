
# Connection

**Updated for Mongodb ver 4.4 and mongo_dart version 0.5.0**
Connecting to a server with TLS is straigthforward, provided that server is properly configured.

You can connect in two ways:

- passing the connection string parameter "tls" (example: `mongodb://replica0:27017/myDb?tls=true`). You can also use `ssl=true`, but it has been deprecated
- requiring a secure connection when opening the db (ex. `await db.open(secure: true);`)
