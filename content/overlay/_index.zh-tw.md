---
title: "Overlay"
---

Gentoo 的 Overlay 機制可以讓使用者使用官方 Portage 樹以外的軟體套件，作為一個軟體來源的擴充和疊加。
故名為 Overlay（意為疊加）。

gentoo-zh Overlay 是 Gentoo 社群歷史悠久的老牌 Overlay 之一，其前身是 2003 年創立的 gentoo-tw
和隨後創立的 gentoo-china。後來，台灣和大陸社群的共同努力下，合併為了 gentoo-zh overlay。本
overlay 旨在為使用者提供：

* 和中國使用者相關的軟體和補丁，例如
  - 某些軟體的 CJK 補丁
  - 本地 Linux 應用
* 額外的軟體
  * 特色軟體套件（不一定和中文或 CJK 相關）
    - 如 gentoo-zh 特色 e-sources 核心套件，整合了多種補丁
  * 從其它 Overlay 搬運過來的軟體套件
* 更新的軟體版本
  - Portage 是一個龐大的系統，有些套件未免會暫時被人忽視而忘記更新
    * 如長期提供最新版本的 Boost
* 錯誤修復
  - gentoo-zh 開發者遇到一個錯誤時，會在解決後第一時間將相關補丁推入源中。
