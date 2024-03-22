; m13_calculator.asm
; CIS-261 final poject: "running total" calculator

.586P
.MODEL FLAT     ; Flat memory model
option casemap:none ; Treat labels as case-sensitive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add C run-time libraries
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; see https://docs.microsoft.com/en-us/cpp/c-runtime-library/crt-library-features?view=vs-2019
; printf() needs the following library:
includelib legacy_stdio_definitions.lib

PUBLIC m13_calculate ; make this procedure externally visible to the linker

m13_calculate   PROTO NEAR32 stdcall, arithmetic_command:DWORD, right_operand:DWORD
binary_plus     PROTO NEAR32 stdcall, right_operand:DWORD
binary_minus    PROTO NEAR32 stdcall, right_operand:DWORD
binary_multiply PROTO NEAR32 stdcall, right_operand:DWORD
binary_divide   PROTO NEAR32 stdcall, right_operand:DWORD
binary_modulo   PROTO NEAR32 stdcall, right_operand:DWORD
binary_assign   PROTO NEAR32 stdcall, right_operand:DWORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; procedures defined in other modules
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EXTERN _m13_left_operand:DWORD ; global variable defined in m13_externs.cpp
EXTERN _print_error@4:NEAR     ; procedure is defined in m13_externs.cpp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; procedures of the C standard library
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EXTERN _printf:NEAR

.const
        ASCII_TAB                   EQU 9
        ERROR_division_by_zero      BYTE ASCII_TAB, "attempt to divide by zero ignored...", 0
        ERROR_unexpected_command    BYTE ASCII_TAB, "unexpected command code [%d]", 0
        ERROR_unimplemented_command BYTE ASCII_TAB, "unimplemented command [%d]", 0

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; command codes for arithmetic operators
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        COMMAND_ADD         EQU 0
        COMMAND_SUBTRACT    EQU 1
        COMMAND_MULTIPLY    EQU 2
        COMMAND_DIVIDE      EQU 3
        COMMAND_MODULO      EQU 4
        COMMAND_ASSIGN      EQU 5
        COMMAND_UNKNOWN     EQU 6

.data   ; The data segment
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Table of addresses of procedures that are invoked indirectly
        ; Zero entry indicates that procedure is still unimplemented
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call_table DWORD OFFSET binary_plus
                   DWORD OFFSET binary_minus
                   DWORD OFFSET binary_multiply
                   DWORD OFFSET binary_divide
                   DWORD OFFSET binary_modulo
                   DWORD OFFSET binary_assign

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.code   ; Code segment begins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; entry point routine to dispatch operations to the appropriate handlers
; inputs:
;   right_operand -- param on the stack
;   arithmetic_command -- code of operation. acceptable codes are:
;   ---------------
;   operation code
;   --------- -----
;       '+'    0
;       '-'    1
;       '*'    2
;       '/'    3
;       '%'    4
;       '='    5
;   ---------------
; returns
;   zero if success, error code otherwise (the returned value is in EAX)
;
m13_calculate   PROC NEAR32 stdcall, arithmetic_command:DWORD, right_operand:DWORD
    push ebx                        ; preserve EBX
    mov   ebx, [arithmetic_command] ; load command code into EBX

    ;;-------------------------------------------------------------------------
    ;; validate range of command code
    ;;-------------------------------------------------------------------------
    cmp ebx, COMMAND_UNKNOWN    ; if ( arithmetic_command < COMMAND_UNKNOWN )
    jb  @F                      ; command is in good range

    ;;-------------------------------------------------------------------------
    ;; command code is out of range
    ;;-------------------------------------------------------------------------
    ; NOTE: printf() follows C convention: arguments passed right to left
    push  ebx                               ; command code to display
    push  OFFSET ERROR_unexpected_command   ; format string to use
    call  _printf                           ; print string
    ; NOTE: printf is a varargs function. It does not
    ; pop its own args off the stack.
    ; The caller must remove the arguments:
    add  esp, 8

    pop ebx                     ; restore EBX
    mov eax, @Line              ; use line number in this file as error code
    ret                         ; RETURN

@@:
    cmp call_table[ ebx * 4 ], 0 ; if ( arithmetic_command != 0 )
    jne @F                       ; command is implemented

    ;;-------------------------------------------------------------------------
    ;; command code is not implemented
    ;;-------------------------------------------------------------------------
    push  ebx                                   ; command code to display
    push  OFFSET ERROR_unimplemented_command    ; format string to use
    call  _printf                               ; print string

    ; NOTE: printf is a varargs function. It does not
    ; pop its own args off the stack.
    ; The caller must remove the arguments:
    add   esp, 8

    pop ebx             ; restore EBX
    mov eax, @Line      ; use line number in this file as error code
    ret                 ; RETURN

