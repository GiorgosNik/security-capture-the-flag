#!/bin/bash

cipher='4f9886291b512f70611cde3188cdbc1b51d17da5ac4f8ea7af3ab8f10543f09e'
       #4f9886291b5d237c6d10d23d84c1b017
       #<----FIRST PART---->__<---MID--><-----------LAST PART---------->
zeroIV=${cipher:0:32}
for hex in {0..10}
do
  echo $hex
  hexIncr=$hex
  hexIncr=$((hexIncr+1))
  hexValue=$(printf "0x%02x" $hexIncr)
  for char in {0..255}
  do
    declare -i i=$char
    byte=$(printf "%X" $char)
    if [ 16 -gt "$char" ]
    then
      byte="0"
      byte+=$(printf "%X" $char)
    else
      byte=$(printf "%X" $char)
    fi
    byte=$(echo $byte | tr A-Z a-z)
    start=$((30-hex*2))
    end=$((start+2))
    firstPart=${cipher:0:$start}
    lastPart=${cipher:32:32}
    complete=$firstPart
    complete+=$byte
    midPart=""
    for (( midIndex=$end; midIndex<=31; midIndex+=2 )); do
      midValue=${zeroIV:midIndex:2}
      hexMid="0x"
      hexMid+=$midValue
      hexMid=$(printf '%X\n' $(( $hexMid ^ $hexValue )))
      hexMid=$(echo $hexMid | tr A-Z a-z)
      midPart+=$hexMid
    done
    complete+=$midPart
    complete+=$lastPart
    form='secret='
    form+=$complete
    form+='&submit=go'
    output=$(curl --max-time 60 --user admin:hammertime -v \
    --http0.9 --data-raw $form  http://127.0.0.1:8000/check_secret.html 2>&1 | grep 'wrong secret')
    if ! [ -z "$output" ] 
    then
      hexByte="0x"
      hexByte+=$byte
      iv=$(printf '%X\n' $(( $hexByte ^ $hexValue )))
      iv=$(echo $iv | tr A-Z a-z)
      newIV=$firstPart
      newIV+=$iv
      newIV+=${zeroIV:end:$((32-end))}
      zeroIV=$newIV
      echo "Zero IV" $zeroIV
      break
    fi
  done
done
echo $zeroIV

hexByte="0x"
hexByte+="0c"
iv=$(printf '%X\n' $(( $hexByte ^ $hexValue )))
iv=$(echo $iv | tr A-Z a-z)
newIV=$firstPart
newIV+=$iv
newIV+=${zeroIV:end:$((32-end))}
zeroIV=$newIV
echo "Zero IV" $zeroIV

zeroIV=${cipher:0:32}
zeroIV="4f988629175d237c6d10d23d84c1b017"
for hex in {12..15}
do
  echo $hex
  hexIncr=$hex
  hexIncr=$((hexIncr+1))
  hexValue=$(printf "0x%02x" $hexIncr)
  for char in {0..255}
  do
    declare -i i=$char
    byte=$(printf "%X" $char)
    if [ 16 -gt "$char" ]
    then
      byte="0"
      byte+=$(printf "%X" $char)
    else
      byte=$(printf "%X" $char)
    fi
    byte=$(echo $byte | tr A-Z a-z)
    start=$((30-hex*2))
    end=$((start+2))
    firstPart=${cipher:0:$start}
    lastPart=${cipher:32:32}
    complete=$firstPart
    complete+=$byte
    midPart=""
    for (( midIndex=$end; midIndex<=31; midIndex+=2 )); do
      midValue=${zeroIV:midIndex:2}
      hexMid="0x"
      hexMid+=$midValue
      hexMid=$(printf '%X\n' $(( $hexMid ^ $hexValue )))
      hexMid=$(echo $hexMid | tr A-Z a-z)
      midPart+=$hexMid
    done
    complete+=$midPart
    complete+=$lastPart
    form='secret='
    form+=$complete
    form+='&submit=go'
    output=$(curl --max-time 60 --user admin:hammertime -v \
    --http0.9 --data-raw $form  http://127.0.0.1:8000/check_secret.html 2>&1 | grep 'wrong secret')
    if ! [ -z "$output" ] 
    then
      hexByte="0x"
      hexByte+=$byte
      iv=$(printf '%X\n' $(( $hexByte ^ $hexValue )))
      iv=$(echo $iv | tr A-Z a-z)
      newIV=$firstPart
      newIV+=$iv
      newIV+=${zeroIV:end:$((32-end))}
      zeroIV=$newIV
      echo "Zero IV" $zeroIV
      break
    fi
  done
done
echo $zeroIV























#   curl --max-time 5 --user admin:hammertime -v --socks5-hostname localhost:9050\
#  xtfbiszfeilgi672ted7hmuq5v7v3zbitdrzvveg2qvtz4ar5jndnxad.onion/ --http0.9 --data-raw $form --socks5-hostname localhost:9050 http://xtfbiszfeilgi672ted7hmuq5v7v3zbitdrzvveg2qvtz4ar5jndnxad.onion/check_secret.html
