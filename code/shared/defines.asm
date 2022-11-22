;***************************************************************************
; Memory Map

ROMBASE             EQU     $000000     ; Base address for ROM space
RAMBASE             EQU     $E00000     ; Base address for RAM
RAMLIMIT            EQU     $F00000     ; Limit of onboard RAM
IOSEL               EQU     $F80000     ; IO Area
DUART               EQU     $F84001     ; DUART memory location
STATUSOUT           EQU     $FC0000     ; Status Board area

;***************************************************************************
; 68681 Duart Register Addresses 
;

DUART_MRA           EQU DUART           ; Mode Register Port A
DUART_SRA           EQU DUART+2         ; Status Register Port A (read only).
DUART_CSRA          EQU DUART+2         ; Clock Select Register Port A (write only)
DUART_CRA           EQU DUART+4         ; Commands Register Port A (write only)
DUART_RBA           EQU DUART+6         ; Receiver Buffer Port A (read only)
DUART_TBA           EQU DUART+6         ; Transmitter Buffer Port A (write only)
DUART_ACR           EQU DUART+8         ; Auxiliary Control Register
DUART_ISR           EQU DUART+10        ; Interrupt Status Register (read only)
DUART_IMR           EQU DUART+10        ; Interrupt Mask Register (write only)
DUART_MRB           EQU DUART+16        ; Mode Register Port B
DUART_SRB           EQU DUART+18        ; Status Register Port B (read only).
DUART_CSRB          EQU DUART+18        ; Clock Select Register Port B (write only)
DUART_CRB           EQU DUART+20        ; Commands Register Port B (write only)
DUART_RBB           EQU DUART+22        ; Receiver Buffer Port B (read only)
DUART_TBB           EQU DUART+22        ; Transmitter Buffer Port B (write only)
DUART_IVR           EQU DUART+24        ; Interrupt Vector Register

****************************************************************************
* ASCII Control Characters
*
BEL                 EQU $07
BKSP                EQU $08             ; CTRL-H
TAB                 EQU $09
LF                  EQU $0A
CR                  EQU $0D
ESC                 EQU $1B

CTRLC	            EQU	$03     
CTRLX	            EQU	$18             ; Line Clear

****************************************************************************
* Errors
*

NO_DUART_ERR        EQU $0F00

GENERIC_ERR         EQU $F000
BUS_ERR             EQU $F001
ADDR_ERR            EQU $F002
ILL_INSTRUCTION_ERR EQU $F003
DIVIDE_BY_ZERO_ERR  EQU $F004
CHK_INSTR_ERR       EQU $F005
PRIV_VIOL_ERR       EQU $F006
FORMAT_ERR          EQU $F007
SPUR_INT_ERR        EQU $F008
UNINIT_VECT_ERR     EQU $F009

****************************************************************************
* Other Status out values
*
TRAP_13             EQU $A000
TRAP_14             EQU $A001
TRAP_15             EQU $A002
