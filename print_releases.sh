#!/bin/bash

cd $1

order=${2:-desc}

if [ "$order" != "desc" ] && [ "$order" != "asc" ]; then
        echo "order must be 'asc' or 'desc'"
        exit 1
fi

desc_flag=""
if [ "$order" = "desc" ]; then
        desc_flag="-"
fi

VERS="$(git tag -l --sort=${desc_flag}v:refname | grep "^[0-9]*.[0-9]*.[0-9]*$")"
echo $VERS
