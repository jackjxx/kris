
port_number=$1

echo "---- Delete Local Path ----"
rm -rf /tmp/$port_number

echo "---- Delete Remote Path ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost 'rm -rf /tmp/'"$port_number"''

echo "---- Make Remote Path ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost 'mkdir /tmp/'"$port_number"''


echo "----Run Sysdiagnose ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost 'sysdiagnose -l -f /tmp/'"$port_number"''


#Copy from remote to local while in local.
rsync -chavzP -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p '"$port_number"'' root@localhost:'/tmp/'"$port_number"'' /tmp
