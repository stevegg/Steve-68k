;
; Homebrew 68k 68681 Test
; Copyright (C) 2021 Neil Klingensmith.  All Rights Reserved.
;
; Permission is hereby granted, free of charge, to any person obtaining a copy of
; this software and associated documentation files (the "Software"), to deal in
; the Software without restriction, including without limitation the rights to
; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
; the Software, and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
; FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
; IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
; https://neilklingensmith.com/teaching/68khomebrew/
;
; 1 tab == 4 spaces!




    ; 68681 REGISTER DEFINITIONS
USART_MRA        EQU $100000
USART_SRA        EQU $100001
USART_CSRA       EQU $100001
USART_BRG_TEST   EQU $100002
USART_CRA        EQU $100002
USART_RHRA       EQU $100003
USART_THRA       EQU $100003
USART_IPCR       EQU $100004
USART_ACR        EQU $100004
USART_ISR        EQU $100005
USART_IMR        EQU $100005
USART_CTU        EQU $100006
USART_CRUR       EQU $100006
USART_CTL        EQU $100007
USART_CTLR       EQU $100007
USART_MRB        EQU $100008
USART_SRB        EQU $100009
USART_CSRB       EQU $100009
USART_1XTEST     EQU $10000A
USART_CRB        EQU $10000A
USART_RHRB       EQU $10000B
USART_THRB       EQU $10000B
USART_IVR        EQU $10000C
USART_IP         EQU $10000D
USART_OPCR       EQU $10000D
USART_START_CTR  EQU $10000E
USART_SOPBC      EQU $10000E
USART_STOP_CTR   EQU $10000F
USART_RESET_OP   EQU $10000F

    ORG 0
; VECTOR TABLE
    DC.L STACK
    DC.L _START
    DC.L DUMMYHANDLER ; BUS ERROR
    DC.L DUMMYHANDLER ; ADDRESS ERROR
    DC.L DUMMYHANDLER ; ILLEGAL INSTRUCTION
    DC.L DUMMYHANDLER ; DIVIDE BY ZERO
    DC.L DUMMYHANDLER ; CHK EXCEPTION
    DC.L DUMMYHANDLER ; TRAPV
    DC.L DUMMYHANDLER ; PRIVILEGE VIOLATION
    DC.L DUMMYHANDLER ; TRACE
    DC.L DUMMYHANDLER ; LINE-A INSTRUCTION
    DC.L DUMMYHANDLER ; LINE-F INSTRUCTION
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; CO-PROCESSOR PROTOCOL VIOLATION
    DC.L DUMMYHANDLER ; FORMAT ERROR
    DC.L DUMMYHANDLER ; UNINITIALIZED INTERRUPT
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; RESERVED
    DC.L DUMMYHANDLER ; SPURIOUS INTERRUPT
    DC.L DUMMYHANDLER ; IRQ1
    DC.L DUMMYHANDLER ; IRQ2
    DC.L DUMMYHANDLER ; IRQ3
    DC.L DUMMYHANDLER ; IRQ4
    DC.L DUMMYHANDLER ; IRQ5
    DC.L DUMMYHANDLER ; IRQ6
    DC.L DUMMYHANDLER ; IRQ7
    DC.L DUMMYHANDLER ; TRAP 0
    DC.L DUMMYHANDLER ; TRAP 1
    DC.L DUMMYHANDLER ; TRAP 2
    DC.L DUMMYHANDLER ; TRAP 3
    DC.L DUMMYHANDLER ; TRAP 4
    DC.L DUMMYHANDLER ; TRAP 5
    DC.L DUMMYHANDLER ; TRAP 6
    DC.L DUMMYHANDLER ; TRAP 7
    DC.L DUMMYHANDLER ; TRAP 8
    DC.L DUMMYHANDLER ; TRAP 9
    DC.L DUMMYHANDLER ; TRAP 10
    DC.L DUMMYHANDLER ; TRAP 11
    DC.L DUMMYHANDLER ; TRAP 12
    DC.L DUMMYHANDLER ; TRAP 13
    DC.L DUMMYHANDLER ; TRAP 14
    DC.L DUMMYHANDLER ; TRAP 15
    
    ORG $500

_START:

    MOVEA.L #STACK,A7
    
    BSR INIT_68681


    PEA WELCOME_MSG
    BSR PUTS
    
