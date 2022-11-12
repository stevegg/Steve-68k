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

DUART_MR1A        EQU DUART
DUART_MR2A        EQU DUART
DUART_SRA         EQU DUART+2         ; Status Register Port A (read only).
DUART_CSRA        EQU DUART+2         ; Clock Select Register Port A (write only)
DUART_CRA         EQU DUART+4         ; Commands Register Port A (write only)
DUART_RBA         EQU DUART+6         ; Receiver Buffer Port A (read only)
DUART_TBA         EQU DUART+6         ; Transmitter Buffer Port A (write only)
DUART_ACR         EQU DUART+8         ; Auxiliary Control Register
DUART_ISR         EQU DUART+10        ; Interrupt Status Register (read only)
DUART_IMR         EQU DUART+10        ; Interrupt Mask Register (write only)
DUART_CUR         EQU DUART+12
DUART_CTUR        EQU DUART+12
DUART_CLR         EQU DUART+14
DUART_CTLR        EQU DUART+14
DUART_MRB         EQU DUART+16        ; Mode Register Port B
DUART_SRB         EQU DUART+18        ; Status Register Port B (read only).
DUART_CSRB        EQU DUART+18        ; Clock Select Register Port B (write only)
DUART_CRB         EQU DUART+20        ; Commands Register Port B (write only)
DUART_RBB         EQU DUART+22        ; Receiver Buffer Port B (read only)
DUART_TBB         EQU DUART+22        ; Transmitter Buffer Port B (write only)
DUART_IVR         EQU DUART+24        ; Interrupt Vector Register
DUART_IP          EQU DUART+26
DUART_OPCR        EQU DUART+26
R_STARTCNTCMD     EQU DUART+28
W_OPR_SETCMD      EQU DUART+28
R_STOPCNTCMD      EQU DUART+30
W_OPR_RESETCMD    EQU DUART+30
    section .text                     ; This is normal code

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

START::

    move.b  #$0,DUART_IMR             ; Mask all interrupts
    move.b  #$93,DUART_MR1A           ; (Rx RTS, RxRDY, Char, No parity, 8 bits) 
    move.b  #$07,DUART_MR2A           ; (Normal, No TX CTS/RTS, 1 stop bit)

;    38400 working
    move.b  #$70,DUART_ACR           ; Set 0, Timer, X1/X2, /16
    move.b  #$CC,DUART_CSRA          ; 38K4

;    57600 working
;    move.b  #$60,DUART_ACR           ; Set 0, Counter, X1/X2, /16
;    move.b  #$DD,DUART_CSRA          ; Baud from timer
    
    ; 115200 working
;    move.b  #$60,DUART_ACR            ; Set 0, Counter, X1/X2, /16
;    move.b  DUART_CRA,D0              ; Enable undocumented rates
;    move.b  #$66,DUART_CSRA           ; 1200 per spec, uses counter instead

    move.b  #0,DUART_CUR              ; Counter high: 0 
    move.b  #2,DUART_CLR              ; Counter  low: 2  (115.2KHz) 
    move.b  R_STARTCNTCMD,D0          ; Start count

    move.b  #%00000011,DUART_OPCR     ; RxCA (1x) on OP2 
    move.b  #%00000101,DUART_CRA      ; Enable TX/RX

    ; TODO CTS/RTS Not yet working - figure out how to lower RTS!    
    move.b  #$ff,W_OPR_RESETCMD       ; Clear all OP bits (lower RTS)
    move.b  #0,W_OPR_SETCMD

    move.b  #'H',D0
    bsr.s   SENDCHAR
    move.b  #'e',D0
    bsr.s   SENDCHAR
    move.b  #'l',D0
    bsr.s   SENDCHAR
    move.b  #'l',D0
    bsr.s   SENDCHAR
    move.b  #'o',D0
    bsr.s   SENDCHAR
    move.b  #',',D0
    bsr.s   SENDCHAR
    move.b  #' ',D0
    bsr.s   SENDCHAR
    move.b  #'W',D0
    bsr.s   SENDCHAR
    move.b  #'o',D0
    bsr.s   SENDCHAR
    move.b  #'r',D0
    bsr.s   SENDCHAR
    move.b  #'l',D0
    bsr.s   SENDCHAR
    move.b  #'d',D0
    bsr.s   SENDCHAR
    move.b  #'!',D0
    bsr.s   SENDCHAR
    move.b  #13,D0
    bsr.s   SENDCHAR
    move.b  #10,D0
    bsr.s   SENDCHAR

.ECHOLOOP:
    bsr.s   RECVCHAR
    bsr.s   SENDCHAR
    bra.s   .ECHOLOOP

; Character in D0
SENDCHAR:
    btst.b  #3,DUART_SRA
    beq.s   SENDCHAR
    move.b  D0,DUART_TBA
    rts

; Result in D0
RECVCHAR:
    btst.b  #0,DUART_SRA
    beq.s   RECVCHAR
    move.b  DUART_RBA,D0
    rts

;***************************************************************************
; Exception handlers   
GENERIC_HANDLER:
    bra GENERIC_HANDLER
    rte