
# Server with a self signed certificate

**Updated for Mongodb ver 4.4 and mongo_dart version 0.5.0**
In a test environment it is quite easy to configure our servers with a self signed certificate.
This involves knowing how security certificates work.
In order to help this process I will report my experience.

The steps are the following:

- create internal certificate authority keys
- generate server certificates
- install certificates
- client connection

## Create an internal CA certificate

First of all we can follow [this tutorial](https://docs.mongodb.com/manual/appendix/security/appendixA-openssl-ca/).
It is quite clear, the only problem that I found is at point six, when it is required to run the following command:

```bash
cat mongodb-test-ca.crt mongodb-test-ia.crt  > test-ca.pem
```

Based on my experience this will not work.
The order of the .crt files mut be "top-down", with the less important at the beginning and the most important at the end.
So, the right command is:

```bash
cat mongodb-test-ia.crt mongodb-test-ca.crt  > test-ca.pem
```

I have created a [small bash script](script/authority-certificate.sh) (linux only), to make the work easier. I guess it should be easy to move it to other systems.
Before running it you have to update the default values where required.
While running it will ask you some values, set them at you like.
Finally (if required) it will ask you the password for crypting the main key (+ retype for confirmation) and also one for crypting the intermediate key (+ confirmation).
The script generates the openssl configuration file, runs the openssl commands, if required crypts the keys with the standard method or with gpg (check if it is installed on you system) and finally does some clean-up.
You can run it this way: ./authority-certificate.sh your-ca-name
The script will create a cert folder from the current directory and generate eveything inside it.

Once that the script has run, you should find this files inside the ./cert folder:

- your-ca-name-ca.key (or your-ca-name-ca.key.gpg if cryptd with gpg).
- your-ca-name-ca.crt
- your-ca-name-ia.key (or your-ca-name-ia.key.gpg if crypted with gpg).
- your-ca-name-ia.crt
- your-ca-name-ca-full-chain.crt (that the tutorial calls test-ca.pem)

In the next step we will need the CAFile (test-ca.pem or, if you used the script, your-ca-name-ca-full-chain.crt), mongodb-test-ia.crt or your-ca-name-ia.crt and the intermediate .key file.
if the intermediate key field have been crypted with gpg from the script you have to decrypt it (gpg -d  crypted-file-name > target-file-name)

Provided that all files are in PEM format (that one that has a '----- Begin .... certificate ----' plus a base64 encoded content and an End certificate line), I will adopt this naming convention (maybe you normally used a different nc, but this way we can easily understand each other).

- .key files -> Are files in PEM format containing the private key. They can be password protected or gpg encrypted (in this last case you have to decrypt them before using)
- .csr files -> Are files in PEM format containing the certificate request. As they are of no use in or case, I delete them after that the public certificate have been created.
- .crt files -> Are files in PEM format containing the public key. Those endind with -full-chain.crt contains a list of certificates in importatnce order (from less to more important). In our case the your-ca-name-full-chain.crt fille will contain two certificates: your-ca-name-ia.crt + your-ca-name-ca.crt strictly in this order. Inverting the order of the certificated causes strange and incomprehensible errors when trying to connect. The mongo db tutorial call these as .pem.
- .pem files -> Are files in PEM format containing a public and a private key. Nornally they are concatenend in this order, and this works. I have never tried to change the order, but I cannot guarantee that it would work.

I explicitly specify "PEM" format because there is also another kind of format, the "DER" one. I didn't use it, so I cannot give you more details on it, with the exception that I'm sure that you can convert the teo formats back and forth.
So, please note that the PEM format does not only refers to the .pem files.

## Server certificates

Theoretically the process should be:

- you create your key for your server on your server (.key file).
- generate a signing request (.csr file).
- send the .csr file to the authority that signs it and sends back to you a certificate (.crt) file.
- concatenate the crt and key files into a pem file (.pem);

Here the critical files are the .key and the .pem as they contains the private key, so set all required file permissions.
Normally the .key is not required for eveyday use, so you can crypt it and guard it in a safe place.
The .pem file, on the opposite, is needed for the server configuration, so we have to manage it with care.

This said, and considering that _we_ are the CA authority, we can relax a little bit (but not so much... :-) ), and generate the keys for the servers on the same computer and then guard them safely. We will only need to send to the server the server.pem file and the your-name-ca-full-chain.crt file in a safe way (scp).

