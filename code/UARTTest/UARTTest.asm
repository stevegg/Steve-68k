;***************************************************************************
; Memory Map

ROMBASE     equ     $000000     ; Base address for ROM space
STATUSOUT   equ     $800000     ; Address of Status Output Board
RAMBASE     equ     $E00000     ; Base address for RAM
RAMLIMIT    equ     $F00000     ; Limit of onboard RAM
DUART       equ     $F00001     ; DUART memory location

;***************************************************************************
; 68681 Duart Register Addresses
;

MRA         EQU DUART           ; Mode Register Port A
SRA         EQU DUART+2         ; Status Register Port A (read only).
CSRA        EQU DUART+2         ; Clock Select Register Port A (write only)
CRA         EQU DUART+4         ; Commands Register Port A (write only)
RBA         EQU DUART+6         ; Receiver Buffer Port A (read only)
TBA         EQU DUART+6         ; Transmitter Buffer Port A (write only)
ACR         EQU DUART+8         ; Auxiliary Control Register
ISR         EQU DUART+10        ; Interrupt Status Register (read only)
IMR         EQU DUART+10        ; Interrupt Mask Register (write only)
MRB         EQU DUART+16        ; Mode Register Port B
SRB         EQU DUART+18        ; Status Register Port B (read only).
CSRB        EQU DUART+18        ; Clock Select Register Port B (write only)
CRB         EQU DUART+20        ; Commands Register Port B (write only)
RBB         EQU DUART+22        ; Receiver Buffer Port B (read only)
TBB         EQU DUART+22        ; Transmitter Buffer Port B (write only)
IVR         EQU DUART+24        ; Interrupt Vector Register

****************************************************************************
* ASCII Control Characters
*
BEL         equ $07
BKSP        equ $08             ; CTRL-H
TAB         equ $09
LF          equ $0A
CR          equ $0D
ESC         equ $1B

CTRLC	    EQU	$03     
CTRLX	    EQU	$18             ; Line Clear

    ORG $0000

VECTORS:
    DC.L    RAMLIMIT            ; 00: Stack
    DC.L    START               ; 01: Start
    DC.L    GENERIC_HANDLER     ; 02: Bus Error
    DC.L    GENERIC_HANDLER     ; 03: Address Error
    DC.L    GENERIC_HANDLER     ; 04: Illegal Instruction
    DC.L    GENERIC_HANDLER     ; 05: Divide by Zero
    DC.L    GENERIC_HANDLER     ; 06: CHK Instruction
    DC.L    GENERIC_HANDLER     ; 07: TRAPV Instruction
    DC.L    GENERIC_HANDLER     ; 08: Privilege Violation
    DC.L    GENERIC_HANDLER     ; 09: Trace
    DC.L    GENERIC_HANDLER     ; 0A: Line 1010 Emulator
    DC.L    GENERIC_HANDLER     ; 0B: Line 1111 Emulator
    DC.L    GENERIC_HANDLER     ; 0C: Reserved
    DC.L    GENERIC_HANDLER     ; 0D: Reserved
    DC.L    GENERIC_HANDLER     ; 0E: Format error (MC68010 Only)
    DC.L    GENERIC_HANDLER     ; 0F: Uninitialized Vector
    DCB.L   8,GENERIC_HANDLER   ; 10-17: Reserved
    DC.L    GENERIC_HANDLER     ; 18: Spurious Interrupt
    DCB.L   7,GENERIC_HANDLER   ; 19-1F: Level 1-7 Autovectors
    DCB.L   13,GENERIC_HANDLER  ; 20-2C: TRAP Handlers (unused)
    DC.L    GENERIC_HANDLER     ; 2D: TRAP#13 handler (replaced later)
    DC.L    GENERIC_HANDLER     ; 2E: TRAP#14 handler
    DC.L    GENERIC_HANDLER     ; 2F: TRAP#15 handler (replaced later)
    DCB.L   16,GENERIC_HANDLER  ; 30-3F: Remaining Reserved vectors
    DCB.L   4,GENERIC_HANDLER   ; 40-43: MFP GPIO #0-3 (Not used)
    DC.L    GENERIC_HANDLER     ; 44: MFP Timer D (Interrupt not used)
    DC.L    GENERIC_HANDLER     ; 45: MFP Timer C (System tick)
    DCB.L   2,GENERIC_HANDLER   ; 46-47: MFP GPIO #4-5 (Not used)
    DC.L    GENERIC_HANDLER     ; 48: MFP Timer B (Not used)
    DC.L    GENERIC_HANDLER     ; 49: Transmitter error (Not used)
    DC.L    GENERIC_HANDLER     ; 4A: Transmitter empty (Replaced later)
    DC.L    GENERIC_HANDLER     ; 4B: Receiver error (Replaced later)
    DC.L    GENERIC_HANDLER     ; 4C: Receiver buffer full (Replaced later)
    DC.L    GENERIC_HANDLER     ; 4D: Timer A (Not used)
    DCB.L   2,GENERIC_HANDLER   ; 4E-4F: MFP GPIO #6-7 (Not used)
    DCB.L   176,GENERIC_HANDLER ; 50-FF: Unused user vectors
