# 鸟哥的 Linux 私房菜基础学习篇 (第三版) 读书笔记

Time: 2012

## 第 1 - 2 章

Thompson 用汇编语言写出了 UNIX 的原型，有两个重要的概念：

1. 所有的程序和装置都是文件。
1. 不管构建编辑器还是附属文件，所写的程序只有一个目的，就是要有效地完成目标。

GNU C Compiler (GCC), GNU C Library (GLIBC)

GPL: General Public License, FSF: Free Software Foundation

自由软件与商业行为并不冲突。

...不过，他发现有很多的软件无法在 Linux 这个内核上运行。这个时候他有两种做法，一种是修改软件，让该软件可以在 Linux 上运行；另一种则是修改 Linux，让 Linux 符合软件能够运作的规范。... 为了让所有的软件都可以在 Linux 上执行，于是 Torvalds 开始参考标准的 POSIX 规范。

Linux distribution = kernel + softwares + tools

## 第 3 - 5 章

IDE 接口是有顺序的：/dev/hd[a-d]，IDE0:master，IDE0:slave，IDE1:master，IDE1:slave ...

SATA/USB/SCSI 接口都是使用 SCSI 模块驱动，设备名是 /dev/sd[a-p]，无顺序，取决于 Linux 内核检测顺序。

分区的最小单位为柱面 (Cylinder)。

spfdisk：可以安装识别 windows/linux 的引导加载程序。

安装过程会写入到 /root/install.log 文件中，并且你刚才选择的所有选项写入到 /root/anaconda-ks.cfg 文件内。(原来这两个文件是安装系统过程中产生的。)

启动参数：`boot: linux nofb apm=off acpi=off pci=noacpi`

gnome 资源管理器是 Nautilus，KDE 资源管理器叫 Konqueror。Nautilus 在编辑菜单里可以设置显示隐藏文件。

RedHat、CentOS、Fedora 用的输入法都是 SCIM，我感觉比 ubuntu 的 iBus 好用。

三个命令：date, cal, bc

- tab: 命令和文件补全
- ctrl+c: 中断目前的程序
- ctrl+d: 代表 EOF，也可以用来替代 exit 的输入，表示退出当前程序。

man 手册中首行命令名称后面的数字含义：

- 1: 用户在 shell 环境中可以操作的命令或可执行文件
- 2: 系统内核可调用的函数或工具，比如 time
- 3: 常用的函数及函数库，一般为 c 函数库 (libc)
- 4: 设备文件的说明，一般是在 /dev 下的文件，比如 null
- 5: 配置文件或某些文件的格式
- 6: games
- 7: 惯例与协议等
- 8: 系统管理器可用的管理命令
- 9: 跟 kernel 有关的文件

以上内容可以通过 `man 7 man` 查看到。

    # man -f command    // command 必须完全匹配
    # man -f printf
    printf (3)           - formatted output conversion
    printf (1)           - format and print data
    # man 3 printf      // 查看 c 函数库中的 printf，而不是默认的 shell 中的 printf 命令帮助
    # man printf        // 不指定数字，默认是先找到的，这里默认会先找到 (1) 中的 printf

    # man -k 命令或数据的部分内容 // 使用 man -f 时，关键词必须完全与结果左边的词条完全匹配，若想模糊查找，则可以使用 man -k 命令。
    # man -k print
    ...
    vsprintf (3)         - formatted output conversion
    vswprintf (3)        - formatted wide-character output conversion
    vwprintf (3)         - formatted wide-character output conversion
    wc (1)               - print newline, word, and byte counts for each file
    whoami (1)           - print effective userid
    ...

    # whatis [命令或数据]   // = man -f
    # apropos [命令或数据]  // = man -k, apropos：恰好的
    # makewhatis          // 以上两个命令的前提是必须建立 whatis 数据库，但在 ubuntu 里没有这个命令，可能是系统自动生成这个数据库了，所以不需要再手动去做

info page，和 man 功能差不多，但提供了页内的超链接跳转功能，暂时无须掌握。

