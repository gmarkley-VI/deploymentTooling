echo "Create Hosts file"
cp backups/hosts .
CURL=$(oc cluster-info | head -n1 | sed 's/.*\/\/api.//g'| sed 's/:.*//g')
echo -n "Enter Windows User Name and press [ENTER]: "
read NAME
echo -n "Enter Windows User Password and press [ENTER]: "
read -n 1 PASSWD
echo -n "Enter Windows machine IP and press [ENTER]: "
read -n 2 IP
sed -i "s/<node_ip>/$IP/g" hosts
sed -i "s/<password>/\x27$PASSWD\x27/g" hosts
sed -i "s/<username>/$NAME/g" hosts
sed -i "s/<cluster_address>/$CURL/g" hosts