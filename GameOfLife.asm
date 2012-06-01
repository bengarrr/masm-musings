INCLUDE Irvine32.inc

.data

genNumber DWORD ?				;number of generations to iterate
posX DWORD ?
posY DWORD ?
amountNeighbors DWORD ?

board BYTE 1024 DUP (?)			;board[32][32]; 32x32 = 1024
tempBoard BYTE 1024 DUP (?)

startGameMsg BYTE "How many Generations would you like to see?:", 0
boardLimit BYTE "--------------------------------------------------", 0

.code 
main PROC
mov edx, offset startGameMsg
call WriteString
call ReadInt
call Crlf

mov ecx, eax
call RandomizeBoard

;call DrawBoard					;debuging call

GameLoop:
	push ecx
	call UpdateBoard
	call DrawBoard
	pop ecx
	loop GameLoop

exit
main ENDP

RandomizeBoard PROC uses eax ebx ecx esi
call Randomize
mov ecx, LENGTHOF board
mov esi, OFFSET board

L1:
mov eax, 255
call RandomRange
inc eax

mov bl, 2
div bl
add ah, 254

mov [esi], ah
inc esi
dec ecx
cmp ecx, 0
jne L1	

ret
RandomizeBoard ENDP

DrawBoard PROC uses esi ecx eax
call Clrscr
mov ecx, 32
mov esi, OFFSET board
mov edx, OFFSET boardLimit 
call WriteString
call Crlf
ROW:
	push ecx
	mov ecx, 32

COL:
	mov al, [esi]
	call WriteChar
	inc esi
	dec ecx
	cmp ecx, 0
	jne COL				;create new column
	pop ecx
	call Crlf
	dec ecx
	cmp ecx, 0
	jne ROW				;create new row
	call Writestring
	call Crlf
ret
DrawBoard ENDP

UpdateBoard PROC uses esi edi
mov ecx, 32
mov posY, 0
mov edi, OFFSET board-1
mov esi, OFFSET tempBoard-1

ROW:
	mov posX, 0				;a new row has been started, intialize the posX counter to 0
	push ecx
	mov ecx, 32

COL:
	inc esi						;board[i], i++
	inc edi						;tempBoard[i], i++
	mov amountNeighbors, 0	;reset the amount of neighbors count for the new cell check

	cmp posX, 31			;check for righthand-boundary
	je NoRight				;jmp to NoRight since there are no neighbors right of the cell
	
	cmp posX, 0				;check for lefthand-boundary
	je NoLeft

	jmp Center				;else jump center

	NoRight:
		call NoRight_s		;call sub
		jmp Finished

	NoLeft:
		call NoLeft_s		;call sub
		jmp Finished

	Center:
		call Center_s		;call sub
		jmp Finished

	Finished:
	cmp BYTE PTR [edi], 254		;board[x][y] == populated?
	je Living

	cmp amountNeighbors, 3		;if board[x][y] == unpopulated && amountNeighbors < 3; then makeDead
	jne MakeDead
	jmp MakeLiving
	
	Living:						;apply rules based on if a cell is populated
		cmp amountNeighbors, 1		
		jle MakeDead

		cmp amountNeighbors, 4
		jge MakeDead

		cmp amountNeighbors, 2
		je  MakeLiving

		cmp amountNeighBors, 3
		je	MakeLiving

	MakeLiving:	
		mov ah, 254					;if amountNeighbors == 2..3; then tempBoard[x][y] = populated
		mov [esi], ah
		jmp Ending

	MakeDead:
		mov ah, 255
		mov [esi], ah		;tempBoard[x][y] = dead
		jmp Ending

	Ending:
		inc posX					;posX++
		dec ecx
		cmp ecx, 0
		jne COL
		pop ecx
		inc posY					;posY++
		dec ecx
		cmp ecx, 0
		jne ROW

		mov ecx, 1024
		std
		rep movsb					;tempBoard[x][y]-->board[x][y]
		call Crlf
ret

UpdateBoard  ENDP

NoRight_s PROC
	cmp posY, 0
	je NoRightTop
	
	cmp posY, 32
	je NoRightBottom

	check1:
	cmp BYTE PTR [edi-1], 254		;board[x-1][y] == populated?
	jne check2
	inc amountNeighbors				;board[x-1][y] == populated, neighbors++

	check2:
	cmp BYTE PTR [edi-32], 254		;board[x][y-1]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi-33], 254		;board[x-1][y-1]
	jne check4
	inc amountNeighbors

	check4:
	cmp BYTE PTR [edi+31], 254		;board[x-1][y+1]
	jne check5
	inc amountNeighbors

	check5:
	cmp BYTE PTR [edi+32], 254		;board[x][y+1]
	jne done
	inc amountNeighbors
	jmp done

	NoRightTop:
		call NoRightTop_s
		jmp done

	NoRightBottom:
		call NoRightBottom_s
		jmp done

	done:
	ret
