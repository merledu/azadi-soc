#/////////////////////////////////////////////////////////////////////////////////////////////////////
# Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
#                                                                                                   //
# Engineers:      Auringzaib Sabir - Verification                                                   //
#                                                                                                   //
# Additional contributions by:                                                                      //
#                                                                                                   //
# Create Date:    09-JAN-2022                                                                       //
# Design Name:    AZADI CORE                                                                        //
# Module Name:    all_args_rand_test.py                                                             //
# Project Name:   Verification of RISC-V BASED CORE - AZADI                                         //
# Language:       Python & YAML                                                                     //
#                                                                                                   //
# Description:                                                                                      //
#         This python code randomize the run time arguments that are present in                     //
#         all_args_rand_test.yaml. RISC-V instruction generator uses these run time arguments       //
#         to generate different kinds of instruction. Furthermore UVM Random test are running on    //
#         random test seed.                                                                         //
#                                                                                                   //
#         How to run?                                                                               //
#         Go to path ../azadi-verify/env/core/vendor/core_ibex/riscv_dv_extension                   //
#         Excecute the following command                                                            //
#         python3 all_args_rand_test.py                                                             //
#                                                                                                   //
# Revision Date:                                                                                    //
#                                                                                                   //
#/////////////////////////////////////////////////////////////////////////////////////////////////////


from random import randint
import os
# print(__file__)
ROOT_DIR = os.path.realpath(os.path.join(os.path.dirname(__file__), ".."))
print("ROOT_DIR =", ROOT_DIR)

def search_multiple_strings_in_file(file_name, list_of_strings):
    """Get line from the file along with line numbers, which contains any string from the list"""
    print("\n======================================================================")
    print("Randomly setting run time options of risc-V isa instruction generating")
    print("======================================================================")
    line_number = 0
    list_of_results = []
    # Open the file in read only mode
    with open(file_name, 'r') as read_obj:
        # Read all lines in the file one by one
        for line in read_obj:
            line_number += 1
            # For each line, check if line contains any string from the list of strings
            for string_to_search in list_of_strings:
                #print (list_of_strings [0])
                if string_to_search in line:
                    Setting_argument = string_to_search
                    #print ('Setting_Argument  =     ', Setting_argument)
                    
                    # Assignation of all argument used
                    #print('instr_count', instr_count)
                    instr_count = "+instr_cnt"
                    num_of_sub_program = "+num_of_sub_program"
                    num_of_tests = "+num_of_tests"
                    enable_unaligned_load_store = "+enable_unaligned_load_store"
                    no_ebreak = "+no_ebreak"
                    no_wfi = "+no_wfi"
                    set_mstatus_tw = "+set_mstatus_tw"
                    no_dret = "+no_dret"
                    no_branch_jump = "+no_branch_jump"
                    no_csr_instr = "+no_csr_instr"
                    enable_illegal_csr_instruction = "+enable_illegal_csr_instruction"
                    enable_access_invalid_csr_level = "+enable_access_invalid_csr_level"
                    enable_misaligned_instr = "+enable_misaligned_instr"
                    no_fence = "+no_fence"
                    disable_compressed_instr = "+disable_compressed_instr"
                    illegal_instr_ratio = "+illegal_instr_ratio"
                    enable_interrupt = "+enable_interrupt"
                    enable_timer_irq = "+enable_timer_irq"
                    enable_ebreak_in_debug_rom = "+enable_ebreak_in_debug_rom"
                    set_dcsr_ebreak = "+set_dcsr_ebreak"
                    enable_debug_single_step = "+enable_debug_single_step"
                    enable_floating_point = "+enable_floating_point"
                    no_load_store = "+no_load_store"
                    fix_sp = "+fix_sp"
                    set_mstatus_mprv = "+set_mstatus_mprv"
                    no_data_page = "+no_data_page"


                    if str(Setting_argument) == instr_count:
                       value = '    +instr_cnt=' + str(randint(2000,8000))    
                       replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == num_of_sub_program:
                         value = '    +num_of_sub_program=' + str(randint(0,10))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == num_of_tests:
                         value = '    +num_of_tests=' + str(randint(1,200))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_unaligned_load_store:
                         value = '    +enable_unaligned_load_store=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_ebreak:
                         value = '    +no_ebreak=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_wfi:
                         value = '    +no_wfi=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == set_mstatus_tw:
                         value = '    +set_mstatus_tw=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_dret:
                         value = '    +no_dret=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_branch_jump:
                         value = '    +no_branch_jump=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_csr_instr:
                         value = '    +no_csr_instr=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_illegal_csr_instruction:
                         value = '    +enable_illegal_csr_instruction=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_access_invalid_csr_level:
                         value = '    +enable_access_invalid_csr_level=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_misaligned_instr:
                         value = '    +enable_misaligned_instr=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_fence:
                         value = '    +no_fence=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == disable_compressed_instr:
                         value = '    +disable_compressed_instr=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == illegal_instr_ratio:
                         value = '    +illegal_instr_ratio=' + str(randint(1,50))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_interrupt:
                         value = '    +enable_interrupt=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_timer_irq:
                         value = '    +enable_timer_irq=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_ebreak_in_debug_rom:
                         value = '    +enable_ebreak_in_debug_rom=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == set_dcsr_ebreak:
                         value = '    +set_dcsr_ebreak=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_debug_single_step:
                         value = '    +enable_debug_single_step=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == enable_floating_point:
                         value = '    +enable_floating_point=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_load_store:
                         value = '    +no_load_store=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == fix_sp:
                         value = '    +fix_sp=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == set_mstatus_mprv:
                         value = '    +set_mstatus_mprv=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    elif str(Setting_argument) == no_data_page:
                         value = '    +no_data_page=' + str(randint(0,1))    
                         replace_line('all_args_rand_test.yaml', line_number, value)
                    else:
                    	  print('Comparison FAILED for ',Setting_argument)
	                  
	            # If any string is found in line, then append that line along with line number in list
                    list_of_results.append((string_to_search, line_number, line.rstrip()))
    # Return list of tuples containing matched string, line numbers and lines where string is found
    return list_of_results
    
