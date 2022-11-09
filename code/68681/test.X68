*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
RAMBASE     equ     $E00000            ; Base address for RAM
ROMTESTER   equ     $800000
DELAYAMT    equ     $1000               ; Delay size

    ORG    $1000
START:                  ; first instruction of program
    lea.l   ROMTESTER,a0
    
MAIN_OUTER_LOOP:
    move.b  #$00,d0
    
MAIN_LOOP:
    cmp.b   #$FF,d0     ; does D0 equal 10?
    beq     MAIN_OUTER_LOOP
    addi    #1,d0       ; increment D0
    
DELAY:
    move.l  #DELAYAMT,d1
    moveq.l #1,d2
LOOP: 
    sub.l   d2,d1       ; 6 cycles for Dn.l->Dn.l
    bne.s   LOOP        ; 10 cycles for branch    
    
    bra     MAIN_LOOP   ; go back and loop


    ; SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
