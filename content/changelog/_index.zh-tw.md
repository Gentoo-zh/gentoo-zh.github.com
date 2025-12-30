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

### 2025-12-30

**Gentoo Linux 安裝指南（基礎篇）**

<details>
<summary><b>5.2 節 make.conf 範例優化（點擊展開）</b></summary>

- 簡化為「快速配置 + 引用進階篇」模式，降低新手入門複雜度
- 新增詳細配置說明提示框，引導使用者查閱 [進階篇 13.11 節](/posts/2025-11-25-gentoo-install-advanced/#1311-詳細配置範例完整註釋版)
- 優化所有配置項的註釋說明，包括編譯優化參數、並行編譯、映象站、USE 標誌、FEATURES、編譯日誌等
- 新增記憶體不足時的調整建議、高階使用者可選配置提示
- 新增 ACCEPT_LICENSE 授權許可管理說明，引導查閱 [進階篇 13.12 節](/posts/2025-11-25-gentoo-install-advanced/#1312-accept_license-軟體授權許可詳解)
- 移除 VIDEO_CARDS / INPUT_DEVICES 配置（已移至桌面配置篇）

</details>

<details>
<summary><b>5.3 節：CPU 指令集優化 (CPU_FLAGS_X86) 內容優化（點擊展開）</b></summary>

**參考文檔**：[CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn)

- 調整本節定位與表述，使其更符合「基礎篇快速上手」風格
- 引導查閱 [進階篇 13.13 節](/posts/2025-11-25-gentoo-install-advanced/#1313-cpu-指令集優化-cpu_flags_x86) 獲取更深入的說明

</details>

<details>
<summary><b>5.4 節新增：Binary Package Host（二進位套件主機）（點擊展開）</b></summary>

**參考文檔**：[Gentoo Handbook: Binary Package Host](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Adding_a_binary_package_host) · [Binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)

- 新增完整章節，介紹如何使用官方二進位套件主機大幅縮短安裝時間
- 包含配置示例：`/etc/portage/binrepos.conf/gentoobinhost.conf`
- 說明 FEATURES 配置：`getbinpkg` / `binpkg-request-signature`
- 提供驗證與測試方法
- 在文章導覽中同步更新相關提示

</details>

<details>
<summary><b>6.4 節 fstab 配置大幅完善（點擊展開）</b></summary>

- 補充「為什麼需要這一步？」說明（自動掛載、UUID 不變性等）
- 新增 genfstab 自動生成完整指南：
  - 安裝方法（Gig-OS / Gentoo Minimal ISO）
  - 三種執行情境：chroot 內 / LiveGUI 新終端機 / TTY 切換
  - 相容性說明：Btrfs 子卷 / LUKS 加密分割區 / 普通分割區
- 新增手動編輯 fstab 詳細說明（欄位含義、基礎配置示例）
- 新增 Btrfs 子卷配置折疊說明：自動生成 + 手動配置 + 常用掛載選項表格
- 新增 LUKS 加密分割區配置折疊說明：UUID 區別 / 自動生成 / 手動配置 / 常見問題
- 將所有 fstab 相關內容以 `<details>` 折疊重排，降低章節長度壓力

</details>

<details>
<summary><b>7.3 節 package.license 說明補充（點擊展開）</b></summary>

- 新增 `package.license` 配置說明，解釋為何在設定 `ACCEPT_LICENSE="*"` 後仍建議為 linux-firmware 單獨建立 license 檔案
- 說明最佳實踐：即使全域接受所有許可證，為特定軟體套件建立 license 檔案是 Gentoo 社群推薦做法，便於將來調整許可證策略時不阻止關鍵軟體安裝

</details>

- 8.1 節「系統服務工具」將 OpenRC / systemd 使用者分別折疊，提升可讀性
- `systemd-boot` 說明改為更保守的表述：強調僅適用於 UEFI，並提示部分 ARM/RISC-V 裝置韌體可能不支援完整 UEFI

---

**Gentoo Linux 安裝指南（桌面篇）**

<details>
<summary><b>12.1 節 VIDEO_CARDS 配置重構（點擊展開）</b></summary>

**參考文檔**：[Gentoo Handbook: VIDEO_CARDS](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#VIDEO_CARDS)

- 從 make.conf 全域配置改為推薦使用 `/etc/portage/package.use/video-cards` 方式（符合官方最佳實踐）
- 新增詳細硬體對照表：Intel / NVIDIA / AMD / Raspberry Pi / QEMU/KVM / WSL 等 9 種平臺
- 補充官方參考連結與推薦做法說明

</details>

---

**Gentoo Linux 安裝指南（進階篇）**

<details>
<summary><b>13.5 節 ACCEPT_LICENSE 引用修正（點擊展開）</b></summary>

- 修正錯誤引用：從「基礎篇 5.2 節：ACCEPT_LICENSE 詳細說明」改為頁內錨點「[13.12 節：ACCEPT_LICENSE 軟體授權許可詳解](#1312-accept_license-軟體授權許可詳解)」
- 原因：基礎篇 5.2 節僅包含簡單配置，詳細說明位於進階篇 13.12 節

</details>

<details>
<summary><b>CPU_FLAGS_X86：基礎篇/進階篇定位去重（點擊展開）</b></summary>

- 調整進階篇 13.13 的內容定位：不再重複基礎篇 5.3 的操作步驟，改為「進階觀念 + 常見注意事項 + 延伸說明」
- 在進階篇 13.13 直接導向基礎篇 [5.3 配置 CPU 指令集優化](/posts/2025-11-25-gentoo-install-base/#53-配置-cpu-指令集優化)，避免讀者在兩篇文章看到幾乎相同的命令段

</details>

<details>
<summary><b>13 章 make.conf 進階配置完全重構（點擊展開）</b></summary>

**參考文檔**：[make.conf - Gentoo Wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

從扁平的 9 個小節重構為結構化的 13 個子章節（13.1-13.13），大幅提升邏輯性與可讀性：

- **13.1 編譯器優化參數**：表格化呈現 `-march=native` / `-O2` / `-O3` / `-pipe` 等參數，新增 `-flto` / `-fomit-frame-pointer` 等進階參數說明，提供高效能/相容性/除錯配置範例
- **13.2 並行編譯配置**：新增硬體配置推薦表（4核到32核），涵蓋 RAM 不足與伺服器環境配置建議
- **13.3 USE 標誌管理**：按系統/桌面/音訊/網路/國際化分類折疊，提供完整 USE 標誌配置範例
- **13.4 語言與本地化**：補充 L10N / LINGUAS / LC_MESSAGES 配置建議
- **13.5 許可證管理 (ACCEPT_LICENSE)**：新增許可證組說明表（@FREE、@BINARY-REDISTRIBUTABLE 等），詳細說明針對特定軟體套件配置方式，引用 13.12 節詳細說明
- **13.6 Portage 功能增強 (FEATURES)**：使用表格呈現選項（parallel-fetch、ccache、distcc 等），加入 ccache 配置示例
- **13.7 映象源配置**：提供中國大陸與全球映象源列表
- **13.8 編譯日誌配置**：說明 PORTAGE_ELOG_CLASSES 與郵件配置
- **13.9 顯示卡與輸入裝置配置**：加入警告框，強調已移至桌面配置篇，推薦使用 package.use 方式配置
- **13.10 完整配置範例**：分為新手推薦與高效能工作站兩種配置，分別摺疊
- **13.11 延伸閱讀**：整合所有相關 Gentoo Wiki 連結
- **13.12 ACCEPT_LICENSE 軟體授權許可詳解**（新增摺疊章節）：詳細說明 GLEP 23、授權許可組概念、常用授權許可組表格、配置方式、單包配置範例等
- **13.13 CPU 指令集優化 (CPU_FLAGS_X86)**（新增摺疊章節）：詳細說明 CPU_FLAGS_X86 配置方法、cpuid2cpuflags 工具使用、範例配置等

</details>

<details>
<summary><b>18 章新增：Secure Boot 配置（點擊展開）</b></summary>

**參考文檔**：[Gentoo Handbook: Secure Boot](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Alternative:_Secure_Boot) · [Signed kernel module support](https://wiki.gentoo.org/wiki/Signed_kernel_module_support)

- **18.1 使用 sbctl 自動化管理（推薦）**：完整 sbctl 工作流程（安裝、生成密鑰、註冊密鑰、簽名、驗證）
- **18.2 手動配置 Secure Boot（使用 OpenSSL）**（折疊）：適合深入學習的使用者，包含密鑰生成、內核模組簽名、UKI 配置、MOK 註冊等
- 補充 Setup Mode 疑難排解：說明如何在 BIOS/UEFI 中清除密鑰以進入 Setup Mode
- 新增常見問題 FAQ

</details>

---

**網站基礎設施**
- GitHub Actions 部署工作流調整 Hugo 版本為 `0.153.2`（與 Blowfish 主題宣告的相容範圍對齊）
- 刪除格式錯誤的 `sync_to_tw.sh`
- 新增 `convert-zh-tw.sh`（用於簡轉繁與台灣本地化處理，包含 OpenCC + 映象源替換等規則）

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
