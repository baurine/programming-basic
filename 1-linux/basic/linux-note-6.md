# Linux Basic Note

## 10 - 网络的配置

查看信息：

    $ mii-tool           # 查看哪个网卡的物理线路是 OK 的
    $ hostname           # 查看主机名
    $ ifconfig [-a]      # 缺省显示所有网卡的信息
    $ ifconfig eth0
    $ ip addr [show]     # 查看 ip
    $ ip addr show eth0
    $ ifup eth0          # 激活 eth0

    # 添加一个 ip 到 eth0
    $ ip addr add 192.168.3.230 dev eth0

同一个网段之间相互访问是不需要网关的。

    $ route -n  # 看网关
    $ ip route
    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    192.168.0.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
    169.254.0.0     0.0.0.0         255.255.0.0     U     0      0        0 eth0
    0.0.0.0         192.168.0.254   0.0.0.0         UG    0      0        0 eth0

最后一行表明到达任意网络 (即 0.0.0.0) 是要通过 192.168.0.254，所以网关是 192.168.0.254。

DNS，如果不通过名字访问， 是不需要 DNS 的。

    $ cat /etc/resolv.conf
    ; generated by /sbin/dhclient-script
    nameserver 202.106.46.151
    nameserver 202.106.0.20

设置：IP，网关，DNS；临时，永久。

临时：测试。

设置 IP：设置前为了避免冲突，先 ping 一下。

    $ ping 192.168.0.22

如果有多个人使用同一个 ip，则 ping 不管用，要使用 arping，同时会返回 mac 地址。

    $ arping 192.168.0.10
    ARPING 192.168.0.10 from 192.168.0.20 eth0
    Unicast reply from 192.168.0.10 [00:E0:1C:3E:7B:C5]  0.626ms
    Unicast reply from 192.168.0.10 [00:B0:C4:01:27:F6]  0.717ms

临时设置一个 ip 地址：

    # 这个命令是临时的，重新启动网络服务就消失了，而且用 ifconfig 命令查看是看不见的。
    $ ip addr add dev eth0 192.168.0.10/24

如果要让 ifconfig 命令能看到，则使用 ifconfig 来临时设置一个 ip：

    $ ifconfig eth0 192.168.1.132

临时设置网关：

    $ ip route
    192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.20
    169.254.0.0/16 dev eth0  scope link
    default via 192.168.0.254 dev eth0
    $ ip route del [网关那行的所有内容]
    $ ip route add 最后一行的所有内容
    $ ip route add default via 192.168.0.254 dev eth0
    $ ip route del default via 192.168.0.254 dev eth0

    $ service network restart  # 以上临时设置的就消失了

今天 (2013/4) 遇到了一个问题，机器上有两个网卡，两个 ip。192.168.1.131 (eth1) 和 192.168.1.132 (eth0)，前者连外网，后者连开发板。一开始都用着后者和开发板通信，今天要用前者和外网通信，但死活连不上外网，用 ping 命令 ping 外网，显示源地址是 192.168.1.132。

用 `route -n` 查看，最后一列 Iface 的值是 eth0。看来问题是出在路由上。

解决办法：

    $ route -n
    $ ip route del 192.168.1.0/24  # 24 表示 mask

再 ping 就 OK 了。

永久：

1. 直接修改配置文件
1. 用 setup 命令配置

修改配置文件：

    $ vim /etc/sysconfig/network-scripts/ifcfg-eth0
    DEVICE=eth0  # 标志设备名
    BOOTPROTO=dhcp

    # 静态手动指定
    # BOOTPROTO=none
    # IPADDR=192.168.0.240
    # NETMASK=255.255.255.0
    # GATEWAY=192.168.0.254

    HWADDR=e0:05:c5:ee:49:3d
    ONBOOT=yes  # yes 网卡在 network 启动时会自动激活，no 表示不激活
    TYPE=Ethernet
    USERCTL=no
    IPV6INIT=no
    PEERDNS=yes

修改 DNS，DNS 没有临时的：

    $ vim /etc/resolv.conf

改完后需要重启 network：

    $ service network restart

查看防火墙：

    $ getenforce
    Disabled

### 服务器的配置

#### sshd 服务

SSH 协议 (Secure xxx)，传输是加密的。

- 服务器端软件包：openssh-server
- 配置文件：/etc/ssh/sshd-config
- 对外的端口：22/tcp

作用：

