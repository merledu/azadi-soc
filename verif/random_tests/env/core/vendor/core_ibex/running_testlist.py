import os
import shutil
import random
import sys
from pathlib import Path


# Setting relative path (__file__)
ROOT_DIR = os.path.realpath(os.path.join(os.path.dirname(__file__), ""))
OUT = "out"


def create_file_if_does_exist():
    path_to_file = ROOT_DIR + "/riscv_dv_extension/running_testlist.txt"
    print(path_to_file)
    path = Path(path_to_file)

    if path.is_file():
        print(f"The file {path_to_file} exists")
    else:
        print(f"The file {path_to_file} does not exist")
        open(path_to_file, "w")
        print(f"Created a file at path {path_to_file}")


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


def read_first_line():
    file_path = ROOT_DIR + "/riscv_dv_extension/running_testlist.txt"
    with open(file_path, "r+") as file:
        first_line = file.readline()
    # print(first_line)
    return first_line


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


if __name__ == "__main__":
    create_file_if_does_exist()
    check_file_size()
    current_test = read_first_line()
    print("Current test " + current_test)
    delete_first_line()
