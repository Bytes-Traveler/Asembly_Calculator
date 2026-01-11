; =========================================
; math.asm
; int32 mathematical operations
; =========================================

%include "../include/constants.inc"

global add_int32
global sub_int32
global mul_int32
global div_int32

section .text

; -----------------------------------------
; Sum: rdi + rsi
; -----------------------------------------
add_int32:
    xor rcx, rcx
    mov rax, rdi
    add rax, rsi
    jo .overflow
    ret

; -----------------------------------------
; Subtract: rdi - rsi
; -----------------------------------------
sub_int32:
    xor rcx, rcx
    mov rax, rdi
    sub rax, rsi
    jo .overflow
    ret

; -----------------------------------------
; Multiplication: rdi * rsi
; -----------------------------------------
mul_int32:
    xor rcx, rcx
    mov rax, rdi
    imul rsi
    jo .overflow
    ret

; -----------------------------------------
; Division: rdi / rsi
; -----------------------------------------
div_int32:
    xor rcx, rcx

    cmp rsi, 0
    je .div_zero

    mov rax, rdi
    cqo
    idiv rsi
    ret

; -----------------------------------------
; Errors
; -----------------------------------------
.overflow:
    mov rcx, 1
    ret

.div_zero:
    mov rcx, 2
    ret
