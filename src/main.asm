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

.input_loop:
    ; Display input prompt
    WRITE STDOUT, prompt, prompt_len

    ; Clear input buffer
    lea rsi, [input_buffer]
    xor rcx, rcx
.clear_buffer:
    cmp rcx, 256
    jge .buffer_cleared
    mov byte [rsi + rcx], 0
    inc rcx
    jmp .clear_buffer

.buffer_cleared:
    ; Read input line from stdin
    lea rsi, [input_buffer]
    mov rdx, 256
    READ STDIN, rsi, rdx

    ; Check if read was successful (rax = bytes read)
    cmp rax, 0
    jle .exit
    
    ; Replace newline with null terminator
    dec rax
    mov byte [input_buffer + rax], 0

    ; Check for exit command
    lea rdi, [input_buffer]
    mov al, [rdi]
    
    ; Check for 'e' (exit)
    cmp al, 'e'
    jne .continue_input

.check_exit_cmd:
    ; Check if it's "exit" (e-x-i-t)
    mov al, [rdi + 1]
    cmp al, 'x'
    jne .continue_input
    mov al, [rdi + 2]
    cmp al, 'i'
    jne .continue_input
    mov al, [rdi + 3]
    cmp al, 't'
    jne .continue_input
    mov al, [rdi + 4]
    cmp al, 0
    jne .continue_input
    jmp .exit
    
.continue_input:
    ; Initialize parsing state
    lea rdi, [input_buffer]
    lea r13, [numbers]        ; Pointer to numbers array
    xor r9, r9                ; r9 = number count
    xor r8d, r8d      
    xor r12d, r12d          ; operador
    xor r14d, r14d          ; flag de error del ciclo (0=ok, 1=ya hubo error)        ; r8 = 0: flag for operator not yet parsed

.main_loop:
    ; Si ya hubo error en este ciclo, abortar parsing
    test r14d, r14d
    jnz .abort_cycle

    ; Load current character
    mov al, [rdi]
    
    ; Skip whitespace characters
    cmp al, 32
    je .skip_space

    ; Check for end of string
    cmp al, 0
    je .check_ready

    cmp r8d, 1
    je .parse_operator
    jmp .parse_number

.parse_operator:
    mov r12b, al            ; Save operator
    mov r8d, 2              ; Move to state 2: expecting more operands
    inc rdi
    jmp .main_loop

.skip_space:
    inc rdi
    jmp .main_loop

.parse_number:
    ; rdi points to a digit or sign
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
    mov r15, rdi              ; fin del número
    mov al, [rdi]             ; guardar delimitador (espacio o 0)
    mov bl, al                ; bl = delimitador original
    mov byte [rdi], 0         ; cortar temporalmente

    mov rdi, r10
    call parse_int

    ; restaurar delimitador
    mov [r15], bl

    ; Avanzar puntero si era espacio
    cmp bl, 32
    jne .no_advance
    lea rdi, [r15 + 1]
    jmp .after_restore

.no_advance:
    mov rdi, r15

.after_restore:
    test rcx, rcx
    jnz .print_error

    mov [r13], rax
    add r13, 8
    inc r9
    
    cmp r8d, 0
    jne .continue_parsing
    mov r8d, 1

.continue_parsing:
    jmp .main_loop

.check_ready:
    ; Si ya hubo error, abortar
    test r14d, r14d
    jnz .abort_cycle
    
    ; Si ya hay error, no sigas
    test rcx, rcx
    jnz .print_error

    ; Validaciones de formato SOLO si no hubo error
    cmp r8d, 2
    jl .format_error
    cmp r9, 2
    jl .format_error

    lea rdi, [numbers]
    mov rsi, r9
    movzx rdx, r12b
    call control_calculate

    test rcx, rcx
    jnz .print_error

    movsxd rdi, eax      ; Sign-extend 32-bit result to 64-bit
    call ui_print_int
    jmp .input_loop

.print_error:
    ; Imprimir y marcar flag de error del ciclo
    mov rdi, rcx
    call ui_print_error
    mov r14d, 1
    ; Reset de estado
    xor rcx, rcx
    xor r8d, r8d
    xor r9, r9
    xor r12d, r12d
    lea rdi, [input_buffer]
    jmp .abort_cycle

.format_error:
    mov rdi, ERR_FORMAT
    call ui_print_error
    mov r14d, 1
    xor rcx, rcx
    xor r8d, r8d
    xor r9, r9
    xor r12d, r12d
    lea rdi, [input_buffer]
    jmp .abort_cycle

.abort_cycle:
    ; Cualquier ruta que marque error en el ciclo termina aquí
    jmp .input_loop
    
.exit:
    EXIT 0
