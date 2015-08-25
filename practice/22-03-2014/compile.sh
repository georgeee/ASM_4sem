#!/bin/bash
gcc-4.6 -c main.c -m32 &&  ../compile_o.sh test1.asm  &&gcc-4.6 main.o test1.o -m32 -o test
