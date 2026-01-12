; ================================
; io.asm
; Input/Output Operations
; ================================
; Basic I/O functions for string output and line input.

%include "syscalls.inc"
%include "macros.inc"

global print_string
global print_newline
global read_line

section .data
newline db 10
newline_len equ 1

section .text

; --------------------------------
; print_string: Output a string to stdout
; Input:  rsi = pointer to string buffer
;         rdx = length in bytes
; --------------------------------
print_string:
    WRITE STDOUT, rsi, rdx
    ret

; --------------------------------
; print_newline: Output a newline character
; --------------------------------
print_newline:
    WRITE STDOUT, newline, newline_len
    ret

; --------------------------------
; read_line: Read a line from stdin
; Input:  rsi = pointer to input buffer
;         rdx = maximum buffer size
; Output: rax = number of bytes read
; --------------------------------
read_line:
    READ STDIN, rsi, rdx
    ret
