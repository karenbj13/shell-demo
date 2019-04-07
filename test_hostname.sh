#!/bin/bash
set -x
set -e
root=$(id -u)
if [ "$root" -ne 0 ] ;then
        echo must run as root
        exit 1
fi

ceph::add_hostname(){
        echo $1 > /etc/hostname
}

ceph:clean(){
        printf "clean"
}

main()
{
  case $1 in
  "osd" )
        shift
        ceph::add_hostname $@
	;;
  "clean" )
        ceph:clean
        ;;
  *)
      echo "usage: $0 m[osd] ip| c[clearn]"
      echo "       $0 osd:      to setup ceph osd with ip"
      echo "       $0 clean:  to clean ceph osd node "
      echo "       unkown command $0 $@"
      ;;
  esac
}
main $@
