; Steve 68k RAM test


RAMBASE     equ     $E00000            ; Base address for RAM
RAMLIMIT    equ     $E0FFFF            ; Limit of onboard RAM
ROMBASE     equ     $000000            ; Base address for ROM space
ERRIND      equ     $F00000
TESTLIMIT   equ     $E00F00

    section .text

VECTORS:
    dc.l    RAMLIMIT                    ; 00: Stack (top of on-board RAM)
    dc.l    START                       ; 01: Initial PC (start of ROM code)
    dc.l    GENERIC_HANDLER             ; 02: Bus Error

    dc.l    GENERIC_HANDLER             ; 02: Bus Error
    dc.l    GENERIC_HANDLER             ; 03: Address Error
    dc.l    GENERIC_HANDLER             ; 04: Illegal Instruction
    dc.l    GENERIC_HANDLER             ; 05: Divide by Zero
    dc.l    GENERIC_HANDLER             ; 06: CHK Instruction
    dc.l    GENERIC_HANDLER             ; 07: TRAPV Instruction
    dc.l    GENERIC_HANDLER             ; 08: Privilege Violation
    dc.l    GENERIC_HANDLER             ; 09: Trace
    dc.l    GENERIC_HANDLER             ; 0A: Line 1010 Emulator
    dc.l    GENERIC_HANDLER             ; 0B: Line 1111 Emulator
    dc.l    GENERIC_HANDLER             ; 0C: Reserved
    dc.l    GENERIC_HANDLER             ; 0D: Reserved
    dc.l    GENERIC_HANDLER             ; 0E: Format error (MC68010 Only)
    dc.l    GENERIC_HANDLER             ; 0F: Uninitialized Vector

    dcb.l   8,GENERIC_HANDLER           ; 10-17: Reserved

    dc.l    GENERIC_HANDLER             ; 18: Spurious Interrupt

    dcb.l   7,GENERIC_HANDLER           ; 19-1F: Level 1-7 Autovectors
    dcb.l   13,GENERIC_HANDLER          ; 20-2C: TRAP Handlers (unused)
    dc.l    GENERIC_HANDLER             ; 2D: TRAP#13 handler (replaced later)
    dc.l    GENERIC_HANDLER             ; 2E: TRAP#14 handler
    dc.l    GENERIC_HANDLER             ; 2F: TRAP#15 handler (replaced later)
    dcb.l   16,GENERIC_HANDLER          ; 30-3F: Remaining Reserved vectors
    dcb.l   4,GENERIC_HANDLER           ; 40-43: MFP GPIO #0-3 (Not used)
    dc.l    GENERIC_HANDLER             ; 44: MFP Timer D (Interrupt not used)
    dc.l    GENERIC_HANDLER             ; 45: MFP Timer C (System tick)
    dcb.l   2,GENERIC_HANDLER           ; 46-47: MFP GPIO #4-5 (Not used)
    dc.l    GENERIC_HANDLER             ; 48: MFP Timer B (Not used)
    dc.l    GENERIC_HANDLER             ; 49: Transmitter error (Not used)
    dc.l    GENERIC_HANDLER             ; 4A: Transmitter empty (Replaced later)
    dc.l    GENERIC_HANDLER             ; 4B: Receiver error (Replaced later)
    dc.l    GENERIC_HANDLER             ; 4C: Receiver buffer full (Replaced later)
    dc.l    GENERIC_HANDLER             ; 4D: Timer A (Not used)
    dcb.l   2,GENERIC_HANDLER           ; 4E-4F: MFP GPIO #6-7 (Not used)
    dcb.l   176,GENERIC_HANDLER         ; 50-FF: Unused user vectors
VECTORS_END:
VECTORS_COUNT   equ     256

START::

MAIN_OUTER_LOOP:

    lea.l     RAMBASE,a0

MAIN_LOOP:

    clr.w   (a0)            ; Clear mem location
    tst.w   (a0)+           ; Check if mem location reads as zero
    beq     MOVE_ON         ; If zero, assume write bus cycle succeeded
    ; sub     #$01,a0
    ; clr.b   ERRIND
    
MOVE_ON:
    cmpa.l  #TESTLIMIT,a0
    blt.w   MAIN_LOOP
    bra.w   MAIN_OUTER_LOOP    

;------------------------------------------------------------
; Exception handlers   
GENERIC_HANDLER::
    bra GENERIC_HANDLER
    rte