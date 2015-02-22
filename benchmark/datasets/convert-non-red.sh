#!/bin/sh

python convert-md5sum-ids.py $1 > /tmp/$1;  python fastaNonRedundant.py /tmp/$1 $1.md5
