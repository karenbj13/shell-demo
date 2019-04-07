#!/bin/bash
arr=(ceph-osd0
ceph-osd1
ceph-osd2)
for i in "${!arr[@]}"; do 
    printf "%s\t%s\n" "$i" "${arr[$i]}"
done
