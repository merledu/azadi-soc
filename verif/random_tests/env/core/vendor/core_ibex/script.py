# ////////////////////////////////////////////////////////////////////////////////////////////////////
# Company:        MICRO-ELECTRONICS RESEARCH LABORATORY                                             //
#                                                                                                   //
# Engineers:      Auringzaib Sabir - Verification Engineer                                          //
#                                                                                                   //
# Additional contributions by:                                                                      //
#                                                                                                   //
# Create Date:    07-August-2022                                                                    //
# Design Name:    SWERV and AZADI core Verfication                                                  //
# Module Name:    script.py                                                                         //
# Project Name:   Regression and aggregate coverages                                                //
# Language:       Python                                                                            //
#                                                                                                   //
# Description:                                                                                      //
#             This python script is used to run the regression and automate the dumping of tests    //
# results in a single files present at path "./out/test_results.txt". This script also automated the//
# coverages collection and merge the coverage result of all the tests that are run under regression //
# and creates a merged coverage file at path "out/cov_work/scope/coverage_all".                     //
#                                                                                                   //
# How to run?                                                                                       //
#                                                                                                   //
# Important:                                                                                        //
#          Add the names of all the tests in the file "./riscv_dv_extension/testlist.txt" that      //
# should be included in regression run.                                                             //
#                                                                                                   //
# Excecute the following command to run the regression and aggregate coverages                      //
# >> python3 regression_aggregate_coverages.py                                                      //
#                                                                                                   //
# NOTE:                                                                                             //
# This script has a 'regression_aggregate_coverages.py' on the top of it.                           //
# All tests are UVM constrained random tests generated by Google DV framework and run on a random   //
# seed value.                                                                                       //
#                                                                                                   //
# Revision Date:                                                                                    //
#                                                                                                   //
# ////////////////////////////////////////////////////////////////////////////////////////////////////

import os
import shutil
import random
import sys
import linecache
from pathlib import Path
from datetime import datetime
from glob import glob


# Setting relative path (__file__)
ROOT_DIR = os.path.realpath(os.path.join(os.path.dirname(__file__), ""))
OUT = "out"
now = datetime.now()  # current date and time
print("ROOT_DIR =", ROOT_DIR)


# This function execute the command on the shell terminal to run a particular test
def run_test(current_test):
    cmd = "make TEST=" + str(current_test)
    print("Command to run = ", cmd)
    os.system(cmd)


# This function generates a random number
def random_num():
    # using sys.maxsize
    long_int = sys.maxsize + 1
    # The data type is represented as int
    print("maxint + 1 :" + str(long_int) + " - " + str(type(long_int)))
    # Generating a random number within a min and max range
    rand = random.randint(1, 99999)
    return rand


# This function generates an 'OUT' directory and check if it already exits
def make_directory(make_dir):
    # Parent Directory path
    parent_dir = ROOT_DIR
    # Directory to create
    directory = make_dir
    # Create the directory
    if make_dir == OUT:
        # Complete of directory to be created
        path = os.path.join(parent_dir, directory)
        print("path of output directory =", path)
        # Check if directory already exist
        is_dir = os.path.isdir(path)
        print(is_dir)
        if is_dir == False:
            print("Directory for output '% s' created" % directory)
            os.mkdir(path)
        else:
            print("Directory for output '% s' already exist" % directory)
    else:
        # Complete of directory to be created
        # path = parent_dir + "/out/" + directory
        path = os.path.join(parent_dir, directory)
        print("path=", path)
        # Check if directory already exist
        is_dir = os.path.isdir(path)
        print(is_dir)
        if is_dir == False:
            print("Directory for Seed '% s' created" % directory)
            os.makedirs(path)
        else:
            print("Directory for Seed '% s' already exist" % directory)
            shutil.rmtree(path)


# This function execute the command on the shell terminal
def run_make():
    cmd = "make run_py"
    print("Command to run = ", cmd)
    os.system(cmd)


# This function finds the latest directory
def find_latest_dir():
    # imports
    import os
    import time
    import operator
    import shutil

    alist = {}
    now = time.time()
    path = ROOT_DIR + "/" + OUT
    print("path=", path)
    directory = os.path.join("/home", path)
    os.chdir(directory)
    for file in os.listdir("."):
        if os.path.isdir(file):
            timestamp = os.path.getmtime(file)
            # get timestamp and directory name and store to dictionary
            alist[os.path.join(os.getcwd(), file)] = timestamp
    # sort the timestamp
    for i in sorted(alist.items(), key=operator.itemgetter(1)):
        latest = "%s" % (i[0])
    # latest=sorted(alist.iteritems(), key=operator.itemgetter(1))[-1]
    print("newest directory is ", latest)
    return latest


# This function copies the given 'file' into the given 'destination directory' from the 'given source directory'
def copy_files(src_dir, dst_dir, copy_file):
    # For copying the all_args_rand_test.yaml in the latest out/seed directory made for specific test
    src_file_path = src_dir + "/" + copy_file
    dst_file_path = dst_dir + "/" + copy_file
    print("src_file_path = ", src_file_path)
    print("dst_file_path = ", dst_file_path)
    shutil.copy(src_file_path, dst_file_path)
    print("Copied file")


