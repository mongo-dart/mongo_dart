#!/bin/bash          

# before running this script put a default value where there is "<update here>"
# $1 is the prefix for the key files name

if [ $# -lt 1 ]; then 
   echo "missing prefix parameter"
   exit 1
fi

# Creates a subfolder called "cert"

mkdir cert
cd cert

echo "Creating authority configuration file"
echo "# For the CA policy" > $1_ssl.cnf
echo "[ policy_match ]" >> $1_ssl.cnf
echo "countryName = match" >> $1_ssl.cnf
echo "stateOrProvinceName = match" >> $1_ssl.cnf
echo "organizationName = match" >> $1_ssl.cnf
echo "organizationalUnitName = optional" >> $1_ssl.cnf
echo "commonName = supplied" >> $1_ssl.cnf
echo "emailAddress = optional" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "[ req ]" >> $1_ssl.cnf
echo "default_bits = 4096" >> $1_ssl.cnf
echo "default_keyfile = myTestCertificateKey.pem    ## The default private key file name." >> $1_ssl.cnf
echo "default_md = sha256                           ## Use SHA-256 for Signatures" >> $1_ssl.cnf
echo "distinguished_name = req_dn" >> $1_ssl.cnf
echo "req_extensions = v3_req" >> $1_ssl.cnf
echo "x509_extensions = v3_ca # The extentions to add to the self signed cert" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "[ v3_req ]" >> $1_ssl.cnf
echo "subjectKeyIdentifier  = hash" >> $1_ssl.cnf
echo "basicConstraints = CA:FALSE" >> $1_ssl.cnf
echo "keyUsage = critical, digitalSignature, keyEncipherment" >> $1_ssl.cnf
echo "nsComment = \"OpenSSL Generated Certificate.\"" >> $1_ssl.cnf
echo "extendedKeyUsage  = serverAuth, clientAuth" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "[ req_dn ]" >> $1_ssl.cnf
echo "countryName = Country Name (2 letter code)" >> $1_ssl.cnf
echo "countryName_default = <update here>" >> $1_ssl.cnf
echo "countryName_min = 2" >> $1_ssl.cnf
echo "countryName_max = 2" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "stateOrProvinceName = State or Province Name (full name)" >> $1_ssl.cnf
echo "stateOrProvinceName_default = <update here>" >> $1_ssl.cnf
echo "stateOrProvinceName_max = 64" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "localityName = Locality Name (eg, city)" >> $1_ssl.cnf
echo "localityName_default = <update here>" >> $1_ssl.cnf
echo "localityName_max = 64" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "organizationName = Organization Name (eg, company)" >> $1_ssl.cnf
echo "organizationName_default = <update here>" >> $1_ssl.cnf
echo "organizationName_max = 64" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "organizationalUnitName = Organizational Unit Name (eg, section)" >> $1_ssl.cnf
echo "organizationalUnitName_default = root" >> $1_ssl.cnf
echo "organizationalUnitName_max = 64" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "commonName = Common Name (eg, YOUR name)" >> $1_ssl.cnf
echo "commonName_max = 64" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "[ v3_ca ]" >> $1_ssl.cnf
echo "# Extensions for a typical CA" >> $1_ssl.cnf
echo "subjectKeyIdentifier=hash" >> $1_ssl.cnf
echo "basicConstraints = critical,CA:true" >> $1_ssl.cnf
echo "authorityKeyIdentifier=keyid:always,issuer:always" >> $1_ssl.cnf
echo "" >> $1_ssl.cnf

echo "Generating root key"
openssl genrsa -out $1-ca.key 4096

echo "Generate root.crt"
openssl req -new -x509 -days 1826 -key $1-ca.key -out $1-ca.crt -config $1_ssl.cnf

echo "Create intermediate key"
openssl genrsa -out $1-ia.key 4096

echo "Create the certificate signing request for the intermediate certificate."
openssl req -new -key $1-ia.key -out $1-ia.csr -config $1_ssl.cnf

echo "Create the intermediate certificate .crt."
openssl x509 -sha256 -req -days 730 -in $1-ia.csr -CA $1-ca.crt -CAkey $1-ca.key -set_serial 01 -out $1-ia.crt -extfile $1_ssl.cnf -extensions v3_ca

echo "create the CA.pem file"
cat $1-ia.crt $1-ca.crt > $1-ca.pem
chmod 600 $1-ca.pem

echo "crypt main key"
gpg -c $1-ca.key

echo "crypt ia key"
gpg -c $1-ia.key

rm $1-ca.key
rm $1-ia.key



