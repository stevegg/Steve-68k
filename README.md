# Steve's 68k

![Steve 68k](./Steve%2068k.png?raw=true "Steve 68k")

This is my extremely simple 68000 single board computer.  It has 512k of ROM and 512k of RAM.

## What's the Point?

I'm building this to learn the fundamentals of microprocessors and their use in computer systems.  Modern day computers are complex and require specific supporting chip sets.  These retro processors were simple and much easier to understand but in the end the principles are the same.


This design **HEAVILLY** borrows from [Neil Klingensmith](https://neilklingensmith.com/teaching/68khomebrew/) whose explanations really helped me grasp some of the fundamentals.

V20220621 was sent for fab on the evening of June 21, 2022.  This version's changes:
- 5v input via Barrel Plug and uses a 7805 to regulate the voltage
- Changes from 1.8432Mhz Clock Oscillator to a 3.6864Mhz for the UART CLK
- Added pull-up resistors for the DTACK input lines to the GAL
- Added an ERROR indicator LED and ERROR output line to the BUS
- Changed Serial connectors to standard FTDDI connector layout
- Added RTS and CTS lines to Serial connector pulled from the IP and OP ports on the 68681
- Fixed D0 label on BUS (was A0)
- Added A17 and A18 to the GAL to allow for more fine grained address decoding
- Other minor fixes

Still having a problem with serial input....challenges are what make the victory sweeter I suppose.

[![Schematic](/steve%2068k%20schematic.png?raw=true)](https://github.com/stevegg/Steve-68k/blob/master/Steve%2068k.pdf?raw=true)
