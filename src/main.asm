; =========================================
; main.asm
; Program Entry Point - Interactive Calculator
; =========================================
; This module implements the main program loop.
; It reads user input, parses the operator and operands,
; and orchestrates the calculation.

%include "syscalls.inc"
%include "macros.inc"
%include "constants.inc"

extern parse_int
extern control_calculate
extern ui_print_int
extern ui_print_error

global _start

section .data
    prompt db "calc> ", 0
    prompt_len equ $ - prompt

section .bss
    input_buffer resb 256    ; Input buffer for user input
    numbers resq 32          ; Array to store parsed operands (up to 32)

section .text

_start:
    ; Display input prompt
    WRITE STDOUT, prompt, prompt_len

    ; Read input line from stdin
    lea rsi, [input_buffer]
    mov rdx, 256
    READ STDIN, rsi, rdx

    ; Check if read was successful (rax = bytes read)
    cmp rax, 0
    jle .format_error
    
    ; Replace newline with null terminator
    dec rax
    mov byte [input_buffer + rax], 0

    ; Initialize parsing state
    lea rdi, [input_buffer]
    lea r13, [numbers]        ; Pointer to numbers array
    xor r9, r9                ; r9 = number count
    xor r8d, r8d              ; r8 = 0: flag for operator not yet parsed

.main_loop:
    ; Load current character
    mov al, [rdi]
    
    ; Skip whitespace characters
    cmp al, 32
    je .skip_space

    ; Check for end of string
    cmp al, 0
    je .check_ready

    ; If operator not yet parsed (r8 == 0), this character is the operator
    cmp r8d, 0
    jne .parse_number

    ; Parse operator: save it and set flag
    mov r12b, al
    mov r8d, 1
    inc rdi
    jmp .main_loop

.skip_space:
    inc rdi
    jmp .main_loop

.parse_number:
    ; rdi points to a digit or sign
    ; Extract number: find space or null
    mov r10, rdi             ; start of number

.find_space:
    mov al, [rdi]
    cmp al, 32
    je .got_number
    cmp al, 0
    je .got_number
    inc rdi
    jmp .find_space

.got_number:
    ; rdi points to space or null
    mov r15, rdi             ; save end position
    mov al, [rdi]
    push rax
    mov byte [rdi], 0
    
    ; Parse
    mov rdi, r10
    call parse_int

    ; Restore WITHOUT clobbering rax
    pop r11
    mov [r15], r11b
    mov rdi, r15

    ; Check error
    test rcx, rcx
    jnz .print_error

    ; Store number
    mov [r13], rax
    add r13, 8
    inc r9

    jmp .main_loop

.check_ready:
    cmp r8d, 0
    je .format_error

    cmp r9, 2
    jl .format_error

    lea rdi, [numbers]
    mov rsi, r9
    movzx rdx, r12b
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
