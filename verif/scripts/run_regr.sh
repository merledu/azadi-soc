#!/bin/sh

make clean && make xm-build COV=1 TEST=$1 BOOT_MODE=ICCM

python3 test_status.py $1 ICCM

make clean && make xm-build COV=1 TEST=$1 BOOT_MODE=QSPI

python3 test_status.py $1 QSPI

