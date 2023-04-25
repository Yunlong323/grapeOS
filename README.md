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

## 电脑启动过程介绍

1. 上电
2. BIOS  基本IO系统
   1. 做硬件配置和初始化
   2. 发现硬件错误，中断报错  （譬如罢了内存条，显示屏上会显示东西，这些就是bios显示的）
3. MBR（boot）  主引导记录：磁盘第一个扇区。磁盘读写以扇区为基本单位，一般每个扇区有512个B。
   1. 电脑启动项选择会编辑 （F12进入的启动设置）
      1. 从哪启动（光盘，U盘，硬盘等）=>启动项
   2. BIOS中配置的驱动器顺序（启动项），就会读取启动盘的第一个扇区【内容就是 MBR】。
      1. 第一个扇区的内容【启动程序入口地址】就决定了启动的一切
      2. 跳到指定的启动程序，开始启动
   3. MBR里面的boot程序会加载loader
4. loader：为了加载内核kernel
   1. BIOS,MBR不能直接加载OS，因为空间不够仅仅512B
   2. 用loader空间不小，所以可以加载kernel，并做一些初始化
5. kernel：运行初始化，最后打开UI，我们就可以进行交互了
6. UI：GUI or cmd



# 所需计组

1. 输入【键盘，鼠标，外存】
2. 输出【显示器，打印机，外存】
3. 存储器【内存+显存+ROM】
   1. 外存【硬盘，U盘，磁带】 冯诺依曼结构中属于外设
4. **控制器** 【in CPU】
5. **运算器** 【in CPU】

如何互相配合工作？

> 输入设备-->内存-->CPU处理--->内存---->输出设备   ，故核心是内存作为周转中介



运行就是：

点击exe文件，执行指针指向exe起始地址，加载exe到内存开始运行，最后结果输出。

程序必须在内存方可运行。



启动：

上电---bios---MBR(BOOT)----loader-----kernel---GUI

> bios读取MBR到内存，指针指过去，运行，加载硬盘上的loader到内存，指针指向loader，初始化后开始加载kernel到内存中，然后执行内核直到打开UI，开始交互



## X86：是种指令集架构

基于intel 8086向后兼容的 CPU指令集架构。 不同指令集架构，编译结果是不一样的。

qemu-system-i386 就是80386的简称。兼容386。 都是向后兼容。所以本质我们的OS运行在80386的32位 保护模式下。

## 实模式和保护模式

实模式：就是8086的模式





