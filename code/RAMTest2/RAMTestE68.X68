*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
RAMBASE     equ     $E00000            ; Base address for RAM
RAMLIMIT    equ     $E0F000            ; Limit of onboard RAM
ROMBASE     equ     $000000            ; Base address for ROM space
ERRIND      equ     $F00000
TESTLIMIT   equ     $E0F000

    ORG    $1000
START:                  ; first instruction of program

MAIN_OUTER_LOOP:

    lea.l     RAMBASE,a0

MAIN_LOOP:

    clr.w   (a0)            ; Clear mem location
    tst.w   (a0)+           ; Check if mem location reads as zero
    beq     MOVE_ON         ; If zero, assume write bus cycle succeeded
    # sub     #$01,a0
    # clr.b   ERRIND
    
MOVE_ON:
    cmpa.l  #TESTLIMIT,a0
    blt.w   MAIN_LOOP
    bra.w   MAIN_OUTER_LOOP    
* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
