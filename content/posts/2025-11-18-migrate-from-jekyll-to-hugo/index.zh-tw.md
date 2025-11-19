---
title: "網站從 Jekyll 遷移至 Hugo"
date: 2025-11-18
categories: ["website", "announcement"]
authors: ["zakkaus"]
---

經過多年使用 Jekyll 作為靜態站點產生器，Gentoo 中文社群網站現已成功遷移至 Hugo。本文介紹此次遷移的原因和主要改進。

## 為什麼選擇 Hugo？

### 效能優勢

- **建置速度快**：Hugo 使用 Go 撰寫，建置速度比 Jekyll 快數十倍
- **無需 Ruby 環境**：Hugo 是單一二進位檔案，部署更簡單
- **記憶體佔用低**：大型站點建置時資源消耗更少

### 功能特性

- **內建多語言支援**：原生支援簡體中文和繁體中文
- **強大的主題系統**：採用 Blowfish 主題，介面現代美觀
- **更好的資源管理**：支援圖片最佳化、CSS/JS 打包等

## 主要改進

### 1. 現代化介面

採用 [Blowfish](https://blowfish.page/) 主題，提供：
- 響應式設計，完美支援行動裝置
- 深色/淺色模式切換
- 優雅的文章排版

### 2. 多語言支援

- 簡體中文（zh-CN）
- 繁體中文（zh-TW）
- 未來可輕鬆新增更多語言

### 3. 內容最佳化

- **下載頁面**：列出官方和中國內陸鏡像源
- **鏡像列表**：詳細的 Portage 樹和 Distfiles 配置說明
- **Overlay 文件**：gentoo-zh overlay 使用指南

### 4. 效能提升

- WebP 圖片格式，減少 85% 檔案大小
- 靜態資源最佳化
- 更快的頁面載入速度

## 技術棧

- **靜態站點產生器**：Hugo v0.1xx+
- **主題**：Blowfish
- **部署**：Cloudflare Pages / GitHub Pages
- **版本控制**：Git

## 遷移過程

### 內容遷移

1. 將 Jekyll 的 `_posts` 目錄遷移到 Hugo 的 `content/posts`
2. 轉換 front matter 格式
3. 調整圖片路徑和資源引用

### 配置調整

1. 將 `_config.yml` 轉換為 Hugo 配置檔案
2. 設定多語言支援
3. 配置主題參數

### 樣式定製

1. 自訂背景圖片
2. 配置社交媒體連結
3. 新增自訂 CSS

## 未來計畫

- 持續完善中文文件
- 新增更多 Gentoo 相關教學

## 回饋與貢獻

如果您在使用新網站時遇到問題，歡迎：
- 加入 Telegram 群組：[@gentoo_zh](https://t.me/gentoo_zh)
- 關注 Telegram 頻道：[@gentoocn](https://t.me/gentoocn)
- 在 [GitHub](https://github.com/gentoo-zh) 提交 Issue
