; =========================================
; ui.asm
; Salida por pantalla
; =========================================

%include "../include/syscall.inc"
%include "../include/macros.inc"
%include "../include/constants.inc"

global ui_print_text
global ui_print_int
global ui_print_error

section .data
    err_overflow db "Error: overflow", 10
    err_divzero  db "Error: division por cero", 10
    err_format   db "Error: formato invalido", 10

section .text

; -----------------------------------------
; ui_print_text
; rdi = puntero a texto
; rsi = longitud
; -----------------------------------------
ui_print_text:
    WRITE STDOUT, rdi, rsi
    ret

; -----------------------------------------
; ui_print_error
; rdi = codigo error
; -----------------------------------------
ui_print_error:
    cmp rdi, ERR_OVERFLOW
    je .overflow
    cmp rdi, ERR_DIVZERO
    je .divzero
    cmp rdi, ERR_FORMAT
    je .format
    ret

.overflow:
    WRITE STDOUT, err_overflow, err_overflow_len
    ret

.divzero:
    WRITE STDOUT, err_divzero, err_divzero_len
    ret

.format:
    WRITE STDOUT, err_format, err_format_len
    ret

; -----------------------------------------
; ui_print_int
; rdi = int64 con signo
; -----------------------------------------
ui_print_int:
    sub rsp, 32              ; buffer temporal
    mov rsi, rsp
    call int_to_string
    mov rdx, rax
    mov rdi, rsp
    call ui_print_text
    add rsp, 32
    ret

; -----------------------------------------
; Conversión entero → string
; rdi = valor
; rsi = buffer
; salida: rax = longitud
; -----------------------------------------
int_to_string:
    mov rax, rdi
    xor rcx, rcx
    mov rbx, 10

    test rax, rax
    jns .positive

    neg rax
    mov byte [rsi], '-'
    inc rsi
    inc rcx

.positive:
    xor rdx, rdx

.convert:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .convert

.print:
    pop rdx
    mov [rsi], dl
    inc rsi
    loop .print

    mov rax, rcx
    ret

section .data
    err_overflow_len equ $ - err_overflow
    err_divzero_len  equ $ - err_divzero
    err_format_len   equ $ - err_format
