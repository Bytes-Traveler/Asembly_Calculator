; ================================
; io.asm
; Program Input and Output
; ================================

%include "../include/syscalls.inc"
%include "../include/macros.inc"

global print_string
global print_newline
global read_line

section .data
newline db 10
newline_len equ 1

section .text

; --------------------------------
; Print a string
; Input:
;   rsi -> address
;   rdx -> size
; --------------------------------
print_string:
    WRITE STDOUT, rsi, rdx
    ret

; --------------------------------
; Print a Line Breack
; --------------------------------
print_newline:
    WRITE STDOUT, newline, newline_len
    ret

; --------------------------------
; Read a line from stdin
; Input:
;   rsi -> buffer
;   rdx -> maximum size
; Output:
;   rax -> bytes read
; --------------------------------
read_line:
    READ STDIN, rsi, rdx
    ret
