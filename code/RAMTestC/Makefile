all:	demo.run

demo.run: demo.c
	m68k-elf-gcc -Wall -m68010 -msoft-float -c demo.c
	m68k-elf-ld --defsym=_start=main -Ttext=0x0000 -Tdata=0x1000 -Tbss=0x2000 --section-start=.rodata=0x5000 demo.o `m68k-elf-gcc -m68010 -print-libgcc-file-name`
	m68k-elf-objcopy -I elf32-m68k -O srec a.out demo.run

demo.s: demo.c
	m68k-elf-gcc -Wall -nostdlib -nodefaultlibs -m68010 -S demo.c
clean:
	$(RM) a.out demo.o demo.run demo.s