MAIN_LOOP:
    ;PEA 'A'
    ;BSR PUTC
    ;ADDA.L #4,A7
    BSR GETC
    
    MOVE.L D0,-(A7)
    BSR PUTC
    ADDA.L #4,A7
    
    BRA MAIN_LOOP

INIT_68681:
    LINK A6,#0
    
    MOVEA.L #USART_MRA,A0             ; SET UP BASE ADDRESS OF UART IN A0
    MOVE.B #$20, 2(A0)                ; CRA: RESET RECEIVER
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    MOVE.B #$30, 2(A0)                ; CRA: RESET TRANSMITTER
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    MOVE.B #$40, 2(A0)                ; CRA: RESET ERROR STATUS
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    MOVE.B #$10, 2(A0)                ; CRA: RESET MODE REGISTER POINTER
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    MOVE.B #$13,(A0)                  ; 8 DATA BITS, NO PARITY
    MOVE.B #$07,(A0)                  ; NO FLOW CONTROL, 1 STOP BIT
    MOVE.B #$CC,1(A0)                 ; SELECT 19.2 KBAUD
    MOVE.B #$05,2(A0)                 ; CRA: ENABLE TX AND RX ON USART A
    MOVE.B #$10,4(A0)                 ; SET ACR[7] = 0 FOR BAUD RATE GEN.
    MOVE.B #$00,5(A0)                 ; IMR: DISABLE INTERRUPTS
    UNLK A6
    RTS

;
; |-----------------------|
; | CHARACTER TO TX       |
; |-----------------------|
; | RETURN ADDRESS        |
; |-----------------------|
; | CALLER'S LR           |
; |-----------------------|
;
PUTC:
    LINK A6,#0
    MOVEM.L D0/A0,-(A7)
    
    LEA USART_SRA,A0

PUTC_LOOP:
    MOVE.B (A0),D0         ; GET VAL OF SRA IN D0
    ANDI.L #4,D0           ; CHECK IF TxRDYA BIT IS SET
    BEQ PUTC_LOOP          ; IF NOT, KEEP CHECKING
    
    LEA USART_THRA,A0      ; GET TRANSMIT HOLDING REG ADDR IN A0
    MOVE.L 8(A6),D0        ; GET CHARACTER TO SEND IN D0
    MOVE.B D0,(A0)         ; SEND THE CHARACTER
    
    MOVEM.L (A7)+,D0/A0
    UNLK A6
    RTS

;
; |-----------------------|
; | CHARACTER TO TX       |
; |-----------------------|
; | RETURN ADDRESS        |
; |-----------------------|
; | CALLER'S LR           |
; |-----------------------|
;
GETC:
    LINK A6,#0
    MOVE.L A0,-(A7)

    LEA USART_SRA,A0

GETC_LOOP:
    MOVE.B (A0),D0         ; GET VAL OF SRA IN D0
    ANDI.L #1,D0           ; CHECK IF RxRDYA BIT IS SET
    BEQ GETC_LOOP          ; IF NOT, KEEP CHECKING
    
    LEA USART_RHRA,A0      ; GET TRANSMIT HOLDING REG ADDR IN A0
    MOVE.B (A0),D0         ; SEND THE CHARACTER
    ANDI.L #$FF,D0

    MOVE.L (A7)+,A0
    UNLK A6
    RTS

;
; |-----------------------|
; | STRING PTR            |
; |-----------------------|
; | RETURN ADDRESS        |
; |-----------------------|
; | CALLER'S LR           |
; |-----------------------|
;
PUTS:
    LINK A6,#0
    MOVEM.L D0/A0,-(A7)

    MOVE.L 8(A6),A0        ; GET CHARACTER TO SEND IN D0
    
PUTS_LOOP:

    MOVE.B (A0)+,D0
    BEQ PUTS_DONE
    ANDI.L #$FF,D0
    MOVE.L D0,-(A7)
    BSR PUTC
    ADDA.L #4,A7
    BRA PUTS_LOOP

PUTS_DONE:

    MOVEM.L (A7)+,D0/A0
    UNLK A6
    RTS



DUMMYHANDLER:

    RTE
    


WELCOME_MSG:
    DC.B $D, $A, $D, $A
    DC.B 'WELCOME TO 68K HOMEBREW!!', $D, $A, 0




    ORG $100000
STACK:

    END _START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
