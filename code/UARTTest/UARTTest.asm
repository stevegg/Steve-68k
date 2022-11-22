    include "../shared/defines.asm"

    ORG $0000

VECTORS:
    DC.L    RAMLIMIT            ; 00: Stack
    DC.L    START               ; 01: Start
    DC.L    BUS_ERR_HANDLER     ; 02: Bus Error
    DC.L    ADDR_ERR_HANDLER    ; 03: Address Error
    DC.L    ILL_INSTR_HANDLER   ; 04: Illegal Instruction
    DC.L    DIV0_HANDLER        ; 05: Divide by Zero
    DC.L    CHK_INSTR_HANLDER   ; 06: CHK Instruction
    DC.L    GENERIC_HANDLER     ; 07: TRAPV Instruction
    DC.L    PRIV_VIOL_HANDLER   ; 08: Privilege Violation
    DC.L    GENERIC_HANDLER     ; 09: Trace
    DC.L    GENERIC_HANDLER     ; 0A: Line 1010 Emulator
    DC.L    GENERIC_HANDLER     ; 0B: Line 1111 Emulator
    DC.L    GENERIC_HANDLER     ; 0C: Reserved
    DC.L    GENERIC_HANDLER     ; 0D: Reserved
    DC.L    FORMAT_ERR_HANDLER  ; 0E: Format error (MC68010 Only)
    DC.L    UNITITVECT_HANDLER  ; 0F: Uninitialized Vector
    DCB.L   8,GENERIC_HANDLER   ; 10-17: Reserved
    DC.L    SPUR_INT_HANDLER    ; 18: Spurious Interrupt
    DCB.L   7,GENERIC_HANDLER   ; 19-1F: Level 1-7 Autovectors
    DCB.L   13,GENERIC_HANDLER  ; 20-2C: TRAP Handlers (unused)
    DC.L    TRAP_13_HANDLER     ; 2D: TRAP#13 handler (replaced later)
    DC.L    TRAP_14_HANDLER     ; 2E: TRAP#14 handler
    DC.L    TRAP_15_HANDLER     ; 2F: TRAP#15 handler (replaced later)
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

; Comment out the next line if you don't want to use the Status board
; USE_STATUS  EQU     1

    ifd USE_STATUS
    echo ""
    echo "------------------------------------------------"
    echo "----->         Using status board         <-----"
    echo "------------------------------------------------"
    echo ""
    else
    echo ""
    echo "------------------------------------------------"
    echo "----->       NOT Using status board       <-----"
    echo "------------------------------------------------"
    echo ""
    endif

;***************************************************************************
; Program Start
;***************************************************************************
START::

    ifd USE_STATUS
    move.w  #$0001, STATUSOUT   ; Output a 1 to the status output
    endif
    jsr     initDuart           ; Setup the serial port

    ifd USE_STATUS
    move.w  #$0005, STATUSOUT   ; Output a 2 to the status output
    endif

.loop:
    lea.l   msgBanner,A0        ; Show our banner
    bsr.w   printString




    ; jsr     inChar              ; Read a character and place in D0
    ; jsr     outChar             ; write the same character out from Do
    jmp     .loop             ; And do it again and again
    

SHOW_STAUTS:

    ifd USE_STATUS
    move.w d5, STATUSOUT
    endif
    rts

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
    btst    #2,DUART_SRA        ; Check if transmitter ready bit is set
    beq     outChar             ; Not ready, try again
    move.b  d0,DUART_TBA        ; Transmit Character
    rts

;***************************************************************************
; Reads in a character from Port A, blocking if none available
;  - Returns character in D0
;    
inChar:
    move.b  DUART_SRA,d0        ; Check if there's something to read
    btst.l  #0,d0               ; RxRDY flag bit set?
    beq     inChar              ; Nope, try again
    move.b  DUART_RBA,d0        ; Read Character into D0
    andi.b  #$7F,d0             ; Clear MSb of character
    rts
        
;***************************************************************************    
; Test for the presence of the 68681
testDuart:
    move.b  #0,D5               ; Indicate no MC68681 by default
    move.b  #$00,DUART_IMR      ; Mask Interrupts
    move.b  DUART_IVR,D0        ; Get IVR - Should be 0x0F at reset
    cmp.b   #$0F,D0  
    bne.s   done
    move.b  #$50,DUART_IVR      ; To further verify, try to set IVR
    move.b  DUART_IVR,D0        ; And then check it was set...
    cmp.b   #$50,D0             ; to 0x50.
    bne.s   done
    move.b  #1,D5               ; Set D5 to indicate to INITSDB that there's a DUART present...
done:    
    rts

;***************************************************************************
; Initializes the 68681 DUART port A(1) as 9600 8N1 

