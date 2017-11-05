# 鸟哥的 Linux 私房菜基础学习篇 (第三版) 读书笔记

## 第 20 章 - 启动流程

启动流程：

1. BISO 自检
1. MBR
1. 加载 kernel，检测硬件，加载驱动
1. 主动调用 init 进程
1. init 调用 /etc/rc.d/rc.sysinit
1. init 启动对应 level 的服务 /etc/rc.d/rc[0-6].d/*
1. init 执行开机启动程序 /etc/rc.d/rc.local
1. init 执行终端机模拟程序 mingetty 来启动 login 进程，等待用户登录

MBR (master boot record) 和 boot sector。

    MBR
      |-- 直接加载 linux 内核启动
      |-- 转交 windows 分区 boot sector 控制
      |-- 转交 linux 分区 boot sector 控制

每个文件系统 (或者说是分区) 都会在分区最前面保留一块引导扇区 (boot sector) 供操作系统安装 boot loader，而通常操作系统默认都会安装一份 loader 到它的根目录所在的文件系统的 boot sector 上。

在安装 Linux 时，你可以选择将 boot loader 安装到 MBR 去，也可以选择不安装。如果选择安装到 MBR，那理论上你在 MBR 和 boot sector 上都会保存有一份 boot loader 程序。至于 windows 安装时，它默认会主动将 MBR 与 boot sector 都装上一份它自己的 boot loader。

(所以，如果你先装 Linux 再装 Windows，那么 Linux 的启动信息就会被 Windows 所覆盖，而且 Windows 无法加载 Linux 分区的 boot sector 中的 boot loader，很讨厌的。而 Linux 的 boot loader 是可以加载 Windows 分区的 boot sector 中的 boot loader。)

boot loader 的主要功能：

1. 提供菜单：用户可以选择不同的启动项
1. 直接加载内核文件：直接指向可启动的程序区段来开始操作系统
1. 转交其它 loader

Linux 内核可以动态加载内核模块，这些内核模块就放置在 /lib/modules/ 中，由于模块放置在 `/` 目录下，所在在启动过程中内核必须要挂载根目录，这样才能够读取内核模块提供加载驱动程序的功能。启动过程中 `/` 是按只读方式挂载的。

虚拟文件系统 (InitialRAM Disk)：/boot/initrd

boot loader 可以加载 kernel 和 initrd，然后在内存中让 initrd 解压成为根目录，kernel 就能够借此加载适当的驱动程序 (usb, raid, lvm, scsi)，最终释放虚拟文件系统，并挂载实际的根目录文件系统。

initrd 的内容：

    # mkdir /tmp/initrd
    # cp /boot/initrd-...img /tmp/initrd/
    # cd /tmp/initrd
    # file initrd-...img
    ...(gzip)
    # mv initrd-...img initrd-...gz
    # gzip -d initrd-...gz
    # file initrd-...
    ...(apio archive)
    # cpio -ivcdu < intrd..
    # ll
    # cat init

第一个进程 init (/sbin/init)

配置文件 /etc/inittab

    # man inittab
    # cat /etc/inittab

init 处理系统初始化流程 (/etc/rc.d/rc.sysinit)

    # cat /etc/rc.d/rc.sysinit

启动过程中用到的主要配置文件

- /etc/rc.d/rc.sysinit
- /etc/rc.d/rc
- /etc/sysconfig/
- /etc/modprobe.conf    // 定义模块的加载

内核与内核模块：

- 内核：/boot/vimlinuz-version
- RAMDisk：/boot/initrd-versino
- 内核模块：/lib/modules/$(uname -r)/kernel
- 内核源码：/usr/src/linux 或 /usr/src/kernels (要手动安装才有)

加载成功后信息记录：

- /proc/version
- /proc/sys/kernel

内核模块相关命令：

    # depmod [-Ane]                // 生成内核模块依赖
    # lsmod                        // 查看加载的内核模块
    # lsmod | grep mii
    # modinfo [-adln] mode_name    // 查看某个内核模块的具体信息
    # modinfo mii

内核模块的加载与删除：

    # insmod [path or mode_name] [parameters]
    # insmod /lib/modules/$(uname -r)/kernel/fs/cifs/cifs.ko
    # lsmod | grep cifs
    # rmmod [-fw] mode_name    // 移除

insmod 和 rmmod 需要手动解决模块的依赖性问题，使用 modprobe 命令可以自动解决。

    # modprobe [-lcfr] mode_name
    -c: 列出模块
    -l: 列出完整路径
    -f: force load mode
    -r: remove

    # modprobe cifs
    # modprobe -r cifs

modprobe 的配置文件：/etc/modprobe.conf

Boot loader: Grub

- Stage1: 执行 boot loader 主程序
- Stage2: 主程序加载配置文件 (/boot/grub/*，最主要的是 menu.lst)

grub 的内容：

    # ll /boot/grub
    ...
    ... menu.lst -> ./grub.conf
    ...
    # file /boot/grub/stage1
    ...x86 boot sector, code offset 0x48
    # cat /boot/grub/menu.lst

menu.lst 详解。两种设置方式：

1. 直接指定内核启动
1. 利用 chain loader 的方式转交控制权

示例：

    # vim /boot/grub/menu.lst
    ...
    title Windows
      hide (hd0,4)            // 隐藏 /dev/sda5
      rootnoverify (hd0,0)    // 不校验 /dev/sda0
      chainloader +1          // /dev/sda0 第一个扇区为 boot sector
      makeactive              // 设置此分区为活动的

initrd 及创建新的 initrd 文件。initrd 可以将 /lib/modules/... 内的启动过程中一定 (是一定) 需要的模块打包成一个文件，然后在启动时通过主机的 int 13 硬件功能将该文件读出来解压缩，并且 initrd 在内存里会仿真成为根目录，由于此虚拟文件系统主要包含磁盘与文件系统的模块，因此我们的内核最后就能认识实际的磁盘，那就能进行实际根目录的挂载。

一般来说，需要 initrd 的时刻：

1. 根目录所在磁盘为 sata, usb 或 scsi 等接口
1. 根目录所在文件系统为 lvm, raid 等特殊格式或非传统 linux 识别的文件系统
1. 其它必须在内核加载时提供的模块

创建 initrd 命令：

    # mkinitrd [-v] [--with=mod_name]  initrd_name kernel_version
    # mkinitrd -v --with=8139too initrd_test $(uname -r)

测试与安装 grub。

安装配置文件：

    # grub-install [--root-directory=DIR] device
    # grub-install --root-directory=/home /dev/hda3

通过 grub shell 将 stage1 安装到 MBR 或 boot sector：

    # grub
    > root (hdx,x)
    > find /boot/grub/stage1 ...
    > setup (hdx,x)    // 安装到 boot sector
    > setup (hdx)      // 安装到 MBR
    > quit

启动前的额外修改：

    e: edit
    o: add new line
    d: delete
    a: append
    b: boot

tty 的 vga 设置：

    # grep "FRAMEBUFFER_CONSOLE" /boot/config-$(uname -r)
    # vim /boot/grub/menu.lst
    ...
    ......quiet vga=790
    ...

启动过程中的问题解决：

1. 为 grub 设置密码：grub-md5-crypt, lock
1. 忘记 root 密码：
   - 进入单用户模式
   - 用启动光盘进入救援模式：linux rescue

1. init 配置文件错误：修改 grub，让内核启动后不执行 init，改执行 bash

         grubedit> ....quiet init=/bin/bash
         # mount -o remount,rw /
         # mount -a

1. 调整了 BIOS 中的磁盘编号

         # cat /boot/grub/device.map
         # grub-install --recheck /dev/hda1    // 主动更新 device.map

1. 使用 chroot 命令切换到另一块硬盘工作

## 第 21 章 - 系统设置工具

打印机设置：略。

硬件信息查看：

    # fdisk, fdisk -l    // 查看分区表
    # hdparm             // 硬盘信息及测速
    # dmesg
    # vmstat
    # iostat
    # lspci [-vvn]       // 查看 pci 设备信息
    # lsusb, lsusb -t    // 查看 usb 设备信息
    /usr/share/hwdata/usb.ids    // 各厂商的 vid, pid
    /usr/share/hwdata/pci.ids

USB 设备驱动。

USB 1.1 版本的控制器有两种规格：

1. OHCI (Open Host Controller Interface): 主要由 Compaq 开发，包括 Compaq，Sis，ALI 厂商开发的芯片使用这个模块；
1. UHCI (Universal Host Controller Interface): 主要由 Intel 开发，包括 Intel，VIA 等厂商开发的芯片使用这个模块；

USB 2.0 使用 EHCI (Enhanced Host Controller Interface) 模块驱动。

    # lsmod | grep hci
    # modinfo ehci_hcd

启动 U 盘：还需要 usb_storage 模块。

使用 lm_sensors 检测温度电压等信息：

    # sensors-detect
    # sensors

udev, hal:

    # pstree -p | egrep '(udev|hal)'

udev 的规则：/etc/udev/rules.d/*

## 第 22 章 - 软件安装

tarball (??): 原始安装 (??)。

    $ gcc
    -Wall (-W+all): 集合了大部分的 -W 选项
    -On: 优化
    -E, -S, -c, -o: 四步骤
    -lx -L/path: 链接到库及指定库路径，默认地址 /lib, /usr/lib
    -I/path: 头文件路径

    # gcc sin.c -lm -L/lib -L/usr/lib -I/usr/include
    CFLAGS 变量：-Wxxx, -O

Makefile 语法：

1. 基本语法

        # Makefile
        目标(target): 目标文件1 目标文件2 ...
        <tab> gcc -o 欲生成的文件 目标文件1 目标文件2 ...

1. 使用变量，$@ 表示当前目标 (target)

        # Makefile
        LIB = -lm
        OBJS = main.o haha.o sin_value.o ...
        CFLAGS = -Wall
        main: ${OBJS}
        <tab> gcc -o $@ ${OBJS} ${LIB}
        clean:
        <tab> rm -rf main ${OBJS}

执行 make：

        # CFLAGS="-Wall" make clean main

tarball 所需基础软件：

1. gcc/cc
1. make, configure (configure 一般是用 autoconfig 生成的?)
1. lib/include, /usr/local/src/xxx

步骤：

1. ./configure [--prefix=/usr/local/xxx]
1. [make clean]
1. make
1. make install

一般 tarball 软件安装的建议事项。

目录，apache 为例，系统安装：

    /etc/httpd
    /usr/lib
    /usr/bin
    /usr/share/man

tarball 默认路径安装：

    /usr/local/etc
    /usr/local/bin
    /usr/local/lib
    /usr/local/man

指定 /usr/local/apache 路径安装：

    /usr/local/apache/etc
    /usr/local/apache/bin
    /usr/local/apache/lib
    /usr/local/apache/man

升级安装及卸载都比较麻烦。卸载时一般直接删除 /usr/local/software 目录即可。但如果被依赖则会影响其它软件的使用。

添加 man 搜索路径，修改 /etc/man.config

    # vim /etc/man.config
    MANPATH /usr/local/software/man

利用 patch 更新源码后，再重新 make, make install

    # patch -pN < patch_file

函数库管理：

- 静态库：.a
- 动态库：.so

ldconfig 与 /etc/ld.so.conf, /etc/ld.so.cache

修改 /etc/ld.so.conf，然后用 ldconfig 重新加载，数据会同时记录在 /etc/ld.so.cache 中。

    # ldconfig [-f conf] [-C cache]
    # ldconfig -p
    # ldconfig

程序的动态库解析：

    # ldd [-vdr] program_file
    -v: 列出内容信息
    -d: 重新将数据有丢失的 link 点显示
    -r: 将 elf 有关的错误内容显示

    # ldd /usr/bin/passwd
    # ldd -v /lib/libc.so.6

校验软件正确性：

    # md5sum/sha1sum [-bct] filename
    # md5sum/sha1sum [--status|--warn]  --check filename
