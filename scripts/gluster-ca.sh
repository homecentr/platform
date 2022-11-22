set -e

printHelp() {
  echo "Arguments:"
  echo "(1) Variable file path"
  echo "(2) Certificate authority name"
}

if [ "$2" == "" ]; then
  printHelp
  exit 1
fi

# Create certificate
openssl req -x509 -new -newkey rsa:4096 -nodes -keyout /tmp/$2.key -sha256 -days 7300 -out /tmp/$2.crt -subj "/CN=$2/C=CZ/L=Kralupy nad Vltavou/O=Homecentr"

echo "gluster_ca_public_key: |" > "./environments/$1"
cat /tmp/$2.crt | ( TAB='  ' ; sed "s/^/$TAB/" ) >> "./environments/$1"

echo "gluster_ca_private_key: |" >> "./environments/$1"
cat /tmp/$2.key | ( TAB='  ' ; sed "s/^/$TAB/" ) >> "./environments/$1"

# Encrypt the variables file
ansible-vault encrypt --vault-password-file "./scripts/vault.sh" "./environments/$1"

# TODO: Delete key files