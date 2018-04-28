
INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE=5000

;islam : getValue,editCell
;ahmad : getBoards,checkIndex,checkAnswer,IsEditable,LoadLastGame
;Hadil : readArray,takeInput
;Raamyy: getDifficulty,printArr,WriteBoard

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

buffer Byte BUFFER_SIZE DUP(?)
fileHandle HANDLE ?

difficulty Byte ?	;1 Easy, 2 Medium, 3 Hard

;Data files paths
fileName Byte "sudoku_boards/diff_?_?.txt",0
solvedFileName Byte "sudoku_boards/diff_?_?_solved.txt",0

lastGameFile Byte "sudoku_boards/last_game/board.txt",0
lastGameSolvedFile Byte "sudoku_boards/last_game/board_solved.txt",0


;Variables for writing in array
str1 BYTE "Cannot create file",0dh,0ah,0  
newline byte 0Dh,0Ah

.code
;----------------------ReadArray-----------------------------
;Reads the array from the file.					     		|
;param: ESI offset of the array to be filled,				|
;param: EBX offset of string file name.						|
;Returns: Array read from file in EDX.						|
;------------------------------------------------------------
ReadArray PROC
		;Setting ECX with the max string size
	mov ecx,34

	;Open the file for input
	mov edx,ebx
	call OpenInputFile
	mov fileHandle, eax

	;Check for reading from file errors
	cmp eax, INVALID_HANDLE_VALUE	
	jne FileHandleIsOk	
	mWrite <"Cannot open file", 0dh, 0ah>
	jmp quit

	FileHandleIsOk :
		; Read the file into a buffer
		mov edx, OFFSET buffer
		mov ecx, BUFFER_SIZE
		call ReadFromFile
		jnc CheckBufferSize	;if carry flag =0 then size of the buffer is ok
		mWrite "Error reading file. "	
		call WriteWindowsMsg
		jmp CloseFilee

	CheckBufferSize	 :
		;Check if buffer is large enough
		cmp eax, BUFFER_SIZE	
		jb BufferSizeOk
		mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
		jmp quit

BufferSizeOk :
		;Insert null terminator
		mov buffer[eax], 0

	mov ebx, OFFSET buffer
	mov ecx, 97
	;store the offset of the array in edx to reuse it
	mov edx,esi

	StoreContentInTheArray :
		  mov al, [ebx]
		  inc ebx
		  cmp al, 13
		  je SkipBecOfEndl
		  cmp al, 10
		  je SkipBecOfEndl
		  mov [esi], al
		  inc esi
		 SkipBecOfEndl : 
	loop StoreContentInTheArray


	mov esi, edx
	;store the offset of the array in edx to reuse it
	
	mov ecx, 81
   ConvertFromCharToInt:
		  sub byte ptr[esi],48
	      inc esi 
	loop ConvertFromCharToInt

	;Return the offset of the filled array in esi
	 mov esi, edx

CloseFilee :
	mov eax, fileHandle
	call CloseFile

	quit :
	ret
ReadArray ENDP



;----------------------CheckIndex----------------------------
;Checks if index out of range / not reserved				|
;param: xCor,yCor,num (var)									|
;Returns: EAX 0, 1											|
;------------------------------------------------------------
CheckIndex PROC
	;Checking xCor lies between 1 and 9
	CMP xCor,9
	ja WRONG
	CMP xCor,1
	jb WRONG

	;Checking yCor lies between 1 and 9
	CMP YCor,9
	ja WRONG
	CMP YCor,1
	jb WRONG

	;Checking num lies between 1 and 9
	CMP num,9
	ja WRONG
	CMP num,1
	jb WRONG

	JMP RIGHT

	WRONG:
		MOV EAX,0
		ret
	RIGHT:
		MOV EAX,1
		ret
CheckIndex ENDP



;----------------------CheckAnswer---------------------------
;Checks if the answer in the given index is correct			|
;Param: x, y, num											|
;Returns: 1 in EAX if true, and 0 otherwise					|
;------------------------------------------------------------
CheckAnswer PROC
	;Getting the answer value in AL
	MOV EDX,offset solvedBoard
	CALL GetValue

	;MOVing the value to check to BL
	MOV bl,num

	;Comparing the given value with the answer
	CMP bl,al
	JE RIGHT
	JMP WRONG

	RIGHT:
	MOV EAX,1
	ret

	WRONG:
	MOV EAX,0

	ret
