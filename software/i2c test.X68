*********************************
* I2C Port
SERIAL_OUT  equ $180000
SERIAL_IN   equ $180001
I2C_OUT     equ $180002
I2C_IN      equ $180003

**********************************
* ASCII Control Characters
*
BEL   equ $07
BKSP  equ $08       * CTRL-H
TAB   equ $09
LF    equ $0A
CR    equ $0D
ESC   equ $1B

CTRLC	EQU	$03     
CTRLX	EQU	$18     * Line Clear

    ORG    $0000
    
**** FIRST 8 bytes loaded after reset ****
    DC.l    STACK_START         * Supervisor stack pointer
    DC.l    START               * Initial PC  

    ORG $500    
START:                  
    lea     STACK_START, SP     * Set our stack pointer to be sure
    jsr     init                * Initialize everything
    bsr.s   delay               * Delay while other things are setting up

    lea     msgBanner, A0       * Show our banner
    bsr.w   printString
loop:
    jmp loop
    
delay:
    move.l  #$100,d0
    moveq.l #1,d1
 dloop:
    sub.l   d1,d0        ; 6 cycles for Dn.l->Dn.l
    bne.s   dloop         ; 10 cycles for branch
       
******
* Print a null terminated string
*
printString:
 .loop:
    move.b  (a0)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.s   outChar      * Otherwise write the character
    bra.s   .loop        * And continue
 .end:
    rts
    
******
* Print a hex byte
*  - Takes byte in D0
printHexByte:
    move.l  D2, -(SP)
    move.b  D0, D2
    lsr.b   #$4, D0
    add.b   #'0', D0
    cmp.b   #'9', D0     * Check if the hex number was from 0-9
    ble.s   .second
    add.b   #7, D0       * Shift 0xA-0xF from ':' to 'A'
.second:
    bsr.s   outChar      * Print the digit
    andi.b  #$0F, D2     * Now we want the lower digit Mask only the lower digit
    add.b   #'0', D2
    cmp.b   #'9', D2     * Same as before    
    ble.s   .end
    add.b   #7, D2
.end:
    move.b  D2, D0
    bsr.s   outChar      * Print the lower digit
    move.l  (SP)+, D2
    rts

*****
* Writes a character to the serial port
outChar:
    move.b d0, SERIAL_OUT    
    rts

*****
* Reads in a character from the serial port
*    
inChar:
    move.b  SERIAL_IN, d0       * Check if there's something to read
    rts
    
*****
* Initializes everything
*
init:

    bsr.s   initSerial
    bsr.s   initDisplay
    
    rts    
    
initSerial:
    rts
    
initDisplay:
    rts
    

**********************************
* Strings
*
msgBanner:
    dc.b CR,LF,'Steve''s 68000 SBC', CR, LF, 0
   
msgNewline:
    dc.b CR,LF,0

    ORG $100000
STACK_START:

    END    START            * last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
