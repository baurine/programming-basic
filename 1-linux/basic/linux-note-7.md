# Linux Basic Note

## Monit

(2017/10/15)

Resources:

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

(2017/10/5)

Resources:

1. [sudo 命令](http://man.linuxde.net/sudo)
1. [深入理解 sudo 与 su 之间的区别](https://linux.cn/article-8404-1.html)
1. [Linux 的 su 與 sudo 指令教學與範例](https://blog.gtwang.org/linux/sudo-su-command-tutorial-examples/)

su: substitute user.

su 用来从一个用户切换到另一个用户，默认是切换到 root 用户，然后就一直使用新用户的身份执行各种操作，直到执行 exit，但也支持切换到新用户后只执行一条 shell 命令后就回到原来的用户 (即 sudo 的默认行为)。

sudo 也用来从一个用户切换到另一个用户，默认也是切换到 root 用户。但它默认是以目标用户的身份执行一条 shell 命令后就回到原来的用户身份。sudo 也支持切换到新用户后，停留在新用户的身份，直到执行 exit 命令 (即 su 的默认行为)。

su 和 sudo 的最大区别：

1. 当切换到 root 用户时，su 命令需要输入 root 用户的密码，而 sudo 命令需要输入的是用户自己本身的密码，无须知道 root 用户的密码。
1. 使用 su 命令，任何用户都可以切换到 root 用户，只要它知道 root 用户的密码。而 sudo 命令，为什么它不需要知道 root 用户的密码，是因为不是所有用户都可以使用 sudo 切换到 root 用户，只有被 root 用户授权过允许切换的用户，才可以切换，这相当于一种信任，所以这就是为什么 sudo 命令输入的是自己的密码。