关机，重启：sync, shutdown, reboot, halt, poweroff, init 0, init 6

规定一下，以后重启一律用 reboot，或者 `shutdown -r now`，关机一律用 `shutdown -h now`, 若关不掉则用 halt 或 `poweroff -f`。

    # shutdown [-t time] [-rhakfFnc] time [warning message]

shutdown 比其它命令灵活的地方在于，可以设定重启或关机发生的时间。

    # fsck /dev/sda1  // 扫描修复磁盘

## 第 6 章 权限、目录

语言配置文件：/etc/sysconfig/i18n

    # cat /etc/sysconfig/i18n
    LANG="zh_CN.UTF-8"

/usr：usr = Unix Software Resource，不是 user 的简写！

Linux 目录配置，写得很深入，学习之！(Page 157，图 6-4)

    # pwd -P             // 显示非链接名
    # mkdir -m 711 dir1  // 不使用默认的属性

umask：用来设置文件或目录被创建时的默认权限，默认值是 022，意味着，目录或文件创建时，对 group 和 other users，没有 w (2) 的权限。

查找：which, whereis, locate, find

## 第 8 章 磁盘与文件系统管理

- 扇区：sector
- 柱面：cylinder
- super block：记录了 inode / block 的使用情况
- inode：每个文件占用一个 inode，记录文件的属性，及文件的数据所在的 block
- block：记录文件的实际内容

这种称呼为索引式文件系统 (indexed allocation)，文件所占用的 block 统一记录在 inode 中。而 windows 下传统的 FAT 文件系统，下一个 block 是记录在上一个 block 里，整体是一个链表，当文件过于分散时，会导致读取效率下降，而索引式文件系统无须遍历就可以一次性读出所有 block。这就是为什么 windows 需要磁盘碎片整理，而 linux 不需要。

Ext2 文件系统：

    启动扇区 | block group ｜ block group | block group | ....

- block group: super block | inode | block，一般只有第一个 block group 拥有 super block。
- data block: 1KB, 2KB, 4KB
- inodetable: 128 bytes，12个直接，1 个间接，1 个双间接，1 个三间接的 block 记录区。每记录一个 block 号需要 4 bytes。
- super block: 1024 bytes，可以使用 dumpe2fs 查看。
- File System Description: 描述 block group 开始与结束的 block 号，及每个 block group 里 super block, bitmap, inodemap, data block 介于哪些 block 中间。也可以用 dumpe2fs 查看。
- block bitmap: 块对照表。位图，记录该 block group 时各 data block 是否使用的情况。
- inode bitmap: inode 对照表，位图，和 block bitmap 类似，记录该 block group 里各 inode 的使用情况。

dumpe2fs：

    # dumpe2fs [-bh] /dev/xxx

好了，经过上面的说明你应该清楚了，inode 本身并不记录文件名，文件名是记录在所属目录的 block 中，这就是为什么在文件权限中，新增 / 删除 / 重命名文件名与目录的 w 权限有关。

日志文件系统 (Journaling File System) 的由来。

虚拟文件系统 (VFS)

    # cat /proc/filesystems

    # df -T    // 同时显示该分区的文件系统

ln，硬链接与符号链接，彻底理解了。

分区

    # fdisk -l
    # df /
    # fdisk /dev/sda          // 后面跟的是硬盘，而不是分区

格式化

    # mkfs -t ext3 /dev/sda5
    # mke2fs xxxx             // 格式化成 ext2/ext3

修复

    # fsck

mount / umount

    # mount [-a] [-l] [-t fs] [-o option] [-L label] [...]
    # vim /etc/fstab
    # vim /etc/mtab
    # cat /proc/filesystems
    # ls /lib/modules/$(uname -r)/kernel/fs/    // 各 FileSystem 的驱动
    # mount -o remount,rw,auto /                // 重新以 rw 的属性挂载

之前说到使用 ln 无法对目录做硬链接，但用 mount 命令却可以做到，如下所示，inode 是一样的。

    # mount --bind /home /mnt/home
    $ ls -ild /home /mnt/home
    1308161 drwxr-xr-x 3 root root 4096  9月 30  2011 /home
    1308161 drwxr-xr-x 3 root root 4096  9月 30  2011 /mnt/home

