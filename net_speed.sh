#!/bin/sh
echo "Collecting data..."
echo ""
cat /proc/net/arp | grep : | grep 0x2 | grep -v 00:00:00:00:00:00 | awk '{print $1,$4}' | sed 's/ /  <------>  /g' | tee  mac-ip_tables
cat /proc/net/arp | grep : | grep 0x2 | grep -v 00:00:00:00:00:00 | awk '{print $1}' > ip_lists
iptables -N UPLOAD
iptables -N DOWNLOAD
while read line;do iptables -I FORWARD 1 -s $line -j UPLOAD;done < ip_lists
while read line;do iptables -I FORWARD 1 -d $line -j DOWNLOAD;done < ip_lists
sleep 1
echo "Download speed:"
echo ""
iptables -nvx -L FORWARD | grep DOWNLOAD | awk '{print $2/1024/1" KB/s ",$1/10" packets/s", $9}' | sort -n -r
echo ""
echo "Upload speed:"
echo ""
iptables -nvx -L FORWARD | grep UPLOAD | awk '{print $2/1024/1" KB/s ",$1/10" packets/s", $8}' | sort -n -r
 
while read line;do iptables -D FORWARD -s $line -j UPLOAD;done < ip_lists
while read line;do iptables -D FORWARD -d $line -j DOWNLOAD;done < ip_lists
iptables -X UPLOAD
iptables -X DOWNLOAD
