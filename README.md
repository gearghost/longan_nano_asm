# longan_nano_asm
risc-v assembly test code for longan nano board

### 主要还是想了解一下risc-v汇编，所以买了块longan nano实验一下，板子上的USART、LED和LCD都简单的涉及到了。代码都是根据别人的C代码，自己改成汇编的，也没有遵从C ABI，只做了一些简单的栈帧操作，处理下ra寄存器保存和恢复操作。

> 这个是在Mac OS下搞的，所以risc-v tool-chain还是要安装好的，板子下载用的是dfu模式，所以使用的程序是dfu-util，都是用brew安装的，上面安装的risc-v编译工具链已经默认支持32位了，之前还要
额外加参数。具体涉及到的相关编译相关的软件和参数，直接参考Makefile就好，
也可以根据自己的情况修改risc-v编译软件版本，我Mac上安装的是riscv64-unknown-elf-*，兼容支持32位的编译。

### 编译方法，在交叉编译工具链和环境准备好之后

```bash
make all
```

#### `生成的文件都在target目录下`, 包括编译生成中间文件.o，链接后生成的.elf文件，剥离elf头之后的二进制文件.bin（用于下载到板子上），还有输出的elf header结构文件.header，用于分析内存结构是否对应的上。

### 反编译二进制文件
```bash
make disasm
```

#### `会在target下根据elf反编译生成.asm文件` 主要是对比经过编译之后汇编指令的变化，因为risc-v使用了很多伪指令，会进行很多指令拆分的操作。

### DFU下载
```bash
make flash
```

设置好longan nano进入DFU模式之后，直接执行就可以下载二进制文件了。
