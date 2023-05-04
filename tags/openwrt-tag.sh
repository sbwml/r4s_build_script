#!/bin/bash

curl -s "https://api.github.com/repos/openwrt/openwrt/tags" > /tmp/tags.json
if [ ! -s /tmp/tags.json ]; then
    echo error
    exit 1
else
    cat /tmp/tags.json | jq . > /tmp/tags.json 2>&1
fi
[ $? -ne 0 ] && exit 1

grep name /tmp/tags.json | grep v22 | head -1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g' | sed 's/v//g' > v22
