#!/bin/bash          

# *** Insert here your default before running The script
# countryName_default - 2 chars
countryNameDefault="insert-here-your-value"
# stateOrProvinceName_default - max 64 chars
stateOrProvinceNameDefault="insert-here-your-value"
# localityName_default - max 64 chars
localityNameDefault="insert-here-your-value"
# organizationName_default -max 64 chars
organizationNameDefault="insert-here-your-value"
# organizationalUnitName_default - max 64 chars
organizationalUnitNameDefault="insert-here-your-value"

# $1 ca name prefix - same as in the CA generation script
# $2 client name

if [ $# -lt 1 ]; then 
   echo "missing ca prefix name"
   exit 1
fi
if [ $# -lt 2 ]; then 
   echo "missing client name parameter"
   exit 1
fi

 
FILENAME="client.$2_ssl.cnf"
GEN_FILE="client.$2"


echo "Creating client configuration file"
echo "# Client $2 configuration file" > $FILENAME
echo "" >> $FILENAME
echo "[ req ]" >> $FILENAME
echo "default_bits = 4096" >> $FILENAME
echo "default_keyfile = myTestClientCertificateKey.pem    ## The default private key file name." >> $FILENAME
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
echo "" >> $FILENAME

echo "[ req_dn ]" >> $FILENAME
echo "countryName = Country Name (2 letter code)" >> $FILENAME
echo "countryName_default = $countryNameDefault" >> $FILENAME
echo "countryName_min = 2" >> $FILENAME
echo "countryName_max = 2" >> $FILENAME
echo "" >> $FILENAME

echo "stateOrProvinceName = State or Province Name (full name)" >> $FILENAME
echo "stateOrProvinceName_default = $stateOrProvinceNameDefault" >> $FILENAME
echo "stateOrProvinceName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "localityName = Locality Name (eg, city)" >> $FILENAME
echo "localityName_default = $localityNameDefault" >> $FILENAME
echo "localityName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "organizationName = Organization Name (eg, company)" >> $FILENAME
echo "organizationName_default = $organizationNameDefault" >> $FILENAME
echo "organizationName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "organizationalUnitName = Organizational Unit Name (eg, section)" >> $FILENAME
echo "organizationalUnitName_default = $organizationalUnitNameDefault" >> $FILENAME
echo "organizationalUnitName_max = 64" >> $FILENAME
echo "" >> $FILENAME

echo "commonName = Common Name (eg, YOUR name)" >> $FILENAME
echo "commonName_max = 64" >> $FILENAME
echo "" >> $FILENAME


echo "Do you wish to password protect your private client key certificate?"

select installType in "No" "Yes standard method (aes256)"; do
    case $REPLY in
        1 ) break;;
        2 ) break;;
        *) echo "invalid response";;
    esac
done

echo "Create client private key (.key)"
if [ $REPLY -eq 2 ]; then
  while true; do
    read -sp "Insert private client key password: " clientPwd	
    echo ""
    read -sp "Confirm private client key password: " confClientPwd	
    echo ""
    if [[ "$clientPwd" == "$confClientPwd" ]]; then
      break
    fi
    echo "Password mismatch, please re-enter"
  done 
 openssl genrsa -aes256  -passout pass:$clientPwd  -out "$GEN_FILE.key" 4096
else
 openssl genrsa -out "$GEN_FILE.key" 4096
fi

echo "Create the client signing request"
openssl req -new -key "$GEN_FILE.key"  -passin pass:$clientPwd  -out "$GEN_FILE.csr"  -config $FILENAME

echo "Create the client public certificate (.crt)"
openssl x509 -sha256 -req -days 365 -in "$GEN_FILE.csr" -CA $1-ia.crt -CAkey $1-ia.key -CAcreateserial -out "$GEN_FILE.crt"  -extfile $FILENAME -extensions v3_req

echo "create PEM file (.crt + .key)"
cat "$GEN_FILE.crt" "$GEN_FILE.key" > "$GEN_FILE.pem"
chmod 600 $GEN_FILE.pem


# clean- up
rm $GEN_FILE.csr
rm $FILENAME
rm $1-ia.srl

