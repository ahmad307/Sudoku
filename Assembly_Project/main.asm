
INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE=5000

;islam : getValue,editCell
;ahmad : getBoards,checkIndex,checkAnswer,IsEditable
;Hadil : readArray,takeInput
;Raamyy: checkAvailble,getDifficulty,printArr

.data

;Sudoko board
board Byte 81 DUP(?)    

;Solved Sudoku board
solvedBoard Byte 81 DUP(?)	

;X coordinate
xCor Byte ?		
;Y coordinate
yCor Byte ?     
;User input value
num Byte ?   

wrongCounter Byte ?
correctCounter Byte ?
remainingCounter Byte ?

buffer BYTE BUFFER_SIZE DUP(?)
fileHandle HANDLE ?

difficulty Byte ?	;1 Easy, 2 Medium, 3 Hard

fileName Byte "sudoku_boards/diff_?_?.txt",0
solvedFileName Byte "sudoku_boards/diff_?_?_solved.txt",0


.code

;Reads the array from the file
;param: Edx offset of the array
;param: Ebx offset of string file name
;Returns: Array read from file in Edx

ReadArray PROC
	;Setting ECX with the max string size
	mov ecx,34

	;Open the file for input
	mov edx,ebx
	call OpenInputFile
	mov fileHandle, eax

	;Check for reading from file errors
	cmp eax, INVALID_HANDLE_VALUE	
	jne file_ok	
	mWrite <"Cannot open file", 0dh, 0ah>
	jmp quit

	file_ok :
		; Read the file into a buffer
		mov edx, OFFSET buffer
		mov ecx, BUFFER_SIZE
		call ReadFromFile
		jnc check_buffer_size	;error reading ?
		mWrite "Error reading file. "	
		call WriteWindowsMsg
		jmp close_file

	check_buffer_size :
		;Check if buffer is large enough
		cmp eax, BUFFER_SIZE	
		jb buf_size_ok
		mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
		jmp quit

	buf_size_ok :
		;Insert null terminator
		mov buffer[eax], 0

	mov ebx, OFFSET buffer
	mov ecx, 97
	mov edx,esi

	l :
	  mov al, [ebx]
	  inc ebx
	  cmp al, 13
	  je line
	  cmp al, 10
	  je line
	  mov [esi], al
	  inc esi
	  line : 
	loop l

	mov esi, edx
	mov ecx, 81
	mov eax, 0

	l1:
	  mov al, [esi]
	  add esi, 1
	loop l1

	mov esi, edx
	mov ecx, 81

	l2:
	   sub byte ptr[esi],48
	   inc esi 
	loop l2

	 mov esi, edx

	close_file :
	mov eax, fileHandle
	call CloseFile

	quit :

	ret
ReadArray ENDP




;Checks if index out of range / not reserved
;param xCor,yCor,num (var)
;ret EAX 0, 1 
CheckIndex PROC
	;Checking xCor lies between 1 and 9
	cmp xCor,9
	ja WRONG
	cmp xCor,1
	jb WRONG

	;Checking yCor lies between 1 and 9
	cmp YCor,9
	ja WRONG
	cmp YCor,1
	jb WRONG

	;Checking num lies between 1 and 9
	cmp num,9
	ja WRONG
	cmp num,1
	jb WRONG

	jmp RIGHT

	WRONG:
		mov eax,0
		ret
	RIGHT:
		mov eax,1
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



;Returns the value in the given index
;Param Edx pointer to the array
;param x
;param y
;return Eax = value
GetValue PROC
	CALL CheckIndex
	PUSH Ecx
	PUSH Edx
	CMP Eax, 1
	Je Body
		Mov Eax, -1
		POP Edx
		POP Ecx
		ret
	Body:
		Dec xCor
		Dec yCor
		Mov Eax, 9
		Movzx Ecx, xCor
		Mul Ecx
		Movzx Ecx, yCor
		Add Eax, Ecx
		POP Edx
		PUSH Edx
		Add Edx, Eax
		Mov eax, 0
		Mov al, [Edx]
		Inc xCor
		Inc yCor
	POP Ecx
	POP Edx
	ret
