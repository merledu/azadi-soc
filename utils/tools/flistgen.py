import os

path ="../src"
#we shall store all the file names in this list
flist = []

for root, dirs, files in os.walk(path):
	for file in files:
        #append the file name to the list
		flist.append(os.path.join(root,file))

#print all the file names
for name in flist:
    print(name)