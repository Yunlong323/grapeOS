# 向MBR写入程序

空MBR

```asm
org 0x7c00
;empty MBR
times 510 db 0 ;重复指令   times 次数  重复动作 设为0 （db 0） 前面510字节都为0
db 0x55,0xaa ;最后两个字节就是55 aa
```

nasm其实也能反汇编：ndisasm xxx.bin

> ndisasm mbr.bin 可以把汇编的bin文件以反汇编代码呈现出来
>
> cpu只是把cs：ip指向单元的二进制码和指令集做对比，对得上号的就直接反汇编。
>
> 如果反汇编不对，导致qemu的CPU一直执行错误的反汇编代码，那如何解决？
>
> 可以用jmp $在这无限循环，CPU至少不再乱执行反汇编代码
>
> $:当前行所在地址
>
> $$:当前程序的其实地址

```asm
org 0x7c00

jmp $ ;loop; 加了这句times就不是510字节的0了，因为jmp指令在代码段，它也在0x7c00之后

times 510-($-$$) db 0 ;更正规的写法，之前那个因为知道要循环510次。实际上这个510应该让程序算出来。
; $-$$ 当前行地址-程序的起始地址 就是前面行用了多少字节数，剩下的就是用0填充的部分了
db 0x55,0xaa 
```

短跳转：段内跳转  jmp short  xxx   执行完后的位置，指针移动  

长跳转：段地址也变了



但是这样其实CPU还是在运行，占用我们的主机内存。怎么优化？其实用hlt指令即可。

```asm
org 0x7c00

;这里写MBR正常代码

stop:
hlt;CPU停止运行，等待任何中断唤醒CPU（降低CPU使用率）
jmp stop

times 510-($-$$) db 0 

db 0x55,0xaa 
```

# 屏幕显示原理与文本模式

屏幕显示：控制屏幕上每个像素的颜色即可显示出各种画面。

CPU(程序)>显存>显示器屏幕

显存中的数据和屏幕上的像素是对应的。【对应关系和模式有关，显卡分为 图形模式或者文本模式】

+ 程序将要显示的数据放入显存
+ 显卡会不断地从显存中取出数据，处理后，发给显示器        
  + 这个取出频率和刷新频率有关
+ 显示器就显示出对应的图形

## 文本模式 

电脑启动后显卡默认的模式就是文本模式，显示25*80 的ASCII码

对屏幕而言，一切都是图形。显卡的文本模式为了方便开发者显示字符用的。

+ 若没有文本模式，任何字符的显示都需要开发者精准控制每一个像素。

在进入图形模式之前，我们需要在文本模式下显示一些提示信息。

默认文本模式下，显存和屏幕的对应关系为。 一个字符 = 每2B  【注意，我们就没有控制像素了：低位1B 表示ascii，高位1B表示颜色】

高位1B的高4bit是背景色，低4bit是前景色。

文本模式下，用RGB控制，一共3bit。表示八种颜色。

高位1B：

​	高4bit（背景色）：KRGB    k:控制是否闪烁

​	低4bit（前景色）：IRGB     I：亮度位（高亮）

> 黑底白字：  高: 0000  低:0111 就是0x07

#### 显存地址分布

+ C0000~C7FFF 32KB 显示适配器BIOS

+ B8000~BFFFF 32KB 文本模式显示适配器   

  + > B8000~B8001 的内容就是第一行第一列的字符 以此类推  一行80个字符 共20行

+ B0000~B7FFF 32KB 黑白显示适配器

+ A0000~AFFFF 64KB 彩色显示适配器

## 显示字符到屏幕的程序

```asm
;启动在屏幕上打个字符v
org 0x7c00

mov ah,0x07 ;黑底白字
mov al,'V'
;此时ax就是有颜色的字符V

mov bx,0xb800 ;文本模式显示适配器
mov es,bx ;段寄存器不能直接赋值
mov [es:0],ax ;把要显示的字符送到显存的第一个位置 （第一行第一列）

stop: ;运行完 要让程序停下来
hlt
jmp stop

times 510-($-$$) db 0;其余空间置为0
db 0x55,0xaa 
```

编译后写入img，用qemu运行

![image-20230425163631697](https://raw.githubusercontent.com/Yunlong323/pic2023/main/202304251636765.png)

可以看出已经完成覆写。现在第一行有内容，所以我们打算下面输出到第二行。

我们知道一行80个字符，第二行第一个字符应该是第81个字符，一个字符2B

所以地址为从0xb800开始的 80*2=160 =hex=>0xA0==>  ax放入内存的目的地址变成 [es:A0] 但其实没必要，因为汇编识别的就是十进制

所以用  [es:160]

```asm

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
```

![image-20230425164204782](https://raw.githubusercontent.com/Yunlong323/pic2023/main/202304251642822.png)

所以我们就可以一个一个字符的输出 ViendeOS

```asm
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
```



![image-20230425164829887](https://raw.githubusercontent.com/Yunlong323/pic2023/main/202304251648930.png)

## 封装字符串打印函数

```asm
org 0x7c00 ;如果不声明，cs那就从0地址开始，后面boot_start_string寻址就不对，打印的就不对。
mov ax,cs
mov ds,ax;DS = CS，因为会用到代码段（有函数） 
;[ds:si]找到的是boot_start_string,ds=cs这样org的声明才能让其找到boot_start_string

mov ax,0xb800
mov es,ax  ;段给到文本显存

;print "boot start"
mov si,boot_start_string  ;函数的第一个参数就是boot_start_string的起始地址
mov di,80 ;屏幕第二行显示
call func_print_string
;[ds:si]是boot_start_string 
;[es:di]是显存目的地址，每次间隔2B

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
shl di,1; 乘以2(屏幕上每个char占2个显存字节) 
.start_char: ;以.开头的标号为局部标号，完整形式为func_print_string.start_char
;开始取字符
mov al,[si]  ;每次把当前要打印的字符从si指向内存传给al，si再inc （line 31）
cmp al,0 ;\0为结束符，判断
jz .end_print;是0，就结束打印
mov [es:di],ax ;字符放入显存
inc si ;指针指向下一个字符
add di,2;
jmp .start_char
.end_print
ret ;函数返

boot_start_string:db "boot start",0 ;定义要打印的字符，以\0结尾


times 510-($-$$) db 0
db 0x55,0xaa
```



![image-20230425172004292](https://raw.githubusercontent.com/Yunlong323/pic2023/main/202304251720332.png)

## 清空屏幕程序

qemu上面有提示字符，所以写入字符并不纯粹，我们需要先清空屏幕程序：**屏幕上全部输出为空格即可**。

25行80列，2000个空格输出即可。

```asm
;constant 类似C的宏
VIDEO_CHAR_MAX_COUNT equ 2000 ;2000个字符 4000个B

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
mov bx,cx ;bx = (cx-1)*2 字符对应的显存地址(从screen右下角清屏,1999个字节，bx索引就变成了3998，所以必须乘2)
dec bx    ;-1
shl bx,1 ;*2
mov [es:bx],ax ;空格写入显存
loop .start_blank ;loop默认用cx计数
ret

times 510-($-$$) db 0
db 0x55,0xaa



```

这样就实现了清屏。



























































































