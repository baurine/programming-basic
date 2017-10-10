# 鸟哥的 Linux 私房菜基础学习篇 (第三版) 读书笔记

## 第 11 章 bash

    # type [-tpa] command

    # test_var=$(date +%F)    // 或者 test_var=`date +%F`
    # echo $test_var
    2012-12-29
    # export test_var
    # unset test_var

单引号和双引导号的区别：

    # new_var="$test_var xxx"
    # echo $new_var
    2012-12-29 xxx

    # new_var='$test_var xxx'
    # echo $new_var
    $test_var xxx

查看变量：

    # env    // 仅查看系统环境变量

常见的 env 变量：HOME，SHELL，PATH，RANDOM。

    # set   // 含环境变量与自定义变量

    $ set | grep ^PS
    PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS2='> '
    PS4='+ '

    $ echo $$
    4145
    $ echo $?
    0

PS1, PS2, PS3, $, ?

环境变量会被 bash 的子进程继承，而自定义变量不会。用 `export/declare -x` 命令把自定义变量变成环境变量，`declare +x` 则是把环境变量变成自定义变量。

    # export [user_define_var]
    # declare [enviroment_var]

    # declare [-aixr] [+x] [-p] var_name
    // -a:array, -i:interger, -x:change to enviroment variable
    // -r:readonly, +x:change to user defined variable, -p:show type
    # sum=10+20
    # echo $sum
    10+20
    # declare -i sum=10+20
    # echo $sum
    30
    # export | grep sum
    # declare -x sum
    # export | grep sum
    declare -ix sum="30"
    # declare -r sum
    $ sum=testing
    bash: sum: 只读变量
    $ declare -p sum
    declare -irx sum="30"
    $ declare +x sum
    $ declare -p sum
    declare -ir sum="30"

locale：

    # locale -a
    # locale

read：

    # read -p "input your name: " -t 10 your_name
    input your name: foo
    # echo $your_name
    foo

(??)：

    # path=$PATH
    # echo ${path#...}     // 从前往后最短的
    # echo ${path##...}    // 从前往后最长的
    # echo ${path%...}     // 从后往前最短的
    # echo ${path%%...}    // 从后往前最长的

变量内容的替换：

    # echo ${path/old/new}     // 只替换第一个
    # echo ${path//old/new}    // 替换所有

变量内容的测试：

    # username=${var1-baurine}
    // username = var1 not exist ? baurine : $var1
    # username=${var1:-baurine}
    // username = var1 not exist or is "" ? baurine : $var1

还有其它各种形式，倒是好理解，但不好记。

    var=${str+expr}
    var=${str:+expr}
    var=${str=expr}
    var=${str:=expr}
    var=${str?expr}
    var=${str:?expr}

登录信息：

    /etc/issue      // 用户登录前的欢迎信息
    /etc/issue.net  // 通过 telnet 登录前的欢迎信息
    /etc/motd       // 用户登录后的欢迎信息

bash 的环境配置文件：

- login shell：取得 bash 时需要完整的登录流程，比如 tty1 - tty6，登录时需要输入用户名和密码，此时获取的 bash 就叫 login shell。
- nologin shell：取得 bash 时不需要重复登录的举动，比如以 X Window 登录 Linux 后，再以 X 界面打开终端，就无须再需要用户名和密码，那个 bash 环境就称为 nologin shell，又比如在原来的 bash 环境下再启动子 bash，同样也没有输入用户名和密码，这个子 bash 也称为 nologin shell。

login 和 nologin shell 取得 bash 时，读取的配置文件并不相同。

login shell：`/etc/profile | ~/.bash_profile | ~/.bash_login | ~/.profile`

