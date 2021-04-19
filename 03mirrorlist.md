---
layout: page
title: 镜像列表
permalink: /mirrorlist/
---

Gentoo 的包管理体系由 Portage 树和 Distfiles 两部分组成。Portage 树是包数据库，通过 rsync 提供；
Distfiles 是下载文件，如软件包的源代码或图片资源，通过 HTTP 或 FTP 提供。

Gentoo 在世界范围内存有大量镜像，这里仅列出位于亚洲，速度对中国用户有优势的主要镜像，
完整的镜像参见

 - <https://www.gentoo.org/downloads/mirrors/#CN>
 - <https://www.gentoo.org/support/rsync-mirrors/#CN>

镜像使用，参阅

- <https://wiki.gentoo.org/wiki//etc/portage/repos.conf/zh-cn>
- <https://wiki.gentoo.org/wiki/GENTOO_MIRRORS/zh-cn>

由于 rsync 是 CPU 与 IO 密集型操作，服务器将会有很大的负担，而且容易遭到 DoS 攻击。因此，绝大多数镜像
均不提供 rsync。

如果你无法找到合适镜像；或防火墙禁止 rsync，可以使用 `emerge-webrsync`，Portage 会从 Distfiles 下载每日
归档的 Portage 压缩包，曲线进行同步。

# 其余列表

* 清华开源镜像站
  - Portage: rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage/
  - Distfiles: https://mirrors.tuna.tsinghua.edu.cn/gentoo/
* 中国科学技术大学（USTC）
  - Portage: rsync://rsync.mirrors.ustc.edu.cn/gentoo-portage/
  - Distfiles: http://mirrors.ustc.edu.cn/gentoo/
* 网易
  - Portage: rsync://mirrors.163.com/gentoo-portage
  - Distfiles: https://mirrors.163.com/gentoo/
* 搜狐
  - Portage: 不提供
  - Distfiles: https://mirrors.sohu.com/gentoo/
* 阿里云
  - Portage：不提供
  - Distfiles: https://mirrors.aliyun.com/gentoo/
* 厦门大学
  - Portage: 不提供
  - Distfiles: http://mirrors.xmu.edu.cn/gentoo/
* 日本北陆尖端科学技术大学院大学（JAIST）
  - Portage: 不提供
  - Distfiles: https://ftp.iij.ad.jp/pub/linux/gentoo/
