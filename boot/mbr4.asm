;启动在屏幕上打个字符v
org 0x7c00

mov ah,0x07 ;黑底白字
mov al,'V'
;此时ax就是有颜色的字符V

mov bx,0xb800 ;文本模式显示适配器
mov es,bx
mov [es:0],ax ;把要显示的字符送到显存的第一个位置 （第一行第一列）

stop:
hlt
jmp stop

times 510-($-$$) db 0;其余空间置为0
db 0x55,0xaa 