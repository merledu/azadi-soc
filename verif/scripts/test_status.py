from sys import argv
import re

testname = argv[1]
boot_mode = argv[2]

status = ["PASS", "FAIL", "TIMEOUT"]

x=0
y=0

result = ""

print("Test name = {}".format(testname))

xrun_log = open("xrun.log", "r")

for line in xrun_log:
    x = re.search("^Test Status.*", line)
    if (x):
        for i in status:
            y = re.search("{}".format(i), line)
            if (y):
                result = i
                break
        break

print(result)

xrun_log.close()

regr_log = open("regr.log", "a")


regr_log.write("{}-{}, {}\n".format(testname, boot_mode, result))
regr_log.close()

