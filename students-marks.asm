org 100h

jmp initalize
msg1 db "Please enter the number of students in the class: $"
msg2 db "Please enter suitable number in range of[1-30]$"
msg3 db "Mark of student number $"
msg4 db "Total grade of student number $"
msg4c db ": $"
msg5 db "The average grade in the class is: $"
gradearr db 3 dup(?)
markarr db 30 dup(?)
count db 1


initalize:
	   mov count, 1        ; set counter to 1 in every time you start a new class.                                  
	   mov ax, 0           ; set ax = 0  as we will use it in interrupt.
	   mov cx, 0           ; set cx = 0 as we will use it to store the input of students number.
	   mov si, 30          ; set si = 30 the total number of students.
	   mov bh, 13          ; set bh = 13 for checking from you have pressed Enter.
       mov dx, offset msg1 ; outputting the message 1.
       mov ah, 9           ; set ah = 9 to output the string.
       int 21h

getRange:
       mov ah, 1     ; set ah = 1 to take input from the user and the input storing in al.
       int 21h
       cmp al, bh    ; check if the input is Enter.
       je checkRange ; if al = 13 that is meaning you have pressed Enter and jump to checkRange.
       sub al, 30h   ; otherwise subtract 30h from the input to get the integer number not charachter.
       mov ah, 0     ; set ah = 0 because we will move ax register 16bit to di register 16bit.
       mov di, ax    ; di storing the new value.
       mov al, 10    ; store 10 in al to use it for multiply. ax = al * any register
       mul cx        ; in cx we will store the old value and multiply it by 10. this is because we need to addition the old value to new value.
       mov cx, ax    ; cx takes the result of multiplying.
       add cx, di    ; addition the old value to new value. >> old value=50 new value=3 then cx = 50+3 >> cx = 53.   
       jmp getRange  ; jump to getRange to take a new digit.
       
        
checkRange:
       cmp cx, si ; compare between the students input number and the total number of students.
	   ja again   ; if the input greater than 30 jump to again.
	   cmp cx, 0  ; if is not greater check if the input = 0.
	   jz finish  ; if zero,  go to finish and the program terminated.
	   mov di, 0  ; we will use it in markarr so set it zero.
	   jmp mark   ; if you have finished from input of the number of students jump to mark. every student has 3 grades.
	   
again: ; to jump to initalize if the number of students > 30.
       call newline ; call newline  
       ; when returned, program continues from here.
	   mov dx, offset msg2
	   mov ah, 9
	   int 21h
	   
	   call newline
	   
	   jmp initalize ; jump to initalize to start again.
	   
mark:
       call newline
	   
       mov dx, offset msg3
       mov ah, 9
       int 21h
       
       call setCounter  ; counting  the student number.
       
       call newline
       mov si, 0        ; we will use it for pointing the positions of array.
       lea bx, gradearr ; move the address of grafearr to bx.
markAgain:
	   mov ah, 1        ; get input to insert the three grades of students. result is stored in al.
	   int 21h
	   
	   cmp al, 13       ; if pressed Enter > al = 13
	   je continue      ; if pressed Enter, jump to contine.
       
       mov [bx+si], al  ; if not pressed, inserting the value in al to gradearr that has address in bx and pointer to si position.
       inc si           ; increment the pointer.
       jmp markAgain    ; if you have not finished yet, jump to markAgain to input the next grade.
       
continue:
	   cmp si, 3        ; check if you have finished insert the three grades.
	   je insertMarks   ; if finished, jump to insertMarks. inserting the total grade of student = summation of max two grades.
	   call newline
	   jmp markAgain    ; if you have not finished yet, jump to markAgain to input the next grade.
	   
insertMarks:
       mov dx, 0        ; set dx = 0 i need to delete and old value to use it.
	   mov si, 0        ; set si = 0 for using it.
	   
       sort:            ; we need sorting to get the two max grades easily just point to the first and second positions.
	   cmp si, 2        ; if pointer reaches to third position si = 2.
	   je totalMark     ; if equals si == 2, jump to totalMarks.
	   
	   mov dh, [bx+si+1]  ; move the value stored in the next position in dh.
	   cmp [bx+si], dh    ; compare the current value and the next value
	   jbe continue2      ; if current <= next, jump to continue2.
	   inc si             ; otherwise current > next so increase the pointer si.
	   jmp sort           ; jump to sort again to sort again.
	   ; bubble sort
	   continue2:
	   mov dl, [bx+si]
	   mov [bx+si], dh
	   mov [bx+si+1], dl
	   inc si             ; after finishing, increase the pointer si.
	   jmp sort           ; jump to sort again to sort again.
          
          
       totalMark:         ; inserting total grade of student.
       lea bp, markarr    ; get the address of markarr in bp.
       mov dh, [bx+0]     ; move the first grade value to dh (the greatest value always in first position).
       sub dh, 30h        ; subtract 30h to get an integer number from characher. ex dh = 5.
       mov [bp+di], dh    ; move grade to the first position in markarr. [bp+di] = 5
       mov dh, [bx+1]     ; move the seconde grade value to dh (the second greatest value). ex dh = 4
       sub dh, 30h        ; subtrack also.
       add [bp+di], dh    ; add the first value with second. [bp+di] = 5+4
       mov dl, [bp+di]    ; just indication to values in markarr.
       inc di             ; increase di pointer. we noticed it in checkRange, the value of di does not change when i jumped. it holds the number of total grades.
       
	   dec cx             ; decrease the number of students (first input).
	   cmp cx, 0          ; check if i inserted all total grades for all students.
	   jnz mark           ; if does not, jump to mark to insertig the total grade for another student.               
	   
	   mov ax, 0          ; set ax = 0 to use it in output.
	   mov cx, 0          ; set ax = 0 to use it in output.
	   mov si, 0          ; set ax = 0 to use it in output.
	   mov count, 1       ; reset count to 1 again.
	          
