rm *.rom
echo Splitting binary file into Odd/Even files
srec_cat -output RAMTest_even.rom -Binary RAMTest2.bin -Binary -Split 2 0
srec_cat -output RAMTest_odd.rom -Binary RAMTest2.bin -Binary -Split 2 1
