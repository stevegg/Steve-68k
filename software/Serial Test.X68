*********************************
* 68681 Duart Register Addresses
*
DUART       equ $100000         * DUART base address
DUART_MRA   equ DUART+0         * Mode Register A           (R/W)
DUART_MRA2  equ DUART+0         * Mode Register A           (R/W)
DUART_SRA   equ DUART+1         * Status Register A         (r)
DUART_CSRA  equ DUART+1         * Clock Select Register A   (w)
DUART_CRA   equ DUART+2         * Commands Register A       (w)
DUART_RBA   equ DUART+3         * Receiver Buffer A         (r)
DUART_TBA   equ DUART+3         * Transmitter Buffer A      (w)
DUART_ACR   equ DUART+4         * Aux. Control Register     (R/W)
DUART_ISR   equ DUART+5         * Interrupt Status Register (R)
DUART_IMR   equ DUART+5         * Interrupt Mask Register   (W)
DUART_MRB   equ DUART+8         * Mode Register B           (R/W)
DUART_SRB   equ DUART+9         * Status Register B         (R)
DUART_CSRB  equ DUART+9         * Clock Select Register B   (W)
DUART_CRB   equ DUART+10        * Commands Register B       (W)
DUART_RBB   equ DUART+11        * Reciever Buffer B         (R)
DUART_TBB   equ DUART+11        * Transmitter Buffer B      (W)
DUART_IVR   equ DUART+12        * Interrupt Vector Register (R/W)
DUART_OPCR  equ DUART+13        * Output port Configuration (W)
DUART_OPBSC equ DUART+14        * Output port Bit Set Cmd   (W)
DUART_OPBRC equ DUART+15         * Output port Bit Reset Cmd (W)

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
    jsr     initDuart           * Setup the serial port
    lea     msgBanner, A0       * Show our banner
    bsr.w   printString
loop:
    bsr.w   inChar              * Read a character from the serial port into d0
    bsr.w   outChar             * Write the character to the serial port
    jmp loop
    
******
* Prints a newline (CR, LF)
printNewline:
    lea     msgNewline, a0
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
    

*****
* Writes a character to Port A, blocking if not ready (Full buffer)
*  - Takes a character in D0
outChar:
    btst    #2, DUART_SRA       * Check if transmitter ready bit is set
    beq     outChar             * Not ready, try again
    move.b  d0, DUART_TBA       * Transmit Character
    rts

*****
* Reads in a character from Port A, blocking if none available
*  - Returns character in D0
*    
inChar:
    move.b  DUART_SRA, d0       * Check if there's something to read
    btst.l  #0, d0              * RxRDY flag bit set?
    beq     inChar              * Nope, try again
    move.b  DUART_RBA, d0       * Read Character into D0
    andi.b  #$7F, d0            * Clear MSb of character
    rts
        
    
*****
* Initializes the 68681 DUART port A(1) as 19200 8N1 
initDuart:
    move.b  #$30, DUART_CRA       * Reset Port A transmitter   
    move.b  #$20, DUART_CRA       * Reset Port A receiver
    move.b  #$10, DUART_CRA       * Reset Port A MR (mode register) pointer

    MOVE.B  #$80, DUART_ACR       * Select baud rate set 2    move.b  #$CC, DUART_CSRA      * Set both Rx, Tx speeds to 19200 baud
    move.b  #$93, DUART_MRA       * Set port A to 8 bit character, no parity
                                  * Enable RxRTS output using MRA
    move.b  #$37, DUART_MRA2      * Select normal operating mode
                                  * TxRTS, TxCTS, one stop bit using MR2A   
    move.b  #$05, DUART_CRA       * Enable Port A transmitter and receiver
    
    rts    

**********************************
* Strings
*
msgBanner:
    dc.b CR,LF,'Steve''s 68000 SBC',CR,LF
    dc.b       '==================',CR,LF
    dc.b 'Type a character and it should echo back', CR, LF, CR, LF, 0
    
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
