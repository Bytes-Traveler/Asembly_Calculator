; =========================================
; math.asm
; 32-bit Signed Integer Arithmetic
; =========================================
; Provides basic arithmetic operations with overflow detection.
; All functions follow System V AMD64 ABI calling convention.

%include "constants.inc"

global add_int32
global sub_int32
global mul_int32
global div_int32

section .text

; -----------------------------------------
; add_int32: Add two 32-bit signed integers
; Input:  edi = first operand
;         esi = second operand
; Output: eax = result
;         rcx = error code (0=success)
; -----------------------------------------
add_int32:
    xor rcx, rcx             ; Clear error code
    mov eax, edi             ; eax = first operand
    add eax, esi             ; eax += second operand
    jo .add_overflow         ; Jump if overflow occurred
    ret

.add_overflow:
    ; Set error code for overflow
    mov rcx, ERR_OVERFLOW
    ret

; -----------------------------------------
; sub_int32: Subtract two 32-bit signed integers
; Input:  edi = minuend
;         esi = subtrahend
; Output: eax = result (edi - esi)
;         rcx = error code (0=success)
; -----------------------------------------
sub_int32:
    xor rcx, rcx             ; Clear error code
    mov eax, edi             ; eax = first operand
    sub eax, esi             ; eax -= second operand
    jo .sub_overflow         ; Jump if overflow occurred
    ret

.sub_overflow:
    ; Set error code for overflow
    mov rcx, ERR_OVERFLOW
    ret

; -----------------------------------------
; mul_int32: Multiply two 32-bit signed integers
; Input:  edi = first operand
;         esi = second operand
; Output: eax = result
;         rcx = error code (0=success)
; -----------------------------------------
mul_int32:
    xor rcx, rcx             ; Clear error code
    mov eax, edi             ; eax = first operand
    imul eax, esi            ; eax *= second operand (signed multiply)
    jo .mul_overflow         ; Jump if overflow occurred
    ret

.mul_overflow:
    ; Set error code for overflow
    mov rcx, ERR_OVERFLOW
    ret

; -----------------------------------------
; div_int32: Divide two 32-bit signed integers
; Input:  edi = dividend
;         esi = divisor
; Output: eax = quotient
;         rcx = error code (0=success)
; -----------------------------------------
div_int32:
    xor rcx, rcx
    cmp esi, 0
    je .div_zero
    mov eax, edi
    cdq
    idiv esi
    ret

.div_zero:
    mov rcx, ERR_DIVZERO
    ret
