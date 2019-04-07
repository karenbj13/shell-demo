#!/bin/bash
#su - dintern <<EOF
#ssh-keygen -t rsa -f /home/dintern/.ssh/id_rsa -N ""
#exit;
#EOF

gen_key(){
su - dintern <<EOF
ssh-keygen -t rsa -f /home/dintern/.ssh/id_rsa -N ""
exit;
EOF
}

main(){
	printf "before"
	gen_key
	printf "end"
}
main
