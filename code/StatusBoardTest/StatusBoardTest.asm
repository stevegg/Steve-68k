    include "../shared/defines.asm"


DELAYAMT    EQU $6000           

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

    move.w  #$0000, d5          ; RESET D5 to 0

CONTINUE:    

    move.l  #DELAYAMT-1, d0     ; Setup Delay

DELAY:

    dbf     d0, DELAY           ; Are we at zero? If not do it again
    
    move.w  d5, STATUSOUT       ; Put the value in D5 into the STATUSOUT
    add.w   #$0001, d5          ; Increment D5
    cmp.w   #$FFFF, d5
    
    beq.l   START               ; Reached the end reset
    bra.b   CONTINUE            ; Do next iteration

;***************************************************************************
; Exception handlers   
GENERIC_HANDLER:
    bra GENERIC_HANDLER
    rte

;*********************************
; Strings
;

    END    START            * last line of source

