
INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE=5000

;islam : getValue,editCell
;ahmad : getBoard,checkIndex,checkAnswer
;Hadil : readArray,takeInput
;Raamyy: checkAvailble,getDifficulty,printArr

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
buffer BYTE BUFFER_SIZE DUP(?)
fileHandle HANDLE ?
difficultyMessage Byte "Please Enter the difficulty",0
fileName Byte "sudoku_boards/diff_?_?.txt",0
solvedFileName Byte "sudoku_boards/diff_?_?_solved.txt",0


.code

;Reads the array from the file
;param: Edx offset of the array
;param: Ebx offset of string file name
ReadArray PROC
; Let user input a filename.
;27 is constant size for filename
mov ecx,27
; Open the file for input.

mov edx,ebx
call OpenInputFile
mov fileHandle, eax

; Check for errors.
cmp eax, INVALID_HANDLE_VALUE; error opening file ?
jne file_ok; no: skip
mWrite <"Cannot open file", 0dh, 0ah>
jmp quit; and quit

file_ok :
; Read the file into a buffer.
mov edx, OFFSET buffer
mov ecx, BUFFER_SIZE
call ReadFromFile
jnc check_buffer_size; error reading ?
mWrite "Error reading file. "; yes: show error message
call WriteWindowsMsg
jmp close_file

check_buffer_size :
cmp eax, BUFFER_SIZE; buffer large enough ?
jb buf_size_ok; yes
mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
jmp quit; and quit

buf_size_ok :
mov buffer[eax], 0; insert null terminator
;mWrite "File size: "
;call WriteDec; display file size
;call Crlf

mov edx, OFFSET buffer; display the buffer
mov esi, edx

mov ecx, 97
mov edx, offset board

l :
  mov al, [esi]
  inc esi
  cmp al, 13
  je line
  cmp al, 10
  je line
  mov[edx], al
  inc edx

  line :
loop l


   mov esi, offset board
   mov ecx, 81
   mov eax, 0
l1:

  mov al, [esi]
  add esi, 1

loop l1

mov esi, offset  board
mov ecx, 81
l2:

   sub byte ptr[esi],48
   inc esi 

loop l2

mov edx,offset board

close_file :
mov eax, fileHandle
call CloseFile

quit :

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

again:

mWrite "Enter the x coordinate :  " 
call WriteWindowsMsg
call ReadDec
mov xCor,al

mWrite "Enter the y coordinate :  " 
call WriteWindowsMsg
call ReadDec
mov yCor,al

mWrite "Enter the number :  " 
call WriteWindowsMsg
call ReadDec
mov num,al

call CheckIndex
cmp eax ,1
je done

mWrite "There is an error in your input values... Please reenter them. " 
jmp again

done:

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