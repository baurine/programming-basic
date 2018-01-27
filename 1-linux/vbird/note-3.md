# 鸟哥的 Linux 私房菜基础学习篇 (第三版) 读书笔记

## 第 13 章 - shell script

    # ll /bin/sh         // sh 是 bash 的符号链接
    # bash xxx.sh
    # sh xxx.sh
    # sh -n -x xxx.sh    // 利用 sh 来执行脚本时，可以利用 -n,-x 等 sh 的参数

整个 script 中，除了第一行的 `#!` 是用来声明 shell 的之外，其它的 `#` 都是注释。

第一行的 `#!/bin/bash` 用来声明这个 scrpit 用的 shell 名称，当这个程序被执行时，它就能加载对应的 shell 的相关环境配置文件 (一般来说就是 no-login shell，比如 ~/.bashrc)。

    # declare -i total=$first*$second
    # total=$(($first*$second))
    # echo $((13%3))
    1
    echo $((运算内容))
    echo $[运算内容]

script 各种执行方式的区别：./script, sh script, source script

- `./script`: 该 script 必须有 x 权限，在 bash 的子进程执行。
- `sh script`: 该 script 只要有 r 权限即可，且可以使用 bash 的参数如 -n -x，在 bash 的子进程执行。
- `source script`: 该 script 只要有 r 权限即可，不能使用 bash 的参数如 -n -x，在当前 bash 进程执行。

利用 test 命令的测试功能

    # test -e /dmtsai && echo "exist" || echo "not exist"

1. 文件类型判断，如 `test -e filename`

   -e / -f / -d / -b / -c / -S / -p / -L

1. 文件权限检测，如 `test -r filename`

   -r / -w / -x / -u: suid / -g: sgid / -k: sticky / -s: file exist and is not empty

3，两个文件比较，如 `test file1 -nt file2`

      -nt: newer
      -ot: older
      -ef: same inode

4，两个整数的检测，如 `test n1 -eq n2`

      -eq: equal
      -ne: not equal
      -gt: greater than
      -lt: less than
      -ge: greater than or equal
      -le: less than or euqal

5，判断字符串，如 `test -z string`

      test -z string: return true if string is empty
      test [-n] string: return true if string is not empty
      test str1=str2
      test str1!=str2

6，逻辑

      -a: test -r file -a -x file
      -o: test -r file -o file
      !: test ! -x file

使用 [] 来判断，与 test 相似的作用，但使用时要特别注意空格。常用在 if...then...if 中。

注意事项：

1. 在中括号 [] 内的每个组件都要用空格隔开；
1. 在 [] 内的变量，最好都以双引号括起来，特别是变量内容里含有空格的，必须用双引号引起来；
1. 在 [] 内的常量，最好以单引号或双引号引起来。

示例：

    # name="baurine sparkle"
    # [ "$name" == "baurine" ]; echo $?
    // 这里 == 也可以写成 =，判断里没有赋值操作

shell script 的默认变量: $0, $1, $2...$#, $@, $*

    # test.sh opt1 opt2 opt3
      $0      $1   $2   $3

- $#: 当前参数个数
- $@: 所有参数，"$1" "$2" "$3"...
- $*: 所有参数，"$1c$2c$3..."，其中 c 为分隔字符，默认是空格
- $$: shell 脚本的进程号，脚本程序一般用它来生成临时文件，比如 tmp_$$

shift: 将参数左移，每 shift 一次，将移出最左边的参数。

条件判断：

    if [ condition ]; then
    fi

    if [ condition ]; then
    else
    if

    if [ condition ]; then
    elif [ condition ]; then
    fi

case...esac 分支判断，注意，双分号结束。

    case $var in
      const1)
        do something
        ;;
      const2)
        do something
        ;;
      *)
        do something
        ;;
    esac

function：

    function fname() {
    }

函数内部也有自己的 $0, $1... 和 shell 本身的 $0, $1 含义一样，但值不一样。

函数可以使用 return 语句返回某个值。

loop：

    while [ condition ]
    do
    done

    until [ conditon ]
    do
    done

for：

    for var in con1 con2 con3...    // 可以用 $(seq 1 100) 产生序列
    do
    done

    for ((init; limit; step))
    do
    done

shell script 的追踪与调试：

    # sh [-nvx] script.sh
    -n: 检查语法
    -v: 执行前先将 script 的内容输出到屏幕上
    -x: trace

补充：From《Linux 程序设计第四版》，setuid 和 setgid 对脚本不起作用，只对二进制程序有效。

语句块，用 {}：

    mkdir test && {
      grep -v "$name" $catfile > $temfile
      cat $tmpfile > $tmp2file
      echo
    }

break, continue。

`. ./xxx.sh`，点命令，相当于 source，在当前 shell 执行命令。

eval：求值

exec：相当于 fork() + exec()，exec 后面的内容不再执行??

exit n：退出时返回退出码 n

export：导出变量，使其可以传递给子进程

expr：将参数作为一个表达式求值，目前一般使用更为有效的 `$(())` 替代。

    x=`expr $x+1` ==> x=$(expr $x+1) ==> x=$(($x+1))

## 第 14 章 - 账号管理与 ACL

了解即可。

/etc/passwd

uid: 0 为 root, 1~499 为系统账户。

/etc/shadow：密码，9 列

    用户名:密码md5值:最近更改密码的日期:密码不可更改的天数:密码需要重新更改的天数:密码需要更改前的警告天数:密码过期后的账号宽限天数:账号失效日期:保留

