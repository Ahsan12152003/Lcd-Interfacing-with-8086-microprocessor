; 8086 Assembly Code for Interfacing ADC 0804, LCD, and 74373 Latch
; Output is sent to Port C

ORG 0000H          ; Start of program

; Define Port Addresses
ADC_CS EQU 00H     ; ADC 0804 Chip Select (Address Decoded)
LCD_RS EQU 01H     ; LCD Register Select
LCD_RW EQU 02H     ; LCD Read/Write
LCD_E  EQU 03H     ; LCD Enable
PORT_C EQU 04H     ; Port C for output

; Initialize LCD
CALL LCD_INIT      ; Initialize the LCD

MAIN_LOOP:
    ; Start ADC Conversion
    MOV AL, 00H    ; Dummy write to start conversion
    OUT ADC_CS, AL ; Send WR signal to ADC

    ; Wait for End of Conversion (EOC)
    WAIT_EOC:
        IN AL, ADC_CS ; Read INTR pin
        TEST AL, 80H  ; Check if INTR is high (EOC)
        JNZ WAIT_EOC  ; Wait until INTR goes low

    ; Read ADC Data
    IN AL, ADC_CS    ; Read digital value from ADC
    MOV BL, AL       ; Store ADC value in BL

    ; Display ADC Value on LCD
    CALL LCD_CLEAR   ; Clear LCD display
    CALL LCD_WRITE   ; Write ADC value to LCD

    ; Send ADC Value to Port C
    MOV AL, BL       ; Move ADC value to AL
    OUT PORT_C, AL   ; Send ADC value to Port C

    JMP MAIN_LOOP    ; Repeat the process

; LCD Initialization Subroutine
LCD_INIT:
    MOV AL, 38H     ; 8-bit mode, 2 lines, 5x7 font
    CALL LCD_CMD     ; Send command to LCD
    MOV AL, 0CH     ; Display ON, Cursor OFF
    CALL LCD_CMD
    MOV AL, 06H     ; Increment cursor, no shift
    CALL LCD_CMD
    MOV AL, 01H     ; Clear LCD
    CALL LCD_CMD
    RET

; LCD Command Subroutine
LCD_CMD:
    OUT LCD_RS, 00H ; RS = 0 for command
    OUT LCD_RW, 00H ; RW = 0 for write
    OUT DATA_PORT, AL ; Send command to data port
    CALL LCD_ENABLE ; Pulse Enable
    RET

; LCD Data Write Subroutine
LCD_WRITE:
    OUT LCD_RS, 01H ; RS = 1 for data
    OUT LCD_RW, 00H ; RW = 0 for write
    OUT DATA_PORT, AL ; Send data to data port
    CALL LCD_ENABLE ; Pulse Enable
    RET

; LCD Enable Pulse Subroutine
LCD_ENABLE:
    OUT LCD_E, 01H  ; Set Enable high
    CALL DELAY      ; Small delay
    OUT LCD_E, 00H  ; Set Enable low
    RET

; LCD Clear Subroutine
LCD_CLEAR:
    MOV AL, 01H     ; Clear LCD command
    CALL LCD_CMD
    RET

; Delay Subroutine
DELAY:
    MOV CX, 0FFFFH  ; Load delay counter
    DELAY_LOOP:
        LOOP DELAY_LOOP
    RET

END