# This function is use to find a string in a particular file
def find_string(string_to_find, in_file):
    # opening a text file
    file = open(in_file, "r")
    # read file content
    readfile = file.read()
    # checking condition for string found or not
    if string_to_find in readfile:
        print("String", string_to_find, "Found In File")
        return 1
    else:
        print("String", string_to_find, "Not Found")
        return 0
    # closing a file
    file.close()


# This function create a file, if it does not exist
def create_file_if_does_exist(file_path):
    path_to_file = file_path
    print(path_to_file)
    path = Path(path_to_file)

    if path.is_file():
        print(f"The file {path_to_file} exists")
    else:
        print(f"The file {path_to_file} does not exist")
        open(path_to_file, "w")
        print(f"Created a file at path {path_to_file}")


# This function copy the content of src file into dst file on condition if dst file is empty
def check_file_size():
    first_file = ROOT_DIR + "/riscv_dv_extension/testlist.txt"
    second_file = ROOT_DIR + "/riscv_dv_extension/running_testlist.txt"
    if os.stat(second_file).st_size == 0:
        print("File is empty")
        with open(first_file) as f:
            with open(second_file, "w") as f1:
                for line in f:
                    f1.write(line)
    else:
        print("File is not empty")


# This function read the first line of a file and return its value as a string
def read_first_line():
    file_path = ROOT_DIR + "/riscv_dv_extension/running_testlist.txt"
    with open(file_path, "r+") as file:
        first_line = file.readline()
    # print(first_line)
    return first_line


# This function deletes the first line
def delete_first_line():
    file_path = ROOT_DIR + "/riscv_dv_extension/running_testlist.txt"
    with open(file_path, "r+") as fp:
        # read an store all lines into list
        lines = fp.readlines()
        # move file pointer to the beginning of a file
        fp.seek(0)
        # truncate the file
        fp.truncate()
        # start writing lines except the first line
        # lines[1:] from line 2 to last line
        fp.writelines(lines[1:])


# This function process the given directory(latest directory), and check if the test passed or not
# and uses the dump_results function to dump the result in a single file
def process_sub_dir(sub_directorires, current_test, current_seed):
    # Path to the regr.log for specific item(seed directory)
    path = sub_directorires + "/" + "regr.log"
    file_path = ROOT_DIR + "/" + OUT + "/test_results.txt"
    if os.path.isfile(path):
        # Print path to log file
        print("Processing file = ", path)
        # file a string in log file to check either test pased or not
        test_status = find_string("[PASSED]:", path)
        # Dump results
        dump_results(test_status, current_test, file_path, current_seed)
        # Print Test status
        if test_status == 1:
            print("TEST PASSED")
        else:
            print("TEST FAILED")
    else:
        print("Log file in", path, " does not exist")


# This function dumps the test result in a "test_result.txt" file, with its seed value, test name, time and test status
def dump_results(test_status, current_test, file_path, current_seed):
    # If the test pass
    if test_status == 1:
        create_file_if_does_exist(file_path)
        time = now.strftime("%H:%M:%S")
        file_name = ROOT_DIR + "/" + OUT + "/test_results.txt"
        print("file name =", file_name)
        lines = no_of_lines(file_name)
        print("Number of lines in /test_results = ", lines)
        string_exist = find_string(current_test, file_name)
        print("String Exist value = ", string_exist)
        if string_exist == 1:
            print("YES! STRING EXIST")
            # using reversed() to perform the back iteration
            for lines in reversed(range(lines + 1)):
                print(" number = ", lines)
                # string to search in file
                print("Printing word to be found =", current_test)
                # read specific line
                line = linecache.getline(file_name, lines)
                print("Printing the line = ", line)
                found_text = line.find(
                    current_test
                )  # if word found then reponse is != -1:
                print("Printing a found text = ", found_text)

                # check if string present on a current line
                if found_text != -1:
                    # print(current_test, "string exists in line")
                    # print("Line Number:", lines.index(line))
                    # print("Line:", line)
                    lines = lines - 1
                    print("Final lines = ", lines)
                    break

        write_data = (
            "Test status: Passed   |   "
            + time
            + "   |   "
            + "Seed "
            + current_seed
            + "   |   "
            + current_test
        )

        f = open(file_name, "r")
        contents = f.readlines()
        print("Print Contents = ", contents)
        f.close()
        contents.insert(lines + 1, write_data)
        f = open(file_name, "w")
        contents = "".join(contents)
        f.write(contents)
        f.close()
    # If the test fails
    else:
        create_file_if_does_exist(file_path)
        time = now.strftime("%H:%M:%S")
        file_name = ROOT_DIR + "/" + OUT + "/test_results.txt"
        print("file name =", file_name)
        lines = no_of_lines(file_name)
        print("Number of lines in /test_results = ", lines)

        string_exist = find_string(current_test, file_name)
        print("String Exist value = ", string_exist)

        if string_exist == 1:
            print("YES! STRING EXIST")
            # using reversed() to perform the back iteration
            for lines in reversed(range(lines + 1)):
                print(" number = ", lines)
                # string to search in file
                print("Printing word to be found =", current_test)
                # read specific line
                line = linecache.getline(file_name, lines)
                print("Printing the line = ", line)
                found_text = line.find(
                    current_test
                )  # if word found then reponse is != -1:
                print("Printing a found text = ", found_text)

                # check if string present on a current line
                if found_text != -1:
                    # print(current_test, "string exists in line")
                    # print("Line Number:", lines.index(line))
                    # print("Line:", line)
                    lines = lines - 1
                    print("Final lines = ", lines)
                    break

        write_data = (
            "Test status: Failed   |   "
            + time
            + "   |   "
            + "Seed "
            + current_seed
            + "   |   "
            + current_test
        )

        f = open(file_name, "r")
        contents = f.readlines()
        print("Print Contents = ", contents)
        f.close()
        contents.insert(lines + 1, write_data)
        f = open(file_name, "w")
        contents = "".join(contents)
        f.write(contents)
        f.close()


