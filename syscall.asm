%include "syscall.inc"


SEGMENT _TEXT PUBLIC CLASS=CODE USE16
GLOBAL _system_call

_system_call:


; Set up segment registers
;
;mov sp, STACK_SEGMENT
;mov ss, sp
;mov sp, STACK_SIZE
pusha
push word SCREEN_SEGMENT
pop es

; Install syscall handler
cli
push word 0
pop ds
mov [4 * SYSCALL_INTERRUPT], word syscallHandler
mov [4 * SYSCALL_INTERRUPT + 2], cs

; Install keyboard handler
mov [4 * KEYBOARD_INTERRUPT], word keyboardHandler
mov [4 * KEYBOARD_INTERRUPT + 2], cs
push cs
pop ds
sti

; Blank screen
mov ax, SYSCALL_CLEAR_SCREEN
int SYSCALL_INTERRUPT

; Ask for login
push word loginMsg
push word loginMsg_size
mov ax, SYSCALL_PRINT_STRING
int SYSCALL_INTERRUPT
add sp, 4

; Read login
push word login
push word login_size
mov ax, SYSCALL_READ_LINE
int SYSCALL_INTERRUPT
add sp, 4

; Print login
push word login
push ax
mov ax, SYSCALL_PRINT_STRING
int SYSCALL_INTERRUPT
add sp, 4
mov ax, SYSCALL_NEWLINE
int SYSCALL_INTERRUPT

popa
ret

;;;;;;;;;;;;;
; Functions ;
;;;;;;;;;;;;;

clearScreen:
; Clear screen and reset cursor position

iret

readChar:
; Read character
; In: none
; Out: ASCII code in AL
; Global:
;	firstInput (modified)
mov bl, [cs:firstInput]
.loop0:
cmp bl, [cs:lastInput]
jne .end
hlt
jmp .loop0
.end:
xor bh, bh
mov al, [cs:inputBuffer + bx]
inc bl
and bl, 15
mov [cs:firstInput], bl
iret

readLine:
; Read line
; In:
;	buffer address (word)
;	buffer size (word)
; Out:
;	string length (ax)
push bp
mov bp, sp
mov di, [bp + 10]
push es
push ds
pop es
mov cx, [bp + 8]
.loop0:
mov ax, SYSCALL_READ_CHAR
int SYSCALL_INTERRUPT
cmp al, 13
je .end
stosb
loop .loop0
.end:
pop es
sub di, [bp + 10]
mov ax, di
pop bp
iret

printChar:
; In:
;	character (byte)
; Out: none
; Global:
;	color		The color to use
;	es		The screen segment
;	cursor_pos	The cursor position (modified)
push bp
mov bp, sp
mov al, [bp + 8]
mov ah, [cs:color]
mov di, [cs:cursor_pos]
stosw
mov [cs:cursor_pos], di
.end:
pop bp
iret

printString:
; Print string
; In:
; 	String offset (word)
;	String length (word)
; Out:
;	none
; Global:
;	color		The color to use
;	es		The screen segment
;	cursor_pos	The cursor position (modified)
push bp
mov bp, sp
mov si, [bp + 10]
mov cx, [bp + 8]
mov ah, [cs:color]
mov di, [cs:cursor_pos]
.loop0:
lodsb	; load byte from string
stosw	; store byte and color on screen
loop .loop0
mov [cs:cursor_pos], di
pop bp
iret

newline:
; Advance cursor to beginning of next line
; In: none
; Out: none
; Global:
;	cursor_pos	Cursor position (modified)

; Divide the cursor position by the number of bytes per row,
; add 1, then multiply by bytes per row
mov ax, [cs:cursor_pos]
xor dx, dx
mov cx, SCREEN_COLS * 2
div cx
inc ax
mul cx
mov [cs:cursor_pos], ax
iret

unknownSyscall:
; Return with ax set to 0 and carry flag set
popf
stc
pushf
xor ax, ax
iret

;;;;;;;;;;;;;;;;;;;;;;
; Interrupt Handlers ;
;;;;;;;;;;;;;;;;;;;;;;

;
; Dispatch system calls
;
syscallHandler:
sti
cmp ax, SYSCALL_INVALID
jb .ok
xor ax, ax	; Invoke unknown syscall handler
.ok:
mov bx, ax
shl bx, 1
jmp near [cs:syscallTable + bx]

;
; Handle keyboard events
;
keyboardHandler:
; save our registers!
pusha

; Read code
in al, 60h

; Ignore codes with high bit set
test al, 80h
jnz .end

; Read the ASCII code from the table
mov bl, al
xor bh, bh
mov al, [cs:bx + keymap]

; Ignore keys with no ASCII code
cmp al, 0
je .end

; Buffer character
mov bl, [cs:lastInput]
inc bl
and bl, 15
cmp bl, [cs:firstInput]
je .end	; buffer full, discard character
xor bh, bh
mov [cs:inputBuffer + bx - 1], al
mov [cs:lastInput], bl

.end:
; Send EOI
mov al, 61h
out 20h, al
; return
popa
iret

;;;;;;;;
; Data ;
;;;;;;;;


loginMsg db "Login: "
loginMsg_size EQU $ - loginMsg
color db 7	; White on black
cursor_pos dw 0
keymap:
%include "keymap.inc"
firstInput db 0
lastInput db 0
syscallTable:
dw unknownSyscall	; 0
dw clearScreen		; 1
dw readChar			; 2
dw readLine			; 3
dw printChar		; 4
dw printString		; 5
dw newline			; 6

;;;;;;;;;;;;;;;;;;;;;;
; Uninitialized data ;
;;;;;;;;;;;;;;;;;;;;;;


inputBuffer resb 16
login resb 16
login_size EQU $ - login