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
    ; Set up stack alignment: reserve even number of 8-byte values
    ; so RSP % 16 == 0 before any 'call' instruction
    push rbp
    mov rbp, rsp

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
    je .check_exit_cmd
    
    ; Check for 'q' (quit)
    cmp al, 'q'
    je .check_quit_cmd
    
    jmp .continue_input

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

.check_quit_cmd:
    ; Check if it's "quit" (q-u-i-t)
    mov al, [rdi + 1]
    cmp al, 'u'
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

    ; State machine:
    ; r8d = 0: expecting first number
    ; r8d = 1: expecting operator
    ; r8d >= 2: expecting more operands (parse as numbers)
    
    cmp r8d, 1
    jne .parse_number_or_op
    
    ; If r8d == 1, we're looking for the operator
    mov r12b, al            ; Save operator
    mov r8d, 2              ; Move to state 2: expecting more operands
    inc rdi
    jmp .main_loop

.parse_number_or_op:
    ; If r8d == 0 or r8d >= 2, this is a number
    jmp .parse_number

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
    
    ; If this is the first number (r8d == 0), move to state 1
    cmp r8d, 0
    jne .continue_parsing
    mov r8d, 1

.continue_parsing:
    jmp .main_loop

.check_ready:
    ; r8d should be >= 2 (we've seen at least one operator)
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

    mov rdi, rax
    call ui_print_int
    jmp .input_loop

.print_error:
    mov rdi, rcx
    call ui_print_error
    jmp .input_loop

.format_error:
    mov rdi, ERR_FORMAT
    call ui_print_error
    jmp .input_loop

.exit:
    mov rsp, rbp
    pop rbp
    EXIT 0
