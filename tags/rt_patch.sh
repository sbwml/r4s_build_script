#!/bin/bash

ROOT="./tmp"

# RT

mkdir -p $ROOT && rm -rf $ROOT/*
cd $ROOT

PATCH_VERSION=`curl -s https://us.cooluc.com/kernel/projects/rt/6.6/ | grep -o 'patch-.*\.patch\.xz' | sed 's/.*">//'`
wget "https://us.cooluc.com/kernel/projects/rt/6.6/$PATCH_VERSION"
xz -d patch-*.xz && rm -f *.xz
