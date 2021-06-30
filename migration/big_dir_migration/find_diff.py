
allCephFiles = {}

with open('allCeph') as fd:
    lines = fd.readlines()
    for line in lines:
        splLine = line.split()
        if len(splLine) == 2:
            allCephFiles[splLine[0]] = splLine[1]
        else:
            print 'WARNING: %s' % splLine


lines = []
with open('allHdfs') as fd:
    lines = fd.readlines()
for line in lines:
    splLine = line.split()
    if not splLine[0].startswith('d'):
        fname = splLine[7]
        fsize = splLine[4]
        if not fname in allCephFiles:
            print fname
        if fsize != allCephFiles[fname]:
            print fname
