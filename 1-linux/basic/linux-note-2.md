# Linux Basic Note

## 3 - 文件权限管理

1. 用户和组的管理
1. 设置文件的权限

### 用户和组

三个文件：/etc/passwd, /etc/shadow, /etc/group

- /etc/passwd：用户的基本信息，唯独没有密码
- /etc/shadow：用户的密码和密码策略
- /etc/group：用户组信息

**/etc/passwd**

    root:x:0:0:root:/root:/bin/bash

- root：用户名
- x：密码占位符
- 0：uid，0 表示超级用户
- 0：gid，group id
- root：用户描述，可有可无
- /root：用户 home 目录
- /bin/bash：默认的 shell，/sbin/nologin 是一个不可用的 shell

增加一个新用户：

    $ useradd user02
    $ passwd user02

**/etc/shadow**

    alice:$1$LkB4RHCy$SoqYkh4MAhqBFO560Svzj.:15698:0:99999:7:::
    user02:!!:15699:0:99999:7:::

    # 格式
    用户名:密码 md5 值 (!!表示密码为空):最近修改时间 (从 1970.1.1 到现在的天数):最小密码修改时间:最长密码修改时间...

**/etc/group**

    root:x:0:root

    # 格式
    组名:密码:gid:包含的用户

添加组：

    $ groupadd hr
    $ groupadd it
    $ groupdel it
    $ userdel user02

每添加一个新用户，默认会添加一个与用户名相同的组名作为该用户的主组。

用户组：主组 (私有组)，附加组 (公有组)

- 主组：每个用户有且只有一个主组
- 附加组：可以有多个

示例：

    $ useradd user10 -u 2000            # 指定 uid
    $ useradd user11 -g hr              # 指定主组
    $ useradd user12 -G hr              # 指定附加组
    $ useradd user13 -d /test01         # 指定 home 目录
    $ useradd user14 -M                 # 不创建用户的 home 目录
    $ useradd user15 -s /sbin/nologin   # 指定 bash
    $ useradd user16 -r                 # 添加系统用户, 0 < uid < 500

    $ id user10                         # 直接查看一个用户的信息

    $ echo 123 | passwd user10 --stdin  # 非交互模式设密码

删除用户：

    $ userdel user10     # 不删除 home 目录，后期只能手动删 home 目录
    $ userdel -r user11  # 同时删除 home 目录

    $ su - user13        # 切换用户
    $ id
    $ whoami

添加或删除用户到组：

    $ gpasswd -a user12 sales
    $ gpasswd -d user12 sales
    $ gpasswd [-A user,...] [-M user,...] group
    $ gpasswd -M user15,user16,user17 sales

修改用户信息：

    $ usermod -s /bin/bash user15
    $ usermod -e/-L ...

### 文件权限

    $ ls -al
    ...
    drwxr-xr-x   5 baurine  staff   170 Oct  7 10:32 1-linux
    -rw-r--r--   1 baurine  staff    20 Oct  7 10:23 README.md

    $ file README.md
    README.md: ASCII text

    $ ll /dev/disk*
    brw-r-----  1 root  operator    1,   0 Oct  4 22:11 /dev/disk0
    ...

    $ file /dev/disk*
    /dev/disk0:   block special (1/0)

第一列：文件类型

- d (directory)
- b (block)
- c (character)
- l (link)

剩下 2-10 列表示不同人的权限：

- 剩下第 2-4 列表属主的权限，r 表示可读，w 表示可写，x 表示可执行。
- 第 5-7 列表示属组的权限
- 第 8-10 列表示其它人的权限

用 u 表示属主，用 g (group) 表示属组，用 o (other) 表示其它人，用 a (all) 表示所有人。

(疑问：属组是怎么确定的?)

设置权限：chgrp, chown, chmod

- chgrp：更改文件的属组
- chown：更改文件的属主和属组
- chmod：设置权限

