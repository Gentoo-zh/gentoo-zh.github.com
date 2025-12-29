---
title: "更新記錄"
date: 2025-12-29
description: "Gentoo 中文社群網站更新記錄"
slug: "changelog"
showDate: false
showAuthor: false
showReadingTime: false
showEdit: false
layoutBackgroundHeaderSpace: false
---

本頁面記錄網站內容的主要更新，便於讀者追蹤變更。

---

## 2025 年 12 月

### 2025-12-29

**網站語言與術語更新**
- 語言選擇器顯示名稱從「繁體中文」改為「傳統中文」，從「简体中文」改為「简化中文」
- 首頁「新聞」標題改為「文章」
- 使用 opencc s2twp 轉換傳統中文版文章，確保字形正確

**關於頁面更新**
- 更新群組規則，強調中華文化跨越地理邊界
- 新增「語言哲學」章節，說明選擇「傳統中文」命名的理由

**Gentoo Linux 安裝指南（基礎篇）**
- 在 7.3 節「安裝韌體與微碼」新增關於 `package.license` 的說明，解釋為何在設定 `ACCEPT_LICENSE="*"` 後仍建議為 linux-firmware 單獨建立 license 檔案
- 優化 5.2 節「make.conf 範例」的懶人配置，為每個參數添加詳細註解說明
- 新增 VIDEO_CARDS、INPUT_DEVICES、PORTAGE_ELOG_CLASSES 等配置範例

**貢獻指南**
- 添加 `content/changelog/` 目錄說明

**Jekyll 遷移至 Hugo 公告**
- 更新 Hugo 版本資訊至 v0.148+
- 添加更新記錄和貢獻指南頁面說明
- 補充貢獻者自動更新功能說明

**網站基礎設施**
- 修復貢獻者自動更新後網站未重新部署的問題（移除提交訊息中的 `[skip ci]` 標記）
- 更新 Blowfish 主題至最新版本
- 新增本更新記錄頁面
- 修正 sync_to_tw.sh 轉換規則

---

## 更新說明

- 本頁面記錄網站**內容**的主要更新，不包括純技術性修改
- 貢獻者資訊每週一自動更新，不在此處記錄
- 如有問題或建議，請聯繫 [admin@zakk.au](mailto:admin@zakk.au) 或在 [Telegram 群組](https://t.me/gentoo_zh) 討論
