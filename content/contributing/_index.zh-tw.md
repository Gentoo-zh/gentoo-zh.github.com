---
title: "貢獻指南"
description: "如何為 Gentoo 中文社群網站做出貢獻"
---

歡迎參與 Gentoo 中文社群網站的建設！本指南介紹網站的專案結構和參與貢獻的方法。

## 專案概況

本網站使用 [Hugo](https://gohugo.io/) 靜態網站產生器和 [Blowfish](https://blowfish.page/) 主題構建，託管在 GitHub Pages 上。

**專案儲存庫**：<https://github.com/gentoo-zh/gentoo-zh.github.com>

## 專案結構

### 內容組織

`content/` 目錄下的各個子目錄對應網站的不同欄目：

- `content/download/` - 下載頁面（包含鏡像源和安裝媒介）
- `content/overlay/` - gentoo-zh Overlay 說明
- `content/mirrorlist/` - 鏡像列表（Portage 樹和 Distfiles 配置）
- `content/about/` - 關於頁面（專案歷史和定位）
- `content/authors/` - 作者頁面（貢獻者資訊）
- `content/posts/` - 新聞文章和教學目錄
- `content/categories/` - 文章分類定義

每個欄目包含簡體中文（`_index.zh-cn.md`）和繁體中文（`_index.zh-tw.md`）版本。

### 配置檔案

主要配置檔案位於 `config/_default/` 目錄：

- `hugo.toml` - Hugo 主配置（網站基本資訊、分類法定義）
- `languages.zh-cn.toml` / `languages.zh-tw.toml` - 語言配置
- `menus.zh-cn.toml` / `menus.zh-tw.toml` - 導覽選單配置
- `params.toml` - 主題參數配置（外觀、功能開關）
- `markup.toml` - Markdown 渲染配置

### 資料檔案

`data/` 目錄儲存結構化資料：

- `data/authors/` - 作者資訊（JSON 格式）
  - 支援 GitHub / Telegram / 微博等社交連結
  - 自動從 GitHub 獲取頭像

### 多語言支援

網站支援簡體中文和繁體中文雙語：
- 簡體中文翻譯：`i18n/zh-CN.yaml`
- 繁體中文翻譯：`i18n/zh-TW.yaml`

### 主題和資源

- `themes/blowfish/` - Blowfish 主題（透過 git submodule 管理）
- `static/` - 靜態資源（圖片、CNAME 等）
- `assets/` - 需要處理的資源檔案
- `layouts/` - 自訂版面配置範本（如作者頁面）

## 如何貢獻

### 1. 提交新文章

在 `content/posts/` 目錄下建立新的文章目錄：

```bash
mkdir content/posts/YYYY-MM-DD-article-name
cd content/posts/YYYY-MM-DD-article-name
```

建立簡體和繁體中文版本：

**index.zh-cn.md** (簡體中文)：
```yaml
---
title: "文章标题"
date: 2025-11-22
categories: ["tutorial"]
authors: ["yourname"]
---

文章内容...
```

**index.zh-tw.md** (繁體中文)：
```yaml
---
title: "文章標題"
date: 2025-11-22
categories: ["tutorial"]
authors: ["yourname"]
---

文章內容...
```

**可用的文章分類**：
- `announcement` - 公告
- `tutorial` - 教學
- `news` - 新聞
- `community` - 社群動態

### 2. 新增作者資訊

在 `data/authors/` 目錄建立 JSON 檔案：

```json
{
  "name": "你的名字",
  "bio": "簡介",
  "social": [
    { "github": "https://github.com/yourname" },
    { "telegram": "https://t.me/yourname" }
  ]
}
```

頭像會自動從 GitHub 獲取。

### 3. 改進現有內容

歡迎改進：
- 修正錯別字或不準確的表述
- 更新過時的技術資訊
- 新增新的使用技巧
- 完善文件說明
- 補充缺失的繁體中文翻譯

### 4. 技術改進

如對網站技術架構有改進建議：
- 功能增強
- 效能提升
- 新功能開發
- 主題客製化

## 貢獻流程

### Fork 和 Clone

```bash
# Fork 專案到你的 GitHub 帳號
# 然後 clone 到本機
git clone https://github.com/你的使用者名稱/gentoo-zh.github.com.git
cd gentoo-zh.github.com

# 初始化主題子模組
git submodule update --init --recursive
```

### 本機預覽

```bash
# 安裝 Hugo (Gentoo)
emerge --ask www-apps/hugo

# 啟動本機伺服器
hugo server -D

# 造訪 http://localhost:1313 預覽
```

### 提交 Pull Request

```bash
# 建立新分支
git checkout -b your-feature-branch

# 提交更改
git add .
git commit -m "描述你的更改"
git push origin your-feature-branch

# 在 GitHub 上建立 Pull Request
```

## 寫作規範

### Markdown 格式

- 使用標準 Markdown 語法
- 程式碼區塊指定語言：\`\`\`bash
- 圖片使用相對路徑
- 連結使用 Markdown 格式

### 中文排版

- 中英文之間新增空格
- 使用全形標點符號
- 數字使用半形
- 專有名詞保持原文（如 Gentoo、Hugo）

### 範例

```markdown
Gentoo Linux 是一個基於原始碼的 Linux 發行版，使用 Portage 套件管理系統。

## 安裝步驟

1. 下載 Stage3 壓縮包
2. 解壓到目標目錄：
   ```bash
   tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
   ```
```

## 常見問題

### 如何更新主題？

```bash
cd themes/blowfish
git pull origin main
cd ../..
git add themes/blowfish
git commit -m "更新 Blowfish 主題"
```

### 如何新增新的頁面？

在 `content/` 下建立新目錄，新增 `_index.zh-cn.md` 和 `_index.zh-tw.md`。

### 繁體中文如何轉換？

可以使用 `opencc` 工具：

```bash
opencc -c s2twp -i index.zh-cn.md -o index.zh-tw.md
```

然後手動調整地域詞彙差異。

## 社群交流

遇到問題或有建議？

- **Telegram 群組**：[@gentoo_zh](https://t.me/gentoo_zh)
- **Telegram 頻道**：[@gentoocn](https://t.me/gentoocn)
- **GitHub Issues**：<https://github.com/gentoo-zh/gentoo-zh.github.com/issues>

## 授權協議

本站內容採用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 授權協議，除非另有說明。

程式碼貢獻遵循專案的 MIT 授權。

---

感謝你的貢獻，讓我們一起建設更好的 Gentoo 中文社群！
