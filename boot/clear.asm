;constant 类似C的宏
VIDEO_CHAR_MAX_COUNT equ 2000

org 0x 7c00

;init 段 寄存器
mov ax,0xb800
mov es,ax;指向文本显存

;清屏
call func_clear_screen

stop:
hlt
jmp stop

;clear screen function
;input arg:none
;output arg :none

func_clear_screen:
mov ah,0x00 ;黑底黑字
mov al,' '
mov cx,VIDEO_CHAR_MAX_COUNT

.start_blank:
mov bx,cx ;bx = (cx-1)*2 字符对应的显存地址(从screen右下角清屏)
dec bx    ;-1
shl bx,1 ;*2，变成字节的索引
mov [es:bx],ax ;空格写入显存
loop .start_blank ;loop默认用cx计数
ret

times 510-($-$$) db 0
db 0x55,0xaa


