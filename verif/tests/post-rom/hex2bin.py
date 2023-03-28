# Copyright MERL contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Description: 
# Converts hex output from objcopy command into plain hex and binary into separate files.

import shutil

fd_hex = open("test.hex", "r")
fd_bin = open("rom.bin", "w")
fd_hex_word = open("rom.hex", "w")

current_word = ''

def hextobin(h):
  return bin(int(h, 16))[2:].zfill((len(h)-1) * 4)

for hexline in fd_hex:
  if (hexline[0] != "@"):
    line = hexline
    line_len = len(line)
    for word in line.split():
      current_word = word + current_word

len_cw = len(current_word)
x = int(len_cw/8)

for n in range(x-1):
  word = current_word[(len_cw-8):len_cw] + "\n"
  len_cw = len_cw-8
  fd_hex_word.write(word)
  fd_bin.write(hextobin(word) + "\n")

fd_bin.close()
