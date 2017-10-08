# Linux Basic Note

## 9 - 任务

1. 进程管理
1. shell 作业控制
1. shell 输入输出，重定向，管道
1. 计划任划

### 进程管理

查看：

- ps - 静态查看
- top - 实时查看

ps 默认只显示当前终端的进程，加上 aux 选项，显示所有用户的进程；

    $ ps aufx   # f 显示进程继承关系
    $ ps -ef    # e 显示父进程

    $ pstree    # 查看进程树

top：

    $ top -d 1  # 默认每 3s 更新一次，-d 重新指定刷新时间

    $ pgrep sshd
    12022
    $ top -p 12022 -d 1

- <> 翻页
- f 调整显示的条目
- M 按内存使用率降序
- R 逆序
- P 按 cpu 占有率排序
- h 帮助
- u 列出指定用户的进程

htop：top 的替代器。

调整优先级：修改 nice 值，－20 最高，19 最低，默认 0

    $ renice -20 pid

给进程发信号，使用 kill 命令 (在 top 命令中，k 发信号)。

    $ kill -l  # 查看信号类型

- 信号 1 - 重启
- 信号 9 - 强制杀死
- 信号 15 - 正常结束

可以通过给 vim 进程分别发送 9 和 15 信号，对比两者的不同。15 信号让 vim 退出，不会产生残留的 .swp 文件，而 9 会。

    $ kill pid       # 缺省是 kill -15 pid
    $ kill -1 pid    # 重启
    $ kill -HUP pid  # 相当于 kill -1 pid
    $ kill -9 pid    # 强杀

在执行某个程序时，可以手动指定其优先级：

    $ nice --10 vim /etc/hosts   # 设置运行级别为 -10，相当于 nice -n -10 vim ...
    $ nice -10 vim /etc/hosts    # 运行级别为 10

其它一些命令：

    $ free
    $ free -m
    $ uptime
    $ ls /proc/
    $ cd /proc/pid
    $ ll fd          # 文件描述符，文件描述符 0, 1, 2 是每个进程都会生成的，控制输入输出
    $ ll exe

    $ w    # 查看登录用户
    $ who  # 查看用户

### 作业控制

前台和后台的调度：

- &
- ctrl + z
- jobs
- bg
- fg

用 `&` 将程序放到后台运行。

    $ sleep 3000 &
    [2] 25069      # [作业号] PID

    $ jobs         # 查看所有作业
    $ jobs [-lrs]
    $ sleep 4000
    ctrl+z         # 把一个前台的进程挂起，放到后台
    [3]+ Stopped   sleep 4000
    $ bg 3         # 把作业 3 在后台运行，标准写法是 bg %3
    [3]+ Running   sleep 4000 &  # + 号表示最近放到后台的进程

    $ fg 3         # 把作业 3 放到前台运行，标准写法是 fg %3
    $ fg           # 不加作业号，默认是 + 号对应的作业号

    $ kill %作业号
    $ kill pid

在终端中使用 vim 时，可以按 ctrl + z 立即将此进程放到后台，再用 fg 命令调回前台。

SSH 远程连接到服务器，即使将程序放到后台，如果自己退出了，这些程序也会跟着退出。

解决办法：使用 nohup

    $ nohup ./configure &

在本地也可以使用 nohup，这样退出终端后进程也不会退出。

    $ nohup gedit &

### 管道

    $ date > date.txt   # 重定向
    $ date >> date.txt

    文件描述符编号  文件描述符  输入 / 输出位置
    0             标准输入    键盘
    1             标准输出    终端
    2             标准错误    终端

重定向：

- `>`
- `>>`
- `<`

标准写法其实应该是：

- `1>`
- `1>>`
- `2>`
- `2>>`
- `0<`

示例：

    $ date > /dev/pts/3

    $ ls /home /fkldsjakfds;a >list.txt         # 标准输出已重定向到了文件，但错误输出仍然打印在终端 上
    $ ls /home /fdsafdsa >list.txt 2>error.txt  # 将错误输出也重定向
    $ ls /home /fdsafdsa >list.txt 2>&1         # 将标准输出和错误输出都重定向到同一个文件，但注意不能这样写 >list.txt 2>list.txt
    $ ls /home /fdsafdsa &>list.txt             # 上面的另一种写法。

特殊的文件 /dev/null：

    $ ll /dev/null      # 字符设备
    $ date > /dev/null  # 输出重定向到空设备

    $ ./configure &              # 放到后台的进程照样会往终端输出内容
    $ ./configure &>/dev/null &  # 注意不要写成了 ./configure & &>/dev/null，后台执行，& 一定要放到最后。

    $ touch 2012-12-28_aaa.txt
    $ touch `date +%F`_bbb.txt   # 在 `` 里的命令会被先执行

输入重定向：

    $ cat </etc/hosts

**管道**

