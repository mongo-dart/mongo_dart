#Functionality Checklist

From [Feature Checklist for Mongo Drivers](http://www.mongodb.org/display/DOCS/Feature+Checklist+for+Mongo+Drivers)

##Essential

- BSON serialization/deserialization: **Done**
- Basic operations: query, insert, update, remove, ensureIndex, findOne, limit, sort: **Done**
- Fetch more data from a cursor when necessary (dbGetMore): **Done**
- Sending of KillCursors operation when use of a cursor has completed (ideally for efficiently these are sent in batches): **Done**
- Convert all strings to utf8: **Done**
- Authentication: **Done**

##Recommended

- automatic _id generation: **Done**
- Database $cmd support and helpers
- Detect { $err: ... } response from a db query and handle appropriately --see Error Handling in Mongo Drivers **Done**
- Automatically connect to proper server, and failover, when connecting to a Replica Set
- ensureIndex commands should be cached to prevent excessive communication with the database. (Or, the driver user should be informed that ensureIndex is not a lightweight operation for the particular driver.)
- Support detecting max BSON size on connection (e.g., using buildinfo or isMaster commands) and allowing users to insert docs up to that size.


##More Recommended

- lasterror helper functions: **Done**
- count() helper function: **Done**
- $where clause: **Done**
- eval()
- File chunking (GridFS) **Done**
- hint fields **Done**
- explain helper **Done**

##More Optional

- addUser, logout helpers
- Allow client user to specify Option_SlaveOk for a query
- Tailable cursor support
- In/out buffer pooling (if implementing in a garbage collected languages)

##More Optional

- connection pooling
- Automatic reconnect on connection failure
- DBRef Support:
 - Ability to generate easily
 - Automatic traversal