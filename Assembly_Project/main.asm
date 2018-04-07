
;islam : GetValue,EditCell
;ahmad : GetBoard,CheckIndex,CheckAnswer
;Hadil : ReadArray,TakeInput
;Raamyy: CheckAvailble,GetDifficulty,PrintArr

INCLUDE Irvine32.inc

.data

board Byte 81 DUP(?)    ;sudoko board
xCor Byte ?		;x coordinate
yCor Byte ?     ;y coordinate
num Byte ?    ;user number to update
difficulty Byte ?	;1 Easy, 2 Medium, 3 Hard
fileName Byte 10 Dup(?), 0
wrongCounter Byte ?
correctCounter Byte ?
remainingCounter Byte ?
difficultyMessage Byte "Please Enter the difficulty",0
fileName Byte "sudoku_boards/diff_?_?.txt",0
solvedFileName Byte "sudoku_boards/diff_?_?_solved.txt",0


.code

;Reads the array from the file
;param: Edx offset of the array
;param: Ebx offset of string file name
ReadArray PROC

	ret
ReadArray ENDP

;Check index not out of range / not reserved
;param x
;param y
;ret Eax 0, 1 
CheckIndex PROC

	ret
CheckIndex ENDP

;Check if the answer in the index is correct
;param x
;param y
;param number
;ret Eax 0, 1
CheckAnswer PROC

	ret
CheckAnswer ENDP

;Return value in the index
;Param Edx pointer to the array
;param x
;param y
;return Eax = value
GetValue PROC
	CALL CheckIndex
	PUSH Edx
	PUSH Ecx
	CMP Eax, 1
	Je Body
		Mov Eax, -1
		POP Edx
		ret
	Body:
		Mov Eax, 9
		Movzx Ecx, xCor
		Mul Ecx
		Movzx Ecx, yCor
		Add Eax, Ecx
		Mov Edx, offset board
		Add Edx, Eax
		Mov Eax, [Edx]
	POP Ecx
	POP Edx
	ret
GetValue ENDP



;Param:	 Difficulty (global var)
;Returns: Desired board in board var
GetBoard PROC
	;Generating random value from ax and cx
	xor ax,cx

	;Getting the value modulu 3
	mov cx,ax
	mov dx,0
	mov bx,3
	div bx		;BX carries a random value less than 3

	;Customizing fileName string with difficulty and random choice
	mov al,bx
	mov fileName[21],al

	mov al,difficulty
	mov fileName[19],al

	;Calling ReadArr with required params to populate board var
	mov edx,offset board
	mov ebx,offset fileName
	call ReadArr

	ret
GetBoard ENDP



;param Edx offset of array
PrintArray PROC
mov Ecx,81
	l1:
		mov Eax,0
		movzx Eax,byte ptr [Edx]  ;Eax contains current number
		push Eax
		push Edx
		mov dx,0
		mov ax,cx     ;dx = cx % 9
 		mov bx,9
		div bx

		cmp dx,0
		jne NoEndl	  ;if dx % 9 = 0 print endl
		call crlf
		NoEndl:
		pop Edx
		pop Eax

		call writeDec
		inc Edx
	loop l1
	call crlf
	ret
	PrintArray ENDP

;Update Global varialble x, y, num
TakeInput PROC

	ret
TakeInput ENDP

;Update Global variable Difficulty 
GetDifficulty PROC

	mov Edx,offset DifficultyMessage
	call WriteString
	call crlf

	;Better use ReadChar for GetBoard Proc;
	call ReadDec
	mov difficulty,al ;take the byte from eax
	
	ret
GetDifficulty ENDP

;Update cell
;param x
;param y
;param num
EditCell PROC
	CALL CheckIndex
	CMP Eax, 0
	JE Ending
		CALL CheckAnswer
		CMP Eax, 0
	JE Ending
		Mov Eax, 9
		Movzx Ecx, xCor
		Mul Ecx
		Movzx Ecx, yCor
		Add Eax, Ecx
		Mov Edx, offset board
		Add Edx, Eax
		Movzx Eax, num
		Mov [Edx], Eax
	Ending:
	ret
EditCell ENDP

main PROC
	
    call dumpregs

	exit
main ENDP

END main