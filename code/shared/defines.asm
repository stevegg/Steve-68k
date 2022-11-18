;***************************************************************************
; Memory Map

ROMBASE     equ     $000000     ; Base address for ROM space
STATUSOUT   equ     $800000     ; Address of Status Output Board
RAMBASE     equ     $E00000     ; Base address for RAM
RAMLIMIT    equ     $F00000     ; Limit of onboard RAM
IOBASE      equ     $F80001     ; IO address space
DUART       equ     $F80001     ; DUART memory location

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