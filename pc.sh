#!/bin/bash
hostname=`hostname`; 
ip=`hostname -I | cut -d" " -f1`; 
uptime=`uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours,",$9,"minutes"}' | tr -d " "`; 
load=`uptime | cut -d ',' -f4 | cut -d ':' -f2 | cut -d '.' -f1`; 
load_h="HIGH"
load_l="OK"
if [ "$load" -gt 3 ]
then
load_stat=`echo "$load_h"`
else
load_stat=`echo "$load_l"`
fi
################
M=`free -m | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d'.' -f1`; #echo "Memory used:" "$m%"
m=`echo $M%`
################
ar=`top -b -n 5 | egrep '^%Cpu|^Cpu' | awk '{print $2}' | tr -d "," | sed 's/%us//g'| cut -d'.' -f1`
cpu_us=`echo "${ar[*]}" | sort -nr | head -n 1`; #echo "CPU_STAT:" "$cpu_us%"
cpu_stat=`echo $cpu_us%`
#################
disk_LT="NORMAL"
disk_GT=`df -hP | grep -v ^F | awk '{print $5 $6}' | grep -e '^ *[8-9][0-9]' -e '^100'`
disk_GC=`echo "$disk_GT" | sed 's/%/%-/g'`
disk_G=`echo $disk_GC | sed 's/ /,/g'`
dc=`df -hP | grep -v ^F | awk '{print $5 $6}' | grep -e '^ *[8-9][0-9]' -e '^100' | wc -l`
if [ "$dc" -ge 1 ]
then
fs_stat=`echo "$disk_G"`
else
fs_stat=`echo "$disk_LT"`
fi
printf '%-60s %-25s %-35s %-9s %-8s %-8s %-7s %-20s\n' $hostname $ip $uptime $load $load_stat $cpu_stat $m $fs_stat 
