# Linux Basic Note

## 4 - 文件查找

- 命令查找：which，whereis，type，从 $PATH 查找
- 文件查找：locate，find

### 命令查找

常见命令的路径：

- /sbin/ - root 用户的命令
- /usr/sbin/ - root 用户的应用程序命令
- /bin/ - 普通用户的命令
- /usr/bin/ - 普通用户的应用程序命令

内部命令：与生俱来，随着 shell 加载到内存，存放在内存里，比如 cd 命令。

    $ which cd
    cd: shell built-in command

    $ whereis cd
    /usr/bin/cd

    $ type cd
    cd is a shell builtin

    $ type -a cd
    cd is a shell builtin
    cd is /usr/bin/cd

外部命令：存放在磁盘，先在磁盘里找着，再加载到内存里，比如 ls。

    $ type -a ls
    ls is an alias for ls -G
    ls is /bin/ls

查找命令的顺序：

1. 不查找的情况：已指定路径，即用 `.` 或 `/` 开头的命令
1. alias
1. builtin
1. $PATH

type 命令，大体相当于 which + whereis。

    $ type -a echo
    echo is a shell builtin
    echo is /bin/echo

### 文件查找

**locate**

    $ locate passwd
    $ touch aaa.txt
    $ locate aaa.txt  # 找不着
    $ locate locate   # /var/lib/mlocate/mlocate.db

因为 locate 是从数据库里找的，计划任务自动更新。手动更新数据库：updatedb。

**find**

find：兢兢业业，没有数据库，直接从磁盘上找。

    # usage:
    $ find path express

    $ find /etc -name passwd
    $ find /etc -name "passwd*"
    $ touch ccc
    $ touch CCC
    $ find . -name ccc
    $ find . -iname ccc      # i 忽略大小写

    $ find /etc -size +5M    # > 5M 的文件
    $ find /etc -size 2k     # = 2k
    $ find /etc -szie -2k    # < 2k

    $ find /etc -mtime +3    # 修改时间超过 3 天
    $ find /etc -mtime 3
    $ find /etc -mtime -3

    $ find /home -user alice
    $ find /home -group alice

    # 取反，!
    $ find /home ! -user alice

    # 进行逻辑运行，-a 和 -o
    $ find /home ! -user alice -a -group hr

    # 查找没有属主的文件
    $ find /home -nouser
    $ find /home -nouser -o -nogroup

    # 按类型查找：f / d / b (block device) / l (link) / s (socket) / p (pipe) / c (char device)
    $ find /ect -type d -ls       # 查找目录，-ls 把详情列出来
    $ find /etc -type f           # 查找普通文件
    $ find /dev -type b/l/s/p/c

    # 按权限查找
    $ find . -perm 777 -ls        # 权限 = 0777
    $ find . -perm -777 -ls       # 只要包含 777 这个权限就行
    $ find . -perm -4000 -ls
    $ find /bin -perm -4000 -ls

    # 找到后对结果进行操作
    $ find /bin -perm -4000 -exec cp -rf {} /var/tmp \;
    # -exec 到 \; 之间的为 shell 命令，{} 表示找到的结果

注意这条指令：

    $ find . -nouser -o -nogroup -exec rm -rvf {} \;
    # 错误，-o 导致的

    $ find . \( -nouser -o -nogroud \) -exec rm -rvf {} \;
    # 正确，加上括号

    $ find . ! -name file16 -a ! -name file3 -exec rm -rvf {} \;
    # -a 能正确执行，但容易引起歧义，最好也加上括号

示例，将 /etc 的目录结构拷贝到 /tmp 目录：

    $ find /etc -type d -exec mkdir -pv /tmp{} \;

更多示例：

    $ cp /etc /var/tmp
    $ cd /var/tmp
    $ find ./etc -type d -exec chmod 777 {} \;
    $ find ./etc -type f -exec chmod 666 {} \;

## 5 - 文件的链接

- 硬链接
- 软链接

硬链接：inode 不变，引用增加 1，原文件删除也无所谓。相当于将原文件在别的地方增加了一个入口。

    $ ln source target

软链接 (符号链接 symbolink)：相当于新建了一个 inode 改变的文件，相当于原文件的快捷方式，依附于原文件而存在，若原文件删除，则此软链接无意义。软链接的权限是 777，但这毫无意义。

    $ ln -s source target

例子：

    $ touch file100
    $ ln /root/file100 /file200
    $ ln -s /root/file100 /file300-s
    $ ll -i /file200 /file300-s /root/file100

硬链接的缺陷：不能为目录做硬链接，不能跨分区，但软链接可以。

为目录做了软链接后，删除时最后不能用 `/`，不然删不掉。

## 6 - 打包 (归档) 和压缩

打包：tar，后缀 .tar，后缀手动加上。tar 只负责将多个文件打包成一个或解包，并不负责压缩。

    $ tar cvf target source
    $ tar cvf etc1.tar /etc

压缩：

- gzip，后缀 .gz，后缀自动加上。
- bzip2，后缀 .bz2，后缀自动加上。

示例：

    $ gzip -r dir10
    $ time gzip etc1.tar
    $ time bzip2 etc2.tar  # 任何命令前加上 time 用来计时

解压缩：

    $ gzip -d etc1.tar.gz
    $ bzip2 -d etc2.tar.bz2

解包：

    $ tar xvf etc1.tar
    $ tar xvf etc2.tar -C /tmp  # -C 解压到别的目录，而不是当前目录

连起来用 (压缩包会保留)：

    # z 表示 gzip 格式，j 表示 bzip2 格式
    # v 表示显示处理中的文件
    # c - 打包并压缩
    $ tar zcvf etc1.tar.gz /etc
    $ tar jcvf etc2.tar.bz2 /etc

    # x - 解压并解包
    $ tar zxvf etc1.tar.gz
    $ tar jxvf etc2.tar.bz2

但现在的 tar 已经很智能了，解压时可以自动判断压缩包的格式，无须 z 或 j 参数：

    $ tar xf etc1.tar.gz
    $ tar xf etc1.tar.bz2

zip 格式的压缩包：

    $ unzip etc.zip

(怎么压缩成 .zip 格式?)

## 7 - rsync

rsync：增量同步

    $ rsync a.txt /1.txt                  # 镜像复制，权限保持一致，本地使用时等于 cp 命令
    $ rsync -va /etc 192.168.3.9:/tmp     # 拷贝到远程机器
    $ rsync -va etc.tar 192.168.3.9:/tmp
    $ rsync -va 192.168.3.9:/etc/hosts .

    $ cd ~
    $ mkdir dir20
    $ touch dir20/file{1..20}
    $ rsync -a dir20 192.168.3.9:/tmp

    $ rm dir20/file1
    $ rsync -a --delete dir20 192.168.3.9:/tmp

(对哦！我可以用这个命令来将将我的 u 盘内容同步到磁盘上。)
