; =========================================
; main.asm
; Program Entry Point
; =========================================

%include "../include/syscall.inc"
%include "../include/macros.inc"
%include "../include/constants.inc"

extern parse_int
extern control_calculate
extern ui_print_int
extern ui_print_error

global _start

section .bss
    numbers resq 32          ; hasta 32 números

section .text

_start:
    ; -------------------------------------
    ; Get argc y argv
    ; -------------------------------------
    mov rbx, rsp
    mov rdi, [rbx]           ; argc
    lea rsi, [rbx + 8]       ; argv

    cmp rdi, 4               ; prog op n1 n2 ...
    jl .format_error

    ; -------------------------------------
    ; Get operador
    ; -------------------------------------
    mov rdx, [rsi + 8]       ; argv[1]
    mov dl, [rdx]            ; primer char

    ; -------------------------------------
    ; Parse números
    ; -------------------------------------
    lea r8, [numbers]
    mov rcx, 2               ; índice argv
    xor r9, r9               ; contador números

.parse_loop:
    cmp rcx, rdi
    jge .do_calculate

    mov rdi, [rsi + rcx*8]   ; argv[i]
    call parse_int

    test rcx, rcx
    jnz .print_error

    mov [r8], rax
    add r8, 8
    inc r9
    inc rcx
    jmp .parse_loop

.do_calculate:
    lea rdi, [numbers]
    mov rsi, r9
    call control_calculate

    test rcx, rcx
    jnz .print_error

    mov rdi, rax
    call ui_print_int
    jmp .exit

.print_error:
    mov rdi, rcx
    call ui_print_error
    jmp .exit

.format_error:
    mov rdi, ERR_FORMAT
    call ui_print_error

.exit:
    EXIT 0
