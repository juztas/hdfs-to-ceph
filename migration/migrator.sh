#!/bin/bash

WORK_DIR=`mktemp -d`
DATA_PATH=$1
SPLIT_SIZE=100
FTS_SERVER="https://cmsfts3.fnal.gov:8446"
#FTS_SERVER="https://fts3-cms.cern.ch:8446"
GSIFTP_FROM="gsiftp://transfer.ultralight.org/"
GSIFTP_TO="gsiftp://transfer-lb.ultralight.org/storage/cms/"


if [ -z "$1" ]
  then
    echo "No argument supplied. Please provide either /store/user/<username> or /store/group/<group_name>"
    exit 1
fi


if [ -f ~/.FTS_IDS ]; then
  echo "=======================      WARNING      ======================="
  echo "FILE ~/.FTS_IDS is present. Did you already submitted transfer requests?"
  echo "IF YOU ALREADY SUBMITTED TRANSFER. Do not delete ~/.FTS_IDS file"
  echo "Move this file as it keeps all your transfer request IDs for monitoring transfers"
  echo "and restart this script again."
  echo "=======================      WARNING      ======================="
  exit 1
fi

ftssubmit () {
  FTSID=`fts-transfer-submit -s $FTS_SERVER -f $WORK_DIR/fts-submit-file -K`
  rm -f $WORK_DIR/fts-submit-file
  echo $FTSID >> ~/.FTS_IDS
  echo "FTSID=$FTSID"
}


echo "=======================      INFO      ======================="
echo "WORK_DIR:   $WORK_DIR"
echo "DATA_PATH:  $DATA_PATH"
echo "SPLIT_SIZE: $SPLIT_SIZE"
echo "FTS_SERVER: $FTS_SERVER"
echo "FTS_ID_SAVED_FILE: ~/.FTS_IDS"
echo "=============================================================="

cd $WORK_DIR
echo "Getting list of all file names from HDFS"
echo "--------------------------------------------------------------"
hdfs dfs -ls -t -R $DATA_PATH  &> GOOD_FILES

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
    fname=`echo $line | awk '{print $8}'`
    fperm=`echo $line | awk '{print $1}'`
    if [[ ! "$fperm" =~ ^d.* ]]; then
      echo "$GSIFTP_FROM$fname $GSIFTP_TO$fname" >> fts-submit-file
      cnt=$[$cnt +1]
    fi
done
if [ -f $WORK_DIR/fts-submit-file ]; then
  ftssubmit
fi




