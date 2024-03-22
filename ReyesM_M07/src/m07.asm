; CIS - 261 Lab exercise M07
; m07.asm
; Empty program that reserves 3 bytes of memory
; in the data segment.

.386					; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT				; Flat memory model
option casemap : none	; Treat labels as case-sensitive

.CONST; Constant data segment
.STACK 100h				; (default is 1 - kilobyte stack)

.DATA					; Begin initialised data segment
	characters  BYTE  'A'
				BYTE  'B'
				BYTE  'C'

.CODE; Begin code segment
	_main PROC				; Main entry point into program

	;version I
	;BYTE 16 DUP(90h)

	;version II
	;mov BYTE PTR[characters],	  'X'
	;mov BYTE PTR[characters + 1], 'Y'
	;mov BYTE PTR[characters + 2], 'Z'

	;version III
	mov edi, OFFSET characters	; load address of 'A' into EDI
	mov al, 58h					; AL = 'X'
update:
	mov [edi], al				; [EDI] = AL
	inc edi						; update address to move to the next char
	inc al						; AL prepare next char: 'Y', 'Z', ...
	cmp al, 5Ah					; compare (AL & 5AH)
	jle update					; "jump" to update if "less" than or "equal" to 5AH
								; aka if (AL <= 5AH) then jump to update

ret
_main ENDP
END _main				; Marks the end of the moduleand sets the program entry point label
