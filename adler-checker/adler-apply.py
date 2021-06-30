import os
from os import walk
import json

class mainClass():
    def __init__(self):
        with open('jsondump', 'r') as fd:
            self.out = json.loads(fd.read())

    def mainCall(self):
        for fName, fAdler in self.out['HDFS_ADLER:'].items():
            print fName, fAdler
        #for fName, fAdler in self.out['HDFS_ADLER:'].items():
        #    cephFile = '/storage/cms/' + fName
        #    if not os.path.isfile(cephFile):
        #        print 'ERROR File not available: %s' % fName
        #    else:
        #        cmd = "xrdadler32 %s %s" % (fName, fAdler)
                

if __name__ == "__main__":
    caller = mainClass()
    caller.mainCall()

