
INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE=5000

;islam : getValue,editCell
;ahmad : getBoards,checkIndex,checkAnswer,IsEditable,LoadLastGame
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
remainingCellsCount Byte ?

;Bool indicating if current game is continuation of last game
lastGameLoaded Byte ?

buffer BYTE BUFFER_SIZE DUP(?)
fileHandle HANDLE ?

difficulty Byte ?	;1 Easy, 2 Medium, 3 Hard

;Data files paths
fileName Byte "sudoku_boards/diff_?_?.txt",0
solvedFileName Byte "sudoku_boards/diff_?_?_solved.txt",0

lastGameFile Byte "sudoku_boards/last_game/board.txt",0
lastGameSolvedFile Byte "sudoku_boards/last_game/board_solved.txt",0


.code

;Reads the array from the file
;param: Esi offset of the array to be filled
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



;Checks if the answer in the given index is correct
;Params: x, y, num
;Returns: 1 in Eax if true, and 0 otherwise
CheckAnswer PROC
	;Getting the answer value in AL
	mov Edx,offset solvedBoard
	call GetValue

	;Moving the value to check to BL
	mov bl,num

	;Comparing the given value with the answer
	cmp bl,al
	je RIGHT
	jmp WRONG

	RIGHT:
	mov Eax,1
	ret

	WRONG:
	mov Eax,0

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
	;Customizing fileName string variables with random choice and difficulty
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

;Updates cell's value in co-ordinate (x,y)
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
		Dec remainingCellsCount
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



;Update number of remaining cells
UpdateRemainingCellsCount PROC
	PUSH Edx
	PUSH Ecx
		Mov remainingCellsCount, 0
		Mov Edx, offset Board
		Mov Ecx, 81
		L1:
			Mov Al, [Edx]
			CMP Al, 0
			JNE skip
				inc remainingCellsCount
			skip:
				inc Edx
		Loop L1
	POP Ecx
	POP Edx
	ret
UpdateRemainingCellsCount ENDP


;Doesn't take parameters
;Fills board var with boards from last played game
LoadLastGame PROC
	mov Esi,offset board
	mov Ebx,offset lastGameFile
	call ReadArray

	mov Esi,offset solvedBoard
	mov Ebx,offset lastGameSolvedFile
	call ReadArray

	mov lastGameLoaded,1

	ret
LoadLastGame ENDP


;Takes: EDX offset of array to write to file
;Takes: EBX offset of file name string
;Writes given array to file with given string as name
WriteBoardToFile PROC


	ret
WriteBoardToFile ENDP



main PROC
	
	mWrite "*** Welcome to Sudoku Game built with Assembly ***"
	call crlf
	call crlf

	;Ask user to continue last played game
	mWrite "Do you want to continue the last game ?"
	call crlf
	mWrite "Enter Y if Yes or N if No"
	call crlf
	call ReadChar

	cmp Al,'Y'
	je RunLastGame
	jmp StartGame

	;Loading last game boards from file
	RunLastGame:
		call LoadLastGame
		jmp PrintBoard

	StartGame:
	;Fetch Sudoku Boards from files depending on chosen difficulty
	call GetDifficulty
	call GetBoards

	PrintBoard:
	;Print Sudoku board
	mov Edx,offset board
	call PrintArray 
	
	;Put number of empty cells in the board in remainingCellsCount var
	call UpdateRemainingCellsCount
	Movzx Eax, remainingCellsCount


	GamePlay:
		;Prompt user for input
		call TakeInput
		call IsEditable
		call EditCell

		;Finish game if no empty cells remaining
		CMP remainingCellsCount, 0
		JE Finish

		;Print updated board
		call clrscr
		PrintUpdatedBoard:
			mWrite "New Sudoko Board"
			call crlf
			mov Edx,offset board
			call PrintArray

		mWrite "Press A to add a new cell"
		call crlf
		mWrite "Press C to reset the current board"
		call crlf
		mWrite "Press E to exit and save current board"
		call crlf
		call ReadChar

		cmp AL,'E'
		je SaveBoard
		cmp Al,'C'
		je ResetBoard
		jmp GamePlay

		;Saving current board if user choses exit
		SaveBoard:
			mov Edx,offset board
			mov Ebx,offset lastGameFile
			call WriteBoardToFile

			mov Edx,offset solvedBoard
			mov Ebx,offset lastGameSolvedFile
			call WriteBoardToFile
			exit

		;Rreset current board to initial state
		ResetBoard:
			cmp lastGameLoaded,1
			je CantReset

			;Calling ReadArray with required params to populate board var
			mov esi,offset board
			mov ebx,offset fileName
			call ReadArray

			;Calling ReadArray with required params to populate solvedBoard var
			mov esi,offset solvedBoard
			mov ebx,offset solvedFileName
			call ReadArray

			call clrscr
			mWrite "Your Game Was Reset!"
			call crlf
			jmp PrintUpdatedBoard

			CantReset:
				mWrite "You can't reset a continued game"
				call crlf
				jmp GamePlay

	Finish:
		call clrscr
		mWrite "Congratulations"
		call crlf

	exit
main ENDP

END main