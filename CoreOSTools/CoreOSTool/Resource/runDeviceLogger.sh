#!/usr/bin/bash

port_number=$1
output_path=$2

echo "----- Run Device Logger -----"
echo "Port: $port_number"
echo "Output: $output_path"


ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $port_number  root@localhost ' log stream --style syslog --filter '"'"'process:"softwareupdateservicesd"'"'"' --filter '"'"'process:"mobileassetd"'"'"' --filter '"'"'process:"Preferences"'"'"' --filter '"'"'process:"softwareupdated"'"'"' --filter '"'"'process:"com.apple.MobileSoftwareUpdate.UpdateBrainService"'"'"' --filter '"'"'process:"Soundboard"'"'"'   --filter '"'"'process:"Pineboard"'"'"'  --filter '"'"'process:"sucontrollerd"'"'"' --filter '"'"'process:"suctlr"'"'"'  --filter '"'"'process:"ramrod"'"'"' --filter '"'"'process:"nanosubridged"'"'"' --filter '"'"'process:"subridged"'"'"' --filter '"'"'process:"itunesstored"'"'"' --filter '"'"'subsystem:"com.apple.nsurlsessiond",category:"background"'"'"' --filter '"'"'subsystem:"com.apple.nsurlsessiond",category:"proxy"'"'"' --filter '"'"'process:"appstored"'"'"'  --filter '"'"'process:"configd",message:"network changed:"'"'"' --filter '"'"'process:"configd",message:"en0: SSID"'"'"' --filter '"'"'process:"configd",message:"en0: Inactive"'"'"' --filter '"'"'subsystem:"com.apple.networkextension",message:"status changed"'"'"' --filter '"'"'process:"nsurlsessiond",message:"basejumper"'"'"'   '  &> $output_path




