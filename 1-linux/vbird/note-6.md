# 鸟哥的 Linux 私房菜基础学习篇 (第三版) 读书笔记

## 第 23 章 软件安装

    distribution   机制   本地命令       在线机制 (命令)
    redhat/fedora  RPM   rpm,rpmbuild  YUM (yum)
    debian/ubuntu  dpkg  dpkg          APT (apt-get)

- RPM: Redhat Package Manager. xxx.rpm
- SRPM: Source RPM，xxx.src.rpm，安装时要先编译成 rpm 包，再按 rpm 包的安装方式进行安装。

平台：i386, i586, i686, x86_64, noarch

- i386, i586, i686: cpu 级别，PII 以后的都是 i686；
- x86_64: 可运行于 64 位平台
- noarch: 程序可运行于任何平台，里面一般不含二进制，一般以 shell script 居多。

### RPM

通过 RPM 安装后的软件的相关信息存放在 /var/lib/rpm/ 目录下的数据库文件中了，这个目录里的数据很重要，将来的查询，升级，数字证书都来自这里的数据库。

真实文件内容分别存放在：

    /usr/bin
    /usr/lib
    /usr/share/doc
    /usr/share/man

**安装**

    # rpm -ivh package_full_name
    -i: install
    -v: 显示详细的安装信息
    -h: 显示进度
    package_full_name: rpm 包的完整名或路径，可以是网络路径
    其它参数：
    --test
    --prefix: --prefix/usr/local

**升级 (upgrade) 或更新 (freshen)**

    # rpm -Uvh package_name
    # rpm -Fvh package_name
    -Uvh: 安装或升级
    -Fvh: 只更新

**查询 (重要!)**

    # rpm -qa
    # rpm -q[licdR] 已安装软件名
    # rpm -qp[licdR] 未安装地软件的文件名
    # prm -qf 存在于系统的某个文件名
    -q: 仅查询
    -qa: 查询所有已安装的软件
    -qi: information，列出该软件详细信息
    -ql: 列出该软件所有文件与目录路径
    -qc: 仅列出设置文件路径
    -qd: 仅列出帮助文件路径
    -qR: 列出依赖软件
    -qf: 反查该文件由哪个软件提供
    -qp[licdR]: 查找某个未安装的 rpm 的相关信息

### RPM 验证与数字证书 (Verify / Signature)

**验证 (Verify)**

使用 /var/lib/rpm 里的数据库和当前系统的文件对比。

    # rpm -V 软件名
    # rpm -Va
    # rpm -Vf 系统里的文件名
    # rpm -Vp 某个 rpm 文件的文件名
    -V: 列出某个软件被改动过的文件
    -Va: 列出所有
    -Vf: 列出此文件所属的软件被改动过的所有文件
    -Vp:

示例，安装 logrotate

    # rpm -ql logrotate

然后修改 /etc/logrotate.conf 后进行验证

    # rpm -V logrotate
    ..5....T c /etc/logrotate

**数字证书**

数字证书，检验软件的来源。

安装一个 RPM 文件时：

1. 首先必须安装原厂发布的公钥文件；
1. 实际安装原厂的 RPM 软件时，RPM 命令会读取 RPM 文件的证书信息，与本机的证书对比；
1. 若相同才能继续，否则警告并停止安装。

GPG: Gnu Private Guard.

    # ll /etc/pki/rpm-gpg/RPM-GPG-KEY-Centos-5

安装证书

    # rpm --import /etc/pki...
    # rpm -qa | grep pubkey | xargs rpm -qi

**卸载与重建数据库**

    # rpm -e 软件名       // 若有依赖问题则无法卸载
    # rpm --rebuilddb    // 重建 /var/lib/rpm 数据库

**SRPM: rpmbuild**

    # rpmbuild --rebuild      // 编译打包
    # rpmbuild --recompile    // 编译打包安装

