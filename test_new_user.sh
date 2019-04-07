#!/bin/bash
set -x
set -e
root=$(id -u)
if [ "$root" -ne 0 ] ;then
	echo must run as root
	exit 1
fi

ceph:prepare_environment(){
	#add new user
	if id dintern &>/dev/null
	then 
		echo "dintern exit"
		userdel -r dintern
		useradd -d /home/dintern -m dintern
		
	else
		echo "no exit"
		useradd -d /home/dintern -m dintern
	fi
}

main(){
ceph:prepare_environment

}
main $@
