
# Client certificate

**Updated for Mongodb ver 4.4 and mongo_dart version 0.5.0**
In order to verify the client identity, we can activate the client certificate check.
This involve three steps:

- configure the server for client certificate checking
- generate client certificates
- pass client certificate to the server

## Configure server to verify client identity

For server set-up we need the ca authority certificate that we have already generated (your-ca-name-full-chain.crt).
In the configuration file (```sudo nano /etc/mongod.conf```) we have to set the path under net: tls: CAFIle

```yaml
net:
  port: 27017  # set your port
  bindIp: #your system Ip addresses to be bind, 
  tls:
    mode: requireTLS
    certificateKeyFile: /var/local/mongodb/your-server-name.pem
    CAFile: /var/local/mongodb/your-ca-name-full-chain.crt
    disabledProtocols: TLS1_0,TLS1_1
```

or you can pass the --tlsCAFile parameter on the command line

```bash
mongod --tlsMode requireTLS --tlsCertificateKeyFile /var/local/mongodb/your-server-name.pem --tlsCAFile /var/local/mongodb/your-ca-name-full-chain.crt
```

Note that in the configuration file we have added also the option for disabling tls 1.0 and tls 1.1. If your system supports tls 1.2 it is a good security choice.

After updating the configuration restart the mongod daemon and check if the status is active

```bash
sudo systemctl restart mongod
sudo systemctl status mongod
```

Repeat this on all the member of the cluster and the server side configuration is OK.

Note that, if certificates are made correctly, the member restarted will immediately reconnect to the cluster.

## Generate Client certificates

The procedure is similar to the one used for creating the server certificates.

Theoretically the process should be:

- create your key for your client on your client (.key file).
- generate a signing request (.csr file).
- send the .csr file to the authority that signs it and sends back to you a public certificate (.crt) file.
- concatenate the crt and key files into a pem file (.pem);

Here the critical files are the .key and the .pem as they contains the private key, so set all required file permissions.
Normally the .key is not required for eveyday use, so you can crypt it and guard it in a safe place.
The .pem file, on the opposite, is needed for the connecting to the server, so we have to mantain it uncrypted. You could eventually set a password on your pem certificate.

This said, and considering that _we_ are the CA authority, we can generate the keys for the clients on the same computer and then guard them safely. We will only need to send to the client the client.pem file (it should already have the your-ca-name-full-chain.crt) in a safe way (scp).

Here too we have a [nice tutorial on the mongodb site](https://docs.mongodb.com/manual/appendix/security/appendixC-openssl-client/) on how to generate the client keys.
You can follow it or [run the script](script/client-certificate.sh) that I have prepared.
You can run it in the cert folder generated before (the intermediate key file ".key" must be decrypted if you used gpg) in this way:
move to the cert folder, run the command `./client-certificate.sh your-ca-name client-name`.
The script will require some parameters, set them as you like, be only careful to set the "Organization name" and the "Organizational Unit name" with at least one parameter different from those you have set in the server configuration. Also the DC (Domain Component) parameters is part of this check, but the script will not ask you for it. When asked for the name (CN) is better to set a client identifier (or the name of a user). It could be useful if you later would like to set the x.509 authentication (not yet managed by the driver).

Create all clients certificates and send them to each client in a safe way.

## Passing the client certificate to the server

On the client we could use the /home/your-user/mongodb folder, but this is only a suggestion.
Authorization on the file and directory must be set in the name of the user that will use the file.
So, if we use the suggested location:

- go to the home dir (```cd ~```),
- create the mongodb folder (```mkdir mongodb```),
- move to the mongodb folder (```cd mongodb```)
- move certs to the new directory(```sudo mv path-to-cert-file/*.pem .```)
- move certs to the new directory(```sudo mv path-to-cert-file/*.crt .```)
- set the user ownership, ```sudo chown your-user:your-user *```,
- set restricted file permission, ```sudo chmod 600 *.pem```
- go back to the home folder (```cd ..```)
- change the owner also for the mongodb folder (```sudo chown your-user:your-user mongodb```)
- change also the dir permission (```sudo chmod 770 mongodb```)

Now that we have the certificate in place, we can test if it is ok.

- Test with mongo shell

```bash
mongo --host your-host --port your-host-port --tls --tlsCAFile path-to-your-full-chain-file/your-ca-name-full-chain.crt --tlsCertificateKeyFile /home/your-user/mongodb/client-name.pem
```

The CAFile is only needed if in the previous step we have not added the ca-certificate in the ca certificates repository.

Now we can use the driver. You can pass it in the connection string or in the `db.open` method:

```dart
  var db = Db('mongodb://host:27017/test?tlsCAFile=path-to-your-full-chain-file/your-ca-name-full-chain.crt&tlsCertificateKeyFile=path-to-your-client-pem-file/client-name.pem');
  await db.open();
```

or

```dart
  var db = Db('mongodb://host:27017/test');
  await db.open(tlsCAFile: 'path-to-your-full-chain-file/your-ca-name-full-chain.crt', tlsCertificateKeyFile: 'path-to-your-client-pem-file/client-name.pem');
```

If the key was password protected you must add also the `tlsCertificateKeyFilePassword` parameter, either in the connection string or as a `db.open()` parameter.

[Prev doc.](tls_connection_no_auth_self_signed_certificate.md) 

