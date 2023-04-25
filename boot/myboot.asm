org 0x7c00
mov ax,0xb800
mov es,ax  ;段给到文本显存

mov ah,0x07 ;高8位 黑底白字
mov al,'V'
mov [es:160],ax ;给到第二行第一个
mov al,'i'
mov [es:162],ax
mov al,'e'
mov [es:164],ax
mov al,'n'
mov [es:166],ax
mov al,'d'
mov [es:168],ax
mov al,'e'
mov [es:170],ax
mov al,'O'
mov [es:172],ax
mov al,'S'
mov [es:174],ax




stop:
hlt
jmp stop

times 510-($-$$) db 0
db 0x55,0xaa