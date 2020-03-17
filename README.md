# Openresty基础教程

## 前言

本人使用Openresty做为后段的开发框架已经有五年多了，通过一段时间的使用对Openresty的使用有了一定的了解，希望将本人知道的一些知识整理出来，做一个小的教程，希望能够帮助到一些初学者。本文章是基于使用Openresty做为后段服务的基础教程，希望大家通过本人的教程能够快速掌握Openresty这一优秀的框架，既然无太多编程经验的人也可以写出简单高效的服务。本人的水平有限，如果有不对之处，也希望大家批评指正。

## 第一章 Openresty简介

以下是Openresty的官方简介：

OpenResty® 是一个基于 Nginx 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

OpenResty® 通过汇聚各种设计精良的 Nginx 模块（主要由 OpenResty 团队自主开发），从而将 Nginx 有效地变成一个强大的通用 Web 应用平台。这样，Web 开发人员和系统工程师可以使用 Lua 脚本语言调动 Nginx 支持的各种 C 以及 Lua 模块，快速构造出足以胜任 10K 乃至 1000K 以上单机并发连接的高性能 Web 应用系统。

OpenResty® 的目标是让你的Web服务直接跑在 Nginx 服务内部，充分利用 Nginx 的非阻塞 I/O 模型，不仅仅对 HTTP 客户端请求,甚至于对远程后端诸如 MySQL、PostgreSQL、Memcached 以及 Redis 等都进行一致的高性能响应。

对于我来说：Openresty就是一个性能高效、编程简单的优秀后段框架。

## 第二章 Openresty的第一个程序

学习语言与框架，第一个程序都是那一个经典程序"Hello World!"，我们也从这一经典程序开始，让我们逐步进入Openresty的世界。

为了方便清晰起见，我将Openresty安装在/opt/openresty目录下。什么？不会安装Openresty。请参考如下命令，找不到的包请教下度娘吧。

去https://github.com/openresty/lua-nginx-module下载代码，我们使用的是1.15.8.1版本，使用如下命令安装：

```shell
tar xvfz openresty-1.15.8.1.tar.gz
cd openresty-1.15.8.1
./configure --prefix=/opt/openresty
make
make install
```

安装好了之后，在/opt/openresty下创建services目录，我们自己的程序将都在这个目录下。

具体的目录结构如下：
```shell
/opt/openresty/services/
/opt/openresty/services/conf/
/opt/openresty/services/src/
/opt/openresty/services/src/lua/
/opt/openresty/services/src/libs/
```

其中:

/opt/openresty/services/conf/目录下放我们的ngxin的conf文件。

/opt/openresty/services/src/lua/目录下放我们自己的lua代码。

/opt/openresty/services/src/libs/目录下放我们自己开发的lua的C库。

其实大家自己的代码可以按照自己的方式放代码，但是为了整洁，我是这样放代码的，同时也是为了说明的方便。

Openresty已经安装完成，代码的目录结构也已经创建好了，基本的准备工作已经完成了，那么就开始写我们的一个程序吧。

见证奇迹的时候到来了。

首先在这里不做nginx相关配置的介绍与说明，具体请参考度娘或者nginx官方文档，上面有非常详细的说明。

再次这里也不做lua语法相关的说明，lua一个非常简单的脚本语言，如果你有C/Java等编程语言的基础，lua是很容易学会的，我在这里也只使用lua最基本的语法，不会涉及过多的晦涩的lua方法与特性。

那么如何开始写一个“Hello World”的程序呢？

为了开发的方便，在写具体的应用之前先如下的准备。

创建一个代码存放的目录，假设叫openresty。在该目录下创建如下目录：
```shell
cd openresty
mkdir bin
mkdir conf
mkdir src
mkdir -p src/lua
```

服务文件的拷贝安装脚本：bin/install.sh
```shell
#! /bin/bash

workdir="/opt/openresty/services"
openresty="/opt/openresty/nginx/sbin/nginx"

if [ ! -d ${workdir} ]; then
    mkdir -p ${workdir}
fi

if [ ! -d ${workdir}/logs ]; then
    mkdir -p ${workdir}/logs
fi

cp conf /opt/openresty/services -fr
cp src /opt/openresty/services -fr
cp bin /opt/openresty/services -fr
```
服务对应的启动停止脚本：bin/openresty.sh
```shell
#! /bin/bash

workdir="/opt/openresty/services"
openresty="/opt/openresty/nginx/sbin/nginx"

if [ ! -d ${workdir} ]; then
    mkdir -p ${workdir}
fi

if [ ! -d ${workdir}/logs ]; then
    mkdir -p ${workdir}/logs
fi

cd ${workdir}

if [ "$1"x = "start"x ] 
then
    echo starting...
    ${openresty} -p ${workdir} -c ${workdir}/conf/openresty.conf
fi

if [ "$1"x = "reload"x ] 
then
    echo reloading...
    ${openresty} -p ${workdir} -c ${workdir}/conf/openresty.conf -s reload
fi

if [ "$1"x = "stop"x ] 
then
    echo stopping...
    ${openresty} -p ${workdir} -c ${workdir}/conf/openresty.conf -s stop
fi
```