NoRight_s ENDP

NoRightTop_s PROC
check1:
	cmp BYTE PTR [edi-1], 254			;board[x-1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi+31], 254			;board[x-1][y+1]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi+32], 254			;board[x][y+1]
	jne done
	inc amountNeighbors

	done:
	ret
NoRightTop_s ENDP

NoRightBottom_s PROC
	check1:
	cmp BYTE PTR [edi-1], 254			;board[x-1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi-32], 254			;board[x][y-1]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi-33], 254			;board[x-1][y-1]
	jne done
	inc amountNeighbors

	done:
	ret
NoRightBottom_s ENDP

NoLeft_s PROC
	cmp posY, 0
	je NoLeftTop

	cmp posY, 32
	je NoLeftBottom

	check1:
	cmp BYTE PTR [edi+1], 254			;board[x+1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi-31], 254			;board[x+1][y-1]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi-32], 254			;board[x][y-1]
	jne check4
	inc amountNeighbors

	check4:
	cmp BYTE PTR [edi+32], 254			;board[x][y+1]
	jne check5
	inc amountNeighbors

	check5:
	cmp BYTE PTR [edi+33], 254			;board[x+1][y+1]
	jne done
	inc amountNeighbors
	jmp done

	NoLeftTop:
		call NoLeftTop_s
		jmp done

	NoLeftBottom:
		call NoLeftBottom_s
		jmp done

	done:
	ret
NoLeft_s ENDP

NoLeftTop_s PROC
	check1:
	cmp BYTE PTR [edi+1], 254			;board[x+1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi+32], 254			;board[x][y+1]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi+33], 254			;board[x+1][y+1]
	jne done
	inc amountNeighbors

	done:
	ret
NoLeftTop_s ENDP

NoLeftBottom_s PROC
	check1:
	cmp BYTE PTR [edi+1], 254			;board[x+1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi-31], 254			;board[x+1][y-1]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi-32], 254			;board[x][y-1]
	jne done
	inc amountNeighbors
	
	done:
	ret
NoLeftBottom_s ENDP

Center_s PROC
	cmp posY, 0
	je CenterTop

	cmp posY, 32
	je CenterBottom

	check1:
	cmp BYTE PTR [edi+1], 254			;board[x+1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi-1], 254			;board[x-1][y]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi+31], 254			;board[x-1][y+1]
	jne check4
	inc amountNeighbors

	check4:
	cmp BYTE PTR [edi-31], 254			;board[x+1][y-1]
	jne check5
	inc amountNeighbors

	check5:
	cmp BYTE PTR [edi+32], 254			;board[x][y+1]
	jne check6
	inc amountNeighbors
	jmp done

	check6:
	cmp BYTE PTR [edi-32], 254			;board[x][y-1]
	jne check7
	inc amountNeighbors

	check7:
	cmp BYTE PTR [edi+33], 254			;board[x+1][y+1]
	jne check8
	inc amountNeighbors

	check8:
	cmp BYTE PTR [edi-33], 254			;board[x-1][y-1]
	jne done
	inc amountNeighbors
	jmp done

	CenterTop:
		call CenterTop_s
		jmp done

	CenterBottom:
		call CenterBottom_s
		jmp done

	done:
	ret
Center_s ENDP

CenterTop_s PROC
	check1:
	cmp BYTE PTR [edi+1], 254			;board[x+1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi-1], 254			;board[x-1][y]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi+31], 254			;board[x-1][y+1]
	jne check4
	inc amountNeighbors

	check4:
	cmp BYTE PTR [edi+32], 254			;board[x][y+1]
	jne check5	
	inc amountNeighbors

	check5:
	cmp BYTE PTR [edi+33], 254			;board[x+1][y+1]
	jne done
	inc amountNeighbors
	
	done:
	ret
CenterTop_s ENDP

CenterBottom_s PROC
	check1:
	cmp BYTE PTR [edi+1], 254			;board[x+1][y]
	jne check2
	inc amountNeighbors

	check2:
	cmp BYTE PTR [edi-1], 254			;board[x-1][y]
	jne check3
	inc amountNeighbors

	check3:
	cmp BYTE PTR [edi-31], 254			;board[x+1][y-1]
	jne check4
	inc amountNeighbors

	check4:
	cmp BYTE PTR [edi-32], 254			;board[x][y-1]
	jne check5
	inc amountNeighbors

	check5:
	cmp BYTE PTR [edi-33], 254			;board[x-1][y-1]
	jne done
	inc amountNeighbors
	
	done:
	ret
CenterBottom_s ENDP

END main