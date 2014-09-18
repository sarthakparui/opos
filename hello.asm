SEGMENT _TEXT PUBLIC CLASS=CODE USE16 
global _opos_loader

[BITS 32]

_opos_loader:
pusha
mov ah,13h
mov al, 1
mov bh, 0
mov bl, 0011_1011b
mov cx,len
push cs
pop es
mov bp,msg
mov dl,5
mov dh,5
int 10h
popa
ret
msg db 'Hello World!',0
len equ $-msg