首先Openresty中一切都是由配置开始，这里给出一个基础的配置文件，以后所有的配置都是基于该配置文件。 
配置文件conf/openresty.conf的内容如下：
```shell
worker_processes  auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 204800;
error_log  logs/error.log  error;
pid        logs/openresty.pid;

user  root;
events {
    use epoll;
    worker_connections 204800;
}


http {
    resolver  8.8.8.8;
    root html;
    default_type  application/octet-stream;

    log_format main '"$time_local","$remote_addr","$request_method","$request_uri","$status","$request_time","$body_bytes_sent","$appdata"';
    log_format monitor escape=none '$appdata';

    client_header_timeout 10s;
    client_header_buffer_size 8k;
    large_client_header_buffers 32 32k;
    client_body_timeout 10s;
    client_body_buffer_size 8m;
    client_max_body_size 8m;

    send_timeout 10s;
    server_tokens off;
    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    expires    -1;
    keepalive_timeout  75s;

    proxy_http_version 1.1;
    proxy_ignore_client_abort on;
    proxy_next_upstream off;

    lua_package_path 'src/lua/?.lua;/usr/local/openresty/lualib/?.lua;/opt/openresty/lualib/?.lua;;';
    lua_package_cpath 'src/libs/?.so;;';

    lua_socket_log_errors off;
    lua_socket_connect_timeout 100ms;
    lua_socket_read_timeout 100ms;
    lua_socket_send_timeout 100ms;
    lua_socket_keepalive_timeout 25s;
    lua_socket_pool_size 100;


    server {
        listen 80;
        server_name openresty.pange.xin;
        error_page 404 = /404.html;

        location = /hello {
            set $appdata '';
            access_log  logs/openresty_access.log  main;

            content_by_lua '
                local hello = require "hello.hello"
                hello.serve()
            ';
        }


        location / {
            deny all;
        }
    }
}
```
其中如下部分指定了lua相关的一些配置，重要的是lua_package_path指定了lua代码的加载位置，lua_package_cpath指定了lua的so的加载位置。
```shell
lua_package_path 'src/lua/?.lua;/usr/local/openresty/lualib/?.lua;/opt/openresty/lualib/?.lua;;';
lua_package_cpath 'src/libs/?.so;;';

lua_socket_log_errors off;
lua_socket_connect_timeout 100ms;
lua_socket_read_timeout 100ms;
lua_socket_send_timeout 100ms;
lua_socket_keepalive_timeout 25s;
lua_socket_pool_size 100;

```

具体文件的目录格式可以依据自己的习惯创建，我这里给出的是一个推荐格式，方便服务运行。


下面是我们的第一个例子的“Hello World”的起始执行位置，也就相当于main函数，其中“set $appdata '';”暂时可以不用，未来会讲到，access_log日志是nginx的访问日志，便于我们排查问题。
```shell
location = /hello {
    set $appdata '';
    access_log  logs/openresty_access.log  main;

    content_by_lua '
        local hello = require "hello.hello"
        hello.serve()
        ';
}

```
当路径是/hello的请求过来的时候，将执行如下代码：
```lua
    local hello = require "hello.hello"
    hello.serve()
```

以上代码是如何执行的呢？当直接执行的时候，去观察openresty的error日志，将会出现如下错误:
```shell
2020/03/17 18:11:01 [error] 21477#0: *62 lua entry thread aborted: runtime error: content_by_lua(openresty.conf:64):2: module 'hello.hello' not found:
        no field package.preload['hello.hello']
        no file 'src/lua/hello/hello.lua'
        no file '/usr/local/openresty/lualib/hello/hello.lua'
        no file '/opt/openresty/lualib/hello/hello.lua'
        no file '/opt/openresty/site/lualib/hello/hello.ljbc'
        no file '/opt/openresty/site/lualib/hello/hello/init.ljbc'
        no file '/opt/openresty/lualib/hello/hello.ljbc'
        no file '/opt/openresty/lualib/hello/hello/init.ljbc'
        no file '/opt/openresty/site/lualib/hello/hello.lua'
        no file '/opt/openresty/site/lualib/hello/hello/init.lua'
        no file '/opt/openresty/lualib/hello/hello.lua'
        no file '/opt/openresty/lualib/hello/hello/init.lua'
        no file './hello/hello.lua'
        no file '/opt/openresty/luajit/share/luajit-2.1.0-beta3/hello/hello.lua'
        no file '/usr/local/share/lua/5.1/hello/hello.lua'
        no file '/usr/local/share/lua/5.1/hello/hello/init.lua'
        no file '/opt/openresty/luajit/share/lua/5.1/hello/hello.lua'
        no file '/opt/openresty/luajit/share/lua/5.1/hello/hello/init.lua'
        no file 'src/libs/hello/hello.so'
        no file '/opt/openresty/site/lualib/hello/hello.so'
        no file '/opt/openresty/lualib/hello/hello.so'
        no file './hello/hello.so'
        no file '/usr/local/lib/lua/5.1/hello/hello.so'
        no file '/opt/openresty/luajit/lib/lua/5.1/hello/hello.so'
        no file '/usr/local/lib/lua/5.1/loadall.so'
        no file 'src/libs/hello.so'
        no file '/opt/openresty/site/lualib/hello.so'
        no file '/opt/openresty/lualib/hello.so'
        no file './hello.so'
        no file '/usr/local/lib/lua/5.1/hello.so'
        no file '/opt/openresty/luajit/lib/lua/5.1/hello.so'
        no file '/usr/local/lib/lua/5.1/loadall.so'
stack traceback:
coroutine 0:
        [C]: in function 'require'
        content_by_lua(openresty.conf:64):2: in main chunk, client: 127.0.0.1, server: openresty.pange.xin, request: "GET /hello HTTP/1.1", host: "127.0.0.1"
```
