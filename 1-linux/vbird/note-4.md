# 鸟哥的 Linux 私房菜基础学习篇 (第三版) 读书笔记

## 第 15 章 磁盘配额和高级文件系统管理

quota，了解即可。

    # mount -o remount,usrquota,grpquota /home

准备：

    # quotacheck [-avugfM] [/mount_point]
    # quotaon [-avug]
    # quotaon [-vug] [/mount_point]
    # quotaoff [-a]
    # quotaoff [-ug] [/mount_point]

设置：

    # edquota [-u username] [-g groupname]
    # edquota -t
    # edquota -p 范本 -u username

报表

    # quota [-uvs] [username]
    # quota [-gvs] [groupname]
    # repquota -a [-vugs]

发警告

    # warnquota
    // 手动
    # vim /etc/warnquota.conf
    ...
    # vim /etc/cron.daily/warnquota
    /usr/bin/warnquota
    // 添加到系统计划任务，自动发邮件提醒
    # chmod 755 /etc/cron.daily/warnquota

RAID = Redundant Arrays of Inexpensive Disks. 廉价的磁盘组成的容错阵列，廉价容错磁盘阵列。

- RAID 0: 等量模式，stripe，性能最佳，至少两块相同的硬盘
- RAID 1: 映象模式，mirror，完整备份，至少两块相同的硬盘
- RAID 0+1，RAID 1+0: 至少四块相同的硬盘
- RAID 5: 性能与数据备份的均衡考虑，至少三块硬盘，每次选择其中任意一块存放校验值。

hardware RAID，software RAID。

software RAID: /dev/md0, /dev/md1... 还可以用同一块硬盘的多个分区来组成 RAID

管理工具：mdadm

    # mdadm --detail /dev/md0
    # mdadm --create --auto=yes /dev/md[0-9] --level=[015] --raid-device=N --spare-device=N /dev/sdx /dev/hdx...
    # mdadm --create --auto=yes /dev/md0 --level=5 --raid-device=4 --spare-device=1 /dev/sda{6,7,8,9,10}
    # mdadm --detail /dev/md0
    # cat /proc/mdstat

格式化，挂载

    # mkfs -t ext3 /dev/md0
    # mkdir /mnt/raid
    # mount /dev/md0 /mnt/raid

仿真 RAID 错误的救援模式

    # mdadm --manage /dev/md[0-9] [--add dev] [--remove dev] [--fail dev]

设置自动挂载

    # mdadm --detail /dev/md0 | grep -i uuid    // 找到 UUID
    # vim /etc/mdadm.conf                       // 设置 mdadm.conf
    # vim /etc/fstab                            // 设置 fstab

关闭软件 RAID (重要！)

    # umount /dev/md0
    # vim /etc/fstab           // 删除自动挂载
    # mdadm --stop /dev/md0    // 停止 RAID
    # cat /proc/mdstat
    # vim /etc/mdadm.conf      // 删除 uuid

逻辑卷管理器：Logical Volume Manager。

已粗略了解，得有用到再回头细看。

physical partition --> PV (Physical Volume) --> VG (Volume Group) --> LV (Logical Volume)

PE: Physical Extent

LVM 的系统快照，可用于快速恢复系统。

## 第 16 章 crontab

略。

## 第 17 章 进程管理和 SELinux

    # jobs [-lrs]
    # nohup ...
    // nohup 与终端机无关，所以输出无法是 stdout 或 stderr，会被重定向到 ./nohup.out 中。

进程管理：

- 静态 ps, pstree
- 动态 top

ps：

    # ps aux     // 查看所有，a:all u:有效用户 x:完整信息
    # ps -l      // 只查看自己的 bash 相关进程
    # ps -lA     // 以 ps -l 的形式显示所有进程
    # ps axjf    // f: 显示进程树，pstree

    # ps -l
    F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
    0 S     0  4027  3667  0  75   0 -  1470 wait   pts/2    00:00:00 bash
    4 R     0  4284  4027  0  77   0 -  1354 -      pts/2    00:00:00 ps

    F: 进程标志 (process flags)，说明这个进程的权限。常见的号码有：
    -4: 进程的权限为 root
    -1: 进程仅可复制，不可执行
    -0: ??

    S: 进程的运行状态
    -S: sleep
    -R: running
    -T: stop
    -Z: zombie
    -D: 不可被唤醒，一般是等待 I/O

    C: CPU
    ADDR/SZ/WCHAN: 都与内存有关
    ADDR: kernel function，如果是个 running 进程，一般显示 -
    SZ: 用掉多少内存
    WCHAN: 进程是否运行中，- 表示运行中

    # ps aux
    // 结果中最后有 <defunct> 表示僵尸进程
    ...
    root      3079  0.0  0.0      0     0 ?        Z    09:10   0:00 [Xsession]
    <defunct>
    ...
    # ps aux | grep defunct
    // 查找僵si进程

    # ps -d 2
    # ps -b -n 2 > /tmp/top.txt

pstree：

    # pstree [-A|-U] [-up]
    -A: ascii
    -U: utf8
    -u: show username
    -p: show pid

    # pstree -Aup
    从 pstree 的结果中可以看到，所有进程都是依附在 init 这个进程下面，而且这个进程的 pid 是 1，因为它是由 Linux 内核所主动调用的第一个进程。还记得下面几个命令吗？
    # init 0
    # init 6
    # init 5

kill：

    # kill -l
    # man 7 signal

    # kill -signal PID
    # kill -SIGHUP $(ps aux | grep 'syslog' | grep -v 'grep' | awk '{print $2}')

    # killall [-iIe] -signal 命令名称    // 后面直接跟的是命令的名称
    -i: interactive，交互
    -e: exact，表示命令名称精确匹配
    -I: ignore，忽略大小写
    # killall -i -9 httpd

