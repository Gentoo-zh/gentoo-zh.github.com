---
title: "鏡像列表"
---

Gentoo 的套件管理體系由 Portage 樹和 Distfiles 兩部分組成。Portage 樹是套件資料庫，透過 rsync 提供；
Distfiles 是下載檔案，如軟體套件的原始碼或圖片資源，透過 HTTP 或 FTP 提供。

Gentoo 在世界範圍內存有大量鏡像，這裡僅列出位於亞洲，速度對中國使用者有優勢的主要鏡像，
完整的鏡像參見

 - <https://www.gentoo.org/downloads/mirrors/\#CN\>
 - <https://www.gentoo.org/support/rsync-mirrors/\#CN\>

鏡像使用，參閱

- <https://wiki.gentoo.org/wiki//etc/portage/repos.conf/zh-cn\>
- <https://wiki.gentoo.org/wiki/GENTOO_MIRRORS/zh-cn\>

由於 rsync 是 CPU 與 IO 密集型操作，伺服器將會有很大的負擔，而且容易遭到 DoS 攻擊。因此，絕大多數鏡像
均不提供 rsync。

如果你無法找到合適鏡像；或防火牆禁止 rsync，可以使用 `emerge-webrsync`，Portage 會從 Distfiles 下載每日
歸檔的 Portage 壓縮套件，曲線進行同步。

# 其餘列表

* 清華開源鏡像站
  - Portage: rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage/
  - Distfiles: https://mirrors.tuna.tsinghua.edu.cn/gentoo/
* 中國科學技術大學（USTC）
  - Portage: rsync://rsync.mirrors.ustc.edu.cn/gentoo-portage/
  - Distfiles: http://mirrors.ustc.edu.cn/gentoo/
* 網易
  - Portage: rsync://mirrors.163.com/gentoo-portage
  - Distfiles: https://mirrors.163.com/gentoo/
* 搜狐
  - Portage: 不提供
  - Distfiles: https://mirrors.sohu.com/gentoo/
* 阿里雲
  - Portage：不提供
  - Distfiles: https://mirrors.aliyun.com/gentoo/
* 廈門大學
  - Portage: 不提供
  - Distfiles: http://mirrors.xmu.edu.cn/gentoo/
* 日本北陸尖端科學技術大學院大學（JAIST）
  - Portage: 不提供
  - Distfiles: https://ftp.iij.ad.jp/pub/linux/gentoo/