@@:
    ;;-------------------------------------------------------------------------
    ;; all validations passed, make calculations
    ;;-------------------------------------------------------------------------
    mov   eax, [right_operand]
    push  eax                   ; prepare right operand on the stack
    call  call_table[ ebx * 4 ] ; invoke command handler
    pop   ebx                   ; restore ebx
    ret
m13_calculate   ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; inputs:
;   m14_left_operand -- global variable
;   right_operand -- param on the stack
; returns:
;   EAX: zero if success, error code otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binary_plus     PROC NEAR32 stdcall, right_operand:DWORD
    mov eax, [right_operand]        ;
    add [_m13_left_operand], eax    ; [_m13_left_operand] += [right_operand]
    xor eax, eax                    ; EAX = 0 indicating success
    ret
binary_plus     ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; inputs:
;   m14_left_operand -- global variable
;   right_operand -- param on the stack
; returns:
;   EAX: zero if success, error code otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binary_minus    PROC NEAR32 stdcall, right_operand:DWORD
    mov eax, [right_operand]        ;
    sub [_m13_left_operand], eax    ; [_m13_left_operand] -= [right_operand]
    xor eax, eax                    ; EAX = 0 indicating success
    ret
binary_minus    ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; inputs:
;   m14_left_operand -- global variable
;   right_operand -- param on the stack
; returns:
;   EAX: zero if success, error code otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binary_multiply PROC NEAR32 stdcall, right_operand:DWORD
    push ecx                        ; preserve ECX
    mov eax, [_m13_left_operand]    ; EAX = multiplicant
    cdq                             ; must extend the sign bit of EAX into the EDX register

    mov ecx, [right_operand]        ; ECX = multiplier

    imul ecx                        ; EAX * ECX
    mov [_m13_left_operand], eax    ; store product
    xor eax, eax                    ; EAX = 0 indicating success
    pop ecx                         ; restore
    ret
binary_multiply ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; inputs:
;   m14_left_operand -- global variable
;   right_operand -- param on the stack
; returns:
;   EAX: zero if success, error code otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binary_divide   PROC NEAR32 stdcall, right_operand:DWORD
    push ecx                        ; preserve ECX
    mov eax, [_m13_left_operand]    ; EAX = dividend
    cdq                             ; must extend the sign bit of EAX into the EDX register

    mov ecx, [right_operand]        ; ECX = divisor
    test ecx, ecx                   ; if ( ECX == 0 )
    jz @F                           ; then error

    idiv ecx                        ; ( quotient EAX : remainder EDX ) = EAX / ECX
    mov [_m13_left_operand], eax    ; store quotient
    xor eax, eax                    ; EAX = 0 indicating success
    pop ecx                         ; restore
    ret
@@:
    push OFFSET ERROR_division_by_zero

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Example using printf() for output
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call _printf    ; print string
    ; NOTE: printf is a varargs function. It does not
    ; pop its own args off the stack.
    ; The caller must remove the arguments:
    add  esp, 4

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Example calling our own C function for output
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;call _print_error@4
    pop ecx                         ; restore ECX
    mov eax, @Line                  ; use line number in this file as error code
    ret

binary_divide   ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; inputs:
;   m14_left_operand -- global variable
;   right_operand -- param on the stack
; returns:
;   EAX: zero if success, error code otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binary_modulo   PROC NEAR32 stdcall, right_operand:DWORD
    push ecx                        ; preserve ECX
    mov eax, [_m13_left_operand]    ; EAX = dividend
    cdq                             ; must extend the sign bit of EAX into the EDX register

    mov ecx, [right_operand]        ; ECX = divisor
    test ecx, ecx                   ; if ( ECX == 0 )
    jz @F                           ; then error division by zero

    idiv ecx                        ; ( quotient in EAX : remainder in EDX ) = EAX / ECX
    mov [_m13_left_operand], edx    ; store remainder
    xor eax, eax                    ; EAX = 0 indicating success
    pop ecx                         ; restore
    ret

@@:
    push OFFSET ERROR_division_by_zero

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Example using printf() for output
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call _printf    ; print string
    ; NOTE: printf is a varargs function. It does not
    ; pop its own args off the stack.
    ; The caller must remove the arguments:
    add  esp, 4

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Example calling our own C function for output
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;call _print_error@4
    pop ecx                         ; restore ECX
    mov eax, @Line                  ; use line number in this file as error code
    ret

binary_modulo   ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; inputs:
;   m14_left_operand -- global variable
;   right_operand -- param on the stack
; returns:
;   EAX: zero if success, error code otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
binary_assign   PROC NEAR32 stdcall, right_operand:DWORD
    mov eax, [right_operand]        ;
    mov [_m13_left_operand], eax    ; [_m13_left_operand] = [right_operand]
    xor eax, eax                    ; EAX = 0 indicating success
    ret
binary_assign   ENDP

END
