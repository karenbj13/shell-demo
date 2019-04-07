#!/bin/bash
ssh_nopass_members=(ceph-osd0
ceph-osd1)
ceph::ssh_copy_id(){
for host in ${ssh_nopass_members[@]}; do
	expect -c "
		set timeout 1200; 
		spawn ssh-copy-id -i /home/dintern/.ssh/id_rsa.pub dintern@$host
		expect {
			\"*yes/no*\" {send \"yes\r\"; exp_continue}
			\"*password*\" {send \"dintern065754\r\";} ##远程IP的密码。
			}
	expect eof;"
done
}
main(){
	ceph::ssh_copy_id
}
main
