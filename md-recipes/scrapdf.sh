#!/bin/sh

if [ $# -gt 3 ]; then
  echo "too many arguments passed"
  exit
fi

link=$1
file_out=$2

python scrape-to-md.py $link > md/$fileout.md
./compile.sh
