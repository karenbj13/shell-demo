#!/bin/bash
monitor_array=()
monitor_num=0
osd_num=0
ceph::test(){
	for ((i=0;i<=$#;i++));do
		a=$i
		shift
		echo $a
	done
}

main(){
	ceph::test $@
}
main $@

