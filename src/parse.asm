; =========================================
; parse.asm
; String to Integer Conversion
; =========================================
; Converts a NUL-terminated string to a signed 32-bit integer.
; Input:  rdi = pointer to string
; Output: rax = parsed integer (sign-extended to 64-bit)
;         rcx = error code (0=success, non-zero=error)
; Preserves: rbx, rsi, r12-r15

%include "constants.inc"
global parse_int

section .text

parse_int:
    ; Preserve callee-saved registers used in this function
    push r8
    push r10
    
    ; Initialize accumulator and state
    xor eax, eax             ; eax = accumulator (result)
    xor ecx, ecx             ; ecx = error code (0=success)
    xor edx, edx             ; edx = character index
    mov r11d, 1              ; r11d = sign (1=positive, -1=negative)

    ; Check first character (must be digit, '+', or '-')
    mov cl, byte [rdi]
    test cl, cl
    jz .fmt_error            ; Empty string is invalid

    ; Handle optional sign prefix
    cmp cl, '-'
    je .neg_sign
    cmp cl, '+'
    jne .main_loop           ; If not '+', assume it's a digit
    inc edx                  ; Skip '+' prefix
    jmp .main_loop

.neg_sign:
    ; Handle '-' prefix
    mov r11d, -1
    inc edx

.main_loop:
    ; Load next character
    mov r10b, byte [rdi + rdx]
    test r10b, r10b
    jz .finish               ; Null terminator marks end of string

    ; Verify character is a digit ('0'-'9')
    mov cl, r10b
    sub cl, '0'
    cmp cl, 9
    ja .fmt_error            ; If cl > 9, not a digit

    ; Multiply accumulator by 10: eax * 10 = (eax << 3) + (eax << 1)
    mov r8d, eax
    shl eax, 3               ; eax *= 8
    add eax, r8d             ; eax += original
    add eax, r8d             ; eax += original (now eax = original * 10)
    movzx r8d, cl            ; cl (digit) -> r8d
    add eax, r8d             ; Add digit to accumulator

    ; Check for positive overflow
    cmp eax, INT32_MAX
    jg .ovf_error

    ; Continue to next character
    inc edx
    jmp .main_loop

.finish:
    ; Apply sign if negative
    cmp r11d, 1
    je .success

    neg eax
    ; Check for negative overflow (INT32_MIN = -2147483648)
    cmp eax, INT32_MIN
    jl .ovf_error

.success:
    ; Return with no error
    xor ecx, ecx
    pop r10
    pop r8
    ret

.fmt_error:
    ; Invalid format (non-digit character)
    mov ecx, ERR_FORMAT
    pop r10
    pop r8
    ret

.ovf_error:
    ; Value overflows 32-bit signed integer range
    mov ecx, ERR_OVERFLOW
    pop r10
    pop r8
    ret
