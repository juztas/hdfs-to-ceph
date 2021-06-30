import os
import sys
from os import listdir
from os.path import isfile, join
import time
import subprocess

proceed = True

#ftsServers = ["https://cmsfts3.fnal.gov:8446", "https://fts3-cms.cern.ch:8446"]
ftsServers = ["https://fts3-cms.cern.ch:8446"]

def submitnew(missdir, ftsServer):
    onlyfiles = [f for f in listdir(missdir) if isfile(join(missdir, f))]
    if not onlyfiles:
        return False
    print 'Total FTS Submissions left: %s' % len(onlyfiles)
    fullPath = '%s/%s' % (missdir, onlyfiles[0])
    submitfts = subprocess.Popen(["/storage/af/other/MIGRATION/migrator-from-fillist-test.sh", fullPath, fullPath[-4:], ftsServer])
    submitfts.communicate()
    print("The exit code was: %d" % submitfts.returncode)
    if submitfts.returncode == 0:
        os.remove(fullPath)
    return True

def getCount(ftsServer):
    cmd = 'fts-transfer-list -s %s | grep SUBMITTED | wc -l' % ftsServer
    out = subprocess.check_output(cmd, shell=True)
    return int(out)

if __name__ == "__main__":
    missdir = sys.argv[1]
    while proceed:
        for ftsServer in ftsServers:
            substate = getCount(ftsServer)
            print 'In submit state we have %s. FTS Server: %s' % (substate, ftsServer)
            if substate <=100:
                proceed = submitnew(missdir, ftsServer)
        print 'Sleep 10seonds'
        time.sleep(10)