1. 远程管理
1. 远程加密传输文件: `rsync -a`，增量传输 (-a)，用的也是 ssh 协议；`scp -r`，全量传。

示例：

    $ ps aux | grep sshd
    $ netstat -tnlp                # t: tcp, l: listen, p: pid, n: 不要反解
    $ service sshd status

    $ ssh root@192.168.0.10
    $ ssh 192.168.0.10             # 默认以当前用户登录
    $ ssh -X root@192.168.0.10
    $ ssh 192.168.0.10 'hostname'  # 仅执行一条命令后就断开连接
    $ ssh 192.168.0.10 date;date

文件传输：

    $ scp [参数] [原路径] [目标路径]

    $ scp -r /etc/hosts 192.168.0.10:/tmp/
    $ scp -r root@192.168.0.10:/etc/services /var/tmp/
    $ rsync -a /etc/hosts 192.168.0.10:/tmp/

/root/.ssh/known_hosts，如果连接时出错误提示，则把这个文件删除。

sshd 的配置：

    $ vim /etc/ssh/sshd_config
    ...
    AllowUsers alice  # 只允许 alice 登录，不允许 root 等其它用户登录

#### ftp

- tftp: 简单文件传输协议，不需要身份验证，防火墙，SE 要关闭
- ftp: file transport protocol

**tftp**

- 服务器端：tftp-server (包名：tftp-server)，端口号 69/udp
- 客户端：tftp (包名 tftp)

tftp-server 依赖于 xinetd (超级守护进程)。

配置：

    # tftp-server 的配置文件，可以通过 rpm -ql tftp-server 查找到
    $ vim /etc/xinetd.d/tftp
    service tftp
    {
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /tftpboot  # 共享目录
        disable                 = yes           # 改为 no 启用 tftp
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
    }

配置完成后，不是重启 tftp-server 进程，只是把上级进程，即 xinetd 进程重启。

    $ service xinetd restart
    $ chkconfig xinetd on
    $ ps aux | grep tftp        # 找不着
    $ netstat -unlp | grep :69  # 找出来的结果 xinetd

这种进程平时是不工作的，所在在进程里是找不到的，只有有连接时，由超级守护进程根据 tftp-server 的配置来决定要不要唤醒 tftp-server。

客户端使用：

    $ tftp 192.168.0.240
    tftp> get xxx         # tftp是极简单的，没有 ls 等命令，不能下载目录
    tftp> put xxx
    tftp> help
    tftp> quit

三步操作：

    $ yum -y install tftp-server
    $ chkconfig tftp on
    $ chkconfig xinetd on
    $ service xinetd restart

    $ tftp 192.168.0.240 -c get xxx  # 直接下载

上传：

1. 修改权限

        $ chmod 777 /tftpboot/

1. 增加创建权限，加上 -c

        $ vim /etc/xinetd.d/tftp
        ...
        server_args = -s /tftpboot -c

        $ service xinetd restart
        $ tftp 192.168.0.240
        tftp> put xxx
        $ tftp 192.168.0.240 -c put xxx

**ftp**

ftp 服务器：

- 服务器软件包：vsftpd (vs:very safe)
- 客户端：ftp, lftp (两者的区别仅在于前者没有自动补全功能，而后者有，所以推荐使用后者)
- 配置文件：/etc/vsftpd/vsftpd.conf
- 端口：20/tcp，21/tcp

安装使用：

    $ yum -y install vsftpd
    $ service vsftpd restart
    $ chkconfig vsftpd on
    $ ps aux | grep vsftpd
    $ netstat -tnlp | grep :21

vsftpd 支持两种用户：匿名，本地用户。

匿名 (其实有名字，叫 ftp 或 anonymous)，密码任意，只能下载。匿名账号的访问目录：/var/ftp。

    $ grep ftp /etc/passwd
    ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
    $ ftp 192.168.0.240
    $ lftp 192.168.0.240

本地用户：访问的用户的家目录，比如 alice 用户的访问目录是 /home/alice。

    $ lftp alice@192.168.0.240

lftp 使用 put 上传，get 下载单个文件，mirror 下载文件夹。

一般会新建一个没有 shell 的用户专门用于 ftp 服务。

    $ useradd ftpuser -s /sbin/nologin

## 11 - 日志管理

- 查看日志
- 定义日志记录的方式
- 将日志记录到远程服务器 (日志服务器)

在 rhel5 上的进程：syslogd，klogd。关注前者，前者是系统日志，后者是记录内核日志的。

日志文件夹：/var/log。

其余略。
