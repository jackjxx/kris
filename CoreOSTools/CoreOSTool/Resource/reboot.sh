#!/usr/bin/bash
port_number=$1

echo $port_number

echo "---- Configure Bootargs ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost 'nvram boot-args=debug=0x14e serial=3'

echo "---- Reboot Device ----"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost 'reboot'

