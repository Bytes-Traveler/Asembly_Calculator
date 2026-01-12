; =========================================
; control.asm
; Calculator Control Unit
; =========================================
; Orchestrates arithmetic calculations by iterating through
; operands and applying the specified operator.

%include "constants.inc"

extern add_int32
extern sub_int32
extern mul_int32
extern div_int32

global control_calculate

section .text

; Function: control_calculate
; Input:  rdi = pointer to numbers array
;         rsi = count of numbers (must be >= 2)
;         rdx = operator character (+, -, *, /)
; Output: rax = result of calculation
;         rcx = error code (0=success)
; Preserves: rbx, r12-r15
control_calculate:
    ; Preserve callee-saved registers
    push rbx
    push r12
    xor rcx, rcx             ; Clear error code

    ; Validate minimum operand count
    cmp rsi, 2
    jl .error_format

    ; Initialize loop:
    ; Load first number, setup loop counter
    mov r12, rsi             ; r12 = remaining operand count
    mov rbx, rdi             ; rbx = pointer to current operand
    mov rax, [rbx]           ; rax = first number (accumulator)
    add rbx, 8               ; Advance to next operand
    dec r12                  ; Decrement remaining count

.loop:
    ; Loop control: continue while operands remain
    cmp r12, 0
    je .done

    ; Load operands for current operation
    ; rdi = accumulator, rsi = next operand
    mov rdi, rax
    mov rsi, [rbx]

    ; Dispatch to appropriate operation
    cmp rdx, '+'
    je .do_add
    cmp rdx, '-'
    je .do_sub
    cmp rdx, '*'
    je .do_mul
    cmp rdx, '/'
    je .do_div

    ; Invalid operator
    jmp .error_format

.do_add:
    ; Compute: rax += next_operand
    call add_int32
    jmp .check

.do_sub:
    ; Compute: rax -= next_operand
    call sub_int32
    jmp .check

.do_mul:
    ; Compute: rax *= next_operand
    call mul_int32
    jmp .check

.do_div:
    ; Compute: rax /= next_operand
    call div_int32
    jmp .check

.check:
    ; Check if operation resulted in error
    test rcx, rcx
    jnz .done             ; Exit if error occurred

    ; Advance to next operand and continue
    add rbx, 8            ; Move pointer to next number
    dec r12               ; Decrement remaining count
    jmp .loop

.done:
    pop r12
    pop rbx
    ret

.error_format:
    mov rcx, ERR_FORMAT
    pop rbx
    ret
