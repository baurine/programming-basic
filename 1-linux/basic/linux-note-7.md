# Linux Basic Note

- Monit
- su & sudo
- ssh

## Monit

参考：

1. [Monit](https://mmonit.com/monit/documentation/monit.html)
1. [Monit Manual](https://linux.die.net/man/1/monit)
1. [How to Install and Setup Monit (Linux Process and Services Monitoring) Program](https://www.tecmint.com/how-to-install-and-setup-monit-linux-process-and-services-monitoring-program/)
1. [如何使用 Monit 部署服务器监控系统](https://linux.cn/article-5542-1.html)

monit 是一个小巧、轻量级的服务器监控软件，可以监控各种服务，还能监控文件系统。

**安装**

以 Ubuntu 为例：

    $ sudo apt-get install monit

**配置**

monit 安装后，默认的启动命令是 `/usr/bin/monit -c /etc/monit/monitrc` (通过 `ps aux | grep monit` 得知)，`/etc/monit/monitrc` 是 monit 的默认配置文件。

看一下 monitrc 中的默认配置：

    ###############################################################################
    ## Global section
    ###############################################################################
    ##
    ## Start Monit in the background (run as a daemon):
    #
      set daemon 120            # check services at 2-minute intervals
    #   with start delay 240    # optional: delay the first check by 4-minutes (by
    #                           # default Monit check immediately after Monit start)
    #
    #
    ## Set syslog logging. If you want to log to a standalone log file instead,
    ## specify the full path to the log file
    #
      set logfile /var/log/monit.log
    ...

    ###############################################################################
    ## Includes
    ###############################################################################
    ##
    ## It is possible to include additional configuration parts from other files or
    ## directories.
    #
      include /etc/monit/conf.d/*
      include /etc/monit/conf-enabled/*

这说明 monit 每隔 2 分钟检查所监控的服务，日志写在 /var/log/monit.log 中，并且同时去加载了 /etc/monit/conf.d 和 /ect/monit/conf-enabled 目录中的配置。所以，自定义的服务监控可以放到后面两个目录中。

为了允许通过 `monit status` 命令查看当前所监控的所有服务的状态，我们必须在 monitrc 中开启 httpd 服务：

    ## Monit has an embedded HTTP interface which can be used to view status of
    ## services monitored and manage services from a web interface. The HTTP
    ## interface is also required if you want to issue Monit commands from the
    ## command line, such as 'monit status' or 'monit restart service' The reason
    ## for this is that the Monit client uses the HTTP interface to send these
    ## commands to a running Monit daemon. See the Monit Wiki if you want to
    ## enable SSL for the HTTP interface.
    #
    set httpd port 2812 and
        use address localhost  # only accept connection from localhost
        allow localhost        # allow localhost to connect to the server and
    #    allow admin:monit      # require user 'admin' with password 'monit'

**监控服务**

monitrc 中默认配置了很多常见服务的监控 (但都处于 comment 状态)，使用 `check process` 语法，比如对 Apache 的监控：

    ## Check that a process is running, in this case Apache, and that it respond
    ## to HTTP and HTTPS requests. Check its resource usage such as cpu and memory,
    ## and number of children. If the process is not running, Monit will restart
    ## it by default. In case the service is restarted very often and the
    ## problem remains, it is possible to disable monitoring using the TIMEOUT
    ## statement. This service depends on another service (apache_bin) which
    ## is defined above.
    #
    #  check process apache with pidfile /usr/local/apache/logs/httpd.pid
    #    start program = "/etc/init.d/httpd start" with timeout 60 seconds
    #    stop program  = "/etc/init.d/httpd stop"
    #    if cpu > 60% for 2 cycles then alert
    #    if cpu > 80% for 5 cycles then restart
    #    if totalmem > 200.0 MB for 5 cycles then restart
    #    if children > 250 then restart
    #    if loadavg(5min) greater than 10 for 8 cycles then stop
    #    if failed host www.tildeslash.com port 80 protocol http
    #       and request "/somefile.html"
    #    then restart
    #    if failed port 443 protocol https with timeout 15 seconds then restart
    #    if 3 restarts within 5 cycles then unmonitor
    #    depends on apache_bin
    #    group server

monitrc 中的具体语法就要看文档了。

**命令**

1. 检测 monitrc 中的配置语法是否正确：

        $ sudo monit -t    // -t 表示 test

1. 查看所监控的所有服务的状态

        $ sudo monit status
        $ sudo monit status | grep -C n group_name_you_care

1. 重新加载 monitrc

        $ sudo monit reload

1. 重启 monit

        $ sudo /etc/init.d/monit [start|restart]

1. 重启所有监控的服务 (注意和上一个的命令的区别)

        $ sudo monit [start|restart] all

1. 重启某个特定的服务

        $ sudo monit [start|restart] name

1. 重启某个特定 group 的服务。比如上面的监控 apache 的脚本，为它指定了 group 是 server，那么可以用下面的命令：

        $ sudo monit -g group_name [start|restart] all
        $ sudo moint -g server [start|restart] all
        // -g 表示 group
        // 文档上说，如果指定了 -g，那么 all 参数其实不是必需的

   重启 restart = stop + start

## su & sudo

参考：

1. [sudo 命令](http://man.linuxde.net/sudo)
1. [深入理解 sudo 与 su 之间的区别](https://linux.cn/article-8404-1.html)
1. [Linux 的 su 與 sudo 指令教學與範例](https://blog.gtwang.org/linux/sudo-su-command-tutorial-examples/)

su: substitute user.

su 用来从一个用户切换到另一个用户，默认是切换到 root 用户，然后就一直使用新用户的身份执行各种操作，直到执行 exit，但也支持切换到新用户后只执行一条 shell 命令后就回到原来的用户 (即 sudo 的默认行为)。

sudo 也用来从一个用户切换到另一个用户，默认也是切换到 root 用户。但它默认是以目标用户的身份执行一条 shell 命令后就回到原来的用户身份。sudo 也支持切换到新用户后，停留在新用户的身份，直到执行 exit 命令 (即 su 的默认行为)。

su 和 sudo 的最大区别：

1. 当切换到 root 用户时，su 命令需要输入 root 用户的密码，而 sudo 命令需要输入的是用户自己本身的密码，无须知道 root 用户的密码。
1. 使用 su 命令，任何用户都可以切换到 root 用户，只要它知道 root 用户的密码。而 sudo 命令，为什么它不需要知道 root 用户的密码，是因为不是所有用户都可以使用 sudo 切换到 root 用户，只有被 root 用户授权过允许切换的用户，才可以切换，这相当于一种信任，所以这就是为什么 sudo 命令输入的是自己的密码。

## ssh

参考：

- [SSH 原理与运用（一）：远程登录](http://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html) (包含错误讲解)
- [SSH 原理与运用（二）：远程操作与端口转发](http://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html)
- [图解 SSH 原理](https://www.jianshu.com/p/33461b619d53) (包含错误讲解)
- [SSH 原理和应用](http://www.cnblogs.com/Finley/p/6413214.html) (比较可信)
- [Generating a new SSH key and adding it to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)

自从理解了 HTTPS 原理和非对称加密以后，很多基本非对称加密的应用也自然很好理解，比如 SSH，其实和 HTTPS 是一样的原理以及工作流程，只不过在这个系统中并没有 CA 的角色，需要自己确认服务器的公钥来防范中间人攻击，但这不是大问题，因为这里的服务器一般是由用户自己控制的。

当 SSH 用于登录远程服务器时，有两种方法：

1. 登录远程服务器时，需要输入用户名和密码，称为口令验证方式。

   在这种方式中，SSH 可以防止密码被中间的设备窃取。工作流程是这样的，客户端请求登录远程服务器，远程服务器返回它的公钥给客户端，客户端用服务器的公钥对密码进行加密，发送给服务器，服务器用私钥解密，确认密码正确后，允许客户端登录。之后的通信，应该是对称加密，但对称密钥是啥呢?

   为了防止中间人攻击，在客户端首次登录服务端时，服务端返回公钥，客户端会把这个公钥打印出来，告诉用户，你确定服务端的公钥是这个值吗? 如果确认，这个公钥和对应的服务器地址会写入到客户端的 `~/.ssh/known_hosts` 中，下次再登录时就不会有确认的提示了。如果服务器的公钥发生了变化，下次登录时会出错，一般的解决办法就是直接把 `~/.ssh/know_hosts` 删掉。

1. 免密码登录，称为私钥验证方式 (?)。

   每次登录时都要输密码，有点烦，SSH 提供免密码登录。在使用密码登录的方式中，需要服务端有密钥对，在免密码登录中，需要客户端有密钥对 (服务端并不需要)。在客户端用 ssh-keygen 命令生成客户端的公钥和私钥，默认位于 `~/.ssh` 目录中，公钥为 `id_rsa.pub`，私钥为 `id_rsa`。

   客户端在首次登录之前，要先把自己的公钥告诉服务端，服务端把它记录在 `~/.ssh/authorized_keys` 文件中。

   ~~然后客户端登录时，服务端首先给客户端返回一串随机字符串，客户端用自己的私钥进行加密，然后服务端用保存在服力端的客户端公钥进行解密，看解密出来的值是否和最初给客户端的那串随机字符串是否相等，如果相等，则登录成功。后续用对称加密方式通信，但对称密钥是什么呢?~~

   (总感觉哪里有点不对...，在免密码登录方式中，怎么是用私钥加密，公钥解密呢，服务端的公私钥的作用何在?)

   上面的怀疑果然是正确的，哪里有私钥加密，公钥解密的呀。公钥加密，私钥解密。私钥是用来签名的。

   真正应该是这样工作的，首先，把公钥记录在服务端的 `~/.ssh/authorized_keys` 中，只是为了告诉服务端，允许持这个公钥的客户端登录而已，客户端使用免密码登录方式登录时，还是需要把自己的公钥传给服务端，服务端检查这个公钥是否在 `~/.ssh/authorized_keys` 中，如果不在，则拒绝此客户端使用免密码方式登录。

   如果服务端验证允许此客户端登录，它产生一串随机字符串，然后用客户端的公钥进行加密，发送回客户端，然后客户端用自己的私钥进行解密，得到这串随机字符串，然后将字符串的 MD5 值发送到服务端，服务端确认 MD5 正确，则登录成功。

客户端会优先使用私钥验证方式，若未配置私钥则使用口令验证方式。

实际这些文章介绍的都只是大概的理论，估计要看 SSH 的代码还能真正明白真正的工作流程，实际的流程远比上面复杂。

使用 SSH 的转发功能，还没用过，先跳过，感觉像是可以用来建 VPN。需要时再看。

**相关命令**

1. 使用 ssh-keygen 命令产生密钥对

        $ ssh-keygen -t rsa -C xxx@yyy.com

        -t: 加密方式，dsa | ecdsa | ed25519 | rsa | rsa1
        -C: comment，一般加上自己的邮箱

1. 把自己的公钥保存到服务端的 `~.ssh/autorized_keys` 中，有两种方式

        $ ssh-copy-id user@host

        $ ssh user@host 'mkdir -p .ssh && cat >> .ssh/authorized_keys' < ~/.ssh/id_rsa.pub

1. 使用 ssh-add 命令将私钥加到入 ssh-agent 的 session 中 (实际并不明白是啥意思)

        // 临时方案，重启后失效
        $ ssh-add

        // macOS 的方案，将私钥永久加入到 ssh-agent 中，待验证
        $ ssh-add -K ~/.ssh/id_rsa

   不执行 ssh-add 的后果是，有时在命令行中使用 ssh 命令会因为找不到本地的私钥而失败。

   关于 ssh-agent，有待进一步理解。
