# grapeOS Development Log

# 开发环境

Qemu 20220822 运行OS

WSL2 CentOS7 编译代码

> yum install nasm
>
> yum install code .    这个是咱们win上vsc有wsl插件，这样在 centos wsl里面输入 code . 直接连接上，特别方便

VSC 编写GrapeOS代码



## 测试开发环境

VSC中编写了这个代码，看看能不能取CentOS里面编译运行

```asm
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


```

把boot.asm放到centos的/root/GrapeOS/testEnv 中



运行如下命令

`dd if=/dev/zero of=/root/GrapeOS/testEnv/GrapeOS.img bs=1M count=4 `

> dd创建虚拟硬盘，of是要创建设备所在路径，if是信息源。大小4MB 足够我们OS那么大了

`nasm boot.asm -o boot.bin`

> 汇编我们的asm源代码为二进制文件机器语言
>
> 然后把我们的boot.bin 机器语言放到生成的Grape.img中
>
> linux dd命令中notrunc表示不要截断输出文件，这个不常用，不用记

`dd conv=notrunc if=boot.bin of=/root/GrapeOS/testEnv/GrapeOS.img`

此时就可以把 **虚拟硬盘挂载到QEMU虚拟机** 中运行这段代码。

然后我们把这个grapeos.img拿回我们windows的目录下：E:\GrapeOS\grapeOS\boot\GrapeOS.img

> 原本从windows用   qemu-system-i386  启动QEMU是无效的
>
> ![image-20230424212757646](C:\Users\viende\AppData\Roaming\Typora\typora-user-images\image-20230424212757646.png)
>
> 因为没什么设备，但是现在我们有了一个dd设备grape.img所以可以挂载使用qemu
>
> `qemu-system-i386 E:\GrapeOS\grapeOS\boot\GrapeOS.img` 即可挂载启动
>
> ![image-20230424213124739](C:\Users\viende\AppData\Roaming\Typora\typora-user-images\image-20230424213124739.png)
>
> 左上角这个GrapeOS就是我们汇编打印的字符。其他字符是qemu模拟器自动输出的。
>
> 这样开发环境已经搭建完成！可以开始开发了！

