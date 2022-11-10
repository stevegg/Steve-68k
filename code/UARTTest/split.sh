#!/bin/sh
rm *.rom
echo Splitting binary file into Odd/Even files
srec_cat -output UARTTest_even.rom -Binary UARTTest.bin -Binary -Split 2 0
srec_cat -output UARTTest_odd.rom -Binary UARTTest.bin -Binary -Split 2 1
