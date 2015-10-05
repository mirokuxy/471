#!/bin/bash

#####
# This script is written and supposed to be run under host "may"
# Author: Yu Xiao
# StudentID: 301267080
#####

thisMachineName=may
thisMachineIP4=192.168.0.5
thisMachineIP6=fdd0:8184:d967:118:250:56ff:fe85:d1d8

myPing=ping   #will be modified to ping6 when testing IPv6
myTracepath=tracepath # will be modified to tracepath6 when testing IPv6


#Test a host with either hostname or IP address
function testHost { # $1: target host; $2: this machine
  echo 
  
  status=false
  $myPing -c 1 -W 1 $1 &> /dev/null && status=true || status=false
  
  if [ $status = 'true' ]; then
    echo $1 is reachable from $2

    etherAddr=`arp $1 2> /dev/null | sed -n '2p' | awk '{ print $3}'`
    if [ $etherAddr ]; then
      echo Ethernet address is $etherAddr
    fi

    $myTracepath $1
    
  else
    echo $1 is not reachable from $2
  fi
}

#Test all hosts with their names
function testWithName {

  #Hosts names
  adminHosts=( january february march april may june july august september october november december spring summer autumn fall winter solstice equinox seansons year )
  net16Hosts=( january april summer june fall september equinox december )
  net17Hosts=( january november spring august autumn february )
  net18Hosts=( december may july winter march )
  net19Hosts=( february october solstice year march )

  #Network names
  nets=( admin net16 net17 net18 net19 )

  #Test hosts in a network
  function testNet { # $1: network name
    #Get the array of host names
    netName=$1
    net=${netName}Hosts
    hosts=$net[@]
    hosts=( "${!hosts}" )
    #echo ${hosts[@]}

    for host in "${hosts[@]}"; do
      #Test each host in the network
      host=${host}.${netName}
      testHost $host $thisMachineName
    done
  }
 
  echo 
  echo ------------------------------------------- 
  echo --------- Testing With Host Names ---------
  echo 
 
  for net in "${nets[@]}"; do #Test each network
    echo
    echo $net
    testNet $net
  done

}

#Test all hosts with their IPv4 address (Scan through a range of IPs)
function testWithIP4 {
  
  index=4    #index of last entry in the array below
  #First three bytes of each network address
  nets=( 192.168.0 172.16.1 172.17.1 172.18.1 172.19.1 )
  lowerBound=( 1 1 1 3 2 )  #lower bound of the last byte for each network for scan
  upperBound=( 20 16 20 15 18 )  #upper bound of the last byte for each network for scan
  
  echo 
  echo ------------------------------------------
  echo ---------- Testing With IPv4 -------------
  echo 

  for i in `seq 0 $index`; do #Test each network
    net=${nets[$i]}
    lB=${lowerBound[$i]}
    uB=${upperBound[$i]}
    
    lByte=$lB
    while [ $lByte -le $uB ]; do #Scan each IP in the range and test
      IP=${net}.${lByte}
      testHost $IP $thisMachineIP4
      
      let lByte+=1
    done
  done
} 

#Test just one host with its IPv6 address
function testWithIP6 {
  targetIP6=fdd0:8184:d967:118:250:56ff:fe85:f802 #march

  echo
  echo -----------------------------------------
  echo ---------- Testing With IPv6 ------------
  echo

  testHost $targetIP6 $thisMachineIP6  
}
  
#Reset global commands for test with host names and test with IPv4 address
myPing=ping
myTracepath=tracepath

testWithName

testWithIP4

#Reset global commands for test with IPv6 address
myPing=ping6
myTracepath=tracepath6

testWithIP6



