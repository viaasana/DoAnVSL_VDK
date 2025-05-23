
ORG 0000H
JMP MAIN




ENGLISH_MODE BIT 20H.0	; 0: VIETNAM; 1:ENGLISH
SENSOR_VAL EQU 31h

	
ORG 003H
INTERUP:
    CPL ENGLISH_MODE     ; Toggle language bit
    JB ENGLISH_MODE, ENG ; If 1, English
    CALL VIE_MODE         ; Else, Vietnamese
    RETI
ENG:
    CALL ENG_MODE
    RETI

;+--------------------------+
;|							|
;|	FONT TABLE				|
;|							|
;+--------------------------+
ORG 1000H   
BIG_FONT_TABLE:
;; Each digit is 16 rows (DB) of 2 bytes each (10 pixels = 8 + 2)
; MSB is leftmost pixel, LSB is rightmost in each byte
;0
DB 0FEH, 1H, 1H, 1H, 1H, 1H, 1H, 1H, 1H,  0FEH
DB 3FH, 40H, 40H, 40H, 40H, 40H, 40H, 40H, 40H, 3FH
;1
DB 0H, 8H, 4H, 2H, 0FFH, 0FFH, 0H, 0H, 0H, 0H
DB 60H, 60H, 60H, 60H, 7FH, 7FH, 60H, 60H, 60H, 60H

;2
DB 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 7EH
DB 3FH, 40H, 40H,  40H,  40H,  40H,  40H,  40H,  40H,  40H

;3
DB 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 7EH
DB 40H, 40H,  40H,  40H,  40H,  40H,  40H,  40H,  40H, 3FH

;4
DB 0FFH, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 0FFH, 80H
DB 0H, 0H, 0H, 0H, 0H, 0H, 0H, 0H, 7FH, 0H

;5
DB 7EH, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H
DB 40H, 40H,  40H,  40H,  40H,  40H,  40H,  40H,  40H, 3FH

;6
DB 7EH, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H
DB 3FH, 40H,  40H,  40H,  40H,  40H,  40H,  40H,  40H, 3FH

;7
DB 0H, 0H, 0H, 1H, 1H, 1H, 1H, 1H, 0E1H, 1FH
DB 0H, 0H, 0H, 0H, 0H, 70H, 0CH, 03H, 0H, 0H

;8
DB 7EH, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 7EH
DB 3FH, 40H, 40H,  40H,  40H,  40H,  40H,  40H,  40H,  3FH

;9
DB 7EH, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 81H, 7EH
DB 0H, 40H, 40H,  40H,  40H,  40H,  40H,  40H,  40H,  3FH


;  5x7 font table (LSB at TOP)

; Character 'M'
FONT_M:     DB  7FH, 8H, 10H, 8H, 7FH


; Character '?' 
FONT_U_HORN_ACUTE: DB 3EH, 20H, 0A0H, 3DH, 3H

; Character 'c'
FONT_C:     DB  3Ch, 42h, 42h, 42h, 24h 

; Space character
FONT_SPACE: DB  00h, 00h, 00h, 00h, 00h  ; 

; Character 'n' 
FONT_N:     DB  7FH, 2H, 4H, 8H, 7FH

; Character 'u' 
FONT_U_HORN: DB 7CH, 40H, 40H, 7DH, 3H

; Character 'o' (o with horn)
FONT_O_HORN: DB 30H, 4AH, 49H, 48H, 36H 

FONT_W: DB 0FFH, 20H, 10H, 20H, 0FFH

FONT_a: DB 48H, 0A4H, 0A4H, 0A4H, 7CH

FONT_t: DB 8H, 7EH, 88H, 88H, 00H

FONT_e: DB 38H, 54H, 94H, 94H, 48H

FONT_r: DB 0FCH, 08H, 04H, 04H, 08H

FONT_L_UPPER: DB 0FFH, 80H, 80H, 80H, 80H

FONT_v: DB 38H, 40H, 80H, 40H, 38H

FONT_L: DB 82H, 82H, 0FEH, 80H, 80H







SDA    EQU P2.0
SCL    EQU P2.1

MAIN:	
	SETB EX0      ; Enable INT0
    SETB EA       ; Global interrupt enable
    SETB IT0      ; Edge triggered

    CLR ENGLISH_MODE	;DEFAULT AS VIETNAM
    ACALL OLED_INIT
    ACALL DELAY
    
	CALL VIE_MODE
	MOV R1, #45
    MOV R2, #3
	MOV A, SENSOR_VAL
	MOV R3, A
    ACALL DISPLAY_2DIGIT

