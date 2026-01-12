; ================================
; constants.inc
; Global Project Constants
; ================================

; 32-bit signed integer limits
INT32_MAX equ 2147483647
INT32_MIN equ -2147483648

; Buffer sizes
INPUT_BUF_SIZE  equ 64
OUTPUT_BUF_SIZE equ 64

; Operand constraints
MIN_OPERANDS equ 2
MAX_OPERANDS equ 32

; Error codes returned by functions
ERR_OK        equ 0  ; No error
ERR_FORMAT    equ 1  ; Invalid input format
ERR_OVERFLOW  equ 2  ; Arithmetic overflow
ERR_DIVZERO   equ 3  ; Division by zero