VECTORS_END:
VECTORS_COUNT   equ     256

;***************************************************************************
; Program Start
;***************************************************************************
START::
    jsr     initDuart           ; Setup the serial port
LOOP:    
    lea     msgBanner,A0        ; Show our banner
    bsr.w   printString
    bra.b   LOOP                ; And do it again and again
    
;***************************************************************************
; Prints a newline (CR, LF)
printNewline:
    lea     msgNewline,a0

;***************************************************************************
; Print a null terminated string
;
printString:
 .loop:
    move.b  (a0)+,d0            * Read in character
    beq.s   .end                * Check for the null
    
    bsr.s   outChar             * Otherwise write the character
    bra.s   .loop               * And continue
 .end:
    rts
    

;***************************************************************************
; Writes a character to Port A, blocking if not ready (Full buffer)
;  - Takes a character in D0
outChar:
    btst    #2,SRA              * Check if transmitter ready bit is set
    beq     outChar             * Not ready, try again
    move.b  d0,TBA              * Transmit Character
    rts

;***************************************************************************
; Reads in a character from Port A, blocking if none available
;  - Returns character in D0
;    
inChar:
    move.b  SRA,d0              * Check if there's something to read
    btst.l  #0,d0               * RxRDY flag bit set?
    beq     inChar              * Nope, try again
    move.b  RBA,d0              * Read Character into D0
    andi.b  #$7F,d0             * Clear MSb of character
    rts
        
;***************************************************************************    
; Test for the presence of the 68681
testDuart:
    move.b  #0,D5               ; Indicate no MC68681 by default
    move.b  #$00,IMR            ; Mask Interrupts
    move.b  IVR,D0              ; Get IVR - Should be 0x0F at reset
    cmp.b   #$0F,D0  
    bne.s   done
    move.b  #$50,IVR            ; To further verify, try to set IVR
    move.b  IVR,D0              ; And then check it was set...
    cmp.b   #$50,D0             ; to 0x50.
    bne.s   done
    move.b  #1,D5               ; Set D5 to indicate to INITSDB that there's a DUART present...
done:    
    rts

;***************************************************************************
; Initializes the 68681 DUART port A(1) as 9600 8N1 

initDuart:    
    jsr testDuart;
    tst.b D5
    beq.s NO_DUART_HALT         ; No DUART

    move.b  #$30,CRA            ; Reset Port A transmitter   
    move.b  #$20,CRA            ; Reset Port A receiver
    move.b  #$10,CRA            ; Reset Port A MR (mode register) pointer

    move.b  #$80,ACR            ; Select baud rate set 2
    move.b  #$BB,CSRA           ; Set both Rx, Tx speeds to 9600 baud
    move.b  #$13,MRA            ; Set port A to 8 bit character, no parity
    move.b  #$07,MRA            ; Select normal operating mode 
    move.b  #$05,CRA            ; Enable Port A transmitter and receiver
    rts    

NO_DUART_HALT:
    move.b #$FF,STATUSOUT
.loop:    
    bra .loop

;***************************************************************************
; Exception handlers   
GENERIC_HANDLER:
    bra GENERIC_HANDLER
    rte

;*********************************
; Strings
;
msgBanner:
    dc.b CR,LF,'Steve''s 68000',CR,LF
    dc.b       '==============',CR,LF,CR,LF,0
   
msgNewline:
    dc.b CR,LF,0

    END    START            * last line of source