GetValue ENDP



;Param:	 Difficulty (global var)
;Returns: Desired board in board var
GetBoards PROC
	;Generating random value from ax and cx
	xor ax,cx

	;Getting the value modulu 3
	mov cx,ax
	mov dx,0
	mov bx,4
	div bx		;DX carries a random value less than 4

	;Setting value to 1 if it's 0
	cmp dx,0
	je ZeroDX
	jmp cont

	ZeroDX:
	mov dx,1

	cont:
	;Customizing fileName variables string with random choice and difficulty
	mov al,dl
	add al,'0'
	mov fileName[21],al

	mov al,difficulty
	add al,'0'
	mov fileName[19],al

	mov al,dl
	add al,'0'
	mov solvedFileName[21],al

	mov al,difficulty
	add al,'0'
	mov solvedFileName[19],al

	;Calling ReadArray with required params to populate board var
	mov esi,offset board
	mov ebx,offset fileName
	call ReadArray

	;Calling ReadArray with required params to populate solvedBoard var
	mov esi,offset solvedBoard
	mov ebx,offset solvedFileName
	call ReadArray

	ret
GetBoards ENDP



;param Edx offset of array
PrintArray PROC
	PUSH Edx
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
	POP Edx
	ret
PrintArray ENDP

;Update Global varialble x, y, num
TakeInput PROC

	again:

	mWrite "Enter the x coordinate :  " 
	call ReadDec
	mov xCor,al

	mWrite "Enter the y coordinate :  " 
	call ReadDec
	mov yCor,al

	mWrite "Enter the number :  " 
	call ReadDec
	mov num,al

	call CheckIndex
	cmp eax ,1
	je done

	mWrite "There is an error in your input values... Please reenter them. " 
	jmp again

	done:

	call iseditable
	cmp eax,1
	je Editable

	mWrite "You Cannot edit this place, Please change it."
	call crlf
	jmp again

	Editable:
	mWrite "Edited"
	call crlf
	ret
TakeInput ENDP



;Update Global variable Difficulty 
GetDifficulty PROC
	again:
	mWrite "Please Enter the difficulty: "
	call crlf

	;;;;Better use ReadChar for GetBoards Proc;;;;

	call ReadDec
	cmp al,1
	je NoError
	cmp al,2
	je NoError
	cmp al,3
	je NoError
	mWrite "Please enter a valid difficulty ( 1 or 2 or 3 ) "
	call crlf
	jmp again
	NoError:
	mov difficulty,al ;take the byte from eax
	
	ret
GetDifficulty ENDP

;Update cell
;param x
;param y
;param num
EditCell PROC
	PUSH Edx
	PUSH Ecx
	CALL CheckIndex
	CMP Eax, 0
	JE Ending
		CALL CheckAnswer
		CMP Eax, 0
	JE Ending
		Dec xCor
		Dec yCor
		Mov Eax, 9
		Movzx Ecx, xCor
		Mul Ecx
		Movzx Ecx, yCor
		Add Eax, Ecx
		Mov Edx, offset board
		Add Edx, Eax
		Mov al, num
		Mov [Edx], al
		Inc xCor
		Inc yCor
	Ending:
		POP Ecx
		pop Edx
		ret
EditCell ENDP



;Checks if cell at x,y (global vars) in board is editable
;Returns: 1 in EAX if the place is editable and 0 otherwise
IsEditable PROC
	mov edx,offset board
	call GetValue

	;Checking value returned from GetValue
	cmp eax,0
	je RIGHT
	jmp WRONG

	RIGHT:
	mov eax,1
	jmp SKIP

	WRONG:
	mov eax,0

	SKIP:
	ret
IsEditable ENDP

main PROC
	
	;Fetch Sudoku Boards
	call GetDifficulty
	call GetBoards

	;Print Sudoku board
	mov Edx,offset board
	call PrintArray 
	
	mov ecx,10
	GamePlay:
	call takeinput
	call iseditable
	call checkanswer
	call editcell
	mWrite "New sudoko iss "
	loop GamePlay






	exit
main ENDP

END main