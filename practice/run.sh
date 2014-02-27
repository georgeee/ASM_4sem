#!/bin/bash

# Small script, that takes asm file path as argument, compiles it in it's directory and launches


asm_file="$1"
out_file=`echo "$1"|sed 's/\.asm$/.out/'`
obj_file=`echo "$1"|sed 's/\.asm$/.o/'`

if [ "${out_file:0:1}" != '/' ] ; then out_file="./$out_file"; fi

yasm -f elf "$asm_file" && gcc-4.6 "$obj_file" -m32 -o "$out_file" && "$out_file" 
