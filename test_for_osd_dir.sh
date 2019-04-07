#!/bin/bash
arr=(ceph-osd0)
su - dintern <<EOF
for i in "${!arr[@]}"; do
        #printf "%s\t%s\n" "$i" "${arr[$i]}"
        osd_name="osd+$i"
        ssh ${arr[$i]}
        sudo mkdir /var/local/$osd_name
        exit
done
EOF

