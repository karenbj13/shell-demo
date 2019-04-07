#!/bin/bash
arr=(ceph-osd0
ceph-osd1
)
su - dintern <<EOF
	ssh-keygen -t rsa -f /home/dintern/.ssh/id_rsa -N ""
	password="dintern065754"
	file="/home/dintern/.ssh/id_rsa.pub"
	
	for host in ${ arr[@] };
	do
		set timeout 10 
		spawn scp $file dintern@$host:$file 
			expect { 
			 "(yes/no)?" 
			   { 
				send "yes\n" 
				expect "*assword:" { send "$password\n"} 
				} 
				 "*assword:" 
				{ 
				 send "$password\n" 
				} 
			} 
		expect "100%" 
		expect eof  
		#exit;
	done
	eixt;
	
EOF