HOLD_LOOP:
	CALL READ_SENSOR
	MOV A, SENSOR_VAL
	MOV R1, #45
    MOV R2, #3
	MOV R3, A
	ACALL DISPLAY_2DIGIT
	ACALL DELAY
	SJMP HOLD_LOOP
	
;--------------------
DELAY:
    MOV R7, #200
DLOOP1:
    MOV R6, #250
DLOOP2:
    DJNZ R6, DLOOP2
    DJNZ R7, DLOOP1
    RET

;--------------------
I2C_START:
    SETB SDA
    SETB SCL
    NOP
    CLR SDA
    CLR SCL
    RET

I2C_STOP:
    CLR SDA
    SETB SCL
    SETB SDA
    RET

I2C_WRITE:
    MOV R7, #8
I2C_WRITE_LOOP:
    RLC A
    JC SDA_HIGH
    CLR SDA
    SJMP SDA_DONE
SDA_HIGH:
    SETB SDA
SDA_DONE:
    NOP
    SETB SCL
    NOP
    CLR SCL
    DJNZ R7, I2C_WRITE_LOOP

    ; Check ACK
    SETB SDA
    SETB SCL
    MOV C, SDA
    CLR SCL
    RET

;--------------------
OLED_COMMAND:
    CALL I2C_START
    MOV A, #078H       ; I2C address: 0x3C << 1 = 0x78
    CALL I2C_WRITE
    MOV A, #080H       ; Co=1, D/C#=0 (command)
    CALL I2C_WRITE
    MOV A, R4
    CALL I2C_WRITE
    CALL I2C_STOP
    RET

OLED_DATA:
    CALL I2C_START
    MOV A, #078H       ; I2C address: 0x3C << 1 = 0x78
    CALL I2C_WRITE
    MOV A, #0C0H       ; Co=0, D/C#=1 (data)
    CALL I2C_WRITE
    MOV A, R4
    CALL I2C_WRITE
    CALL I2C_STOP
    RET

;--------------------
OLED_INIT:
    MOV R4, #0AEH      ; Display OFF
    CALL OLED_COMMAND

    MOV R4, #0A6H      ; Normal display
    CALL OLED_COMMAND

    MOV R4, #040H      ; Display start line = 0
    CALL OLED_COMMAND

    MOV R4, #020H      ; Set memory addressing mode
    CALL OLED_COMMAND
    MOV R4, #000H      ; Horizontal addressing
    CALL OLED_COMMAND

    MOV R4, #21H       ; Set column address
    CALL OLED_COMMAND
    MOV R4, #00H       ; Start
    CALL OLED_COMMAND
    MOV R4, #7FH       ; End (127)
    CALL OLED_COMMAND

    MOV R4, #22H       ; Set page address
    CALL OLED_COMMAND
    MOV R4, #00H       ; Start
    CALL OLED_COMMAND
    MOV R4, #07H       ; End
    CALL OLED_COMMAND

    MOV R4, #0AFH      ; Display ON
    CALL OLED_COMMAND

    RET


SET_COLUMN:
    MOV A, R0           ; R0 holds column value (0–127)
    ANL A, #0FH         ; Keep lower 4 bits
    ORL A, #00H         ; Lower column bits (0x00 – 0x0F)
    MOV R4, A
    ACALL OLED_COMMAND

    MOV A, R0
    ANL A, #0F0H         ; Upper 4 bits
    SWAP A              ; Shift upper nibble to lower
    ORL A, #10H         ; 0x10 is the upper column address command
    MOV R4, A
    ACALL OLED_COMMAND
    RET

SET_PAGE:
    MOV A, R0           ; R0 holds page number (0–7)
    ADD A, #0B0H        ; Page base address
    MOV R4, A
    CALL OLED_COMMAND
    RET
;--------------------
OLED_CLEAR:
    MOV R1, #8         ; 8 pages
FILL_PAGE:
    MOV A, R1
    MOV R0, A
    ACALL SET_PAGE
    MOV R0, #0
    ACALL SET_COLUMN
    MOV R2, #130       ; 128 columns
    MOV R4, #00H      ; Fill white (all pixels ON)
FILL_COLUMN:
    CALL OLED_DATA
    DJNZ R2, FILL_COLUMN
    DJNZ R1, FILL_PAGE
    RET

;------------
TEXT_VIE:
	MOV DPTR, #FONT_M
	ACALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_U_HORN_ACUTE
	ACALL DRAW_TEXT
	
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_C
	ACALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #10
	MOV R1, A
	MOV DPTR, #FONT_N
	ACALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_U_HORN
	ACALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_O_HORN
	ACALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_C
	ACALL DRAW_TEXT
      
      
	RET
    
    
    
