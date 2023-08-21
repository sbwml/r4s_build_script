#!/bin/bash

curl -s "https://api.github.com/repos/openwrt/openwrt/tags" -o tags.json || exit 1
if [ ! -s tags.json ]; then
    echo error
    exit 1
else
    cat tags.json | jq . > jq.json 2>&1
fi

grep name jq.json | grep v23 | head -1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g' | sed 's/v//g' > v23
rm -f tags.json jq.json