/etc/profile：还会去读取 /etc/inputrc，/etc/profile.d/*.sh，/etc/sysconfig/i18n

nologin shell：仅读取 ~/.bashrc

~/.bashrc：还会去调用 /etc/bashrc

修改配置文件后立即生效：

    # source ~/.bashrc
    # . ~/.bashrc

终端机的环境设置：stty，set

    # stty -a          // 显示所有的 stty 设置
    # stty erase ^h    // 重新设置 erase 的快捷键为 ctrl+h

    # set [+-] [uvCHhmBx]
    # echo $-
    himBH
    # set -u    // 开启错误提示
    # set +u    // 关闭错误提示
    # set -x    // 相当于 dos 批处理中的 echo on
    # set +x    // echo off

- ctrl+u：删除 bash 整行命令
- ctrl+c
- ctrl+d
- ctrl+s
- ctrl+q
- ctrl+a
- ctrl+e
- ctrl+k
- ctrl+u
- ctrl+l
- ctrl+z

bash 通配符与特殊符号：

- 通配符：* ? [] [-] [^]
- 特殊符号：# \ | ; ~ $ & ! / >,>> <,<< '' "" `` () {}

输入重定向：`<`, `<<`。`<<` 表示结束输入的意思。

    # cat > catfile << "eof"    // 表示输入时不再以 ctrl+d 作为结束符，而是用 eof

混合追加输出重定向请使用这种例子的方法：

    $ date >>log.txt 2>&1

注意，没有下面这两种用法：

    $ date >>log.txt 2>>&1
    $ date &>>log.txt

执行多个命令：; && ||

    # ls /tmp/abc || mkdir /tmp/abc && touch /tmp/abc/hehe
    # ls /tmp/abc && echo "exist" || echo "not exist"

pipe 管道：

- 管道仅会处理 standard output，对于 standard error 会忽略。
- 管道命令必须能够接收前一个命令的数据成为 standard input 继续处理才行。所以像 less more tail 就可以作管道命令，而 ls cp mv 不行，因为它们不接受 stand input 的数据。

选取命令：cut, grep

    # echo $PATH | cut -d ':' -f2-5
    # echo $PATH | cut -d ':' -f2,5
    # export | cut -c 12-

cut 比较少用，awk 功能比 cut 强大。

排序命令：sort，uniq，wc

    sort [-tkrnfbMu] filename|stdin // -kntr 常用
    -t:分隔符，默认是 \t 分隔
    -n:以数值排序，默认以字符排序
    -k:以第几列排序
    -r:逆序
    -u:uniq，相同记录仅显示一行

    uniq [-ic]
    -i:忽略大小写
    -c:统计

    wc [-lwm]
    -l:line
    -w:work
    -m:characters

    $ last | cut -d ' ' -f1 | sort | uniq -c | sort -nr -k1
     28 sparkle
      8 reboot
      1 wtmp
      1

tee：双向重定向，即将结果同时输到出 stdout 和文件。

字符转换命令：tr col join paste expand

- tr: 删除和替换
- col: 将 tab 转换成空格
- join: 智能合并两个文件中同一行具有相同元素的内容
- paste: 合并两个文件同一行的内容，用 \t 分隔
- expand: \t 和空格的互相转换

文件切割命令：split

    # split [-bl] filename prefix
    -b:按大小
    -l:按行数

参数代换：xargs，产生命令所需要参数，主要用在管道里，为那些非管道命令比如　ls，也可以使用管道。

    xargs [-0epn] command
    # find /sbin -perm +7000 | xargs ls -l

`-` 的作用：作为 stdout 或　stdin

    # ls -al / | split -l 10 - lsroot
    # wc -l lsroot*

## 第 12 章 正则表达式

基本正则表达式，略。

sed 工具：主要对整行进行操作。

    sed [-neirf] 'action' [filename|stdin]
    -n: slient mode, only show the line that sed operate
    -e: 直接在命令模式上进行 sed 的动作编辑
    -i: 直接修改读取的文件内容，而不是输出到屏幕
    -r: 支持扩展型正则表达式
    -f: 动作来自文件
    action: [n1,[n2]] function
    function:
    a/i: 新增行，a 加在行后，i 加在行前
    c: 整行替换
    d: 整行删行
    p: 打印，一般和 -n 合用，用来显示中间的几行
    s: 部分替换，正则表达式

示例：

    # cat /etc/passwd | sed -n '1,10p' > sed_test
    # nl sed_test | sed '2,5d'
    # nl sed_test | sed '2d'
    # nl sed_test | sed '2,$d'
    # nl sed_test | sed '2a drink tea'
    # nl sed_test | sed '$a drink tea'
    # nl sed_test | sed '2i drink tea'
    # nl sed_test | sed '2-5c No 2-5 number'
    # nl sed_test | sed '1,$s/old/new/g' 
    // 注意，在 sed 里不能用 % 替代 1,$
    # sed '1,$s/$/\./g' sed_test 
    // 结果显示在 stdout 上
    # sed -i '1,$/\.$/\!/g' sed_test 
    // 直接修改原文件内容，不显示在 stdout

扩展正则表达式：

- 基本：`grep -v '^$' regular_express.txt | grep -v '^#'`
- 扩展：`egrep -v '^$|^#' regular_express.txt`

grep 默认仅支持基本正则表达式，如果要使用扩展型，则要使用 grep -E 或者 egrep。(really? 经实验，在 rh5 上还真是耶！)

扩展正则表达式语法：

- +: 重复 >=1 次前面的字符或组字符
- ?: 重复 0 或 1 次前面的字符或组字符
- |: 或
- (): 组字符
- ()+: 多个重复组的判别

示例：

    # egrep -n 'go+d' regular_express.txt
    # egrep -n 'go?d' regular_express.txt
    # egrep -n 'gd|good|god' regular_express.txt
    # egrep -n 'g(d|oo|o)d' regular_express.txt
    # echo 'AxyzxyzxzyC' | egrep 'A(xyz)+C'

文件的格式化和相关处理：printf，awk。

printf，了解即可。

awk，sed 对整行进行处理，而 awk 则是将一行分为数个 "字段" 来处理。

awk 默认以空格和 tab 分隔

    awk 'conditon1 {action1} condition2 {action2}'
    # last -n 5 | awk '{print $1 "\t" $3}'
    # cat /etc/passwd | awk '{FS=":"} $3<10 {print $1 "\t" $3}'
    # cat /etc/passwd | awk 'BEGIN {FS=":"} $3<10 {print $1 "\t" $3}' 
    # cat /etc/passwd | awk -F: '$3<10 {print $1"\t"$3}'

变量：$0, $1, $2 ... NF, NR, FS ...

- $0: 该行所有内容
- $1, $2 ... : 该行第一列，第二列 ... 内容
- NF: 该行总列数
- NR: 第几行
- FS: 分隔符

文件比较工具：diff，cmp，patch

    # diff [-bBi] file1 file2    // 按行比较文本内容
    -b: 忽略同一行单个和多个空白的区别
    -B: 忽略空白行
    -i: 忽略大小写

    # mkdir /tmp/test
    # cd /tmp/test
    # cp /etc/passwd passwd.old
    # cat passwd.old | sed -e '4d' -e '6c no six line' > passwd.new
    # diff passwd.old passwd.new

    # cmp [-s] file1 file2   // 按字节比较
    -s:显示所有不同的地方，默认只显示第一个

    # patch
    # diff -Naur passwd.old passwd.new > passwd.patch
    # patch -p0 < passwd.patch       // 打 patch
    # patch -R -p0 < passwd.patch    // 还原
