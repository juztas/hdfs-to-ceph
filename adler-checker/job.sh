#!/bin/sh

WORK_PATH=/storage/af/user/jbalcas/MIGR/unmerged/missing/
PROCID=`cat .job.ad | grep 'ProcId' | awk '{print $3}'`
#PROCID=10

if [ "$PROCID" == 0 ]
then
  exit 0
fi

source /cvmfs/cms.cern.ch/cmsset_default.sh
cmsrel CMSSW_10_2_3
cd CMSSW_10_2_3/src/
cmsenv


for fname in `ls $WORK_PATH`; do
  LFN=`awk "NR == n" n=$PROCID $WORK_PATH/$fname`
  if [ -z "$LFN" ]
  then
    echo "No file for $PROCID in $WORK_PATH/$fname"
  else
    echo $PROCID $LFN
    ST_TIME=`date +%s`
    ADLER=`xrdadler32 /storage/cms/$LFN`
    EN_TIME=`date +%s`
    HST_TIME=`date +%s`
    HADLER=`xrdadler32 /mnt/hadoop/$LFN`
    HEN_TIME=`date +%s`
    echo "CEPH_ADLER: " $ADLER $ST_TIME $EN_TIME
    echo "HDFS_ADLER: " $HADLER $HST_TIME $HEN_TIME
  fi
done

exit 0
