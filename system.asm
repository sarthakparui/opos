global protect_enable
global _gdt_flush  
extern _gp                 ; _gp is the pointer to the base of GDT

[BITS 16]

;Enable Protected Mode
protect_enable:
mov eax,cr0
or eax,1
mov cr0,eax
ret


; This will set up our new segment registers. We need to do
; something special in order to set CS. We do what is called a
; far jump. A jump that includes a segment as well as an offset.
; This is declared in C as 'extern void gdt_flush();'
_gdt_flush:
    lgdt [_gp]        ; Load the GDT with our '_gp' which is a special pointer
    mov ax, 0x37C0      ; 0x10 is the offset in the GDT to our data segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp 0x37C0:flush    ; 0x08 is the offset to our code segment: Far jump!
flush:
    ret               ; Returns back to the C code!
		
