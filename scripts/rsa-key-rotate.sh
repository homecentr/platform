# 1 = CN
# 2 = Variable file path
# 3 = Variable name -> sub props

set -e

printHelp() {
  echo "Arguments:"
  echo "(1) Variable file path"
  echo "(2) Variable name"
  echo "(3) Certificate authority name"
}

if [ "$2" == "" ]; then
  printHelp
  exit 1
fi

# Create certificate
openssl req -x509 -new -newkey rsa:4096 -nodes -keyout /tmp/$3.key -sha256 -days 7300 -out /tmp/$3.crt -subj "/CN=$3/C=CZ/L=Kralupy nad Vltavou/O=Homecentr"

echo "$2:" > "./environments/$1"
echo "  public_key: |" >> "./environments/$1"
cat /tmp/$3.crt | ( TAB='    ' ; sed "s/^/$TAB/" ) >> "./environments/$1"

echo "  private_key: |" >> "./environments/$1"
cat /tmp/$3.key | ( TAB='    ' ; sed "s/^/$TAB/" ) >> "./environments/$1"

# Encrypt the variables file
ansible-vault encrypt --vault-password-file "./scripts/vault.sh" "./environments/$1"

# Remove the interim files
rm -f /tmp/$3.key
rm -f /tmp/$3.crt