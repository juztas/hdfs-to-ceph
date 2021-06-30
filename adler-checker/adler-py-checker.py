import os
from os import walk
import json

MYPATH="/storage/af/user/jbalcas/work/hdfs-checksum-unmerged/job/"

def cutFName(fName):
    if fName.startswith('/mnt/hadoop/'):
        return fName[12:]
    if fName.startswith('/storage/cms/'):
        return fName[13:]
    return fName

class mainClass():
    def __init__(self):
        self.out = {'CEPH_ADLER:': {}, 'HDFS_ADLER:': {}}

    def parseLines(self, inLines):
        for line in inLines:
            if line.startswith('CEPH_ADLER') or line.startswith('HDFS_ADLER'):
                splLine = line.split(' ')
                self.out[splLine[0]][cutFName(splLine[3])] = splLine[2]

    def readFile(self, fName):
        """ Read file """
        if not os.path.isfile(fName):
            return
        with open(fName, 'r') as fd:
            allLines = fd.readlines()
            self.parseLines(allLines)



    def mainCall(self):
        for (dirpath, dirnames, filenames) in walk(MYPATH):
            for filename in filenames:
                fName = MYPATH + filename
                self.readFile(fName)
        with open('jsondump', 'w') as fd:
            json.dump(self.out, fd)
        for fName, fAdler in self.out['CEPH_ADLER:'].items():
            if fName not in self.out['HDFS_ADLER:'].keys():
                print 'ERROR NOT AVAILABLE: %s' % fName
            elif fAdler != self.out['HDFS_ADLER:'][fName]:
                print 'ERROR ADLER: %s %s %s' % (fName, fAdler, self.out['HDFS_ADLER:'][fName])


if __name__ == "__main__":
    caller = mainClass()
    caller.mainCall()

