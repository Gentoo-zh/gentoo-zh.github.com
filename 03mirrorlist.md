---
layout: page
title: 镜像列表
permalink: /mirrorlist/
---

Gentoo 的包管理体系由 Portage 树和 Distfiles 两部分组成。Portage 树是包数据库，通过 rsync 提供；
Distfiles 是下载文件，如软件包的源代码或图片资源，通过 HTTP 或 FTP 提供。

Gentoo 在世界范围内存有大量镜像，这里仅列出位于亚洲，速度对中国用户有优势的主要镜像，
完整的镜像参见[官方镜像列表](http://www.gentoo.org/main/en/mirrors2.xml)。

要使用镜像，你需要编辑 `/etc/portage/make.conf` 文件，Portage 镜像可通过设置 `SYNC` 变量指定，
Distfiles 镜像可通过 `GENTOO_MIRRORS` 变量指定。Portage 镜像和 Distfiles 镜像不一定来自同一镜像。如

{% highlight bash %}
SYNC="rsync://mirrors.ustc.edu.cn/gentoo-portage/"
GENTOO_MIRRORS="http://mirrors.aliyun.com/gentoo/"
{% endhighlight %}

使用来自中国科学技术大学的 Portage 镜像和阿里云的 Distfiles 镜像。

由于 rsync 是 CPU 与 IO 密集型操作，服务器将会有很大的负担，而且容易遭到 DoS 攻击。因此，绝大多数镜像
均不提供 rsync。

如果你无法找到合适镜像；或防火墙禁止 rsync，可以使用 `emerge-webrsync`，Portage 会从 Distfiles 下载每日
归档的 Portage 压缩包，曲线进行同步。

# 列表

* 网易
  - Portage: 已失效
  - Distfiles: http://mirrors.163.com/gentoo/
* 搜狐
  - Portage: 不提供
  - Distfiles: http://mirrors.sohu.com/gentoo/
* 阿里云
  - Portage：不提供
  - Distfiles: http://mirrors.aliyun.com/gentoo/
* 中国科学技术大学（USTC）
  - Portage: http://mirrors.ustc.edu.cn/gentoo/
  - Distfiles: rsync://rsync.mirrors.ustc.edu.cn/gentoo-portage/
* 厦门大学
  - Portage: 不提供
  - Distfiles: http://mirrors.xmu.edu.cn/gentoo/
* 日本北陆尖端科学技术大学院大学（JAIST）
  - Portage: 不提供
  - Distfiles: http://ftp.iij.ad.jp/pub/linux/gentoo/
