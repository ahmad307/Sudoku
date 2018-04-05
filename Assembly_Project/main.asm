INCLUDE Irvine32.inc

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

.code

;Read the array from the file
;param Edx offset of the array
;param Ebx offset of string file name
ReadArray PROC

	ret
ReadArray ENDP

;Check index not out of range
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
	
	ret
GetValue ENDP

;Return sudoko Board
;param Difficulty (Easy, Medium, Hard)
GetBoard PROC

	ret
GetBoard ENDP

;param Edx offset of array
PrintArray PROC

	ret
PrintArray ENDP

;Update Global varialble x, y, num
TakeInput PROC

	ret
TakeInput ENDP

;Update Global variable Difficulty 
GetDifficulty PROC

	ret
GetDifficulty ENDP

;Update cell
;param x
;param y
;param num
EditCell PROC

	ret
EditCell ENDP

main PROC
	
    call dumpregs

	exit
main ENDP

END main