umount [-fn] 设备名或挂载点，但使用 --bind 挂载的目录，后面只能跟挂载点。

    # umount /mnt/home
    # umount /dev/cdrom

umount 时若显示 device is busy，说明此时工作目录位于挂载点里，先 cd 到其它目录再 umount 即可。

使用卷标来挂载，好处是不用知道该设备的设备名。

    # dumpe2fs -h /dev/hda6          // 可以用 dumpe2fs 来查询卷标名
    # mount -L "study" /mnt/study    // 将卷标为 sutdy 的分区挂载到 /mnt/study

磁盘参数修改，不是很明白，mknod。

e2label，修改 label 名。

    # e2label /dev/sdb1 "my_udisk"
    # tune2fs [-jlL] /dev/sdb1    // -j:ext2 to ext3; -l:dumpe2fs -h; -L:e2label

自动挂载，/etc/fstab，/etc/mtab，后者是由前者的内容自动生成的。

    # vim /etc/fstab
    Device | mount point | filesystem | parameters | dump(0 or 1) | fsck (0 or 1 or 2)

若不小心改错了 fstab 导致无法正常进入系统，可以进入单用户模式，但此时 `/` 是 r 属性，所以先重新挂载为 rw 属性，再修改 fstab。

    # mount -n -o remout,rw /    // -n 表示不写入 /etc/mtab 中。

dd 的妙用：

    # mount -o loop ~/xxx.iso /mnt/xxx                    // 使用 -o loop 挂载虚拟设备文件
    # dd if=/dev/zero of=/home/loopdev bs=1M count=512    // bs 表示每个 block 的大小。
    # mkfs -t ext3 /home/loopdev
    # mount -o loop /home/loopdev /media/cdrom

swap 分区的手动构建：

1. 使用物理分区构建

        # fdisk /dev/sda        // 分出一个 swap 分区
        # partprobe             // 使分区生效
        # mkswap /dev/sda7      // 相当于格式化成 swap 分区，不能用 mkfs 命令
        # swapon /dev/sda7      // 加载 swap 分区
        # swapoff /dev/sda7     // 卸载 swap 分区

1. 使用文件构建

        # dd if=/dev/zero of=/tmp/swap bs=1M count=128
        # mkswap /tmp/swap
        # swapon /tmp/swap
        # swapon -s
        # swapoff /tmp/swap

boot sector 与 super block 的关系：

boot sector 和 super block 的大小都是 1KB, 若 block 的单位是 1KB, 则 boot sector 在 block 0，super block 在 block 1; 若 block 的单位为 2KB 或 4KB，则 boot sector 和 super block 都在 block 0。

fdisk 分区只支持 2TB 以下的硬盘，足够用了，若要想对 2TB 以上的硬盘分区，则可以使用 parted。

    # parted 设备名 [选项]

## 第 9 章 打包与压缩

compress, gzip, zcat, bzip2, bzcat, tar

    # tar [-j|-z] [-c|-x|-t] [-p|-P] [-v] [-f] zipfilename [source_folder] [-C target_folder] [--exclude=xxx] [--newer] [--newer_time]
    -p: 保持原来的权限
    -P: 保持原来的绝对路径
    -t: 查询

- .tar: tarfile
- .tar.gz, .tar.bz2: tarball

dump，restore，完整备份恢复。

光盘制作、刻录命令：mkisofs, cdrecord。

    # mkisofs -rv -V "linux_file" -o /tmp/system.img -m /home/lost+found -graft-point /root=/root /home=/home /etc=/etc
    // graft：移花接木
    # ll -h /tmp/system.img
    # mount -o loop /tmp/system.img /mnt
    # ll /mnt
    # umount /mnt

dd, cpio

    # dd if=/dev/hda1 of=/tmp/boot.img bs=512 count=1    // 拷贝第一个扇区

## 第 10 章 vim

略。
