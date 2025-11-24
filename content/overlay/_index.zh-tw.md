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

## 倉庫地址

gentoo-zh overlay 的原始碼託管在 GitHub 上：

<https://github.com/microcai/gentoo-zh>

## 如何使用

> **重要提示**（更新時間：2025-10-07）
>
> 根據 [Gentoo 官方公告](https://www.gentoo.org/support/news-items/2025-10-07-cache-enabled-mirrors-removal.html)，Gentoo 已停止為第三方倉庫提供快取鏡像支援。從 2025-10-30 起，所有第三方倉庫（包括 gentoo-zh）的鏡像配置將從官方倉庫列表中移除。
>
> **這意味著什麼？**
> - `eselect repository` 和 `layman` 等工具仍可正常使用
> - 官方將不再提供快取鏡像，改為直接從上游源（GitHub）同步
> - 官方倉庫（::gentoo、::guru、::kde、::science）不受影響，仍可使用鏡像
>
> **如果您之前已新增 gentoo-zh overlay，請更新同步 URI：**
>
> ```bash
> # 檢視已安裝的倉庫
> eselect repository list -i
>
> # 移除舊配置
> eselect repository remove gentoo-zh
>
> # 重新啟用（將自動使用正確的上游源）
> eselect repository enable gentoo-zh
> ```

### 手動配置

在 `/etc/portage/repos.conf/` 目錄下建立 `gentoo-zh.conf` 檔案，內容如下：

```ini
[gentoo-zh]
location = /var/db/repos/gentoo-zh
sync-type = git
sync-uri = https://github.com/microcai/gentoo-zh.git
auto-sync = yes
```

然後同步：

```bash
emerge --sync gentoo-zh
```

## 鏡像加速

### gentoo-zh distfiles 鏡像

提供 gentoo-zh overlay distfiles 快取，加速軟體套件下載。

**源地址**：<https://distfiles.gentoocn.org/>

**鏡像站點**：
- 重慶大學：<https://mirror.cqu.edu.cn/gentoo-zh>
- 南京大學：<https://mirror.nju.edu.cn/gentoo-zh>

**使用幫助**：<https://t.me/gentoocn/56>

### gentoo-zh.git 鏡像

提供 gentoo-zh overlay 的 Git 倉庫鏡像，加速 overlay 同步。

**源地址**：<https://github.com/microcai/gentoo-zh.git>

**鏡像站點**：
- 重慶大學：<https://mirrors.cqu.edu.cn/git/gentoo-zh.git>
- 南京大學：<https://mirror.nju.edu.cn/git/gentoo-zh.git>

**配置範例**（使用鏡像加速同步）：

```ini
[gentoo-zh]
location = /var/db/repos/gentoo-zh
sync-type = git
sync-uri = https://mirrors.cqu.edu.cn/git/gentoo-zh.git
auto-sync = yes
```

## 使用 overlay 中的軟體套件

配置完成後，就可以像使用官方源一樣安裝 overlay 中的軟體套件了：

```bash
emerge --ask <package-name>
```

如果想檢視 overlay 提供了哪些軟體套件，可以使用：

```bash
eix -RO gentoo-zh
```

## 參與貢獻

歡迎向 gentoo-zh overlay 貢獻程式碼！請造訪 GitHub 倉庫提交 Pull Request 或回報問題。