CheckAnswer ENDP




;----------------------GetValue------------------------------
;Returns the value in the given index						|
;Param: EDX pointer to the array							|
;Param: x													|
;Param: y													|
;Return: EAX = value										|
;------------------------------------------------------------
GetValue PROC
	CALL CheckIndex
	PUSH ECX
	PUSH EDX
	CMP EAX, 1
	JE Body
		MOV EAX, -1
		POP EDX
		POP ECX
		ret
	Body:
		DEC xCor
		DEC yCor
		MOV EAX, 9
		MOVzx ECX, xCor
		Mul ECX
		MOVzx ECX, yCor
		Add EAX, ECX
		POP EDX
		PUSH EDX
		Add EDX, EAX
		MOV EAX, 0
		MOV al, [EDX]
		INC xCor
		INC yCor
	POP ECX
	POP EDX
	ret
GetValue ENDP



;----------------------GetBoards----------------------------
;Fills board,solvedBoards variables with data read from	   |
;	file depending on given difficulty and a generated	   |
;	random number.										   |	
;Param:   Difficulty (global var)						   |
;Returns: Desired board in board variable				   |
;-----------------------------------------------------------
GetBoards PROC
	;Generating random value from AX and CX
	xor AX,CX

	;Getting the value modulu 3
	MOV dx,0
	MOV BX,4
	div BX		;DX carries a random value less than 4

	;Setting value to 1 if it's 0
	CMP dx,0
	JE ZeroDX
	JMP cont

	ZeroDX:
	MOV dx,1

	cont:
	;Customizing fileName string variables with random choice and difficulty
	MOV al,dl
	add al,'0'
	MOV fileName[21],al

	MOV al,difficulty
	add al,'0'
	MOV fileName[19],al

	MOV al,dl
	add al,'0'
	MOV solvedFileName[21],al

	MOV al,difficulty
	add al,'0'
	MOV solvedFileName[19],al

	;Calling ReadArray with required params to populate board var
	MOV ESI,offset board
	MOV EBX,offset fileName
	CALL ReadArray

	;Calling ReadArray with required params to populate solvedBoard var
	MOV ESI,offset solvedBoard
	MOV EBX,offset solvedFileName
	CALL ReadArray

	ret
GetBoards ENDP



;----------------------PrintArray----------------------------
;Prints the array to the console screen.					|
;Param: EDX offset of array									|
;------------------------------------------------------------
PrintArray PROC
	PUSH EDX ;will be popped after finishing the function 
	MOV ECX,81
	l1:
		MOV EAX,0
		MOVzx EAX,byte ptr [EDX]  ;EAX contains current number
		PUSH EAX
		PUSH EDX

		MOV dx,0
		MOV AX,CX     ;dx = CX % 9
 		MOV BX,9
		div BX

		CMP dx,0
		JNE NoEndl	  ;if dx % 9 = 0 print endl
		CALL crlf

		NoEndl:
		POP EDX
		POP EAX

		CALL writeDec
		INC EDX
	loop l1

	CALL crlf
	POP EDX
	ret
PrintArray ENDP



;----------------------TakeInput-----------------------------
;Prompts user to enter a cells value.						|
;Does not take parameters.									|
;Updates: x, y, num global variables.						|
;------------------------------------------------------------
TakeInput PROC

	again:

	mWrite "Enter the x coordinate :  " 
	CALL ReadDec
	MOV xCor,AL

	mWrite "Enter the y coordinate :  " 
	CALL ReadDec
	MOV yCor,AL

	mWrite "Enter the number :  " 
	CALL ReadDec
	MOV num,AL

	CALL CheckIndex
	CMP EAX ,1
	JE done

	mWrite "There is an error in your input values... Please reEnter them. " 
	CALL crlf
	JMP again

	done:

	CALL iseditable
	CMP EAX,1
	JE Editable

	mWrite "You Cannot edit this place, Please change it."
	CALL crlf
	JMP again

	Editable:
	mWrite "Edited"
	CALL crlf
	ret
TakeInput ENDP



