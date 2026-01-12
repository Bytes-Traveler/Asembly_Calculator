; ================================
; macros.inc
; Common Project Macros
; ================================

; EXIT macro: Exit program with given code
; Usage: EXIT <exit_code>
%macro EXIT 1
    mov rax, SYS_EXIT
    mov rdi, %1
    syscall
%endmacro

; WRITE macro: Write data to file descriptor
; Usage: WRITE <fd>, <buffer>, <size>
%macro WRITE 3
    mov rax, SYS_WRITE
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

; READ macro: Read data from file descriptor
; Usage: READ <fd>, <buffer>, <size>
; Returns: rax = bytes read
%macro READ 3
    mov rax, SYS_READ
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro
