# Linux Basic Note

## 8 - 软件包的管理

- 查询
- 安装
- 卸载

以 RedHat 发行版为例。

rpm：RedHat Package Manager

rpm 包的安装渠道：光盘、网络 (rpmfind.net) ...

有两种管理方式：

1. rpm
1. yum

**mount & unmount**

因为我们待会要通过 RedHat 的安装光盘来进行安装一些应用。所以要先把 CDROM 挂载到系统 (现在的图形界面已经可以自动挂载了)，因此先初步学习一下 mount 和 unmount。

先 umount：

    $ umount /dev/cdrom
    $ umount /dev/sr0
    $ umount /media/RHL...

umount 后，光驱只能被系统访问，比如制作光盘镜像：

    $ dd if=/dev/cdrom of=/root/rh5_8.iso

(所以，挂载意味站加载了它的文件系统？我想是的。)

重新 mount：

    $ mkdir /mnt/cdrom
    $ mount /dev/cdrom /mnt/cdrom

**rpm**

rpm 的包名格式：vnc-4.1.2-14.el5_6.6.i386.rpm

- vnc - rpm 包名
- 4.1.2 - 版本
- 14.el5_6.6 - 发行版本 (el5 = redhat Enterprise Linux 5)
- i386/i686 - 32位

一些查看内核版本、平台的命令：

- `cat /etc/issue` : 查看当前系统的发行版本
- `uname -m` : 查看平台 32/64，i686，x86_64
- `uname -r` : 内核版本

要装的包：

- 服务器端：tftp-server, vsftpd, httpd, openssh-server
- 客户端：tftp, ftp, lftp, elinks, openssh-client

装之前先查询有没有安装：

    $ rpm -q rpm_package_name      # 包名必须严格相同，无法通配

    $ rpm -q vnc                   # 无须后面的版本号等信息
    $ rpm -qa | grep vnc           # a 显示所有，再过滤

    $ rpm -q tftp-server

安装：

    $ rpm -ivh rpm_name            # v 显示详情，h -- hash

    $ rpm -ivh ntfs-3g-2011.4.12-5.el5.i386.rpm

卸载：

    $ rpm -e rpm_name  # e -- erase，rpm 包名不需要后面的版本号

    $ rpm -e ntfs-3g   # 可以不用 rpm -e ntfs-3g-2011.4.12-5.el5

**yum**

通过 rpm 安装要手动解决包的依赖关系，而 yum 可以自动解决依赖关系 (内部用的还是 rpm)。

我们用光盘来安装这些应用，光盘的 Server/repodata/ 目录里记录了包的依赖关系。

使用 yum，第一步告诉 yum 的软件仓库位置。挂载 CDROM 后，仓库位置位于 /mnt/cdrom/Server。编辑 /etc/yum.repos.d/rhel5.repo，文件名随便，但后缀必须是 repo。

    $ vim /etc/yum.repos.d/rhel5.repo

    [rhel5]
    name=rhel5
    baseurl=file:///mnt/cdrom/Server
    gpgcheck=0  # 不检查软件包的签名

查询：

    $ yum list httpd
    $ yum list mysql-server

安装：

    $ yum install httpd
    $ yum -y install httpd  # 不询问
    $ yum repolist          # 查看配置的所有仓库

卸载：

    $ yum -y remove httpd

组查询和组安装：

    $ yum grouplist
    $ yum groupinstall "group1" "group2" -y
    $ yum groupremove "group1"

升级：

    $ yum -y update httpd

全部升级：

    $ yum -y update

查询某个命令是由哪个 rpm 包提供的：

    $ dhcpd
    command not found
    $ yum -y install dhcpd
    No package dhcpd available  # dhcpd不是一个包，只是一个包里的命令
    $ yum provides dhcpd
    ....
    $ yum provides */dhcpd
    # 查出来是 dhcp-xxxx 包
    $ yum -y install dhcp

    # 也可以查询某个文件是由哪个 rpm 包提供的
    $ yum provides */smb.conf

rpm 只能查询已安装的命令或文件是由哪个 rpm 包提供的，而 yum 对已安装和未安装的都可以查询。

    $ which date
    /bin/date
    $ rmp -qf /bin/date
    coreutils-xxx.el5

    $ rpm -q yum

    # 查询 yum 装了哪些文件在电脑上
    $ rpm -ql yum

清缓存：

    # 安装的缓存
    $ cd /var/cache/yum

    # 会将 /var/cache/yum 里面的缓存清空
    $ yum clean all

yum 只能单独使用，不能同时有两个 yum 进程。

图形化的界面：应用程序 --> 添加 / 删除软件，前提是要先配置好 yum。

**继续探索 mount**

不用光盘的两种办法：

1. 把光盘里的内容拷贝到硬盘里，需要挂载。

        $ cp -rvf /mnt/cdrom/* /root/rhel5

1. 把光盘做镜像，无须挂载。做完镜像后再将镜像挂载到系统。

        # 做光盘镜像是由于不用访问文件系统，所以不用挂载
        $ dd if=/dev/cdrom of=/root/xxx.iso

        # 挂载镜像
        $ mount /root/rhel5_8.iso /mnt/cdrom
        # 错误！会提示 iso 不是块设备，需要加 -o loop 选项

一个设备不可以同时被挂载多次！

挂载时可以通过 -o 添加各种选项：

    $ mount -o ro /dev/sdb1 /mnt/usb
    $ mount  # 显示各挂载点的属性
    /dev/sdb1 on /media/disk type vfat (rw,nosuid,nodev,shortname=winnt,uid=0)
    /root/rhel5.iso on /mnt/cdrom type iso9660 (rw,loop=/dev/loop0)

以上的挂载都是临时的，重启后就没有，可将上面的挂载命令写入到开机启动脚本中。

    $ vim /etc/rc.local  # 开机自动启动脚本，这个脚本具有 x 属性

sync 命令，将 buffer 里的数据同步到外存里，当在 linux 里 umonut 设备显示 busy 时，可以用一下这个命令。

    $ cat /proc/meminfo | grep D
    Dirty:  60KB
    $ sync
    $ cat /proc/meminfo | grep D
    Dirty:  0KB

umount 时可以用　-l 命令进行强制卸载，但此时就不会理会 buffer 里面的内容。

    $ umount /mnt/usb/ -l

关机时会自动 sync。

mount / unmount 要熟练掌握。

watch 命令：

    # watch -n 1 [命令]  # 持续地看输出结果
    $ watch -n 1 "cat /proc/meminfo | grep D"
    # 动态时钟
    $ watch -n 1 date

/proc 是内存状态，并非实际存在的文件目录。

du：统计目录体积

    $ du -h /etc
    # -s: summary
    $ du -sh /etc

    $ cp /media/rhel5/* /home/dir20/
    $ watch -n 1 du -sh /home/dir20/

### 源码包的安装

无平台区分，必须要先安装好各种编译器和库。

三步曲：

1. 配置 (可选)。执行 `./configure` 命令。主要是检查是否具备编译的条件，定制定制安装的选项，比如安装的路径，功能模块。最终会生成一个叫 makefile 的文件。
1. 编译。执行 `make` 命令。make 命令要据 makefile 进行编译。
1. 安装。执行 `make install` 命令。

一般源码包下会有 INSTALL 和 README 两个帮助文件指导安装过程。

以安装 httpd-2.2.11.tar.bz2 源码包为例：

解压：

    $ tar xvf httpd-xxx -C /tmp
    $ cd /tmp/httpd-xxx

配置：

    $ ./configure --prefix=/usr/local/apache2
    # --prefix 指定安装路径，二进制源码包一般安装到 /usr/local/服务名
    # 如果没指定 --prefix，可以通过 --help 查看，里面会说明默认的安装路径

编译：

    $ time make -j 2
    # 用 time 计时
    # -j 2 表示用 2 个核进行编译

安装：

    $ make install

安装后就可以启动 apache 服务：

    $ /usr/local/apache2/bin/apachectl start
    # 要想开机就启动就把这条命令加到 rc.local 里

此时通过浏览器访问 ip 就能看到效果了。

卸载时，把服务停止，把整个安装目录删除即可，就跟 windows 下的绿色软件一样。

    $ make uninstall
    # 这样也可以卸载，但需要 makefile 有 uninstall 的支持

### bin 包的安装

加上 x 属性，运行即可，默认安装在当前目录。

以 jdk-6u27-linux-i586.bin 为例：

    $ chmod 777 jdk-6u27-linux-i586.bin
    $ ./jdk-6u27-linux-i586.bin
