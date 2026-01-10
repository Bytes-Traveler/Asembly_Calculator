; ================================
; main.asm
; Program entry point
; ================================

%include "../include/constants.inc"
%include "../include/syscalls.inc"
%include "../include/macros.inc"

global _start

section .text

_start:
    call program_init
    call main_loop
    EXIT 0

; --------------------------------
; Program initialization
; --------------------------------
program_init:
    ; future initializations will go here
    ret

; --------------------------------
; Main loop
; --------------------------------
main_loop:
    ; The menu and logic will go here.
    ret
