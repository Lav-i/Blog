---
title: Docker——让环境变得干干净净
date: 2021-04-06 01:05:39
tags:
    Docker
---

## 前言
&emsp;&emsp;我知道，在第一次使用Docker的时候，也就是刚刚得到实验室服务器密钥的时候使用Docker的方式是邪道的。那时候完全是把它当作一个隔离的虚拟机来用。后来才知道官方并不提倡这种做法，于是乎改邪归正写下这篇文章，本文中使用的例子为本博客的Docker化操作。

## 流程

### Dockerfile

```
FROM node:12.18-alpine

WORKDIR /usr/src/app

COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm config set registry http://registry.npm.taobao.org/
RUN npm install hexo-cli -g
RUN npm install

COPY . .
EXPOSE 4000

ENTRYPOINT [ "hexo" ]
CMD ["server"]
```

### docker build

```bash
docker build --rm -f ".\Dockerfile" -t blog:latest .
```

### docker run 

```bash
docker run --rm --name blog -it -p 4000:4000 blog:latest
```

### docker exec

```bash
docker exec -it blog sh
```

## 技术细节

### EXPOSE与-p

&emsp;&emsp;EXPOSE指令通知Docker容器在运行时监听指定的网络端口。可以指定端口是监听TCP还是UDP，默认为TCP。EXPOSE指令实际上并不发布端口。它的作用是作为构建镜像的人和运行容器的人之间的一种文档，关于要发布哪些端口。当运行容器时，要实际发布端口，使用 `docker run` 中的-p标志来发布和映射一个或多个端口，或者使用-p标志来发布所有公开的端口并将它们映射到高阶端口。

&emsp;&emsp;在运行时使用-P标志可以将所有公开的端口发布到主机接口上的随机端口，它是-publish-all的缩写。而-p标志可以让你发布一个容器的特定端口到Docker主机。它是-publish的缩写，它允许你显式地映射一个容器的端口或一组端口到主机——而不是公开所有Docker端口。不管Dockerfile中的EXPOSE指令是什么，在运行时使用-p标志可以覆盖它们。

例如：
` docker run -p 80:80/tcp -p 80:80/udp ... `

### ADD和COPY

&emsp;&emsp;ADD和COPY在功能上相似，但一般来说，COPY是首选。这是因为它比ADD更透明。COPY只支持将本地文件基本复制到容器中，而ADD有一些不那么明显的特性（如仅本地tar提取和远程URL支持）。因为镜像大小很重要，所以强烈反对使用ADD从远程url获取包。而应该使用`curl`或`wget`来代替。

例如：
```
# Bad
ADD https://example.com/big.tar.xz /usr/src/things/
RUN tar -xJf /usr/src/things/big.tar.xz -C /usr/src/things
RUN make -C /usr/src/things all
And instead, do something like:

# Good
RUN mkdir -p /usr/src/things \
    && curl -SL https://example.com/big.tar.xz \
    | tar -xJC /usr/src/things \
    && make -C /usr/src/things all
```

### CMD与ENTRYPOINT的区别

&emsp;&emsp;Docker有一个默认的entrypoint `/bin/sh -c`，但是没有默认的命令。如果这样运行 `docker run -i -t ubuntu bash` entrypoint是默认的 `/bin/sh -c`，镜像是ubuntu，命令是bash。该命令通过entrypoint运行。也就是说，实际执行的是 `/bin/sh -c bash` 。后来，人们要求能够定制它，所以引入了entrypoint。

&emsp;&emsp;在 `docker run -i -t ubuntu bash` 中， `ubuntu` 之后的所有内容都是命令，并被传递到入口点。当使用CMD指令时，它就像你在做 `docker run -i -t ubuntu <CMD>` 。 `<CMD>` 将是入口点的参数。如果输入 `docker run -i -t ubuntu` 命令，也会得到同样的结果。你仍然会在容器中启动bash shell，因为ubuntu Dockerfile指定了默认的CMD: CMD ["bash"]。

例如：
```
# Dockerfile
FROM debian:wheezy
ENTRYPOINT ["/bin/ping"]
CMD ["localhost"]
```

执行 `/bin/ping localhost`
```
$ docker run -it test
PING localhost (127.0.0.1): 48 data bytes
56 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.096 ms
56 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.088 ms
56 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.088 ms
^C--- localhost ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.088/0.091/0.096/0.000 ms
Now, running the image with an argument will ping the argument:
```

localhost被覆盖为google.com，执行默认 `/bin/ping google.com`
```
$ docker run -it test google.com
PING google.com (173.194.45.70): 48 data bytes
56 bytes from 173.194.45.70: icmp_seq=0 ttl=55 time=32.583 ms
56 bytes from 173.194.45.70: icmp_seq=2 ttl=55 time=30.327 ms
56 bytes from 173.194.45.70: icmp_seq=4 ttl=55 time=46.379 ms
^C--- google.com ping statistics ---
5 packets transmitted, 3 packets received, 40% packet loss
round-trip min/avg/max/stddev = 30.327/36.430/46.379/7.095 ms
For comparison, if your Dockerfile is:
```

例如：
```
# Dockerfile
FROM debian:wheezy
CMD ["/bin/ping", "localhost"]
```

执行 `/bin/ping localhost`
```
$ docker run -it test
PING localhost (127.0.0.1): 48 data bytes
56 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.076 ms
56 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.087 ms
56 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.090 ms
^C--- localhost ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.076/0.084/0.090/0.000 ms
But running the image with an argument will run the argument:
```

进入 `bash`
```
$ docker run -it test bash
root@e8bb7249b843:/#
```

## 后记

&emsp;&emsp;我在没有安装nodejs的情况下发布了这篇文章，好耶！（失败力，如果想要用到hexo的自动部署功能，还需要安装git、openssh，最重要的是还需要id_rsa，这可太难搞了）