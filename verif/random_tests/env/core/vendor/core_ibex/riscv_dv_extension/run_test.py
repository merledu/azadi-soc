#/////////////////////////////////////////////////////////////////////////////////////////////////////
# Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
#                                                                                                   //
# Engineers:      Auringzaib Sabir - Verification                                                   //
#                                                                                                   //
# Additional contributions by:                                                                      //
#                                                                                                   //
# Create Date:    11-JAN-2022                                                                       //
# Design Name:    AZADI CORE                                                                        //
# Module Name:    run_test.py                                                                       //
# Project Name:   Verification of RISC-V BASED CORE - AZADI                                         //
# Language:       Python & YAML                                                                     //
#                                                                                                   //
# Description:                                                                                      //
#        This run_test.py python code is used to re-run the UVM constraint random test with         //
#        the previous values of run time arguments of the RISC-V instruction generator and on a     //
#        specific test-seed                                                                         //
#                                                                                                   //
#        How to run?                                                                                //
#        Go to path ../azadi-verify/env/core/vendor/core_ibex/riscv_dv_extension                    //
#        Excecute the following command                                                             //
#        python3 run_test.py <any previously run test seed>                                         //
#                                                                                                   //
# Revision Date:                                                                                    //
#                                                                                                   //
#/////////////////////////////////////////////////////////////////////////////////////////////////////

from random import randint
import os
import sys

# print(__file__)
ROOT_DIR = os.path.realpath(os.path.join(os.path.dirname(__file__), ".."))
print("ROOT_DIR =", ROOT_DIR)

def main():
    seed = sys.argv
    print ("Seed from the command line = ", seed[1])
    test_list = ROOT_DIR+"/out/seed-"+str(seed[1])+"/all_args_rand_test.yaml"
    print("test_list=",test_list)
    cmd = "make TEST=all_args_rand_test ITERATIONS=1 "+"TESTLIST="+test_list+" SEED="+str(seed[1])+" ISA=rv32imfdc COV=1 WAVES=1"
    print("Command to run = ", cmd)

    # Changing directory to execute the 'make command'
    print("Printing Current working directory")
    print (os.getcwd())
    change_path = ROOT_DIR+"/"
    os.chdir(change_path)
    print("Changed directory is")
    print (os.getcwd())
    os.system(cmd)
if __name__ == '__main__':
    main()

