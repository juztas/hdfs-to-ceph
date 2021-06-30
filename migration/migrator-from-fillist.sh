#!/bin/bash

WORK_DIR=`mktemp -d`
DATA_PATH=$1
SPLIT_SIZE=200
#FTS_SERVER="https://cmsfts3.fnal.gov:8446"
FTS_SERVER="https://fts3-cms.cern.ch:8446"
GSIFTP_FROM="gsiftp://transfer.ultralight.org/"
GSIFTP_TO="gsiftp://transfer-lb.ultralight.org/storage/cms/"


if [ -z "$1" ]
  then
    echo "No filename was specified."
    exit 1
fi

if [ -z "$2" ]
  then
    echo "No ID was specified."
    exit 1
fi


if [ -f ~/.FTS_IDS_$2 ]; then
  echo "=======================      WARNING      ======================="
  echo "FILE ~/.FTS_IDS_$1 is present. Did you already submitted transfer requests?"
  echo "IF YOU ALREADY SUBMITTED TRANSFER. Do not delete ~/.FTS_IDS_$2 file"
  echo "Move this file as it keeps all your transfer request IDs for monitoring transfers"
  echo "and restart this script again."
  echo "=======================      WARNING      ======================="
  exit 1
fi

ftssubmit () {
  FTSID=`fts-transfer-submit -s $FTS_SERVER -f $WORK_DIR/fts-submit-file -o --retry 3 --retry-delay 60  --reuse`
  rm -f $WORK_DIR/fts-submit-file
  echo $FTSID >> ~/.FTS_IDS_$2
  echo "FTSID=$FTSID"
  sleep 1
}


echo "=======================      INFO      ======================="
echo "WORK_DIR:   $WORK_DIR"
echo "DATA_PATH:  $DATA_PATH"
echo "SPLIT_SIZE: $SPLIT_SIZE"
echo "FTS_SERVER: $FTS_SERVER"
echo "FTS_ID_SAVED_FILE: ~/.FTS_IDS_$2"
echo "=============================================================="

cd $WORK_DIR
echo "Getting list of all file names from filename"
echo "--------------------------------------------------------------"
#hdfs dfs -ls -t -R $DATA_PATH  &> GOOD_FILES
cp $1 GOOD_FILES

SUM=`cat GOOD_FILES | wc -l`

echo "Total number of files: $SUM"
echo "Start to split files to $SPLIT_SIZE and submit to FTS at $FTS_SERVER"
cnt=0
cat GOOD_FILES | while read line
do
    if [[ "$cnt" -eq $SPLIT_SIZE ]]; then
        cnt=0
        ftssubmit
    fi
    fname=`echo $line`
    echo "$GSIFTP_FROM$fname $GSIFTP_TO$fname" >> fts-submit-file
    cnt=$[$cnt +1]
done
if [ -f $WORK_DIR/fts-submit-file ]; then
  ftssubmit
fi




