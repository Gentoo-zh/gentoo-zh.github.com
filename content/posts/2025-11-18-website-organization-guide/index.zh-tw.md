---
title: "網站文件組織與貢獻指南"
date: 2025-11-18
categories: ["website"]
authors: ["zakkaus"]
---

本指南介紹 Gentoo 中文社群網站的專案結構和參與貢獻的方法。

## 專案結構

本網站使用 [Hugo](https://gohugo.io/) 靜態網站產生器和 [Blowfish](https://blowfish.page/) 主題構建。

### 內容組織

`content/` 目錄下的各個子目錄對應網站的不同欄目：

- `content/download/` - 下載頁面
- `content/overlay/` - 中文 Overlay 說明
- `content/mirrorlist/` - 鏡像列表
- `content/about/` - 關於頁面
- `content/posts/` - 新聞文章目錄
- `content/categories/` - 文章分類定義

每個欄目包含簡體中文（`_index.zh-cn.md`）和繁體中文（`_index.zh-tw.md`）版本。

### 配置檔案

主要配置檔案位於 `config/_default/` 目錄：

- `hugo.toml` - Hugo 主配置
- `languages.zh-cn.toml` / `languages.zh-tw.toml` - 語言配置
- `menus.zh-cn.toml` / `menus.zh-tw.toml` - 導航選單配置
- `params.toml` - 主題參數配置

### 多語言支援

網站支援簡體中文和繁體中文雙語：
- 簡體中文翻譯：`i18n/zh-CN.yaml`
- 繁體中文翻譯：`i18n/zh-TW.yaml`

### 主題和資源

- `themes/blowfish/` - Blowfish 主題（透過 git submodule 管理）
- `static/` - 靜態資源（圖片、CNAME 等）
- `assets/` - 需要處理的資源檔案

## 發布新文章

在 `content/posts/` 目錄下創建新的文章目錄，包含：
- `index.zh-cn.md` - 簡體中文版本
- `index.zh-tw.md` - 繁體中文版本

文章頭部需包含 frontmatter 配置：

```yaml
---
title: "文章標題"
date: 2025-11-19
categories: ["分類"]
authors: ["作者ID"]
---
```

### 可用的文章分類

- `announcement` - 公告
- `community` - 社群動態
- `tutorial` - 教學
- `website` - 網站相關

## 參與貢獻

### 提交文章

1. Fork 專案倉庫
2. 在 `content/posts/` 創建新文章目錄
3. 撰寫簡體中文和繁體中文版本
4. 提交 Pull Request

### 改進現有內容

歡迎改進：
- 修正錯別字或不準確的表述
- 更新過時的技術資訊
- 新增新的使用技巧
- 完善文件說明

### 技術改進

如對網站技術架構有改進建議：
- 功能增強
- 效能提升
- 新功能開發

請到 GitHub 提交 Issue 或 Pull Request：  
<https://github.com/Zakkaus/gentoo-zh.github.com>

## 社群交流

- Telegram 群組：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 頻道：[@gentoocn](https://t.me/gentoocn)
- GitHub：<https://github.com/gentoo-zh>

歡迎加入我們，一起建設更好的 Gentoo 中文社群！
