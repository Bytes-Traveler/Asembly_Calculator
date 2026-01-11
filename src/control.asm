; =========================================
; control.asm
; Calculator orchestrator
; =========================================

%include "../include/constants.inc"

extern add_int32
extern sub_int32
extern mul_int32
extern div_int32

global control_calculate

section .text

control_calculate:
    xor rcx, rcx

    cmp rsi, 2
    jl .error_format

    mov rbx, rdi
    mov rax, [rbx]
    add rbx, 8
    dec rsi

.loop:
    cmp rsi, 0
    je .done

    mov rdi, rax
    mov rsi, [rbx]

    cmp rdx, '+'
    je .do_add
    cmp rdx, '-'
    je .do_sub
    cmp rdx, '*'
    je .do_mul
    cmp rdx, '/'
    je .do_div

    jmp .error_format

.do_add:
    call add_int32
    jmp .check

.do_sub:
    call sub_int32
    jmp .check

.do_mul:
    call mul_int32
    jmp .check

.do_div:
    call div_int32
    jmp .check

.check:
    test rcx, rcx
    jnz .done

    add rbx, 8
    dec rsi
    jmp .loop

.done:
    ret

.error_format:
    mov rcx, ERR_FORMAT
    ret
