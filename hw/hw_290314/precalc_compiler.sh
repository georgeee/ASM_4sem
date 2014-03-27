#!/bin/bash
echo -n "   pow10: db " > precalc.txt ; for i in {38..0}; do pow10=1`j=0;while [ $j -lt $i ]; do echo -n '0';j=$(($j+1));done`; echo -n $(./generator "" -`./hex_printer $pow10`); echo -n ", "; done |head -c -2 >> precalc.txt
