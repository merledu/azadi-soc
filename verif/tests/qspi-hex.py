# Copyright MERL contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Description: 
# Converts hex output from objcopy command into plain hex and binary into separate files.

from sys import argv

hexfile = argv[1]

fd_hex = open(hexfile, "r")

current_word = ''

for hexline in fd_hex:
  if (hexline[0] != "@"):
    line = hexline
    line_len = len(line)
    for word in line.split():
      current_word = word + current_word

len_cw = len(current_word)
word_len = int(len_cw/8)
x = 8

instr = ''
word = ''

for i in range(word_len-1):
  for n in range(4):
    word = current_word[(len_cw-2):len_cw] + " " + word
    len_cw = len_cw - 2
  word = word + "\n"
  instr = instr+word
  word = ''


with open("../template.vmf" , "r") as temp_file:
  buf = temp_file.readlines()

with open("mem_Q128_bottom.vmf", "w") as flash_mem_file:
  for line in buf:
    if line == "00 00 00 13\n":
      line = line + instr
    flash_mem_file.write(line)