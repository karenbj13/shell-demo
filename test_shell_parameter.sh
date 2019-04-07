#!/bin/bash

kube::node_up()
{
  echo "node up"
  echo "one paremeter:$1"
  echo "$@"
}

kube::rejoin()
{
  echo "rejoin"
  echo "rejoin $@"
}


main()
{
  case $1 in
  "m" | "master" )
      echo "master"
      ;;
  "j" | "join" )
  #    shift
      kube::node_up $@
      ;;
  "d" | "down" )
      kube::tear_down
      ;;
  "r" | "rejoin" )
      kube::rejoin $@
      ;;
  *)
      echo "usage: $0 m[master] | j[join] token | d[down] | r[rejoin]"
      echo "       $0 master to setup master "
      echo "       $0 join   to join master with token "
      echo "       $0 down   to tear all down ,inlude all data! so be carefull"
      echo "       $0 rejoin to rejoin master with token "
      echo "       unkown command $0 $@"
      ;;
  esac
}

main $@
