; =========================================
; ui.asm
; User Interface - Output Functions
; =========================================
; Handles all output operations: printing integers and error messages.

%include "syscalls.inc"
%include "macros.inc"
%include "constants.inc"

global ui_print_text
global ui_print_int
global ui_print_error

section .data
    err_overflow db "Error: overflow", 10
    err_divzero  db "Error: division by zero", 10
    err_format   db "Error: invalid format", 10
    newline db 10

section .text

; -----------------------------------------
; ui_print_text: Output text to stdout
; Input:  rdi = pointer to text buffer
;         rdx = length in bytes
; -----------------------------------------
ui_print_text:
    mov rsi, rdi             ; Move buffer pointer to rsi for WRITE macro
    WRITE STDOUT, rsi, rdx
    ret

; -----------------------------------------
; ui_print_error: Output error message based on error code
; Input:  rdi = error code (ERR_FORMAT, ERR_OVERFLOW, ERR_DIVZERO)
; -----------------------------------------
ui_print_error:
    ; Dispatch to appropriate error message
    cmp rdi, ERR_OVERFLOW
    je .overflow
    cmp rdi, ERR_DIVZERO
    je .divzero
    cmp rdi, ERR_FORMAT
    je .format
    ret

.overflow:
    ; Print overflow error
    WRITE STDOUT, err_overflow, err_overflow_len
    ret

.divzero:
    ; Print division by zero error
    WRITE STDOUT, err_divzero, err_divzero_len
    ret

.format:
    ; Print invalid format error
    WRITE STDOUT, err_format, err_format_len
    ret

; -----------------------------------------
; ui_print_int: Output a signed 64-bit integer
; Input:  rdi = signed integer to print
; -----------------------------------------
ui_print_int:
    ; Allocate temporary buffer on stack
    sub rsp, 32              ; 32-byte buffer for number string
    mov rsi, rsp             ; rsi = buffer pointer
    call int_to_string       ; Convert to string, returns length in rax
    
    ; Print the resulting string
    mov rdx, rax             ; rdx = string length
    mov rdi, rsp             ; rdi = buffer pointer
    call ui_print_text       ; Output the number
    
    ; Print newline
    WRITE STDOUT, newline, newline_len
    
    ; Clean up and return
    add rsp, 32
    ret

; -----------------------------------------
; int_to_string: Convert signed 64-bit integer to ASCII string
; Input:  rdi = signed integer value
;         rsi = pointer to output buffer
; Output: rax = length of resulting string (in bytes)
; Note:   Buffer must be at least 21 bytes (sign + 19 digits + null)
; -----------------------------------------
int_to_string:
    ; Preserve callee-saved registers
    push rbx
    push r10
    
    ; Initialize conversion
    mov rax, rdi             ; rax = value to convert
    xor rcx, rcx             ; rcx = digit counter
    mov rbx, 10              ; rbx = base for division

    ; Handle negative numbers
    test rax, rax
    jns .positive

    ; For negative: output '-' and negate value
    neg rax
    mov byte [rsi], '-'
    inc rsi
    inc rcx                  ; Count the '-' character

.positive:
    ; Convert absolute value to decimal digits
    xor rdx, rdx

.convert:
    ; Extract next digit (rightmost to leftmost)
    xor rdx, rdx
    div rbx                  ; rax /= 10, remainder in rdx
    add dl, '0'              ; Convert digit to ASCII
    push rdx                 ; Push digit (will be reversed later)
    inc rcx
    test rax, rax
    jnz .convert             ; Continue while value > 0

    ; Save total length before printing
    mov r10, rcx             ; r10 = length (including sign)

.print:
    ; Pop digits in reverse order and write to buffer
    pop rdx
    mov [rsi], dl            ; Write digit to buffer
    inc rsi
    dec rcx
    jnz .print

    ; Return total string length
    mov rax, r10             ; rax = length
    pop r10
    pop rbx
    ret

section .data
    err_overflow_len equ $ - err_overflow
    err_divzero_len  equ $ - err_divzero
    err_format_len   equ $ - err_format
    newline_len equ $ - newline
