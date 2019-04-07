#!/bin/bash
set -x
set -e
root=$(id -u)
if [ "$root" -ne 0 ] ;then
	echo must run as root
	exit 1
fi

ssh_nopass_members=(
ceph-osd0
ceph-osd1
ceph-osd2
)
osd_num=3
#monitor列表，"ceph-monitor0 ceph-monitor1"
monitor_str="ceph-moni"
cluster_str="ceph-moni ceph-osd0 ceph-osd1 ceph-osd2"
osd_rbd_dir="ceph-osd0:/var/local/osd0 ceph-osd1:/var/local/osd1 ceph-osd2:/var/local/osd2"

ceph::add_new_user(){
	#add new user
	if id dintern &>/dev/null
        then
			userdel -r dintern
			useradd -d /home/dintern -m dintern

        else
            useradd -d /home/dintern -m dintern
    	fi
	echo dintern065754 | passwd --stdin dintern
	echo "dintern ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/dintern
	#grant new new user to  user bash
	cp /etc/sudoers /etc/sudoers_bak
	sed -i 's/Defaults    requiretty/Defaults:ceph !requiretty/g' /etc/sudoers
}

ceph::ssh_nopassword(){
su - dintern <<EOF
ssh-keygen -t rsa -f /home/dintern/.ssh/id_rsa -N ""
EOF

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

ceph::add_hostname(){
	echo $1 > /etc/hostname	
}

ceph::make_osd_dir(){
     osd_dir_name="osd$2";
     rm -rf /var/local/$osd_dir_name
     mkdir /var/local/$osd_dir_name
     chmod 777 -R /var/local/$osd_dir_name
}

ceph::get_package(){
	yum install expect  -y
	expect -c "
	set timeout 1200; ##设置拷贝的时间，根据目录大小决定，我这里是1200秒。
	spawn /usr/bin/scp -r root@9.111.213.23:/root/ceph /root/ceph
	expect {
	\"*yes/no*\" {send \"yes\r\"; exp_continue}
	\"*password*\" {send \"Passw0rd\r\";} ##远程IP的密码。
	}
	expect eof;"
}

ceph::install_ceph(){
	cd /root/ceph
	rpm --import release.asc
	cd /root/ceph/ceph
	yum localinstall *.rpm -y
}

ceph::install_ceph_deploy(){
	cd /root/ceph
	rpm --import release.asc
	cd /root/ceph/ceph-deploy
	yum localinstall *.rpm -y
}

ceph::config_cluster(){
su - dintern <<EOF
mkdir /home/dintern/ceph-cluster
cd /home/dintern/ceph-cluster
rm -rf /etc/ceph/*
ceph-deploy new $monitor_str
	
osd_config="osd pool default size = $osd_num"
echo "[mon]">>ceph.conf
echo "mon_allow_pool_delete = true">>ceph.conf

ceph-deploy mon create-initial
ceph-deploy osd prepare $osd_rbd_dir
ceph-deploy osd activate $osd_rbd_dir
ceph-deploy admin $cluster_str
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
EOF
}

ceph::admin_up(){
	ceph::add_new_user
	ceph::ssh_nopassword
	ceph::add_hostname $@
	ceph::get_package
	ceph::install_ceph_deploy
	ceph::install_ceph
	ceph::config_cluster
}

ceph::osd_up(){
	ceph::add_new_user
	#ceph::add_cluster_dns
	ceph::add_hostname $@
	ceph::make_osd_dir $@
	ceph::get_package
	ceph::install_ceph
}

ceph::clean(){
	printf "clean"
}

main()
{
  case $1 in
  "admin" )
	shift
    ceph::admin_up $@
      ;;
  "osd" )
      shift
      ceph::osd_up $@
      ;;
  "clean" )
	ceph::clean
	;;
  *)
      echo "usage: $0 m[admin] hostname| o[osd] hostname num "
      echo "       $0 admin to setup ceph cluster "
      echo "       $0 osd num  "
      echo "       $0 down   to tear all down ,inlude all data! so be carefull"
      echo "       $0 rejoin to rejoin master with token "
      echo "       unkown command $0 $@"
      ;;
  esac
}

main $@

