call clearScreen ; Calls the clear function
[org 0x7c00] ; Set origin of the memory address
mov ah, 0x0e ; 

mov si, welcome ; Set the welcome string to be displayed
call print_string ; Prints the welcome string to the screen

mainloop:
    mov si, prompt ; Gets the prmopt string or aka ">" to the screen
    call print_string ; Prints the prmopt string to the screen

    mov di, buffer ; Waits for sometime
    call get_string ; Gets the users string

    mov si, buffer ; Waits for sometime
    cmp byte [si], 0  ; Is the user prompt blank line?
    je mainloop       ; yes, ignore it

    mov si, buffer ; Waits for sometime
    mov di, cmd_help  ; Get's the value of the cmd_help string in this case it is 'help'
    call strcmp ; Calls the string compare function to compare if the users input and the cmd_help string are equal
    jc .help ; If yes then run the help function

    mov si, buffer ; Waits for sometime
    mov di, cmd_clear ; Get's the value of the cmd_clear string in this case it is 'clear'
    call strcmp ; Calls the string compare function to compare if the users input and the cmd_clear string are equal
    call clearScreen ; If yes then clear's the screen

    mov si, buffer ; Waits for sometime
    mov di, cmd_shutdown ; Get's the value of the cmd_clear string in this case it is 'clear'
    call strcmp ; Calls the string compare function to compare if the users input and the cmd_shutdown string are equal
    call shutdown ; If yes then run then shuts down

    mov si, badcommand ; Gets the badcommand string if none of the above functions equals
    call print_string ; Prints the badcommand string
    jmp mainloop ; loops back to the main loop

    .help:
        mov si, msg_help ; gets the msg_help string
        call print_string ; Prints the msg_help string
        je mainloop ; loops back to the main loop


jmp mainloop ; loops back to the main loop

; Library of string to print and compare
welcome db ' Welcome to DOS But Bettter!', 0x0D, 0x0A, ' Type "help" to show commands!', 0x0D, 0x0A, 0 ; Holds the welcome string in "welcome"
badcommand db 'Invalid command!', 0x0D, 0x0A, 0 ; When it's an invalid command
prompt db 0x0D, 0x0A, ' > ', 0 ; The prompt string which is always printed
cmd_clear db 'clear', 0 ; Clear String
cmd_help db 'help', 0 ; Help String
cmd_shutdown db 'shutdown', 0, ; Shutdown String
msg_help db ' Commands: clear, shutdown', 0x0D, 0x0A, 0 ; Help Message string
buffer times 64 db 0 ; Wait

; To set the cursor poition
setCursor:
    pusha
    mov ah, 0x02 ; '0x02' means about to set cursor and about to print smthing to the screen, '0x0e' means about to print
    mov bh, 0 ; Set the video page (needs to be zero for graphical mode)
    int 0x10  ; call BIOS video interrupt
    popa
    ret

; To clear the screen
clearScreen:
    pusha
    mov ax, 0x700 ; function 07, AL=0 where the function scroll the whole windows
    mov bh, 0x07 ; character atrribute to make text white on black
    mov cx, 0x0000  ; row = 0, col = 0
    mov dx, 0x184f  ; row = 24 (0x18), col = 79 (0x4f)
    int 0x10        ; call BIOS video interrupt
    mov dx, 0x0000  ; Set <ds> and <dx> to the row and column to set the cursor to
    call setCursor ; Call the subroutine to actually change the cursor location
    popa
    ret

; To shutdown the application
shutdown: 
    mov ax, ss ; Set the segment register to the stack segment
    mov sp, 0xf000 ; Set the stack pointer to the top of the stack
    mov ax, 0x5307 ; Function 53, AL=7 to shutdown the computer
    mov bx, 0x0001 ; BX=1 to shutdown the computer
    mov cx, 0x0003 ; CX=3 to shutdown the computer
    int 0x15 ; Call the BIOS interrupt

print_string:
   lodsb        ; grab a byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, get out
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character!
 
   jmp print_string ; and loop back to the top
 
 .done:
   ret ; return
 
 get_string:
   xor cl, cl ; grabs the string inputed by the user
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl ; increment character count
   jmp .loop ; loop back to the top
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E ; print out a space
   mov al, 0x08 ; to overwrite the character
   int 10h		; backspace on the screen
 
   mov al, ' ' ; print out a space
   int 10h		; blank character out
 
   mov al, 0x08 
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; null terminator
   stosb 
 
   mov ah, 0x0E 
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret ; return

 
 strcmp:
    .loop:
    mov al, [si]   ; grab a byte from SI
    mov bl, [di]   ; grab a byte from DI
    cmp al, bl     ; are they equal?
    jne .notequal  ; nope, we're done.
    
    cmp al, 0  ; are both bytes (they were equal before) null?
    je .done   ; yes, we're done.
    
    inc di     ; increment DI
    inc si     ; increment SI
    jmp .loop  ; loop!
    
    .notequal:
    clc  ; not equal, clear the carry flag
    ret ; return
    
    .done: 	
    stc  ; equal, set the carry flag
    ret ; return


; End of the program, Rest is default value
times 510-($-$$) db 0
db 0x55, 0xaa

