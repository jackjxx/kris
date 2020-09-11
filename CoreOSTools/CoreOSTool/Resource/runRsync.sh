#!/usr/bin/bash

port_number=$1
local_path=$2
remote_path=$3


echo "---- Delete Remote Path ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost 'rm -rf '"$remote_path"''

echo "---- Make Remote Path ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost 'mkdir '"$remote_path"''

echo "----- Run Rsync-----"
echo "Port: $port_number"
echo "From: $local_path"
echo "To: $remote_path"


echo "---- Save Current Max Inactivity ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost '/usr/local/bin/profilectl effnum  maxInactivity > /tmp/maxInactivity.log'


echo "----- Increase Max Inactivity to Maximum -----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost '/usr/local/bin/profilectl setnum maxInactivity 300'

echo "----- Copy Asset to device -----"
RETRY_INDEX=1
while [ $RETRY_INDEX -le 6 ]
do
    rsync --progress --partial -vazp  -e 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p '"$port_number"''  $local_path root@localhost:$remote_path
    if [ "$?" = "0" ] ; then
        echo "rsync completed."
        exit
    else
        RETRY_INDEX=$(( $RETRY_INDEX + 1 ))
        echo "rsync failure. Retrying in 10 sec.."
        sleep 10
    fi
done
echo "rsync failure. No more retries."
exit -1

#Copy from remote to local while in local.
#rsync -chavzP -e "ssh -p 13022" root@localhost:/var/mobile/Library/Logs/CrashReporter/DiagnosticLogs/sysdiagnose/sysdiagnose_2018.05.28_09-39-43+0300_iPhone_OS_iPhone_16A297.tar.gz /tmp
