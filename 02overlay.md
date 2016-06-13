---
layout: page
title: Overlay
permalink: /overlay/
---

Gentoo 的 Overlay 机制可以让用户使用官方 Portage 树以外的软件包，作为一个软件来源的扩充和叠加。
故名为 Overlay（意为叠加）。

gentoo-zh Overlay 是 Gentoo 社区历史悠久的老牌 Overlay 之一，其前身是 2003 年创立的 gentoo-tw
和随后创立的 gentoo-china。后来，台湾和大陆社区的共同努力下，合并为了 gentoo-zh overlay。本
overlay 旨在为用户提供：

* 和中国用户相关的软件和补丁，例如
  - 某些软件的 CJK 补丁
  - 中国某些互联网服务的开源客户端实现
  - 国产 Linux 应用程序
* 额外的软件
  * 特色软件包（不一定和中文或 CJK 相关）
    - 如 gentoo-zh 特色 e-sources 内核包，整合了多种补丁
  * 从其它 Overlay 搬运过来的软件包
* 更新的软件版本
  - Portage 是一个庞大的系统，有些包未免会暂时被人忽视而忘记更新
    * 如长期提供最新版本的 Boost
* 错误修复
  - gentoo-zh 开发者遇到一个错误时，会在解决后第一时间将相关补丁推入源中。