Here too we have a [nice tutorial on the mongodb site](https://docs.mongodb.com/manual/appendix/security/appendixB-openssl-server/) on how to generate the server keys.
You can follow it or [run the script](script/server-certificate.sh) I have prepared.
You can run it in the cert folder generated before (the intermediate key file ".key" must be decrypted if you used gpg), in this way:
move to the cert folder, run the command ./server-certificate.sh your-ca-name server-ip-address dns-server-name.
The dns-server-name is optional. If you give it, you will need to use that name in the mongodb connection string.
The script will require some parameters, set them as you like, be only careful to set the "Organization name" and the "Organizational Unit name" equal for all the servers that you will generate. Also the DC (Domain Component) parameters must be equal, but the script will not ask you for it.

Create all servers certificates and send them to the servers in a safe way.

## Install certificates

Now that we have the certificates on the server we have to store them somewhere. One place could be /var/local/mongodb, but it is only a suggestion. What we absolutely must do is to grant the ownership for the cert files **and for the folder that contains them** to the user running the mongod instance (normally "mongodb" user). So, if we use the suggested location:

- go to the /var/local dir (```cd /var/local```),
- create the mongodb folder (```sudo mkdir mongodb```),
- move to the mongodb folder (```cd mongodb```)
- move certs to the new directory(```sudo mv path-to-cert-file/*.pem .```)
- move certs to the new directory(```sudo mv path-to-cert-file/*.crt .```)
- set the mongodb user ownership (or any user running mongodb), ```sudo chown mongodb:mongodb *```,
- set restricted file permission, ```sudo chmod 600 *.pem```
- go back to the /var/local folder (```cd ..```)
- change the owner also for the mongodb folder (```sudo chown mongodb:mongodb /var/local/mongodb```)
- change also the dir permission (```sudo chmod 770 /var/local/mongodb```)

Ok, now we only to change the configuration file and restart the mongod daemon.
Here I'm assuming that you are running mongod as a daemon, if not you can already run it on the command line
(```mongod --tlsMode requireTLS --tlsCertificateKeyFile <pem>```)

### Change mongod.conf

Edit the cofiguration file (```sudo nano /etc/mongod.conf```).
Go to the net section and add the `tls`, `mode` and `certificateKeyFile` parameters:

```yaml
net:
  port: 27017  # set your port
  bindIp: #your system Ip addresses to be bind, 
  tls:
    mode: requireTLS
    certificateKeyFile: /var/local/mongodb/your-server-name.pem
```

Now, before restarting, consider that with this setting the server you are updating will not be able to connect to the other members of the replica set. I assume that we are working on an initial configuration in a test environment. If you need to make the server immediately available, you have to set the mode parameter to `allowTLS`, update all servers and then gradually move to `requireTLS` passing by `preferTLS`. [See this tutorial](https://docs.mongodb.com/manual/tutorial/configure-ssl/) for more details.

Restart the server (`sudo systemctl restart mongod`) and check if everything is OK (`sudo systemctl status mongod`).
It is important to check because it is enough to write a parameter in a wrong way (for example requireTls instead of requireTLS) to make mongod abort the initialization. In case, look at the log, `sudo tail /var/log/mongodb/mongod.log` for info.

If everything is OK you can repeat these steps on the other servers. As soon as you start the servers with the new configuration you should see them from the first server.

## Client connection

Now, it is important to understand what's going on.
The server has a certificate. This allows him to crypt the traffic with a tls protocol.
But, the first thing that the server does is sending back his certificate (the public part) to the client.
At this point the client checks if it is a valid certificate and decide if it wants to continue the communication.
The check is related to the host name and the general validity of the certificate (same authority, not expired, etc.).
In order to check if it is a valid certificate we need the "your-ca-name-full-chain.crt" certificate.

We theoretically have three ways to provide to the client the authority root certificate.

- Use the system CA certificate repository
- Provide the certificate while connecting (CAFile options)
- Accept also invalid certificates (allowInvalidCertificates options)

### System CA Certificate Repository

We are adding the certificates to the _client_ system CA certificate repository in order to avoid the hassel to specify the CAFile everytime
I only tested this procedure on Ubuntu, please check your system documentation to see how to add root certificates to the system CA repository.
On Ubuntu:

- copy the your-ca-name-ca.crt and your-ca-name-ia.crt files into the folder /usr/local/share/ca-certificates (```sudo cp path-to-you-certs/your-ca-name-ca.crt /usr/local/share/ca-certificates/your-ca-name-ca.crt``` and ```sudo cp path-to-you-certs/your-ca-name-ia.crt /usr/local/share/ca-certificates/your-ca-name-ia.crt```)
- update the system store (```sudo update-ca-certificates```)

After this you should be ok. You can test the configuration with the mongo shell, for example ```mongo --host myHost --port myPort --tls```

**Please note** that we have already a file with the two certificates (the your-ca-name-full-chain.crt file), but the update-ca-certificates seems to skip this joined certificates and only accept files with _one_ certificate. The extension _must_ be .crt (if you have created the certificates with the script it is already like that).

if you are using mongo_dart you can use one of:

- `tls` connection string parameter (Ex. ```var db = Db('mongodb://host:27017/test?tls=true');```)
- secure parm on `db.open` (Ex. ```await db.open(secure: true);```)

### CA file option

If your certificate is not in the system store you can pass it in the connection string or in the `db.open` method:

```dart
  var db = Db('mongodb://host:27017/test?tlsCAFile=path-to-your-full-chain-file/your-ca-name-full-chain.crt');
  await db.open();
```

or

```dart
  var db = Db('mongodb://host:27017/test');
  await db.open(tlsCAFile: 'path-to-your-full-chain-file/your-ca-name-full-chain.crt');
```

**Please note** that in both cases the `tls` flag is implicitly set to true ('tls=true' in the first case, 'secure: true' in the second case)

### Allow invalid server certificate

This is an option not to be used in production. It is a shortcut when you have to fastly test if the connection is working. Even if the connection is secured, not verifing the server credentials is not a safe approach.

You can set this flag in two ways, in the connection string or in the `db.open` method:

```dart
  var db = Db('mongodb://host:27017/test?tlsAllowInvalidCertificates=true');
  await db.open();
```

or

```dart
  var db = Db('mongodb://host:27017/test');
  await db.open(tlsAllowInvalidCertificates: true);
```

**Please note** that in both cases the `tls` flag is implicitly set to true ('tls=true' in the first case, 'secure: true' in the second case)

OK, so now we have a valid TLS connection working. What if we want the server to verify a client certificate? See next tutorial.

[Prev doc.](tls_connection_no_auth.md) - [Next doc.](tls_connection_no_auth_client_certificate.md)