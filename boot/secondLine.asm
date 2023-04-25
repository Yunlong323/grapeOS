
org 0x7c00

mov ah,0x07 
mov al,'V'


mov bx,0xb800 
mov es,bx
mov [es:160],ax ;把要显示的字符送到显存的第81个位置 （第二行第一列）

stop:
hlt
jmp stop

times 510-($-$$) db 0
db 0x55,0xaa 