def replace_line(file_name, line_num, text):
		lines = open(file_name, 'r').readlines()
		lines[line_num-1] = text+"\n"
		out = open(file_name, 'w')
		out.writelines(lines)
		print('Modified_Argument = ', lines[line_num-1])
		out.close()

def copy_in_latest_test():
     import os
     import time
     import operator
     import shutil
     alist={}
     now = time.time()
     path = ROOT_DIR+"/out"
     print("path=",path)
     directory=os.path.join("/home",path)
     os.chdir(directory)
     for file in os.listdir("."):
         if os.path.isdir(file):
            timestamp = os.path.getmtime( file )
            # get timestamp and directory name and store to dictionary
            alist[os.path.join(os.getcwd(),file)]=timestamp
     # sort the timestamp 
     for i in sorted(alist.items(), key=operator.itemgetter(1)):
         latest="%s" % ( i[0])
     # latest=sorted(alist.iteritems(), key=operator.itemgetter(1))[-1]
     print ("newest directory is ", latest)
     os.chdir(latest)
     # For copying the all_args_rand_test.yaml in the latest out/seed directory made for specific test
     src_path = ROOT_DIR+"/riscv_dv_extension/all_args_rand_test.yaml"
     dst_path = latest + "/all_args_rand_test.yaml"
     print ("src_path = " , src_path)
     print ("dst_path = " , dst_path)
     shutil.copy(src_path, dst_path)
     print('Copied "all_args_rand_test.yaml"')
     # For copying the run_test.py in the latest out/seed directory made for specific test
     src_path = ROOT_DIR+"/riscv_dv_extension/run_test.py"
     dst_path = latest + "/run_test.py"
     print ("src_path = " , src_path)
     print ("dst_path = " , dst_path)
     shutil.copy(src_path, dst_path)
     print('Copied "run_test.py"')

def main():
    matched_lines = search_multiple_strings_in_file('all_args_rand_test.yaml', ['+instr_cnt', '+num_of_sub_program', '+num_of_tests' , '+num_of_tests', '+num_of_sub_program', '+instr_cnt', '+enable_unaligned_load_store', '+no_ebreak', '+no_wfi', '+set_mstatus_tw', '+no_dret', '+no_branch_jump', '+no_csr_instr', '+enable_illegal_csr_instruction', '+enable_access_invalid_csr_level', '+enable_misaligned_instr', '+no_fence', '+disable_compressed_instr', '+illegal_instr_ratio', '+enable_interrupt', '+enable_timer_irq', '+enable_ebreak_in_debug_rom', '+set_dcsr_ebreak', '+enable_debug_single_step', '+enable_floating_point', '+no_load_store', '+fix_sp', '+set_mstatus_mprv', '+no_data_page'])
    print('Total Matched lines : ', len(matched_lines))
    for elem in matched_lines:
        print('Word = ', elem[0], ' :: Line Number = ', elem[1], ' :: Line = ', elem[2])
        #value = '    +instr_cnt=' + str(randint(0,10))
        #replace_line('all_args_rand_test.yaml', elem[1],value)
    
    test_list = ROOT_DIR+"/riscv_dv_extension/all_args_rand_test.yaml"
    print("testlist=",test_list)
    cmd = "make TEST=all_args_rand_test ITERATIONS=1 "+"TESTLIST="+test_list+" ISA=rv32imfdc COV=1 WAVES=1"
    print("Command to run = ", cmd)


    # Changing directory to execute the 'make command'
    print("Printing Current working directory")
    print (os.getcwd())
    change_path = ROOT_DIR+"/"
    os.chdir(change_path)
    print("Changed directory is")
    print (os.getcwd())
    os.system(cmd)

    copy_in_latest_test()

if __name__ == '__main__':
    main()  



