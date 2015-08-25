#!/bin/bash
gcc-4.6 -g -c main.c -m32 &&  ../compile_o.sh test1.asm  && gcc-4.6 -g main.o test1.o -m32 -o test
