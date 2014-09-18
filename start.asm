;%include "system.asm"
;%include "system.c"

extern protect_enable
extern _gdt_install
extern _main

[BITS 16]


;Install GDT
call _gdt_install

;Enable Protected Mode
call protect_enable

;Call 32 bit Kernel code
call _main


SECTION .bss
    resb 8192 
