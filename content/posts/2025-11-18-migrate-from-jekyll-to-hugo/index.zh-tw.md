---
title: "網站從 Jekyll 遷移至 Hugo"
date: 2025-11-18
categories: ["announcement"]
authors: ["zakkaus"]
---

經過多年使用 Jekyll 作為靜態站點產生器，Gentoo 中文社群網站現已成功遷移至 Hugo。本文介紹此次遷移的背景、原因和主要改進。

## 專案背景

Gentoo 中文社群網站創建於 2014 年，由 [@zhcj](https://github.com/zhcj)（清風博主）與 [@biergaizi](https://github.com/biergaizi)（比爾蓋子）共同發起。專案使用 Jekyll 作為靜態站點產生器已有多年，但隨著社群發展和技術演進，Jekyll 的一些限制逐漸顯現。

經創始人 @biergaizi 授權，[@Zakkaus](https://github.com/zakkaus) 於 2025 年接手本專案的日常維護工作，並啟動了從 Jekyll 到 Hugo 的遷移工作。

## 為什麼選擇 Hugo？

### 效能優勢

- **建置速度快**：Hugo 使用 Go 編寫，建置速度比 Jekyll 快數十倍
- **無需 Ruby 環境**：Hugo 是單一二進位檔案，部署更簡單
- **記憶體佔用低**：大型站點建置時資源消耗更少

### 功能特性

- **內建多語言支援**：原生支援簡體中文和傳統中文
- **強大的主題系統**：採用 Blowfish 主題，介面現代美觀
- **更好的資源管理**：支援圖片最佳化、CSS/JS 打包等
- **靈活的內容組織**：Page Bundles 讓資源管理更直觀

## 主要改進

### 1. 現代化介面

採用 [Blowfish](https://blowfish.page/) 主題，提供：
- 響應式設計，完美支援行動裝置
- 深色/淺色模式切換
- 優雅的文章排版
- 更好的可讀性

### 2. 多語言支援

- 簡體中文（zh-CN）
- 傳統中文（zh-TW）
- 未來可輕鬆新增更多語言

### 3. 內容最佳化

新增和完善的頁面：
- **下載頁面**：列出官方和中國內陸鏡像源，特別標註 Apple Silicon Mac 使用者注意事項
- **鏡像列表**：詳細的 Portage 樹和 Distfiles 配置說明
- **Overlay 文件**：gentoo-zh overlay 使用指南
- **關於頁面**：專案歷史和團隊介紹
- **貢獻者頁面**：展示社群貢獻者資訊（每週自動更新）
- **更新記錄**：記錄網站內容的重要變更
- **貢獻指南**：完整的專案結構和貢獻流程說明

### 4. 效能提升

- WebP 圖片格式，減少檔案大小
- 靜態資源最佳化
- 更快的頁面載入速度
- 改進的 SEO 最佳化

### 5. 使用者體驗改進

- 摺疊式導覽選單，頁面更簡潔
- GitHub 連結使用圖示顯示
- 改進的行動端體驗
- 更好的中文字型渲染

## 技術棧

- **靜態站點產生器**：Hugo v0.148+
- **主題**：Blowfish
- **部署**：GitHub Pages
- **版本控制**：Git
- **CI/CD**：GitHub Actions（自動部署 + 每週自動更新貢獻者資訊）

## 遷移過程

### 內容遷移

1. 將 Jekyll 的 `_posts` 目錄遷移到 Hugo 的 `content/posts`
2. 轉換 front matter 格式（YAML → TOML）
3. 調整圖片路徑和資源引用
4. 使用 Page Bundles 組織文章資源

### 配置調整

1. 將 `_config.yml` 轉換為 Hugo 配置檔案結構
2. 設定多語言支援（簡體/傳統中文）
3. 配置主題參數和自訂選項
4. 設定選單和導覽結構

### 樣式定製

1. 自訂背景圖片和配色方案
2. 配置社交媒體連結
3. 新增自訂 CSS 最佳化中文顯示
4. 最佳化行動端版面配置

## 資料遷移

所有作者資訊已遷移到 `data/authors/` 目錄：
- [@biergaizi](https://github.com/biergaizi) - 創始人
- [@zhcj](https://github.com/zhcj) - 創始人
- [@zakkaus](https://github.com/zakkaus) - 現任維護者

作者系統支援：
- GitHub / Telegram / 微博等社交連結
- 個人簡介
- 文章關聯

## 未來計畫

- 持續完善中文文件
- 新增更多 Gentoo 相關教學
- 改進搜尋功能
- 新增評論系統（可選）
- 最佳化建置流程

## 回饋與貢獻

如果您在使用新網站時遇到問題或有建議，歡迎：
- 加入 Telegram 群組：[@gentoo_zh](https://t.me/gentoo_zh)
- 關注 Telegram 頻道：[@gentoocn](https://t.me/gentoocn)
- 在 [GitHub](https://github.com/gentoo-zh/gentoo-zh.github.com) 提交 Issue 或 Pull Request

## 致謝

感謝 [@biergaizi](https://github.com/biergaizi) 和 [@zhcj](https://github.com/zhcj) 創立並長期維護 Gentoo 中文社群。感謝 Blowfish 主題的開發者提供了優秀的主題框架。感謝所有為 Gentoo 中文社群做出貢獻的成員！

---

*網站遷移完成於 2025 年 11 月*
