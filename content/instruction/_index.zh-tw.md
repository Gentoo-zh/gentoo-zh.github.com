---
title: "文件組織說明"
---

## 項目結構

本網站使用 [Hugo](https://gohugo.io/) 靜態網站生成器和 [Blowfish](https://blowfish.page/) 主題構建。

### 內容組織

`content/` 目錄下的各個子目錄對應網站的不同欄目：

- `content/download/` - 下載頁面
- `content/overlay/` - 中文 Overlay 說明
- `content/mirrorlist/` - 鏡像列表
- `content/about/` - 關於頁面
- `content/instruction/` - 本說明頁面
- `content/posts/` - 新聞文章目錄

每個欄目包含簡體中文（`_index.zh-cn.md`）和繁體中文（`_index.zh-tw.md`）版本。

### 配置文件

主要配置文件位於 `config/_default/` 目錄：

- `hugo.toml` - Hugo 主配置
- `languages.zh-cn.toml` / `languages.zh-tw.toml` - 語言配置
- `menus.zh-cn.toml` / `menus.zh-tw.toml` - 導航菜單配置
- `params.toml` - 主題參數配置

### 多語言支持

網站支持簡體中文和繁體中文雙語：
- 簡體中文翻譯：`i18n/zh-CN.yaml`
- 繁體中文翻譯：`i18n/zh-TW.yaml`

### 主題和資源

- `themes/blowfish/` - Blowfish 主題（通過 git submodule 管理）
- `static/` - 靜態資源（圖片、CNAME 等）
- `assets/` - 需要處理的資源文件

### 發布新文章

在 `content/posts/` 目錄下創建新的文章目錄，包含：
- `index.zh-cn.md` - 簡體中文版本
- `index.zh-tw.md` - 繁體中文版本

文章頭部需包含 frontmatter 配置：
```yaml
---
title: "文章標題"
date: 2025-11-18
categories: ["分類"]
---
```

### 參與貢獻

如想對本網站進行改進，請到此處發起 Pull Request：  
<https://github.com/Zakkaus/gentoo-zh.github.com>
