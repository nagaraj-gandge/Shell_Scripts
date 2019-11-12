#!/bin/bash
#set -x

if [ $# -lt 2 ]
then
   echo
   echo "*************************************************************"
   echo "The script requires minumum of two arguments"
   echo
   echo "Usage: "
   echo
   echo "       ./3par_Datacollection.sh 3parstorage_IP 3par_Username"
   echo
   echo "**************************************************************"
   exit -1
fi
echo "*********************************************************************************"

echo -e "Please Wait While we are collecting your 3Par System logs for Analysis..\n"
echo -e "Creating 3par logs in logs directory..\n"

mkdir -p ./reports/
mkdir -p ./logs/
echo -e "If Password-less ssh is not set It will Prompt for the password\n"
echo -e "Please wait event logs are being collected..\n"

#echo -e "Enter the password to collect the event logs..\n"
ssh $2@$1 'showeventlog -min 1440 -comp rmm' > ./logs/eventlogs.log
echo -e "\nEvent logs are collected.\n"
echo -e "Please wait Remote Copy logs are being collected..\n"
#echo -e  "Enter the Password to collect rcopy logs..\n"
ssh $2@$1 'showrcopy' > ./logs/rcopylist.log
echo -e "\nRemote Copy logs are collected.\n"
sleep 1
echo -e "Creating a CSV file from the Remote Copy logs collected..\n"
touch ./reports/report.csv
(echo "RCopy_Group,RCG_RPO") > ./reports/rcopygrps.csv
column -t ./logs/rcopylist.log | grep "Period" |awk '{print $1"\t" $11}' | sed 's/,.*//' | sed 's/\t/,/g' >> ./reports/rcopygrps.csv
echo -e "Creating a CSV file from the Event logs collected..\n"
(echo "Date,Time,RCG_Name,Data_MBs,Time_Taken") >> ./reports/report.csv
grep "Remote Copy synchronization" -B4 ./logs/eventlogs.log | grep -e ^Time -e ^Message | sed ':begin;$!N;s/\nMessage/ /;tbegin;P;D' |sed 's/Time[ ]*://' | sed 's/ ://' |awk '{print $1 ","$2","$12","$25","$27}' >> ./reports/report.csv

echo -e "Now generating csv data to plot the graphs\n"

python3.6 manipulate_csv.py

echo -e "\nAlmost done..!\n"
echo -e "3PAR logs are collected and CSV is generated..! \n\nPlease check the log and reports directory (./logs and ./reports).\n"
echo -e "*********************************************************************************"