# This function search for a string in specific file
def find_line(search_string, file_path):
    word = search_string
    print("Finding line in file = ", file_path)
    # with open(file_path, "r") as fp:
    fp = open(file_path, "r")
    # read all lines in a list
    lines = fp.readlines()
    for line in lines:
        # check if string present on a current line
        if line.find(word) != -1:
            print(word, "string exists in file")
            print("Line Number:", lines.index(line))
            print("Line:", line)


# This function counts the number of lines in a file and return its value
def no_of_lines(file_name):
    fp = open(file_name, "r")
    lines = len(fp.readlines())
    # print("Total lines:", lines)
    print("Total number of test_results = ", lines)
    return lines


# This function finds the seed value using the find_latest_dir function and return it
def find_seed():
    strValue = find_latest_dir()
    ch = ""
    # Remove all characters after the character '-' from string
    before, sep, after = strValue.partition("seed-")
    print("Seed = ", after)
    return after


# This function finds the aggregated coverage and dumps the merged result file in "./out/cov_work" directory
def aggregate_coverages(current_test, current_seed):
    latest_directory = find_latest_dir()
    # Find all the sub directories, print them and perform operation on them
    # Path to the main diectory
    path_to_out_directory = ROOT_DIR + "/" + OUT
    path_to_out_seeds = ROOT_DIR + "/" + OUT + "/seed"
    print("path_to_out_seeds", path_to_out_seeds)
    # list the sub directories and assigning that list as a parameter
    sub_directories = os.listdir(path_to_out_directory)
    # print the sub directory
    print("List of sub directories = ", sub_directories)

    # processing a specific directory one by one in a list
    merge_ucd_directories_sting = ""
    for file in os.listdir(path_to_out_directory):
        # path to to processing seed directory
        strValue = path_to_out_directory + "/" + file
        before, sep, after = strValue.partition("seed")
        path_seed_dir_check = before + sep
        print("path_seed_dir_check = ", path_seed_dir_check)
        # print("print my string value string =", strValue)
        if path_to_out_seeds == path_seed_dir_check:
            directory = os.path.join(path_to_out_directory, file)
            # print("directory", directory)
            # find path to test directory in a seed directory e.g ./out/seed-23981/rtl_sim/<specific_test>.0/scope/test
            file_path = directory + "/rtl_sim" + "/*/"
            cov_directory = glob(file_path, recursive=True)
            ucd_file_dir = cov_directory[1] + "scope/test"
            if os.path.isdir(ucd_file_dir):
                print("ucd_file_dir", ucd_file_dir)
                merge_ucd_directories_sting += ucd_file_dir + " "
    print("merge_ucd_directories_sting = ", merge_ucd_directories_sting)
    # Command to excecute on terminal - Avoid changing the below command
    cmd = (
        "imc -execcmd "
        + "'"
        + "merge "
        + merge_ucd_directories_sting
        + " -overwrite -out coverage_all"
        + "'"
    )
    print("Command to run = ", cmd)
    os.system(cmd)


# Main function
def main():
    # run_test_list = ROOT_DIR + "/riscv_dv_extension/testlist.txt"
    # total_regr_test = no_of_lines(run_test_list)
    # for x in range(total_regr_test):
    file_name = ROOT_DIR + "/riscv_dv_extension/running_testlist.txt"
    create_file_if_does_exist(file_name)
    check_file_size()
    current_test = read_first_line()
    print("Current test " + current_test)
    delete_first_line()
    # Running test on random seed
    run_test(current_test)
    # Finding a latest directory in output directory
    latest_dir = find_latest_dir()
    current_seed = find_seed()
    print(current_seed)
    # Process the latest directory
    process_sub_dir(latest_dir, current_test, current_seed)
    # Coverages
    aggregate_coverages(current_test, current_seed)


if __name__ == "__main__":
    main()