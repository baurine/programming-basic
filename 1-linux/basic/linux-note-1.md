# Linux Basic Note

主要内容：

- 文件管理
- 权限管理
- 网络配置

## 1 - 启动

Linux 的 7 个启动级别：

- 0：关机
- 1：单用户模式 (不启动网络，root 用户，无须密码)
- 2：多用户模式 (很少用，与级别 3 相比，仅缺少 nfs 功能)
- 3：字符模式
- 4：保留
- 5：图形
- 6：重启

平时常用的只有 3 和 5，破解密码需要用到模式 1。

启动时在 grub 菜单，使用 a/e 命令修改 kernel 一行的参数，在最后加上 1，表示进行模式 1。进入后使用 passwd root 修改 root 密码。

为了防止别人使用这种方法破解 root 密码，可以为 grub 加上密码, 方法是修改 [/etc/grub.conf](./grub.conf) 文件，在 title 上面加上一行 `password --md5 xxxx`，可以用 grub-md5-crypt 命令产生 md5 值。

在 grub 加上密码后，就只能使用启动光盘，进入 rescue 模式来修改 root 密码。

使用光盘启动,输入：

    $ linux rescue
    $ chroot /mnt/sysimage
    $ passwd root

分区：swap 是系统内核层使用的，不是给用户层使用的，所以不需要挂载。

Gnome，KDE 是在 X window 上的图形环境，不能脱离 X window 而存在。

## 2 - 常用 shell 命令

**tty**

tty 命令用来查看所在终端，终端也是个文件。

- 本地终端：/dev/tty1, /dev/tty2 ...
- 远程终端：/dev/pts/1, /dev/pts/2 ...

(为何在图形界面本地终端是 /dev/pts/1 ?)

**shell**

shell：命令解释器，把命令翻译给内核，广义上是指外围的一切应用程序，窄义是指文本命令行，shell 也是一个程序。

    $ echo $SHELL
    /bin/bash  # GNU 开发的

    $ cat /etc/shells
    sh, bash, tcsh, csh, ksh ...

一般 `#` 开头表示 root 用户，`$` 开头表示普通用户。

- ctrl + d：退出的快捷键
- ctrl + l：清屏

shell 命令的格式：命令 选项 参数

- 选项：-a, --all ...
- 参数：

示例：

    $ date +%F
    $ date -s 14:28      # -s 是选项，14:28 是参数
    $ date 122513452012  # 只有参数，没有选项

命令是主体，选项是影响或微调命令的行为，参数是命令作用的对象。

ls，显示文件列表，目录也是一种文件。

`ls -l`，显示的是 mtime。

- atime: access time
- ctime: change time，权限修改时的时间
- mtime: modify time

自动补全：只有命令和文件可以补全，选项和参数无法补全，自动补全时，如果出现 `/`，说明这是一个目录。

    $ service network restart  # 只有 service 可以补全，network，restart 是参数

命令的历史记录：history

- 上下键 - 查看历史命令
- ctrl + r 快捷键 - 查找历史命令，只能找到最相似的一条
- !da - 查找最近以 da 开头的命令，只能找到最近的一条
- !! - 上一条命令
- ctrl + p - 上一条命令
- !-1 - 上一条命令
- !33 - 执行历史命令中的第 33 条

        $ history | grep cat
        ...
        10047  cat /etc/shells
        $ !10047
        # = cat /etc/shells

- !$ - 上一个命令最后一个参数

        ls /home/alice
        cd !$
        # 等于 cd /home/alice

- $? - 上一个程序运行的结果，一般是 0 或 1，0 表示 成功，其它表示失败，一般用来在 shell script 用来判断上一条语句是否执行成功

        $ date
        $ echo $?
        0

输入命令时：

- ctrl + a - 回到行首
- ctrl + e - 回到行末
- ctrl + k - 从光标处删除到行末

关机：poweroff, halt, shutdown -F now, init 0

重启：reboot, init 6, shutdown -r now

runlevel：查看当前运行级别

获得帮助：

    $ cmd --help
    $ man [n] cmd

路径：绝对路径，相对路径。

    $ cd -  # 返回上一次离开的位置

mkdir：

    $ mkdir -p ~/dir1/dir2        # 创建整个目录结构
    $ mkdir -v /home/{dir5,dir6}  # 好高级的用法呀

