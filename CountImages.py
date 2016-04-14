'''to be placed at same level as images/'''

import os
l = 0
for root, dirs, files in os.walk('.', topdown=False):
    if 'images\\' in root:
        for f in files:
            assert('.jpg' in f)
        l += len(files)
print('number of images==', l)