initDuart:    
    jsr testDuart;
    ifd USE_STATUS
    move.w  #$0002, STATUSOUT
    endif

    tst.b D5
    beq.s NO_DUART_HALT         ; No DUART

    ifd USE_STATUS
    move.w  #$0003, STATUSOUT
    endif

    move.b  #$30,DUART_CRA      ; Reset Port A transmitter   
    move.b  #$20,DUART_CRA      ; Reset Port A receiver
    move.b  #$10,DUART_CRA      ; Reset Port A MR (mode register) pointer

    ; Enable Hardware Flow Control version
;    move.b  #$60,DUART_ACR      ; Select baud rate set 2
;    move.b  #$BB,DUART_CSRA     ; Set both Rx, Tx speeds to 9600 baud
;    move.b  #$13,DUART_MRA      ; Set port A to 8 bit character, no parity
;                                ; Enable RxRTS output using MR1A
;    move.b  #$37,DUART_MRA      ; Select normal operating mode
                                ; TxRTS, TxCTS, one stop bit using MR2A

    ; Version of init without hardware flow control                                
    move.b  #$60,DUART_ACR      ; Select baud rate set 1
    move.b  #$BB,DUART_CSRA     ; Set both Rx, Tx speeds to 9600 baud
    move.b  #$13,DUART_MRA      ; Set port A to 8 bit character, no parity
    move.b  #$07,DUART_MRA      ; Select normal operating mode 

 
    move.b  #$05,DUART_CRA      ; Enable Port A transmitter and receiver

    ifd USE_STATUS
    move.w  #$0004, STATUSOUT
    endif

    rts    

NO_DUART_HALT:
    ifd USE_STATUS
    move.w #NO_DUART_ERR,STATUSOUT  ; ERROR No Duart detected
    endif
.loop:    
    bra .loop

;***************************************************************************
; Exception handlers   
GENERIC_HANDLER::
    ifd USE_STATUS
    move.w #GENERIC_ERR,STATUSOUT  ; Generic Error Handler
    endif
    bra GENERIC_HANDLER
    rte

BUS_ERR_HANDLER::                   ; 02: Bus Error
    ifd USE_STATUS
    move.w #BUS_ERR,STATUSOUT   ; Generic Error Handler
    endif
    bra BUS_ERR_HANDLER
    rte

ADDR_ERR_HANDLER::                  ; 03: Address Error
    ifd USE_STATUS
    move.w #ADDR_ERR,STATUSOUT  ; Generic Error Handler
    endif
    bra ADDR_ERR_HANDLER
    rte

ILL_INSTR_HANDLER::                 ; 04: Illegal Instruction
    ifd USE_STATUS
    move.w #ILL_INSTRUCTION_ERR,STATUSOUT  ; Generic Error Handler
    endif
    bra ILL_INSTR_HANDLER
    rte

DIV0_HANDLER::                      ; 05: Divide by Zero
    ifd USE_STATUS
    move.w #DIVIDE_BY_ZERO_ERR,STATUSOUT  ; Generic Error Handler
    endif
    bra DIV0_HANDLER
    rte

CHK_INSTR_HANLDER::                 ; 06: CHK Instruction
    ifd USE_STATUS
    move.w #CHK_INSTR_ERR,STATUSOUT  ; Generic Error Handler
    endif
    bra CHK_INSTR_HANLDER
    rte

PRIV_VIOL_HANDLER::                 ; 08: Privilege Violation
    ifd USE_STATUS
    move.w #PRIV_VIOL_ERR,STATUSOUT  ; Generic Error Handler
    endif
    bra PRIV_VIOL_HANDLER
    rte

FORMAT_ERR_HANDLER::                ; 0E: Format error (MC68010 Only)    
    ifd USE_STATUS
    move.w #FORMAT_ERR,STATUSOUT  ; Generic Error Handler
    endif
    bra FORMAT_ERR_HANDLER
    rte

SPUR_INT_HANDLER::
    ifd USE_STATUS
    move.w #SPUR_INT_ERR,STATUSOUT  ; Spurious Interrupt Error
    endif
    bra SPUR_INT_HANDLER
    rte

UNITITVECT_HANDLER::
    ifd USE_STATUS
    move.w #UNINIT_VECT_ERR,STATUSOUT  ; Uninitialized Vector Error
    endif
    bra UNITITVECT_HANDLER
    rte

TRAP_13_HANDLER::
    ifd USE_STATUS
    move.w #TRAP_13,STATUSOUT
    endif
    rte
TRAP_14_HANDLER::
    ifd USE_STATUS
    move.w #TRAP_14,STATUSOUT
    endif
    rte
TRAP_15_HANDLER::  
    ifd USE_STATUS
    move.w #TRAP_15,STATUSOUT
    endif
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

