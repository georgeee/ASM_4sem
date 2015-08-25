#!/bin/bash

# Small script, that takes asm file path as argument, compiles it in it's directory and launches


asm_file="$1"

yasm -g dwarf2 -f elf "$asm_file"
