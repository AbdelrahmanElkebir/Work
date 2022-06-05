#!/bin/bash
sed 's/75%//' ns-sent.csv | sed 's/50%//' | sed 's/25%//' | sed 's/100%//' | sed 's/80%//' | awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' > new-ns-sent.csv
echo "Time"",""MSISDN"",""Status"",""SMS_Template_ID"",""LandLine">> sentsms.csv
input1=$1
userdate=$(date -d "$1" '+%d-%m-%Y')
INPUT=new-ns-sent.csv
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read  Time Empty Empty Empty MSISDN Status LandLine SMS_Template_ID Empty Empty Empty
do 

if [[ $Time = *"$userdate"* ]];
then

echo $Time","$MSISDN","$Status","$SMS_Template_ID","${LandLine//[^(0-9)]/} #Get Landline column in numbers only
#${LandLine//[^(0-9)]/}
fi

done < $INPUT > sentsms.csv
IFS=$OLDIFS

( tail -n +2 sentsms.csv ) | sort -t, -k+5 -n -r > sortedsms.csv


awk -F "|" '{print $1,$6,$20,$2}' OFS="," adslSubscribers_$1*.csv > Adsl.csv

( tail -n +2 Adsl.csv ) | sort -t, -k+4 -n -r > sortedadsl.csv


echo "Time,MSISDN,Status,SMS_Template_ID,LandLine,SubscriberId,CycleDay,UCID"  > AdslSMS_Report_$input1.csv 
( tail -n +2 AdslSMS_Report_$input1.csv ) | awk -F',' 'NR==FNR{ a[$4]=$1","$2","$3; next } FNR>1 || ($5 in a){ split(a[$5], b); $6=b[1]; $7=b[2]; $8=b[3]; }1' OFS=',' sortedadsl.csv sortedsms.csv >> AdslSMS_Report_$input1.csv #best


echo "SubscriberId,CycleDay,UCID,LandLineNumber" > AdslOthers_$input1.csv
 awk -F',' 'FNR==NR{a[$4]=1; next}  !a[$4] ' sortedsms.csv sortedadsl.csv >>AdslOthers_$input1.csv


rm sentsms.csv
rm sortedsms.csv
rm Adsl.csv
rm sortedadsl.csv
rm new-ns-sent.csv







