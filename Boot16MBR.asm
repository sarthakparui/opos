;*************************************************************************
[BITS 16]
ORG 0h
jmp     START

OEM_ID                db "QUASI-OS"
BytesPerSector        dw 0x0200
SectorsPerCluster     db 0x40
ReservedSectors       dw 0x0006
TotalFATs             db 0x02
MaxRootEntries        dw 0x0200
TotalSectorsSmall     dw 0x0000
MediaDescriptor       db 0xF8
SectorsPerFAT         dw 0x00F5
SectorsPerTrack       dw 0x003F
NumHeads              dw 0x00FF
HiddenSectors         dd 0x0000003F
TotalSectorsLarge     dd 0x003D3FBF
DriveNumber           db 0x00
Flags                 db 0x00
Signature             db 0x29
VolumeID              dd 0xFFFFFFFF
VolumeLabel           db "QUASI  BOOT"
SystemID              db "FAT16   "

START:
; code located at 0000:7C00, adjust segment registers
     cli
	 mov     ax, 0x07C0
     mov     ds, ax
     mov     es, ax
     
; create stack
     mov     ax, 0x0000
     mov     ss, ax
     mov     sp, 0xFFFF
     sti

LOAD_ROOT:
; compute size of root directory and store in "cx"
     xor     cx, cx
     xor     dx, dx
     mov     ax, 0x0020                          ; 32 byte directory entry
     mul     WORD [MaxRootEntries]               ; total size of directory
     div     WORD [BytesPerSector]               ; sectors used by directory
     xchg    ax, cx
; compute location(LBA) of root directory and store in "ax"
     mov     al, BYTE [TotalFATs]                ; number of FATs
     mul     WORD [SectorsPerFAT]                ; sectors used by FATs
     add     ax, WORD [ReservedSectors]          ; adjust for bootsector
	 add	 ax, WORD [HiddenSectors]
     mov     WORD [datasector], ax               ; base of root directory
     add     WORD [datasector], cx
; read root directory into memory (7C00:0200)
     mov     bx, 0x0200                          ; copy root dir above bootcode
     call    ReadSectors

pusha
mov     si, msgCRLF
call    DisplayMessage
popa

; browse root directory for binary image
     mov     cx, WORD [MaxRootEntries]           ; load loop counter
     mov     di, 0x0200                          ; locate first root entry
.LOOP:
     push    cx
     mov     cx, 0x000B                          ; eleven character name
     mov     si, ImageName                       ; image name to find
	 pusha
	 call    DisplayMessage
	 popa
	 push    di
	 rep     cmpsb                               ; test for entry match
     pop     di
     je      LOAD_FAT
     pop     cx
     add     di, 0x0020                          ; queue next directory entry
     loop    .LOOP
     jmp     FAILURE


LOAD_FAT:
pusha
mov     si, msgFAT
call    DisplayMessage
;mov ah,0x00
;int 0x16
popa

; save starting cluster of boot image
     mov     dx, WORD [di + 0x001A]
     mov     WORD [cluster], dx                  ; file's first cluster
; compute size of FAT and store in "cx"
     mov 	 cx,WORD [SectorsPerFAT]
     
; compute location of FAT and store in "ax"
     mov     ax, WORD [HiddenSectors]         	 ; adjust for bootsector
	 add     ax, WORD [ReservedSectors]
	 
; read FAT into memory (17C0:0200)
     push 	 ax
	 mov     ax, 0x17C0
     mov     es, ax
	 pop 	 ax
	 mov     bx, 0x0200                          ; copy FAT above bootcode
     call    ReadSectors	

; read image file into memory (37C0:0100)(es:bx)
     mov     si, msgCRLF
     call    DisplayMessage
	 mov     si, msgImg
     call    DisplayMessage
     mov     ax, 0x37C0
     mov     es, ax                              ; destination for image
     mov     bx, 0x0100                          ; destination for image
     push    bx
	 mov     ax, 0x17C0							 ; FAT Segment	
     mov     gs, ax     

	 
	 
LOAD_IMAGE:
     mov     ax, WORD [cluster]              	 ; cluster to read
     pop     bx                                  ; buffer to read into
     call    ClusterLBA                          ; convert cluster to LBA
     xor     cx, cx
     mov     cl, BYTE [SectorsPerCluster]        ; sectors to read
     call    ReadSectors
     push    bx