;----------------------GetDifficulty-------------------------
;Prompts the user to enter desired game difficulty.			|
;Does not take parameters.									|
;Updates: Difficulty global variable.						|
;------------------------------------------------------------
GetDifficulty PROC
	
	again:
	mWrite "Please Enter the difficulty: "
	CALL crlf

	;Checks if the difficulty is 1 or 2 or 3
	CALL ReadDec
	CMP AL,1
	JE NoError
	CMP AL,2
	JE NoError
	CMP AL,3
	JE NoError

	mWrite "Please enter a valid difficulty ( 1 or 2 or 3 ) "
	CALL crlf
	JMP again ;Re Enter difficulty if it was wrong

	NoError:
	MOV difficulty,AL ;take the byte from EAX which will be 1 or 2 or 3
	
	ret
GetDifficulty ENDP



;----------------------EditCell------------------------------
;Updates cell's value at co-ordinate (x,y).					|
;Params: x, y, num (global variables).						|
;Updates:  Cell value at co-ordinate (x,y).					|
;------------------------------------------------------------
EditCell PROC
	PUSH EDX
	PUSH ECX
	CALL CheckIndex
	CMP EAX, 0
	JE Ending
		CALL CheckAnswer
		CMP EAX, 0
	JE Ending
		DEC xCor
		DEC yCor
		MOV EAX, 9
		MOVzx ECX, xCor
		Mul ECX
		MOVzx ECX, yCor
		Add EAX, ECX
		MOV EDX, offset board
		Add EDX, EAX
		MOV AL, num
		MOV [EDX], AL
		INC xCor
		INC yCor
		DEC remainingCellsCount
	Ending:
		POP ECX
		POP EDX
		ret
EditCell ENDP



;----------------------IsEditable----------------------------
;Checks if cell at x,y (global vars) in board is editable.	 |
;Does not take parameters.									 |
;Returns: 1 in EAX if the place is editable and 0 otherwise. |
;------------------------------------------------------------
IsEditable PROC
	MOV EDX,offset board
	CALL GetValue

	;Checking value returned from GetValue
	CMP EAX,0
	JE RIGHT
	JMP WRONG

	RIGHT:
	MOV EAX,1
	JMP SKIP

	WRONG:
	MOV EAX,0

	SKIP:
	ret
IsEditable ENDP



;----------------UpdateRemainingCellsCount------------------
;Counts the number of unchanged cells in the board.		   |
;Param: Board (global variable).						   |
;Update: remainingCellsCount global variable.			   |
;-----------------------------------------------------------
UpdateRemainingCellsCount PROC
	PUSH EDX
	PUSH ECX
		MOV remainingCellsCount, 0
		MOV EDX, offset Board
		MOV ECX, 81
		L1:
			MOV Al, [EDX]
			CMP Al, 0
			JNE skip
				INC remainingCellsCount
			skip:
				INC EDX
		Loop L1
	POP ECX
	POP EDX
	ret
UpdateRemainingCellsCount ENDP



;----------------------LoadLastGame--------------------------
;Fills board variable with last played game boards.			|
;Does not take parametrs.									|
;------------------------------------------------------------
LoadLastGame PROC
	MOV ESI,offset board
	MOV EBX,offset lastGameFile
	CALL ReadArray

	MOV ESI,offset solvedBoard
	MOV EBX,offset lastGameSolvedFile
	CALL ReadArray

	MOV lastGameLoaded,1

	ret
LoadLastGame ENDP



;----------------------WARNING !-----------------------------
;  This function changes the values of the board variable.  |
;  So it must be CALLed only in the end of the program !    |
;------------------------------------------------------------

;-------------------WriteBoardToFile-------------------------
;Writes given array to file with given string as name.		|
;Param: EDX offset of array to write to file.				|	
;Param: EBX offset of file name string.						|
;------------------------------------------------------------
WriteBoardToFile PROC

	PUSH EDX
	;Convert all Numbers of the array to chars to be written in the file
	 MOV ECX,81		 ; MOVe number of board elements to ECX
	 loo:
	 MOV EAX,48
	 add [EDX],al
	 INC EDX
	 loop loo

	; Create a new text file and error check.
	 MOV EDX,EBX	;MOVe file name offset to EDX for CreatOutputFile
	 CALL CreateOutputFile
	 MOV fileHandle,EAX
	 ; Check for errors.
	 CMP EAX, INVALID_HANDLE_VALUE 
	 ; error found? 
	 JNE file_ok	; no: skip
	 MOV EDX,OFFSET str1
	 ; display error 
	 CALL WriteString
	 JMP quit 
	 file_ok:  