示例：

    $ chgrp hr c.txt

    $ chown alice.hr c.txt
    $ chown alice c.txt
    $ chown .hr c.txt

    $ chmod u/g/o/a +/-/= r/w/x
    $ chmod g=rw,o=r c.txt
    $ chmod 777 c.txt
    # = chmod 0777 c.txt

    # 改变该目录下所有文件及文件夹的权限
    $ chgrp/chown/chmod -r/-R folder

- r
  - 文件：读内容
  - 目录：列出目录中的文件，ls
- w
  - 文件：修改文件的内容,不包括删除
  - 目录：创建，删除目录中的文件，不管文件的权限如何
- x
  - 文件：执行文件 (内容必须可执行)
  - 目录：进入这个目录，cd

显示目录的权限：

    $ ll -d /home/test1/

#### 特殊权限

**setuid**

普通用户 alice，`cat /root/c.txt`，看不了。`chmod u+s /bin/cat` 后，`cat /root/c.txt` 就可以执行了。

    用户(普通)   工具        做的事
    alice       /bin/cat   /root/c.txt
    X           V          X

从工具下手，把工具升级为尚方宝剑。

    $ chmod u+s /bin/cat
    $ ll /bin/cat
    -rwxr-xr-x  1 root  wheel    23K Mar 23  2017 /bin/cat

setuid：一个文件 (这个文件只能是二进制可执行文件，脚本不行)，一旦设置了 setuid 后，任何人执行都相当于以所有者的身份执行。比如上面这个 cat，它的所有者是 root，设置了 setuid 后，任何人执行都相当于是 root 执行。

/etc/shadow 的权限是 `-r--------`，但普通用户是可以修改密码，秘密在于 passwd 拥有 s 属性：

    $ which passwd
    /usr/bin/passwd
    $ ls -l /usr/bin/passwd
    -rwsr-xr-x

证实：普通用户运行 passwd，然后使用 `ps aux | grep passwd` 查看到 passwd 进程的所有者是 root，而不是普通用户。

对于 root 用户来说，它没有什么权限，它有的是权力，它可以做一切它想做的事情。所以虽然 /etc/shadow 的权限是 `-r--------`，但对于 root 用户来说 `r--` 的权限毫无约束力。

euid：euid，有效 uid，alice (uid=500) 用户在执行 passwd 时，euid 就是 0，即 root 用户。

    -rws------ s 表示同时具有 x 属性
    -rwS------ S 表示没有 x 属性

**setgid**

    $ chmod g+s file|dir

在针对二进制可执行文件时，基本同 setuid，但是以属组身份执行。

    $ which
    /usr/bin/wall
    $ ll /usr/bin/wall
    -r-xr-sr-x  1 root  tty    24K Mar 23  2017 /usr/bin/wall

在针对目录时，在该目录下任何人新建的文件都会继承该目录的属组。

    ----rws--- s 表示同时有 x 属性
    ----rwS--- S 表示没有 x 属性

**sticky**

    $ chmod o+t dir

仅针对目录，使得访目录里的文件，只有其所有者才可以删除。

    $ ll /tmp/
    -rwxr-xr-t

    -------rwt t 表示同时有 x 属性
    -------rWT T 表示没有 x 属性

数字法：

    $ chmod 3777 file|dir

    setuid  setgid  sticky
    4       2       1

#### ACL

UGO (user, group, other) 缺陷：一个文件或目录只能有一个属主和属组，新的解决办法 ACL。

ACL：getfacl, setfacl

    $ setfacl -m u:alice:rw fstab
    $ setfacl -m g:hr:rw fstab

此时，再用 ll 查看时，在权限栏最后出现一个 + 号。

ACL 对未来的文件设置权限。

    $ mkdir /home/test3
    $ chown alice /home/test3
    $ setfacl -m d:u:jack:rwx /home/test3
    # d means default，对将来产生的文件设置权限，对当前的文件不起作用，在 ftp 上可以使用
