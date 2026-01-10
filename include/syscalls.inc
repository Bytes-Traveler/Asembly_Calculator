; ================================
; syscalls.inc
; Syscalls Linux x86-64
; ================================

; Syscall numbers
SYS_READ  equ 0
SYS_WRITE equ 1
SYS_EXIT  equ 60

; File descriptors
STDIN  equ 0
STDOUT equ 1
STDERR equ 2
