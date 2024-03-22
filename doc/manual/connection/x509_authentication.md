
# X509 Authentication

## Prerequisites

For X509 authentication, we have to pass the same parameters like fordar the connection with the client certificate.
Be careful that at leat one in:

- Organization (O)
- Organizational Unit (OU)
- Domain Component (DC)

 must be different between the client and the server certificates.

When you insert the user in the db, you have to store in the "$external" database the credentials. The user must be the subject of the certificate, for example "CN=myName,OU=myOrgUnit,O=myOrg,L=myLocality,ST=myState,C=myCountry".

```javaScript
db.getSiblingDB("$external").runCommand(
  {
    createUser: "CN=myName,OU=myOrgUnit,O=myOrg,L=myLocality,ST=myState,C=myCountry",
    roles: [
         { role: "readWrite", db: "test" },
         { role: "userAdminAnyDatabase", db: "admin" }
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)
```


You can extract this from the certificate with the command:

```bash
openssl x509 -in <pathToClientPEM> -inform PEM -subject -nameopt RFC2253
```

for more detail give a look to this two pages:

- [Use certificates](https://www.mongodb.com/docs/manual/tutorial/configure-x509-client-authentication/).
- [X509](https://www.mongodb.com/docs/manual/core/security-x.509/).

## How to Authenticate

Then we have to options:

- Authenticate immediately: for this you have to pass also the parameter `authMechanism=MONGODB-X509` in the connection string. You don't need to pass also the "$external" datbase as authsource because the driver authomatically will set it in case of X509 authentication.
- Authenticate after connecting: you have to use the `db.authenticateX509()` method after that the connection is in place.

[Prev doc.](tls_connection_no_auth_client_certificate.md)