; compute next cluster
     mov     ax, WORD [cluster]              	 ; identify current cluster
     mov     bx, 0x0200                          ; location of FAT in memory
     add	 ax, ax								 ; 16 bit(2 byte) FAT entry
	 add     bx, ax                              ; index into FAT
     mov     dx, WORD [gs:bx]                    ; read two bytes from FAT
.DONE:
     mov     WORD [cluster], dx              	 ; store new cluster
	 cmp     dx, 0x0FF0                          ; test for end of file
     jnb      LOAD_IMAGE
DONE:
     mov     si, msgCRLF
     call    DisplayMessage
     push    WORD 0x37C0
     push    WORD 0x0100
     retf
FAILURE:
     mov     si, msgFailure
     call    DisplayMessage
     mov     ah, 0x00
     int     0x16                                ; await keypress
     int     0x19                                ; warm boot computer


;*************************************************************************
; PROCEDURE DisplayMessage
; display ASCIIZ string at "ds:si" via BIOS
;*************************************************************************
DisplayMessage:
     lodsb                                       ; load next character
     or      al, al                              ; test for NUL character
     jz      .DONE
     mov     ah, 0x0E                            ; BIOS teletype
     mov     bh, 0x00                            ; display page 0
     mov     bl, 0x07                            ; text attribute
     int     0x10                                ; invoke BIOS
     jmp     DisplayMessage
.DONE:
     ret

;*************************************************************************
; PROCEDURE ReadSectors
; reads "cx" sectors from disk starting at "ax" into memory location "es:bx"
;*************************************************************************
ReadSectors:
	 mov WORD[DAPBuffer],bx
	 mov WORD[DAPBuffer+2],es
	 mov WORD[DAPStart],ax
.MAIN:
     mov     di, 0x0005                          ; five retries for error
.SECTORLOOP:
     push    ax
     push    bx
     push    cx
	 
     push si
     mov ah,0x42
     mov dl,0x80
     mov si,DAPSizeOfPacket
     int 0x13
     pop si
	 
     jnc     .SUCCESS                            ; test for read error
     xor     ax, ax                              ; BIOS reset disk
     int     0x13                                ; invoke BIOS
     dec     di                                  ; decrement error counter
     pop     cx
     pop     bx
     pop     ax
	 jnz     .SECTORLOOP                         ; attempt to read again
	 int     0x18
.SUCCESS:
     mov     si, msgProgress
     call    DisplayMessage
     pop     cx
     pop     bx
     pop     ax
     add     bx, WORD [BytesPerSector]           ; queue next buffer
	 cmp	 bx,0x0000	
	 jne	 .NextSector
	 push 	 ax
	 mov	 ax, es
	 add	 ax, 0x1000
     mov     es, ax
	 pop 	 ax
	 
.NextSector:
     inc     ax                                  ; queue next sector
	 mov WORD[DAPBuffer],bx
	 mov WORD[DAPStart],ax
     loop    .MAIN                               ; read next sector
     ret
 
 
;*************************************************************************
; PROCEDURE ClusterLBA
; convert FAT cluster into LBA addressing scheme
; LBA = (cluster - 2) * sectors per cluster
;*************************************************************************
ClusterLBA:
     sub     ax, 0x0002                          ; zero base cluster number
     xor     cx, cx
     mov     cl, BYTE [SectorsPerCluster]        ; convert byte to word
     mul     cx
     add     ax, WORD [datasector]               ; base data sector
	 ret
	 

DAPSizeOfPacket db 10h
DAPReserved		db 00h
DAPTransfer		dw 0001h
DAPBuffer		dd 00000000h
DAPStart		dq 0000000000000000h


absoluteSector db 0x00
absoluteHead   db 0x00
absoluteTrack  db 0x00

datasector 	dw 0x0000
cluster     dw 0x0000
ImageName   db "LOADER  BIN" ,0x0D, 0x0A,0x00
msgCRLF     db 0x0D, 0x0A, 0x00
msgProgress db "*", 0x00
msgFailure  db 0x0D, 0x0A, "ROOT", 0x00
msgFail		db "Read",0x00
msgFAT		db  0x0D, 0x0A,"Loading FAT", 0x0D, 0x0A, 0x00
msgImg		db "Loading Image", 0x0D, 0x0A, 0x00

     TIMES 510-($-$$) DB 0
     DW 0xAA55
;*************************************************************************
