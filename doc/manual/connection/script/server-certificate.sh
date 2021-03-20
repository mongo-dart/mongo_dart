#!/bin/bash          

# before running this script put a default value where there is "<update here>"

# $1 ca name prefix - same as in the CA generation script
# $2 server ip address
# $3 optional server name 

if [ $# -lt 1 ]; then 
   echo "missing ca prefix name"
   exit 1
fi
if [ $# -lt 2 ]; then 
   echo "missing server addres/name parameter"
   exit 1
fi

if [ $3 != "" ]; then 
  FILENAME="$3_ssl.cnf"
  GEN_FILE="$3"
else   
  FILENAME="serv.$2_ssl.cnf"
  GEN_FILE="serv.$2"
fi


echo "Creating server configuration file"
echo "# Server $2 configuration file" > $FILENAME
echo "" >> $FILENAME
echo "[ req ]" >> $FILENAME
echo "default_bits = 4096" >> $FILENAME
echo "default_keyfile = myTestCertificateKey.pem    ## The default private key file name." >> $FILENAME
echo "default_md = sha256                           ## Use SHA-256 for Signatures" >> $FILENAME
echo "distinguished_name = req_dn" >> $FILENAME
echo "req_extensions = v3_req" >> $FILENAME
echo "" >> $FILENAME

echo "[ v3_req ]" >> $FILENAME
echo "subjectKeyIdentifier  = hash" >> $FILENAME
echo "basicConstraints = CA:FALSE" >> $FILENAME
echo "keyUsage = critical, digitalSignature, keyEncipherment" >> $FILENAME
echo "nsComment = \"OpenSSL Generated Certificate.\"" >> $FILENAME
echo "extendedKeyUsage  = serverAuth, clientAuth" >> $FILENAME
echo "subjectAltName = @alt_names" >> $FILENAME
echo "" >> $FILENAME

echo "[ alt_names ]" >> $FILENAME
if [ $3 != "" ]; then 
  echo "DNS.1 = $3" >> $FILENAME
fi
echo "IP.1 = $2" >> $FILENAME
echo "" >> $FILENAME

echo "[ req_dn ]" >> $FILENAME
echo "countryName = Country Name (2 letter code)" >> $FILENAME
echo "countryName_default = <update here>" >> $FILENAME
echo "countryName_min = 2" >> $FILENAME
echo "countryName_max = 2" >> $FILENAME
echo "" >> $FILENAME

echo "stateOrProvinceName = State or Province Name (full name)" >> $FILENAME
echo "stateOrProvinceName_default = <update here>" >> $FILENAME
echo "stateOrProvinceName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "localityName = Locality Name (eg, city)" >> $FILENAME
echo "localityName_default = <update here>" >> $FILENAME
echo "localityName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "organizationName = Organization Name (eg, company)" >> $FILENAME
echo "organizationName_default = <update here>" >> $FILENAME
echo "organizationName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "organizationalUnitName = Organizational Unit Name (eg, section)" >> $FILENAME
echo "organizationalUnitName_default = <update here>" >> $FILENAME
echo "organizationalUnitName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "commonName = Common Name (eg, YOUR name)" >> $FILENAME
echo "commonName_max = 64" >> $FILENAME
echo "" >> $FILENAME


echo "Create server key"
openssl genrsa -out "$GEN_FILE.key" 4096

echo "Create the test certificate signing request"
openssl req -new -key "$GEN_FILE.key" -out "$GEN_FILE.csr"  -config $FILENAME

echo "Create the test server certificate"
openssl x509 -sha256 -req -days 365 -in "$GEN_FILE.csr" -CA $1-ia.crt -CAkey $1-ia.key -CAcreateserial -out "$GEN_FILE.crt"  -extfile $FILENAME -extensions v3_req

echo "create PEM file"
cat "$GEN_FILE.crt" "$GEN_FILE.key" > "$GEN_FILE.pem"
chmod 600 $GEN_FILE.pem




