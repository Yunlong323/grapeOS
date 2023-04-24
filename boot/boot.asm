org 0x7c00
mov ax,cs
mov ds,ax
mov ax,0xb800
mov gs,ax

mov ah,0x07
mov al,'G'
mov [gs:0x0],ax
mov al,'r'

mov [gs:0x2],ax
mov al,'a'

mov [gs:0x4],ax
mov al,'p'

mov [gs:0x6],ax
mov al,'e'

mov [gs:0x8],ax
mov al,'O'

mov [gs:0xa],ax
mov al,'S'

mov [gs:0xc],ax

stop:
hlt
jmp stop

times 510-($-$$) db 0
db 0x55,0xaa