;Writing in the file
   POP EDX		;address of the array to be typed
   MOV ECX,81	;Length of array

   l5:
	   ;write charachter in the file
	   MOV EAX,fileHandle
	   PUSH EDX		 ;Push current character address
	   PUSH ECX		 ;Push the loop iterator
	   MOV ECX,1
	   CALL WriteToFile
	   POP ECX

	   ;check if a new line should be printed or not
			MOV dx,0
			DEC ECX
			MOV AX,CX     ;dx = CX-1 % 9
 			MOV BX,9
			div BX

			CMP dx,0 ; if not div by 9 , then no newline required.
			JNE noEndl

			PUSH ECX
			 MOV EAX,fileHandle
			 MOV ECX,lengthof newline
			 MOV EDX,offset newline
			 CALL WriteToFile
			POP ECX
	
		noEndl:
	   INC ECX  ;as it was decremented above for calculating modulus
	   POP EDX  ;return the address of the read char
	   INC EDX  ;staging for writing next char
   loop l5

   quit:
   
	ret
WriteBoardToFile ENDP



main PROC
	
	mWrite "*** Welcome to Sudoku Game built with Assembly ***"
	CALL crlf
	CALL crlf

	;Ask user to continue last played game
	mWrite "Do you want to continue the last game ?"
	CALL crlf
	mWrite "Enter Y if Yes or N if No"
	CALL crlf
	CALL ReadChar

	CMP Al,'Y'
	JE RunLastGame
	JMP StartGame

	;Loading last game boards from file
	RunLastGame:
		CALL LoadLastGame
		JMP PrintBoard

	StartGame:
	;Fetch Sudoku Boards from files depending on chosen difficulty
	CALL GetDifficulty
	CALL GetBoards

	PrintBoard:
	;Print Sudoku board
	MOV EDX,offset board
	CALL PrintArray 
	
	;Put number of empty cells in the board in remainingCellsCount var
	CALL UpdateRemainingCellsCount
	MOVzx EAX, remainingCellsCount


	GamePlay:
		;Prompt user for input
		CALL TakeInput
		CALL IsEditable
		CALL EditCell

		;Finish game if no empty cells remaining
		CMP remainingCellsCount, 0
		JE Finish

		;Print updated board
		CALL clrscr
		PrintUpdatedBoard:
			mWrite "New Sudoko Board"
			CALL crlf
			MOV EDX,offset board
			CALL PrintArray

		mWrite "Press A to add a new cell"
		CALL crlf
		mWrite "Press C to reset the current board"
		CALL crlf
		mWrite "Press E to exit and save current board"
		CALL crlf
		CALL ReadChar

		CMP AL,'E'
		JE SaveBoard
		CMP Al,'C'
		JE ResetBoard
		JMP GamePlay

		;Saving current board if user choses exit
		SaveBoard:
			MOV EDX,offset board
			MOV EBX,offset lastGameFile
			CALL WriteBoardToFile

			MOV EDX,offset solvedBoard
			MOV EBX,offset lastGameSolvedFile
			CALL WriteBoardToFile

			CALL crlf
			mwrite " ** Your Board was saved succssfully ! **"
			CALL crlf
			mwrite " ** Thanks for Playing **"
			CALL crlf
			exit

		;Rreset current board to initial state
		ResetBoard:
			CMP lastGameLoaded,1
			JE CantReset

			;calling ReadArray with required params to populate board var
			MOV ESI,offset board
			MOV EBX,offset fileName
			CALL ReadArray

			;Calling ReadArray with required params to populate solvedBoard var
			MOV ESI,offset solvedBoard
			MOV EBX,offset solvedFileName
			CALL ReadArray

			CALL clrscr
			mWrite "Your Game Was Reset!"
			CALL crlf
			JMP PrintUpdatedBoard

			CantReset:
				mWrite "You can't reset a continued game"
				CALL crlf
				JMP GamePlay

	Finish:
		CALL clrscr
		mWrite "Congratulations"
		CALL crlf

	exit
main ENDP

END main