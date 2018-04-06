INCLUDE Irvine32.inc

;islam : getValue,editCell
;ahmad : getBoard,checkIndex,checkAnswer
;Hadil : readArray,takeInput
;Raamyy: checkAvailble,getDifficulty,printArr

.data

board Byte 81 DUP(?) ;sudoko board
xCor Byte ? ;x coordinate
yCor Byte ? ;y coordinate
num Byte ?  ;user number to update
difficulty Byte ? ;1 Easy, 2 Medium, 3 Hard
fileName Byte 10 Dup(?), 0
wrongCounter Byte ?
correctCounter Byte ?
remainingCounter Byte ?
DifficultyMessage Byte "Please Enter the difficulty",0
.code

;Read the array from the file
;param Edx offset of the array
;param Ebx offset of string file name
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

;Return sudoko Board
;param Difficulty (Easy, Medium, Hard)
GetBoard PROC

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