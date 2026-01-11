; =========================================
; parse.asm
; Conversion from string to signed int32
; =========================================

%include "../include/constants.inc"

global parse_int32

section .text

; -------------------------------------------------
; parse_int32
;
; Convert an ASCII string to an int32 integer
;
; Input:
;   rsi -> string address
;   rdx -> string length
;
; Output:
;   rax -> converted value
;   rcx -> error code
;          0 = OK
;          1 = invalid format
;          2 = overflow / underflow
; -------------------------------------------------
parse_int32:
    xor rax, rax        ; accumulator = 0
    xor rcx, rcx        ; error = 0
    xor rbx, rbx        ; index = 0
    mov r8, 1           ; sign = +1

    ; empty string → error
    test rdx, rdx
    jz .error_format

    ; ---------------------------------------------
    ; Detect sign
    ; ---------------------------------------------
    mov al, [rsi]

    cmp al, '-'
    jne .check_plus
    mov r8, -1
    inc rbx
    jmp .check_after_sign

.check_plus:
    cmp al, '+'
    jne .check_after_sign
    inc rbx

.check_after_sign:
    ; only sign without digits → error
    cmp rbx, rdx
    jge .error_format

    ; ---------------------------------------------
    ; Main conversion loop
    ; ---------------------------------------------
.loop:
    cmp rbx, rdx
    jge .apply_sign

    mov al, [rsi + rbx]

    ; validate '0'..'9'
    cmp al, '0'
    jl .error_format
    cmp al, '9'
    jg .error_format

    ; convert ASCII to value
    sub al, '0'

    ; rax = rax * 10
    mov r9, rax
    shl rax, 3              ; rax = rax * 8
    lea rax, [rax + r9*2]   ; rax = rax * 10

    ; add digit
    movzx r10, al
    add rax, r10

    ; detect positive overflow before the sign
    cmp rax, INT32_MAX
    jg .error_overflow

    inc rbx
    jmp .loop

    ; ---------------------------------------------
    ; Apply sign
    ; ---------------------------------------------
.apply_sign:
    cmp r8, 1
    je .done

    neg rax
    cmp rax, INT32_MIN
    jl .error_overflow

.done:
    ret

; ---------------------------------------------
; Errors
; ---------------------------------------------
.error_format:
    mov rcx, 1
    ret

.error_overflow:
    mov rcx, 2
    ret