alias：

    $ alias ys='cd /home/alice'
    $ unalias cp

touch：

1. 新建文件

        $ touch file{1..100}  # 两个点号
        $ touch file{2,3,4}

1. 改变已存在文件的 time

stat：查看文件属性，包括 access time (atime)，modify time (mtime)，change time (ctime)，change time 表示是权限修改时的时间。

    $ stat README.md
    16777220 69835765 -rw-r--r-- 1 baurine staff 0 20 "Oct  7 10:25:34 2017" "Oct  7 10:23:29 2017" "Oct  7 10:23:29 2017" "Oct  7 10:23:29 2017" 4096 8 0 README.md

which：查看命令路径

    $ which cp
    /bin/cp

shell 优先使用别名，在命令前加个 `\`，则不使用别名。

    $ \cp -f /etc/hosts /home/dir1

安全的删除方法 (?)：

    $ cd xxx && rm -rf zzz

**文件内容**

查看文本文件的命令：cat, tac, more, less, head, tail

    $ cat /etc/hosts
    $ cat -n /etc/hosts    # 显示行号
    $ cat -A /etc/hosts    # 显示控制字符，换行，回车

- more：只能用空格和回车控制前进，无法后退，所以基本不用
- less：可以前进，后退，搜索，常用。操作方式和 vim 的命令模式相同
- head：看前几行 `head -5 /etc/passwd`
- tail：看后几行 `tail -5 /etc/passwd`

`tail -f`，查看文本的实时内容：

    $ tail -f test.txt
    $ echo 111 >> test.txt
    # 但是如果用 vim test.txt 往 test.txt 里写内容，tail -f 的输出却不会动态更新。
    # 原因：用 ll -i test.txt 命令查看文件的索引号，用 vim 编辑后索引号会变，而使用 echo 追加时索引号不会变。 tail -f 是通过索引号去寻找文件的。

unix2dos, dos2unix：转换 windows 和 linux 的文本文件

记住！linux 的所有命令，重点在于它的各种选项和参数！基本没有可以直接拿来用的，所以要多用 man 和 --help。

**grep**

grep：按行正则查找。

    $ grep 'root' /etc/passwd
    $ grep --color 'root' /etc/passwd

    # 行首带 root 的行
    $ grep --color '^root' /etc/passwd
    $ grep --color 'nologin$' /etc/passwd

    # 找单词
    $ cat a.txt
    tommorrow
    hello tom, how are you!
    555
    666
    $ grep --color -n '\<tom\>' a.txt

    # -A5: after 5 lines
    $ grep --color -A5 'do_rsa1_keygen()' /etc/init.d/sshd

    # -A5: after 5 lines
    # -B5: before 5 lines
    $ grep --color -A5 -B5 'do_rsa1_keygen()' /etc/init.d/sshd

    # -C5: after and before 5 lines.
    $ grep --color -C5 'do_rsa1_keygen()' /etc/init.d/sshd

    # 只能一级目录按文件内容搜索
    $ grep 'do_rsa1_keygen' /etc/init.d/*

    # 只能一级目录按文件内容搜索, -l 只显示文件名
    $ grep -l 'do_rsa1_keygen' /etc/init.d/*

    # 递规搜索，可以多级目录
    $ grep -r 'do_rsa1_keygen' /etc

    # -v 参数，取反，表示查找不匹配的结果
    # 查找不含  do_rsa_keygen 的文件
    $ grep -v 'do_rsa_keygen' /etc

    # -o 参数
    $ (待补)

粘贴：

- 在 tty1-tty6，用鼠标选中一段文字后，点鼠标右键粘贴；
- 在 tty7 的终端里，用鼠标选中一段文字后，点击滚轮粘贴；

显示二进制文件中的字符内容：

    # 打印文件中可打印的内容，可用来提取字符串。
    > strings /bin/cp
    $FreeBSD: src/bin/cp/utils.c,v 1.46 2005/09/05 04:36:08 csjp Exp $
    $FreeBSD: src/bin/cp/cp.c,v 1.52 2005/09/05 04:36:08 csjp Exp $
    @(#)PROGRAM:cp  PROJECT:file_cmds-264.50.1
    %s not overwritten
    overwrite %s? %s
    ...

**修改文件：vim**

已将此部分内容合并到 vim 的笔记中。
