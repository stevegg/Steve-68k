; DUART DEFINITIONS
DUART   EQU $60000
MRA     EQU DUART+0
MRA2    EQU DUART+0
SRA     EQU DUART+2
CSRA    EQU DUART+2
CRA     EQU DUART+4
RBA     EQU DUART+6
TBA     EQU DUART+6
ACR     EQU DUART+8
ISR     EQU DUART+10
IMR     EQU DUART+10

LF      equ $0A
CR      equ $0D

    ORG    $0000

    DC.l    STACK_START         * Supervisor stack pointer
    DC.l    START               * Initial PC  

    ORG $400    
START:                  
    lea     STACK_START, SP     * Set our stack pointer to be sure
    jsr     initDuart           * Setup the serial port
    lea     msgBanner, A0       * Show our banner
loop:
    bsr.w   printString
    ; bsr.l   inChar              * Read a character from the serial port into d0
    ; bsr.l   outChar             * Write the character to the serial port
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
    btst    #2, SRA     * Check if transmitter ready bit is set
    beq     outChar     * Not ready, try again
    move.b  d0, TBA     * Transmit Character
    rts

*****
* Reads in a character from Port A, blocking if none available
*  - Returns character in D0
*    
inChar:
    move.b  SRA, d0     * Check if there's something to read
    btst.l  #0, d0      * RxRDY flag bit set?
    beq     inChar      * Nope, try again
    move.b  RBA, d0     * Read Character into D0
    andi.b  #$7F, d0    * Clear MSb of character
    rts    

*****
* Initializes the 68681 DUART port A(1) as 19200 8N1 
initDuart:
    move.b  #$30, CRA   * Reset Port A transmitter   
    move.b  #$20, CRA   * Reset Port A receiver
    move.b  #$10, CRA   * Reset Port A MR (mode register) pointer

    MOVE.B  #$80, ACR   * Select baud rate set 2
    move.b  #$CC, CSRA  * Set both Rx, Tx speeds to 19200 baud
    move.b  #$93, MRA   * Set port A to 8 bit character, no parity
                        * Enable RxRTS output using MRA
    move.b  #$37, MRA2  * Select normal operating mode
                        * TxRTS, TxCTS, one stop bit using MR2A   
    move.b  #$05, CRA   * Enable Port A transmitter and receiver
    
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

    ORG $20000
STACK_START:

    END    START            * last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
