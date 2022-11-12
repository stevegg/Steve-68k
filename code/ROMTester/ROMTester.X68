*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $0000

; Steve 68k ROM Tester


RAMBASE     equ     $E00000            ; Base address for RAM
RAMLIMIT    equ     $E0F000            ; Limit of onboard RAM
ROMBASE     equ     $000000            ; Base address for ROM space
ROMTESTER   equ     $800000
DELAYAMT    equ     $0500               ; Delay size

VECTORS:
    dc.l    RAMLIMIT                    ; 00: Stack (top of on-board RAM)
    dc.l    START                       ; 01: Initial PC (start of ROM code)
DC.L

    DC.L    GENERIC_HANDLER             ; 02: Bus Error
    DC.L    GENERIC_HANDLER             ; 03: Address Error
    DC.L    GENERIC_HANDLER             ; 04: Illegal Instruction
    DC.L    GENERIC_HANDLER             ; 05: Divide by Zero
    DC.L    GENERIC_HANDLER             ; 06: CHK Instruction
    DC.L    GENERIC_HANDLER             ; 07: TRAPV Instruction
    DC.L    GENERIC_HANDLER             ; 08: Privilege Violation
    DC.L    GENERIC_HANDLER             ; 09: Trace
    DC.L    GENERIC_HANDLER             ; 0A: Line 1010 Emulator
    DC.L    GENERIC_HANDLER             ; 0B: Line 1111 Emulator
    DC.L    GENERIC_HANDLER             ; 0C: Reserved
    DC.L    GENERIC_HANDLER             ; 0D: Reserved
    DC.L    GENERIC_HANDLER             ; 0E: Format error (MC68010 Only)
    DC.L    GENERIC_HANDLER             ; 0F: Uninitialized Vector

    DCB.L   8,GENERIC_HANDLER           ; 10-17: Reserved

    DC.L    GENERIC_HANDLER             ; 18: Spurious Interrupt

    DCB.L   7,GENERIC_HANDLER           ; 19-1F: Level 1-7 Autovectors
    DCB.L   13,GENERIC_HANDLER          ; 20-2C: TRAP Handlers (unused)
    DC.L    GENERIC_HANDLER             ; 2D: TRAP#13 handler (replaced later)
    DC.L    GENERIC_HANDLER             ; 2E: TRAP#14 handler
    DC.L    GENERIC_HANDLER             ; 2F: TRAP#15 handler (replaced later)
    DCB.L   16,GENERIC_HANDLER          ; 30-3F: Remaining Reserved vectors
    DCB.L   4,GENERIC_HANDLER           ; 40-43: MFP GPIO #0-3 (Not used)
    DC.L    GENERIC_HANDLER             ; 44: MFP Timer D (Interrupt not used)
    DC.L    GENERIC_HANDLER             ; 45: MFP Timer C (System tick)
    DCB.L   2,GENERIC_HANDLER           ; 46-47: MFP GPIO #4-5 (Not used)
    DC.L    GENERIC_HANDLER             ; 48: MFP Timer B (Not used)
    DC.L    GENERIC_HANDLER             ; 49: Transmitter error (Not used)
    DC.L    GENERIC_HANDLER             ; 4A: Transmitter empty (Replaced later)
    DC.L    GENERIC_HANDLER             ; 4B: Receiver error (Replaced later)
    DC.L    GENERIC_HANDLER             ; 4C: Receiver buffer full (Replaced later)
    DC.L    GENERIC_HANDLER             ; 4D: Timer A (Not used)
    DCB.L   2,GENERIC_HANDLER           ; 4E-4F: MFP GPIO #6-7 (Not used)
    DCB.L   176,GENERIC_HANDLER         ; 50-FF: Unused user vectors
VECTORS_END:
VECTORS_COUNT   equ     256    
    
START:                  ; first instruction of program

    lea.l   ROMTESTER,a0
    
MAIN_OUTER_LOOP:
    move.w  #$0000,d0
    
MAIN_LOOP:
    move.w  d0,(a0)
    cmp.w   #$FFFF,d0     ; does D0 equal 10?
    beq     MAIN_OUTER_LOOP
    addi    #1,d0       ; increment D0
    
DELAY:
    move.l  #DELAYAMT,d1
    moveq.l #1,d2
    
LOOP: 
    sub.l   d2,d1       ; 6 cycles for Dn.l->Dn.l
    bne.s   LOOP        ; 10 cycles for branch    
    bra     MAIN_LOOP   ; go back and loop
    
GENERIC_HANDLER:
    bra GENERIC_HANDLER
    rte    

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
