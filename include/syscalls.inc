; ================================
; syscalls.inc
; Linux x86-64 System Calls
; ================================

; Linux x86-64 system call numbers
SYS_READ  equ 0   ; read() syscall
SYS_WRITE equ 1   ; write() syscall
SYS_EXIT  equ 60  ; exit() syscall

; Standard file descriptors
STDIN  equ 0  ; Standard input
STDOUT equ 1  ; Standard output
STDERR equ 2  ; Standard error
