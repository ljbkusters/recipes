#!/bin/sh

SRC=md            # Source directory
OUT=pdf           # Output directory
ITYPE=markdown    # Source type
I_EXT=md          # Source type file extension
OTYPE=latex       # Output type
O_EXT=pdf         # Output type file extension
ACTION=CHANGED    # Which files to compile (CHANGED/ALL/SINGLE)
VERBOSE=false     # give verbose output
MAXFILES=-1

compile_file(){
  FILE_PATH=$1
  FILE=$(echo "$FILE_PATH" | cut -f 2 -d '/')
  filename=$(echo "$FILE" | cut -f 1 -d '.')
  verbose_echo "compiling $filename..."
  pandoc -f $ITYPE -t $OTYPE $SRC/$FILE -o $OUT/$filename.$O_EXT
}

success(){
  verbose_echo "Done!\n"
}

fail(){
  verbose_echo "Something went wrong...\n"
  exit
}

check_if_changed(){
  # get md file
  FILE_PATH=$1
  # get file name without extension
  FILE=$(echo "$FILE_PATH" | cut -f 2 -d '/')
  filename=$(echo "$FILE" | cut -f 1 -d '.')
  # get corresponding pdf file
  PDF_FILE=$OUT/$filename.$O_EXT
  # check if edited date of md file is younger than edited date of pdf file
  
  # check if the pdf file actually exists (this won't be the case for
  # new recipes!) 
  if [ -f $PDF_FILE ];then 
    # if so, check if the md file is newer than the pdf file
    # this means the file was changed after the last compilation
    if [ $FILE_PATH -nt $PDF_FILE ]; then
      compile_file $FILE_PATH
    else
      # no compilation needed
      verbose_echo "No changes found"
    fi
  else
    # the file was not compiled yet, Therefore we want to compile it now
    verbose_echo "New file found, compiling..."
    compile_file $FILE_PATH
  fi
}

compile_changed(){
  verbose_echo "(Re)compiling all changed files to pdf"
  for FILE_PATH in $SRC/*; do
    verbose_echo $FILE_PATH
    check_if_changed $FILE_PATH || fail
  done
}

compile_all(){
  verbose_echo "(Re)compiling all md files to pdf"
  MAXFILES=$(expr $(/bin/ls -1U | wc -l) - 1)
  FILECOUNTER=1
  for FILE_PATH in $SRC/*; do
    verbose_echo $FILE_PATH
    update_progress_bar $FILECOUNTER
    compile_file $FILE_PATH || fail
    FILECOUNTER=$(expr $FILECOUNTER + 1)
  done
  end_progress_bar
}

verbose_echo(){
  if [ $VERBOSE = true ];then
    echo $1
  fi
}

update_progress_bar(){
  echo -n "(file $1 of $MAXFILES)\r" 
}
end_progress_bar(){
  echo -n "\n"
}

while getopts 's:achv' c
do
  case $c in
    a) ACTION=ALL; ;;
    s) ACTION=SINGLE; SINGLE_FILE=${OPTARG};;
    v) VERBOSE=true;;
    h) ACTION=NONE; echo "Options:\\n NO ARGUMENTS\tcompile only files that have been changed\\n -v\t\tVerbose output\\n -h\t\tShow this message\\n -a\t\tcompile all\\n -s <FILE>\tCompile a single file";;
    *) ACTION=NONE; echo "Option not found! (see -h for help)"; exit;;
  esac
done

case $ACTION in
  CHANGED) compile_changed && success || fail ;;
  ALL) compile_all && success || fail ;;   
  SINGLE) compile_file $SINGLE_FILE && success || fail;;
  NONE) exit ;;
  *) fail;;
esac
