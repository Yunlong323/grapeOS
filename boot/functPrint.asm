org 0x7c00
mov ax,cs
mov ds,ax;DS = CS

mov ax,0xb800
mov es,ax  ;段给到文本显存

;print "boot start"
mov si,boot_start_string  ;函数的第一个参数就是boot_start_string的起始地址
mov di,80 ;屏幕第二行显示
call func_print_string


stop:
hlt
jmp stop

;print函数
;入参 ds:si,di             
;无输出参数
;si 字符串base地址，以0结束符
;di 目的地址，即字符串在屏幕上显示的起始位置(0~1999   25*80)，di就是字符的索引
func_print_string:
mov ah,0x07;黑底白字
shl di,1; 屏幕上每个char占2个显存字节  竖着打印
.start_char: ;以.开头的标号为局部标号，完整形式为func_print_string.start_char
;开始取字符
mov al,[si]  ;每次把当前要打印的字符从si指向内存传给al，si再inc （line 31）
cmp al,0 ;\0为结束符，判断
jz .end_print;是0，就结束打印
mov [es:di],ax ;字符放入显存
inc si ;指针指向下一个字符
add di,2;每次+2 第一列，第二列....
jmp .start_char
.end_print:
ret ;函数返

boot_start_string:db "boot start",0 ;定义要打印的字符，以\0结尾


times 510-($-$$) db 0
db 0x55,0xaa