生产汽车的例子，流水线。

    $ rpm -qa | grep vim

    # -k4 按第 4 列排序，-n 按数值排序，显示 cpu 占有率最高的 8 个进程
    $ ps aux | sort -k4 -n | tail -8

    # 显示根目录的已使用空间比例
    $ df | grep /$ | awk '{print $5}' | awk -F% '{print $1}'

    # 提取 ip addr 中的 ip 地址
    $ ip addr | grep 'inet ' | awk '{print $2}' | awk -F/ '{print $1}'

### 计划任务

- 一次性的：at
- 周期性的：crontab

一次性的：

    $ at -l
    $ at 17:00
    at> poweroff
    at> ctrl+d
    $ at --help

周期性的：

    $ ps aux | grep crond  # crond 是计划任务的监视进程，每隔一分钟检测，d 表示 daemon
    $ service crond stop   # stop crond
    $ service crond start  # start crond

    $ chkconfig crond on      # 设置 crond 开机启动
    $ chkconfig crond --list  # 显示 crond 在各运行级别开机是否运行的情况
    crond           0:关闭  1:关闭  2:启用  3:启用  4:启用  5:启用  6:关闭

    $ ls /etc/init.d/crond    # crond 服务所在路径
    $ /etc/init.d/crond

用法：/etc/init.d/crond {start|stop|status|reload|restart|condrestart}

    $ /etc/init.d/crond status
    $ /etc/init.d/crond restart  # restart = stop + start
    $ /etc/init.d/crond reload   # reload 读取新的配置

/etc/init.d/ 路径中的脚本都是类似的服务，也可以用 service 来控制：

    $ service crond {stop|stop|status...}

注意：使用 rpm 或 yum 安装的服务会自动拥有上面的这些功能，通过源码包安装的应该是需要手动配置的。

    $ /etc/init.d/iptables stop  # 停止防火墙
    $ chkconfig iptables off     # 将防火墙设为开机不启动

或者在 setup 里面设置：

    $ setup

只有在 crond 运行着的情况下计划任务才能正常运行。

    $ service crond start
    $ chkconfig crond on

crond：每分钟检查一次。

- 系统级别：例如定期清理 /tmp，/var/tmp，定期生成 locate 数据库。系统级别的计划任务保存在 /etc/crontab 文件中
- 用户级别：每天备份文件... `crontab -e`，保存到 /var 目录下

/etc 保存的是各种配置文件。

    $ vim /etc/crontab
    ...
    01 * * * * root run-parts /etc/cron.hourly
    02 4 * * * root run-parts /etc/cron.daily
    22 4 * * 0 root run-parts /etc/cron.weekly
    42 4 1 * * root run-parts /etc/cron.monthly

/etc/cron.hourly，/etc/cron.daily，/etc/cron.weekly，/etc/cron.monthly 是四个目录，里面又存放了真正要执行的脚本。

时间表：

    42 4  1 *  * root run-parts /etc/cron.monthly
    分 时 日 月 周

取值范围：

- 分：0 - 59
- 时：0 - 23
- 日：1 - 31
- 月：1 - 12
- 周：0 - 7， 0 和 7 都表示周日

`*` 表示所有范围，表示 "每"。

    01 * * * * : 每小时的第1分钟
    02 4 * * * : 第天第 4 小时的第 2 分钟

星期和日月是或的关系，不互斥：

    42 4 1 * 0 : 每个月第一天或者每周日执行

    */5 * * * * : 每隔 5 分钟， 0, 5, 10...
    * */5 * * * : 每隔 5 小时， 0, 5, 10...

    01 02 2-10   * * : 每个月的 2 - 10 号
    01 02 2,5,10 * * : 每个月的 2, 5, 10 号

    $ crontab -e
    * * * * * date  # 输出不会打到终端，默认是发邮件，用 mail 查看邮件
    00 17 * * * date &>/dev/pts/1

修改后要重启 crond 服务：

    $ service crond restart  # 好像不用重启也能生效

计划任务有日志：

    $ tail /var/log/cron

用户级别的计划任务和系统级别的区别：

1. 用户级别不用在第二列指定用户，因为就是本身，不同用户的用户级别计划任务存放在不同路径。系统级别的计划任务需要在第二列指定运行的用户身份；
1. 系统级别的计划任务使用了 run-parts 命令，这表示后面跟的是目录，这个功能在用户级别也可以使用

查看计划任务：

    $ crontab -l
    $ crontab -l -u alice  # 怎么看系统级别的呢? 没有命令，只能看文件
    $ crontab -r           # 清空

查看计划任务的结果：

1. 查看邮件：mail
1. 查看 cron 日志：tail /var/log/cron
1. 查看程序自身的日志

按秒为执行计划任务，利用 sleep 的延时 (因为 crontab 的最小粒度是分钟)：

    * * * * * date >/dev/pts/3
    * * * * * sleep 10;date >/dev/pts/3
    * * * * * sleep 20;date >/dev/pts/3
    * * * * * sleep 30;date >/dev/pts/3
    * * * * * sleep 40;date >/dev/pts/3
    * * * * * sleep 50;date >/dev/pts/3
