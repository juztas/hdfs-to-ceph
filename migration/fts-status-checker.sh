#!/bin/bash

FTS_SERVER="https://cmsfts3.fnal.gov:8446"
#FTS_SERVER="https://fts3-cms.cern.ch:8446"
transfercheck () {
cat $1 | while read line
do
    ST=`fts-transfer-status -s $FTS_SERVER $line`
    echo "$line $ST"
    if [[ "$ST" =~ ^(FAILED|FINISHEDDIRTY)$ ]]; then
      echo "To debug failed transfer. execute: fts-transfer-status -s $FTS_SERVER $line -l"
    fi
done

}

if [ -f ~/.FTS_IDS ]; then
  SUM=`cat ~/.FTS_IDS | wc -l`
  echo "There is $SUM FTS Transfers to check"
  transfercheck ~/.FTS_IDS
fi

if [ -f ~/.FTS_IDS_RESUB ]; then
  SUM=`cat ~/.FTS_IDS_RESUB | wc -l`
  echo "There is $SUM FTS Transfers to check in RESUBMIT"
  transfercheck ~/.FTS_IDS_RESUB
fi


