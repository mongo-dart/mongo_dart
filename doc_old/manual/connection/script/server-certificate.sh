#!/bin/bash          

# *** Insert here your defaults before running The script
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


echo "Do you wish to password protect your private server key certificate?"

select installType in "No" "Yes standard method (aes256)"; do
    case $REPLY in
        1 ) break;;
        2 ) break;;
        *) echo "invalid response";;
    esac
done

echo "***"
echo "   - Creating server private key certificate (.key)"
if [ $REPLY -eq 2 ]; then
  while true; do
    read -sp "Insert private server key password: " serverpwd	
    echo ""
    read -sp "Confirm private server key password: " confserverpwd	
    echo ""
    if [[ "$serverpwd" == "$confserverpwd" ]]; then
      break
    fi
    echo "Password mismatch, please re-enter"
  done 
  openssl genrsa -aes256 -passout pass:$serverpwd -out "$GEN_FILE.key" 4096
else
 openssl genrsa -out "$GEN_FILE.key" 4096
fi

echo "***"
echo "   - Creating the server signing request certificate"
openssl req -new -key "$GEN_FILE.key" -passin pass:$serverpwd  -out "$GEN_FILE.csr"  -config $FILENAME

echo "***"
echo "   - Creating the server public certificate (.crt)"
openssl x509 -sha256 -req -days 365 -in "$GEN_FILE.csr" -CA $1-ia.crt -CAkey $1-ia.key -CAcreateserial -out "$GEN_FILE.crt"  -extfile $FILENAME -extensions v3_req

echo "***"
echo "   - creating PEM file (.crt + .key)"
cat "$GEN_FILE.crt" "$GEN_FILE.key" > "$GEN_FILE.pem"
chmod 600 $GEN_FILE.pem

# clean- up
rm $GEN_FILE.csr
rm $FILENAME
rm $1-ia.srl