优先级与 nice 值：

    # ps -l
    PRI NI
    PRI 值由内核决定，用户无法修改，用户只能通过修改 NI 值来影响 PRI 值。
    注意事项
    1. nice 值范围：-20 ~ 19
    2. root 用户可随意调整任意进程的 nice 值
    3. 一般用户只能调整自己的进程的 nice 值，且只能在 0 ~ 19 之间调整
    4. 一般用户只能将 nice 值调高，而不能调低

    # nice [-n nice_value] comand
    # nice -n -5 vim &
    # ps -l

    # renice [nice_value] pid

系统资源查看

    # free [-b|-k|-m|-g] [-t]
    // -b, -k, -m, -g 是显示单位，-t 显示物理内存和 swap 总量
    # uname [-asrmpi]
    # uptime
    # netstat [-atunlp]
    -a: all
    -t: tcp
    -u: udp
    -n: not show service name, show its port number
    -l: show service that is listening
    -p: show pid and service name
    # netstat
    # netstat -tlnp    // 查看哪些进程启动了网络监听服务
    # dmesg            // 查看内核产生的信息，开机硬件检测的信息
    # vmstat           // 查看系统资源变化

特殊文件与程序

    # ls /proc/
    /proc/pids/...
    /proc/cmdlines
    /proc/cupinfo
    /proc/devices
    /proc/filesystems
    /proc/meminfo
    ...

查看已打开文件或已执行程序打开的文件

    # fuser
    # lsof    // 列出被进程所打开的文件名
    # pidof [-sx] program_name
    // 类似 ps aux | grep program_name | grep -v grep | awk '{print $2}'

SELinux，了解即可，用到回头再看

    # ll -Z
    # getenforce

SELinux的三种模式：enforcing, permissive, diabled

启动的策略 (Policy) 有两种：targeted, strict

    # sestatus [-vb]
    # vim /etc/selinux/config
    # setenforce [0|1]
    # chcon ...
    # restorecon

服务：setroubleshoot，auditd (/var/log/audit/audit.log)

    # audit2why < /var/log/audit/audit.log

    # seinfo ...
    # sesearch ...

    # getsebool ...
    # setsebool ...

    # semanage ...
    ...

## 第 18 章 daemons

daemon 与 service: daemon 程序提供 service 服务。可视为相同。

daemon 分类：stand alone，super daemon (xinetd)

daemon 的工作形态：

1. signal-control：类似中断，只要有请求就去即去处理
1. interval-control：轮循，crond，atd

daemon 的命令规则：通过在服务的名称后加一个 d。

daemon 的启动脚本与启动方式

- /etc/run/xxx.pid
- `/etc/inti.d/*`: 启动脚本放置处，公认的目录，CentOS 实际上放置在 /etc/rc.d/init.d，`/etc/init.d/*` 链接到了此处。
- /etc/sysconfig/*: 各服务的初始化环境配置文件，比如 /etc/sysconfig/syslog，/etc/sysconfig/network。
- /etc/xinetd.conf, /etc/xintd.d/*: super daemon 的配置文件
- /etc/*: 各服务各自的配置文件
- /var/lib/*: 各服务产生的数据库，比如 /var/lib/mysql/
- /var/run/*.pid: 各服务程序的 pid 记录处，比如 /var/run/syslog.pid

命令：

    # /etc/init.d/[service_name] {start|stop|...}
    # service service_name {start|stop|...}
    # service --status-all
    // 查看所有服务的状态

属于 xinetd 控制的服务，要修改 /etc/xinetd.d/ 目录下相应的配置文件，将 diabled 属性改为 no 才可能被启动。

    # grep -i 'disable' /etc/xinetd.d/*

super daemon 的配置文件 /etc/xinetd.conf

服务的防火墙管理：xinetd，tcp wrappers

任何以 xinted 管理的服务都可以通过 /etc/hosts.allow，/etc/hosts.deny 来设置防火墙。这两个文件也是 /usr/bin/tcpd 的配置文件，/usr/bin/tcpd 实际上相当于 windows 里的网络过滤驱动。

    # ldd $(which sshd) | grep libwrap
    # ldd $(which httpd) | grep libwrap

TCP Wrappers 特殊功能

    # rpm -q tcp_wrappers
    spawn (action)
    twist (action)

设置服务开机启动：chkconfig, ntsysv/setup (redhat 专用)

    # chkconfig --list [service_name]
    # chkconfig [--level [0123456]] service_name [on|off]
    # chkconfig [--add|--del] service_name 
    // 添加删除自己写的service

Linux 开机流程：

1. BIOS 自检
1. MBR
1. 加载 kernel
1. 内核主动调用 init 进程 (/sbin/init)
1. init 进程开始执行系统初始化 (/etc/rc.d/rc.sysinit)
1. 依据 init 的设置进行 daemon start (/etc/rc.d/rc[0-6].d/*)
1. 加载本机设置 (/etc/rc.d/rc.local)

## 第 19 章 系统日志

logrotate 的设置

- /etc/logrotate.conf
- /etc/logrotate.d/*

使用：

    # logrotate [-vf] log配置文件
    -v: 显示过程
    -f: 强制进行 logrotate
    # logrotate -v /etc/logrotate.conf
    # logrotate -vf /etc/logrotate.d/admin    // admin 是自己新建的

logwatch，一个系统提供的日志分析工具，每天分析一次系统日志并发邮件。
