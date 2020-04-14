#!/bin/sh

SRC=md            # Source directory
OUT=pdf           # Output directory
ITYPE=markdown    # Source type
I_EXT=md          # Source type file extension
OTYPE=latex       # Output type
O_EXT=pdf         # Output type file extension
ACTION=CHANGED    # Which files to compile (CHANGED/ALL/SINGLE)

compile_file(){
  PATH_FILE=$1
  FILE=$(echo "$PATH_FILE" | cut -f 2 -d '/')
  filename=$(echo "$FILE" | cut -f 1 -d '.')
  echo "compiling $filename..."
  pandoc -f $ITYPE -t $OTYPE $SRC/$FILE -o $OUT/$filename.$O_EXT
}

while getopts 'a:s:h' c
do
  case $c in
    a) ACTION=ALL;;
    s) ACTION=SINGLE; SINGLE_FILE=${OPTARGS};;
    h) echo "Options:\\n NO ARGUMENTS\tcompile only files that have been changed\\n -h\t\tShow this message\\n -a\t\tcompile all\\n -s <FILE>\tCompile a single file";;
    *) echo "Option not found! (see -h for help)";;
  esac
done

if [ $ACTION == ALL ] ; then
  for PATH_FILE in $SRC/*; do
    compile_file $PATH_FILE
    echo "Done!"
  done
elif [ $ACTION == SINGLE ] ; then
  compoile_file $SINGLE_FILE
  echo "Done!"
fi