有效与初始用户组

/etc/group

账号管理：useradd, passwd, usermod, userdel

    # useradd [-u uid] [-g group] [-G group] [-mM] [-c desc] [-d home_folder] [-s shell] [-r] user_name
    # useradd -D    // 查看 useradd 时的默认值
    ...
    SKEL=/etc/skel
    ...

    # cat /etc/login.defs | egrep -v "^$|^#"
    /etc/default/useradd
    /etc/login.defs
    /etc/skel/*

    # passwd username
    # echo "12345" | passwd --stdin username
    # chage ...     // 密码参数功能显示  passwd -S username
    # usermod ...
    # userdel [-r] ...

查看

    # finger
    # finger [-sm] username
    # id
    # id username

修改

    # chfn [-foph] username
    # chsh [-s]    // change shell

新增与删除组

    # groupadd [-g gid] [-r] groupname
    # groupmod [-g gid] [-n newname] oldname
    # groupdel groupname

gpasswd：用户组管理员功能

root 用户：

    # gpasswd groupname
    // 为 group 设密码

    # gpasswd [-A user1,user2...] [-M user3,user4...] groupname
    -A: 增加管理员用户
    -M: 增加普通用户

    # gpasswd [-rR] groupname
    -r: 将 groupname 密码删除
    -R: 将 groupname 密码栏失效

用户组管理员：

    # gpasswd [-ad] username groupname
    -a: 将用户添加到组中
    -d: 将用户从组中删除

组成员：

    # newgrp groupname

### ACL

ACL: Access Control List

    # dumpe2fs -h /dev/sda7 | grep acl
    # mount -o remount,acl /
    # mount | grep acl
    # vim /etc/fstab
    LABEL=/1 / ext3 defaults,acl 1 1

    # setfacl [-bkRd] [-m|x acl 参数] [file|folder]
    -m: 设置
    -x: 删除

    # getfacl
    u:[username]:[rwx]
    // 若 [username] 为空，则默认表示属主

    # setfacl -m u:vbird:rx acl_test1
    # setfacl -m u::rwx acl_test1
    g:[groupname]:[rwx]
    # setfacl -m g:group1:rx acl_tets1
    m:[rwx]
    // 设置 mask
    # setfacl -m m:r acl_test1

用户身份切换：su, sudo

    # su [- -l] [-mp] [-c cmd] username
    -: 同时切换环境变量，如果不加 -，切换的仅仅是 username，但环境变量还是当前的
    -l: 同 -
    -m, -p: 相当于不用 - 的情况，仅切换 usrname，不切换环境变量
    -c: 仅使用一次命令，自动切换回到当前用户

    # sudo [-b] [-u username]
    // -u 命令后面可以跟使用 nologin shell 的 user
    # sudo -u sshd touch /tmp/testsshd
    # sudo -u vbird sh -c "mkdir ~vbird/www; cd ~vbird/www; echo 'xxxx' > out.txt"

/etc/sudoers: sudo 的规则配置文件

    $ sudo cat /etc/sudoers | egrep -v "^$|^#"
    ...
    root    ALL=(ALL:ALL) ALL
    %admin  ALL=(ALL) ALL           // % 表示组
    %sudo   ALL=(ALL:ALL) ALL
    ...
    # visudo

其余的规则配置都好复杂，平时也用不到，了解一下即可。

特殊的 shell：/sbin/nologin

    # vim /etc/nologin.txt
    $ su - nologinuser

PAM (Pluggable Authentication Modules)，一个公共的认证模块，跟现在互联网上的 Auth 认证意义接近。

pam_cracklib.so: 字典模块

    /etc/pam.d/*    // 配置文件

    # cat /etc/pam.d/login
    /etc/pam.d/*
    /etc/security/*
    /lib/security/*
    ubuntu: /lib/i386-linux-gnu/security/*
    # find /lib -name "pam*"

**用户信息传递**

查询：w, who, last, lastlog

- last: 迄今为止所有用户的登录情况
- lastlog: 每个用户的最近登录时间

用户对谈：write, mesg, wall

    # write username [ttyname]
    # mesg
    # mesg [ny]
    n: 关闭信息
    y: 打开信息
    # wall    // 广播

发邮件：mail

    # mail user@host -s title
    # mail
    // 查看本用户邮件，看完的邮件会移到 ~/mbox

    # mail -f ~/mbox

**手动管理用户**

即手工编辑各个配置文件。

手动新增用户

    # pwck
    # pwconv      // 把用户密码从 /etc/passwd 转移到 /etc/shadow 中
    # pwunconv    // 把用户密码从 /etc/shadow 转移到 /etc/passwd 中，并删除 /etc/shadow，最好不要用
    # chpasswd    // 可以用 passwd --stdin 替代
    # echo "vbird:123456" | chpasswd -m

手工创建的过程：比如创建 normaluser，属于 normalgroup

新增组

    # vim /etc/group
    normalgroup:x:520:    // 手动新增一行
    # grpconv             // 同步 gshadow
    # grep 'normalgroup' /etc/group /etc/gshadow

新增用户

    # vim /etc/passwd
    normaluser:x:700:520::/home/normaluser:/bin/bash    // 手动新增一行
    # pwconv                                            // 同步 /etc/shadow
    # grep 'normaluser' /etc/passwd /etc/shadow
    # passwd normaluser

设置权限

    # cp -a /etc/skel /home/normaluser
    # chown -R normaluser:normalgroup /home/normaluser
    # chmod 700 /home/normaluser