DRAW_TEXT:
     ; Input: R1 = Column, R2 = Starting Page,DPTR= Poit to memory that storing the font
	MOV A, R1
	MOV R0, A
	ACALL SET_COLUMN
     
	MOV A, R2
	MOV R0, A
	ACALL SET_PAGE
	
	MOV R3, #5
DRAW_TEXT_LOOP:
	CLR A
	MOVC A, @A+DPTR
	MOV R4, A
	ACALL OLED_DATA
	INC DPTR
	DJNZ R3, DRAW_TEXT_LOOP
	RET
	
	
TEXT_ENG:
	; Input: R1 = Column, R2 = Starting Page
	MOV DPTR, #FONT_W
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_a
	CALL DRAW_TEXT
	
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_t
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #5
	MOV R1, A
	MOV DPTR, #FONT_e
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_r
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #10
	MOV R1, A
	MOV DPTR, #FONT_L_UPPER
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_e
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_v
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_e
	CALL DRAW_TEXT
      
	MOV A, R1
	ADD A, #6
	MOV R1, A
	MOV DPTR, #FONT_L
	CALL DRAW_TEXT

      
      
      RET



;---------------------------
DISPLAY_BIG_DIGIT:
    ; Input: R1 = Column, R2 = Starting Page, R3 = Digit (0-9)

    ; Calculate font data offset
     MOV A, R3
     MOV B, #20
     MUL AB 

     MOV DPTR, #BIG_FONT_TABLE
     ADD A, DPL
     MOV DPL, A
     MOV A, DPH
     ADDC A, #0
     MOV DPH, A
     
     
     MOV A, R1
     MOV R0, A
     CALL SET_COLUMN
     
     MOV A, R2
     MOV R0, A
     CALL SET_PAGE
     
     MOV R7, #10		; DISPLAY FIRST 10 BYTES 
HIGHTS_BYTES:
      PUSH 7
      MOV A, R7
      CLR A
      MOVC A, @A+DPTR
      MOV R4, A
      CALL OLED_DATA
      INC DPTR
      POP 7
      DJNZ R7, HIGHTS_BYTES
      
      MOV A, R1
      MOV R0, A
      CALL SET_COLUMN
      MOV A, R2
      INC A
      MOV R0, A
      CALL SET_PAGE
      
      
      MOV R7, #10
LOW_BYTES:
     PUSH 7
      MOV A, R7
      CLR A
      MOVC A, @A+DPTR
      MOV R4, A
      CALL OLED_DATA
      INC DPTR
      POP 7
      DJNZ R7, LOW_BYTES
	RET



;-------------------
DISPLAY_2DIGIT:
    MOV A, R3
    MOV B, #10
    DIV AB           ; A = tens, B = units

    MOV 32h, A       ; store tens digit in internal RAM 30h
    MOV 33h, B       ; store units digit in internal RAM 31h

    ; Display Tens Digit
    MOV R3, 32h
    ACALL DISPLAY_BIG_DIGIT

    ; Adjust X position for units digit
    MOV A, R1
    ADD A, #20
    MOV R1, A

    ; Display Units Digit
    MOV R3, 33h
    ACALL DISPLAY_BIG_DIGIT
    RET

;-------------------
; 	read sensor
READ_SENSOR:
	CLR P0.0		; CS = 0
	CLR P0.2		; WR = 0
	SETB P0.2		; WR = 1 -> Start conversion

WAIT_INTR:
	JNB P0.3, READ_ADC
	SJMP WAIT_INTR


READ_ADC:
	CLR P0.1		; RD = 0
	MOV R0, P1		; Read ADC value

	; Scale the value
	MOV A, R0
	MOV B, #10
	MUL AB
	ACALL SHIFTRIGHT6
	
	MOV SENSOR_VAL, R0	; Store result
	SETB P0.1			; RD = 1 (end read)
	RET

; Divide A*B by 64
SHIFTRIGHT6:
	MOV R0, A
	MOV R1, B
	MOV R2, #6
SHIFT_LOOP:
	CLR C
	MOV A, R1
	RRC A
	MOV R1, A

	MOV A, R0
	RRC A
	MOV R0, A

	DJNZ R2, SHIFT_LOOP
	RET


;-----------------------
;	DISPLAY IN VIETNAMESE MODE
VIE_MODE:
	ACALL OLED_CLEAR
	MOV R1, #40
	MOV R2, #1
    CALL TEXT_VIE
	RET
;-----------------------
;	DISPLAY IN ENGLISH MODE
ENG_MODE:
	ACALL OLED_CLEAR
	MOV R1, #35
	MOV R2, #1
	CALL TEXT_ENG
	RET
END
