#!/bin/bash

WORK_DIR=`mktemp -d`
DATA_PATH=$1
SPLIT_SIZE=100
FTS_SERVER="https://cmsfts3.fnal.gov:8446"
#FTS_SERVER="https://fts3-cms.cern.ch:8446"

if [ ! -f ~/.FTS_IDS ]; then
  echo "=======================      WARNING      ======================="
  echo "FILE ~/.FTS_IDS is not present. There is nothing to check!"
  echo "=======================      WARNING      ======================="
  exit 1
fi

ftssubmit () {
  FTSID=`fts-transfer-submit -s $FTS_SERVER -f $WORK_DIR/fts-submit-file -K`
  rm -f $WORK_DIR/fts-submit-file
  echo $FTSID >> ~/.FTS_IDS_RESUB
  echo "FTSID=$FTSID"
}


SUM=`cat ~/.FTS_IDS | wc -l`
echo "There is $SUM FTS Transfers to check"
tac ~/.FTS_IDS | while read line
do
    ST=`fts-transfer-status -s $FTS_SERVER $line`
    if [[ "$ST" =~ ^(FAILED|FINISHEDDIRTY|CANCELED)$ ]]; then
      fts-transfer-status -s $FTS_SERVER $line -l &> $WORK_DIR/fts-failed-transfers
      SOURCE=""
      DEST=""
      FSTATE=""
      set -f; IFS=$'\n'
      for line1 in `cat $WORK_DIR/fts-failed-transfers`;
      do
        line1=`echo $line1 | xargs`
        if [[ "$line1" =~ ^Source:.* ]]; then
            SOURCE=`echo $line1 | awk '{print $2}'`
        fi
        if [[ "$line1" =~ ^Destination:.* ]]; then
            DEST=`echo $line1 | awk '{print $2}'`
        fi
        if [[ "$line1" =~ ^State:.* ]]; then
            FSTATE=`echo $line1 | awk '{print $2}'`
        fi

        if [ ! -z "$SOURCE" ] && [ ! -z "$DEST" ] && [ ! -z "$FSTATE" ]; then
            if [[ "$FSTATE" == "FAILED" ]]; then
              echo "$SOURCE $DEST" >> $WORK_DIR/fts-submit-file
            fi
            unset SOURCE DEST FSTATE
        fi
      done
      if [ -f $WORK_DIR/fts-submit-file ]; then
        ftssubmit
      fi
      set +f; unset IFS
    fi
done