output:   
	   call newline
	   mov dx, offset msg4
       mov ah, 9
       int 21h
       
       call setCounter
       
       mov dx, offset msg4c  ; continuing to message 4.
       mov ah, 9
       int 21h
       
	   mov ah, 0
	   
	   add cl, [bp+si]       ; cl will store the summation of all grades in markarr. we need it in average.
	   mov dl, [bp+si]       ; move the the values of markarr in dl.
	   cmp dl, 10            ; compare between the result in dl and 10. as 10 is the maximum grade.
	   je resultIsTen        ; if dl == 10, jump to resultIsTen.
	   
	   add dl, 30h           ; otherwise add 30h to get the charachter number.
	   mov ah, 2             ; outout mode.
	   int 21h
	   
	   checkFinish:          ; check all total grades of all srudents are ouputted. 
	   inc si                ; increase the pointer of markarr.
	   dec di                ; decrease di, as di represents the number of total grades of students. value of di is stored from totalMark. we use it to check if you finished from insertting all total grades.
	   
	   cmp di, 0             ; compare between di value and zero.
	   jnz output            ; if di != 0 then jump to output. output has not finished.
	   
	   call newline
	   mov dx, offset msg5   ; message of average.
	   mov ah, 9
	   int 21h
	   
	   mov ax, 0             ; as probably the last ax holds 10 so set ax = 0 for using it again.
	   mov al, cl            ; move the summation of total grades in al to use it in division. ah = 0.
	   mov bx, si            ; move the number of total grades in markarr in bx.
	   mov bh, 0             ; set bh = 0 as we need bl only.
	   div bl                ; al = summation of grades (ax) / number of grades (bl).
	   	                      
	   cmp al, 10            
	   je Ten                ; jump to Ten if average al == 10.
	   mov dl, al            ; otherwise move al value to dl. al < 10.
	   add dl, 30h           ; get the charachter number.
	   mov ah, 2             ; output mode.
	   int 21h
	   call newline
	   call newline
	   jmp initalize         ; the program has finished, jump to creat a new class.
	   
	   Ten:                  ; output 10 as like max grade when it equals 10.
	   mov dl, 10
	   div dl                ; al = 1 and ah = 0.
	   mov dl, al
	   mov dh, ah
	   
	   add dl, 30h
	   mov ah, 2
	   int 21h
	   
	   mov dl, dh
	   add dl, 30h
	   int 21h
	      
	   call newline
	   call newline
	   jmp initalize         ; the program has finished, jump to creat a new class.
	   
	   
resultIsTen:
	   mov al, 10           ; move al=10 to use it in division.
	   div dl
	   mov dl, al           ; al now = 1.
	   mov dh, ah           ; ah now = 0 remainder.
	   
	   add dl, 30h          ; add 30h to ger the charachter number.
	   mov ah, 2
	   int 21h
	   
	   mov dl, dh           ; get the remainder.
	   add dl, 30h
	   int 21h
	   
	   jmp checkFinish      ; jump to checkFinish to check all total grades of all srudents are ouputted.
	   	   

	   	   	   
finish: ret

newline:	  
	   mov ah, 2   ; output to user
	   mov dl, 10  ; put the value which will output to the screen in dl. dl = 10 as 10 is considerd a new line from ascii. 
	   int 21h
	   mov dl, 13  ; output again but dl = 13 to set pointer in the first line.
	   int 21h
	   ret         ; return to the position of calling.

setCounter:
	   mov dl, count     ; set dl = 1
       cmp dl, 10        ; check dl and 10.
       jae newcount      ; jump if dl >= 10.
       add dl, 30h       ; otherwise add 30h to get a charachter number. 
       mov ah, 2         ; output
       int 21h
       jmp continueto    ; for ignoring newcount.
        
       newcount:         
       mov ax, 0         ; set ax = 0.
       mov al, dl        ; move the value of count to al and ah = 0 so ax use it as divisor. al = ax(divisor) / any register (dividened)
       mov bl, 10        ; bl = 10 to use it as dividened.
       
       div bl            ; example: ax = 11 and bl = 10 then al = 1 and ah = 1.
       mov dl, al        ; output the quotient. ex dl = 1
       add dl, 30h       ; get a charachter number.
       mov dh, ah        ; move the remainder to dh to continue outputting.
       mov ah, 2
       int 21h           ; output = 1
       
       mov dl, dh        ; ouput the remainder. dl = 1
       add dl, 30h
       int 21h           ; output = 11
       
       continueto:
       add count, 1      ; increment count  
       
       ret	