工作目录

    /etc/src/redhat/SPECS      // 设置文件，重要！
    /etc/src/redhat/SOURCES    // 源码及 config 文件
    /etc/src/redhat/BUILD      // 编译过程数据暂存地
    /etc/src/redhat/RPMS       // 最后生成的 rpm
    /etc/src/redhat/SRPMS      // srpm

    # rpm -i xxx.src.rpm       // 将 srpm 文件释放到 /etc/src/redhat/ 目录

    # vim /etc/src/redhat/SPECS/xxx.spec

修改 xxx.spec 后

    # rpmbuild -ba xxx.spec    // 同时编译成 rpm 和 srpm
    # rpmbuild -bb xxx.spec    // 仅编译成 rpm

### YUM

**查询**

    # yum [list|info|search|provides|whatprovides]
    list: 类似 rpm -qa，也可以模糊查找，比如 yum list pam*
    info: 类似 rpm -qi
    search: 好用，模糊查找软件名
    provides: 反查，从文件名反查软件名，类似 rpm -qf，但比 rpm -qf 更好的地方在于可以反查还未安装的软件名，而 rpm -qf 只能查找已安装的软件名

    # yum search raid
    # yum info mdadm
    # yum list [updates]
    # yum list pam*
    # yum provides passwd

**安装和升级**

    # yum [-y] [--installroot=path] [update|install] 软件名
    update: 若后面不跟软件名，则升级整个系统的软件
    -y: 自动 yes

**卸载**

    # yum remove 软件名

yum 的配置文件：/etc/yum.repos.d/xxx.repo

    # yum repolist [all]

若修改了配置文件，比如改了 baseurl 却没有改 id，则有可能需要清缓存，以免数据不同步。

    # yum clean [packages|headers|all]

yum 组功能

    # yum [grouplist|groupinfo|groupinstall|groupremove]

## 第 24 章 X Window

X11 --> X11R6 --> X11R6.3 --> XFree86 (X + Free Software + x86) --> Xorg --> X11R6.8 --> X11R7 ...

- X Server
- X Client
- X Window Manager (特殊的X Client): gnome, kde, xfce
- Display Manager: 提供登录需求，gdm

startx 命令：

    # startx [X client 参数] -- [X Server 参数]

startx 只是一个脚本，用来先配置或读取 X 环境参数，真正起作用的是 xinit。

X Server 参数顺序：

1. startx 参数
1. ~/.xserverrc
1. /etc/X11/xinit/xserverrc
1. 执行 /usr/bin/X

X Client 参数顺序：

1. startx 参数
1. ~/.xinitrc
1. /etc/X11/xinit/xinitrc
1. 执行 xterm (此为 X 下面的终端机软件)

startx 会调用 xinit

    # xinit [client option] -- [server or display option]

默认

    # xinit xterm -geometry +1+1 -n login -display :0 -- X :0

X Server 会读取 /etc/X11/xorg.conf

试验：

在 tty1 启动 X，在 tty8 看

    # X :1 &
    # xterm -display :1 &
    # xclock -display :1 &
    # xeyes -display :1 &
    # twm -display :1 &
    # jobs
    # kill %n

**X Server 配置**

- 配置：/etc/X11, /etc/X11/xorg.conf
- 模块：/usr/lib/xorg/modules
- 字体：/usr/share/X11/fonts

        # chkfontpath

- 显卡芯片组：/usr/lib/xorg/modules/drivers/

## 第 25 章 备份策略

略。

## 第 26 章 内核编译与管理

    # make mrproper
    # make clean

/boot/config-xxxx

    # make menuconfig
    # make oldconfig
    # make xconfig    // Qt, KDE
    # make gconfig    // Gtk, gnome
    # make config

    # make vmlinux    // 生成未经压缩的内核
    # make modules    // 仅内核模块
    # make bzImage    // 生成压缩的内核
    # make all

    # make modules_install

    # mkinitrd ...    // ?
    # vim /boot/grub/menu.lst
