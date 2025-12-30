---
title: "Gentoo Linux 安裝指南 (基礎篇)"
date: 2025-11-25
summary: "Gentoo Linux 基礎系統安裝教程，涵蓋分區、Stage3、內核編譯、引導程式配置等。也突出有 LUKS 全盤加密教學。"
description: "2025 年最新 Gentoo Linux 安裝指南 (基礎篇)，詳細講解 UEFI 安裝流程、內核編譯等。適合 Linux 進階用戶和 Gentoo 新手。也突出有 LUKS 全盤加密教學。"
keywords:
  - Gentoo Linux
  - Linux 安裝
  - 源碼編譯
  - systemd
  - OpenRC
  - Portage
  - make.conf
  - 內核編譯
  - UEFI 安裝
tags:
  - Gentoo
  - Linux
  - 教程
  - 系統安裝
categories:
  - tutorial
authors:
  - zakkaus
---

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 文章特別說明

本文是 **Gentoo Linux 安裝指南** 系列的第一部分：**基礎安裝**。

**系列導航**：
1. **基礎安裝（本文）**：從零開始安裝 Gentoo 基礎系統
2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：顯卡驅動、桌面環境、輸入法等
3. [進階優化](/posts/2025-11-25-gentoo-install-advanced/)：make.conf 優化、LTO、系統維護

**建議閱讀方式**：
- 按需閱讀：基礎安裝（0-11 節）→ 桌面配置（12 節）→ 進階優化（13-17 節）

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 關於本指南

本文旨在提供一個完整的 Gentoo 安裝流程演示，並**密集提供可供學習的參考文獻**。文章中包含大量官方 Wiki 鏈接和技術文檔，幫助讀者深入理解每個步驟的原理和配置細節。

**這不是一份簡單的傻瓜式教程，而是一份引導性的學習資源**——使用 Gentoo 的第一步是學會自己閱讀 Wiki 並解決問題，善用 Google 甚至 AI 工具尋找答案。遇到問題或需要深入瞭解時，請務必查閱官方手冊和本文提供的參考鏈接。

如果在閱讀過程中遇到疑問或發現問題，歡迎通過以下渠道提出：
- **Gentoo 中文社區**：[Telegram 群組](https://t.me/gentoo_zh) | [Telegram 頻道](https://t.me/gentoocn) | [GitHub](https://github.com/Gentoo-zh)
- **官方社區**：[Gentoo Forums](https://forums.gentoo.org/) | IRC: #gentoo @ Libera.Chat

**非常建議以官方手冊為準**：
- [Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [Gentoo Handbook: AMD64 (簡體中文)](https://wiki.gentoo.org/wiki/Handbook:AMD64/zh-cn)

<p style="opacity: 0.8; margin-top: 1rem;">✓ 已驗證至 2025 年 11 月 25 日</p>

</div>

## 什麼是 Gentoo？

Gentoo Linux 是一個基於源碼的 Linux 發行版，以其**高度可定製性**和**性能優化**著稱。與其他發行版不同，Gentoo 讓你從源代碼編譯所有軟件，這意味著：

- **極致性能**：所有軟件針對你的硬件優化編譯
- **完全掌控**：你決定系統包含什麼，不包含什麼
- **深度學習**：通過親手構建系統深入理解 Linux
- **編譯時間**：初次安裝需要較長時間（建議預留 3-6 小時）
- **學習曲線**：需要一定的 Linux 基礎知識

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94);">

**適合誰？**
- 想要深入學習 Linux 的技術愛好者
- 追求系統性能和定製化的用戶
- 享受 DIY 過程的 Geek

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11);">

**不適合誰？**
- 只想快速安裝使用的新手（建議先嚐試 Ubuntu、Fedora 等）
- 沒有時間折騰系統的用戶

</div>

</div>

<details>
<summary><b>核心概念速覽（點擊展開）</b></summary>

在開始安裝前，先了解幾個核心概念：

**Stage3** ([Wiki](https://wiki.gentoo.org/wiki/Stage_file))
一個最小化的 Gentoo 基礎系統壓縮包。它包含了構建完整系統的基礎工具鏈（編譯器、庫等）。你將解壓它到硬盤上，作為新系統的"地基"。

**Portage** ([Wiki](https://wiki.gentoo.org/wiki/Portage/zh-cn))
Gentoo 的套件管理系統。它不直接安裝預編譯的軟件包，而是下載源代碼、根據你的配置編譯，然後安裝。核心命令是 `emerge`。

**USE Flags** ([Wiki](https://wiki.gentoo.org/wiki/USE_flag/zh-cn))
控制軟件功能的開關。例如，`USE="bluetooth"` 會讓所有支持藍牙的軟件在編譯時啟用藍牙功能。這是 Gentoo 定製化的核心。

**Profile** ([Wiki](https://wiki.gentoo.org/wiki/Profile_(Portage)))
預設的系統配置模板。例如 `desktop/plasma/systemd` profile 會自動啟用適合 KDE Plasma 桌面的默認 USE flags。

**Emerge** ([Wiki](https://wiki.gentoo.org/wiki/Emerge))
Portage 的命令行工具。常用命令：
- `emerge --ask <包名>` - 安裝軟件
- `emerge --sync` - 同步軟件倉庫
- `emerge -avuDN @world` - 更新整個系統

</details>

<details>
<summary><b>安裝時間估算（點擊展開）</b></summary>

| 步驟 | 預計時間 |
|---|----------|
| 準備安裝媒介 | 10-15 分鐘 |
| 磁盤分區與格式化 | 15-30 分鐘 |
| 下載並解壓 Stage3 | 5-10 分鐘 |
| 配置 Portage 與 Profile | 15-20 分鐘 |
| **編譯內核**（最耗時） | **30 分鐘 - 2 小時** |
| 安裝系統工具 | 20-40 分鐘 |
| 配置引導程式 | 10-15 分鐘 |
| **安裝桌面環境**（可選） | **1-3 小時** |
| **總計** | **3-6 小時**（取決於硬件性能）|

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

使用預編譯內核和二進制包可以大幅縮短時間，但會犧牲部分定製性。

</div>

</details>

<details>
<summary><b>磁盤空間需求與開始前檢查清單（點擊展開）</b></summary>

### 磁盤空間需求

- **最小安裝**：10 GB（無桌面環境）
- **推薦空間**：30 GB（輕量桌面）
- **舒適空間**：80 GB+（完整桌面 + 編譯緩存）

### 開始前的檢查清單

- 已備份所有重要數據
- 準備了 8GB+ 的 USB 閃存盤
- 確認網絡連接穩定（有線網絡最佳）
- 預留了充足的時間（建議完整的半天）
- 有一定的 Linux 命令行基礎
- 準備好另一臺設備查閱文檔（或者使用 GUI LiveCD）

</details>

---

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 本指南內容概覽

本指南將引導你在 x86_64 UEFI 平臺上安裝 Gentoo Linux。

**本文將教你**：
- 從零開始安裝 Gentoo 基礎系統（分區、Stage3、內核、引導程式）
- 配置 Portage 並優化編譯參數（make.conf、USE flags、CPU flags）
- 安裝桌面環境（KDE Plasma、GNOME、Hyprland）
- 配置中文環境（locale、字體、Fcitx5 輸入法）
- 可選進階配置（LUKS 全盤加密、LTO 優化、內核調優、RAID）
- 系統維護（SSD TRIM、電源管理、Flatpak、系統更新）

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要提醒**

**請先關閉 Secure Boot**  
在開始安裝之前，請務必進入 BIOS 設置，將 **Secure Boot** 暫時關閉。開啟 Secure Boot 可能會導致安裝介質無法啟動，或者安裝後的系統無法引導。你可以在系統安裝完成併成功啟動後，再參考本指南後面的章節重新配置並開啟 Secure Boot。

**備份所有重要數據！**  
本指南涉及磁盤分區操作，請務必在開始前備份所有重要數據！

</div>

---

## 0. 準備安裝媒介 {#step-0-prepare}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 選擇安裝媒介](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media/zh-cn)

</div>

### 0.1 下載 Gentoo ISO

根據[**下載頁面**](/download/) 提供的方式獲取下載鏈接

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

以下鏈接中的日期（如 `20251123T...`）僅供參考，請務必在鏡像站中選擇**最新日期**的文件。

</div>

下載 Minimal ISO（以 TWAREN 鏡像站為例）：
```bash
wget http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso
wget http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso.asc
```

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**新手推薦：使用 LiveGUI USB Image**

如果希望安裝時能直接使用瀏覽器或更方便地連接 Wi-Fi，可以選擇 **LiveGUI USB Image**。

**新手入坑推薦使用每週構建的 KDE 桌面環境的 Live ISO**： <https://iso.gig-os.org/>  
（來自 Gig-OS <https://github.com/Gig-OS> 項目）

**Live ISO 登錄憑據**：
- 賬號：`live`
- 密碼：`live`
- Root 密碼：`live`

**系統支持**：
- 支持中文顯示和中文輸入法 (fcitx5), flclash 等

</div>

驗證簽名（可選）：
```bash
# 從密鑰服務器獲取 Gentoo 發佈簽名公鑰
gpg --keyserver hkps://keys.openpgp.org --recv-keys 0xBB572E0E2D1829105A8D0F7CF7A88992
# --keyserver: 指定密鑰服務器地址
# --recv-keys: 接收並導入公鑰
# 0xBB...992: Gentoo Release Media 簽名密鑰指紋

# 驗證 ISO 文件的數字簽名
gpg --verify install-amd64-minimal-20251123T153051Z.iso.asc install-amd64-minimal-20251123T153051Z.iso
# --verify: 驗證簽名文件
# .iso.asc: 簽名文件（ASCII armored）
# .iso: 被驗證的 ISO 文件
```

### 0.2 製作 USB 安裝盤

**Linux：**
```bash
sudo dd if=install-amd64-minimal-20251123T153051Z.iso of=/dev/sdX bs=4M status=progress oflag=sync
# if=輸入文件 of=輸出設備 bs=塊大小 status=顯示進度
```
<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

請將 `sdX` 替換成 USB 裝置名稱，例如 `/dev/sdb`。

</div>

**Windows：** 推薦使用 [Rufus](https://rufus.ie/) → 選擇 ISO → 寫入時選 DD 模式。

---

## 1. 進入 Live 環境並連接網絡 {#step-1-network}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 配置網絡](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Gentoo 的安裝過程完全依賴網絡來下載源碼包 (Stage3) 和軟件倉庫 (Portage)。在 Live 環境中配置好網絡是安裝的第一步。

</div>

### 1.1 有線網絡

```bash
ip link        # 查看網卡接口名稱 (如 eno1, wlan0)
dhcpcd eno1    # 對有線網卡啟用 DHCP 自動獲取 IP
ping -c3 gentoo.org # 測試網絡連通性
```

### 1.2 無線網絡
使用 net-setup：
```bash
net-setup 
```

**wpa_supplicant：**
```bash
wpa_passphrase "SSID" "PASSWORD" | tee /etc/wpa_supplicant/wpa_supplicant.conf
wpa_supplicant -B -i wlp0s20f3 -c /etc/wpa_supplicant/wpa_supplicant.conf
dhcpcd wlp0s20f3
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

若 WPA3 不穩定，請先退回 WPA2。

</div>

<details>
<summary><b>進階設置：啟動 SSH 方便遠程操作（點擊展開）</b></summary>

```bash
passwd                      # 設定 root 密碼 (遠程登錄需要)
rc-service sshd start       # 啟動 SSH 服務
rc-update add sshd default  # 設置 SSH 開機自啟 (Live 環境中可選)
ip a | grep inet            # 查看當前 IP 地址
# 在另一臺設備上：ssh root@<IP>
```

</details>


## 2. 規劃磁盤分區 {#step-2-partition}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 準備磁盤](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

我們需要為 Linux 系統劃分獨立的存儲空間。UEFI 系統通常需要一個 ESP 分區 (引導) 和一個根分區 (系統)。合理的規劃能讓日後的維護更輕鬆。

### 什麼是 EFI 系統分區 (ESP)？

在使用由 UEFI 引導（而不是 BIOS）的操作系統上安裝 Gentoo 時，創建 EFI 系統分區 (ESP) 是必要的。ESP 必須是 FAT 變體（有時在 Linux 系統上顯示為 vfat）。官方 UEFI 規範表示 UEFI 韌體將識別 FAT12、16 或 32 文件系統，但建議使用 FAT32。

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**  
如果 ESP 沒有使用 FAT 變體進行格式化，那麼系統的 UEFI 韌體將找不到引導加載程式（或 Linux 內核）並且很可能無法引導系統！

</div>

### 建議分區方案（UEFI）

下表提供了一個可用於 Gentoo 試用安裝的推薦默認分區表。

| 設備路徑 | 掛載點 | 文件系統 | 描述 |
| :--- | :--- | :--- | :--- |
| `/dev/nvme0n1p1` | `/efi` | vfat | EFI 系統分區 (ESP) |
| `/dev/nvme0n1p2` | `swap` | swap | 交換分區 |
| `/dev/nvme0n1p3` | `/` | xfs | 根分區 |

### cfdisk 實戰示例（推薦）

`cfdisk` 是一個圖形化的分區工具，操作簡單直觀。

```bash
cfdisk /dev/nvme0n1
```

**操作提示**：
1.  選擇 **GPT** 標籤類型。
2.  **創建 ESP**：新建分區 -> 大小 `1G` -> 類型選擇 `EFI System`。
3.  **創建 Swap**：新建分區 -> 大小 `4G` -> 類型選擇 `Linux swap`。
4.  **創建 Root**：新建分區 -> 剩餘空間 -> 類型選擇 `Linux filesystem` (默認)。
5.  選擇 **Write** 寫入更改，輸入 `yes` 確認。
6.  選擇 **Quit** 退出。

```text
                                                                 Disk: /dev/nvme0n1
                                              Size: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
                                            Label: gpt, identifier: 9737D323-129E-4B5F-9049-8080EDD29C02

    設備                                       Start                   終點                  扇區               Size 類型
    /dev/nvme0n1p1                                34                  32767                 32734                16M Microsoft reserved
    /dev/nvme0n1p2                             32768              879779839             879747072             419.5G Microsoft basic data
    /dev/nvme0n1p3                        1416650752             1418747903               2097152                 1G EFI System
    /dev/nvme0n1p4                        1418747904             1437622271              18874368                 9G Linux swap
    /dev/nvme0n1p5                        1437622272             1953523711             515901440               246G Linux filesystem
>>  /dev/nvme0n1p6                         879779840             1416650751             536870912               256G Linux filesystem

 ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
 │  Partition UUID: F2F1EF58-82EA-46A6-BF49-896AA40C6060                                                                                           │
 │  Partition type: Linux filesystem (0FC63DAF-8483-4772-8E79-3D69D8477DE4)                                                                        │
 │ Filesystem UUID: b4b0b42d-20be-4cf8-be81-9775efa6c151                                                                                           │
 │Filesystem LABEL: crypthomevar                                                                                                                   │
 │      Filesystem: crypto_LUKS                                                                                                                    │
 └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                   [ 刪除 ]  [Resize]  [ 退出 ]  [ 類型 ]  [ 幫助 ]  [ 排序 ]  [ 寫入 ]  [ 導出 ]


                                                        Quit program without writing changes
```

<details>
<summary><b>進階設置：fdisk 命令行分區教程（點擊展開）</b></summary>

`fdisk` 是一個功能強大的命令行分區工具。

```bash
fdisk /dev/nvme0n1
```

**1. 查看當前分區佈局**

使用 `p` 鍵來顯示磁盤當前的分區配置。

```text
Command (m for help): p
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: NVMe SSD
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 3E56EE74-0571-462B-A992-9872E3855D75

Device           Start        End    Sectors   Size Type
/dev/nvme0n1p1    2048    2099199    2097152     1G EFI System
/dev/nvme0n1p2 2099200   10487807    8388608     4G Linux swap
/dev/nvme0n1p3 10487808 1953523711 1943035904 926.5G Linux root (x86-64)
```

**2. 創建一個新的磁盤標籤**

按下 `g` 鍵將立即刪除所有現有的磁盤分區並創建一個新的 GPT 磁盤標籤：

```text
Command (m for help): g
Created a new GPT disklabel (GUID: ...).
```

或者，要保留現有的 GPT 磁盤標籤，可以使用 `d` 鍵逐個刪除現有分區。

**3. 創建 EFI 系統分區 (ESP)**

輸入 `n` 創建一個新分區，選擇分區號 1，起始扇區默認（2048），結束扇區輸入 `+1G`：

```text
Command (m for help): n
Partition number (1-128, default 1): 1
First sector (2048-..., default 2048): <Enter>
Last sector, +/-sectors or +/-size{K,M,G,T,P} (...): +1G

Created a new partition 1 of type 'Linux filesystem' and of size 1 GiB.
Partition #1 contains a vfat signature.

Do you want to remove the signature? [Y]es/[N]o: Y
The signature will be removed by a write command.
```

將分區標記為 EFI 系統分區（類型代碼 1）：

```text
Command (m for help): t
Selected partition 1
Partition type or alias (type L to list all): 1
Changed type of partition 'Linux filesystem' to 'EFI System'.
```

**4. 創建 Swap 分區**

創建 4GB 的 Swap 分區：

```text
Command (m for help): n
Partition number (2-128, default 2): 2
First sector (...): <Enter>
Last sector (...): +4G

Created a new partition 2 of type 'Linux filesystem' and of size 4 GiB.

Command (m for help): t
Partition number (1,2, default 2): 2
Partition type or alias (type L to list all): 19
Changed type of partition 'Linux filesystem' to 'Linux swap'.
```
*(注：Type 19 是 Linux swap)*

**5. 創建根分區**

將剩餘空間分配給根分區：

```text
Command (m for help): n
Partition number (3-128, default 3): 3
First sector (...): <Enter>
Last sector (...): <Enter>

Created a new partition 3 of type 'Linux filesystem' and of size 926.5 GiB.
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

將根分區的類型設置為 "Linux root (x86-64)" 並不是必須的，如果將其設置為 "Linux filesystem" 類型，系統也能正常運行。只有在使用支持它的 bootloader (即 systemd-boot) 並且不需要 fstab 文件時，才需要這種文件系統類型。

</div>

設置分區類型為 "Linux root (x86-64)"（類型代碼 23）：

```text
Command (m for help): t
Partition number (1-3, default 3): 3
Partition type or alias (type L to list all): 23
Changed type of partition 'Linux filesystem' to 'Linux root (x86-64)'.
```

**6. 寫入更改**

檢查無誤後，輸入 `w` 寫入更改並退出：

```text
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

</details>

---

## 3. 建立文件系統並掛載 {#step-3-filesystem}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 準備磁盤](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn) · [Ext4](https://wiki.gentoo.org/wiki/Ext4/zh-cn) · [XFS](https://wiki.gentoo.org/wiki/XFS/zh-cn) · [Btrfs](https://wiki.gentoo.org/wiki/Btrfs/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

磁盤分區只是劃分了空間，但還不能存儲數據。建立文件系統 (如 ext4, Btrfs) 才能讓操作系統管理和訪問這些空間。掛載則是將這些文件系統連接到 Linux 文件樹的特定位置。

</div>

### 3.1 格式化

```bash
mkfs.fat -F 32 /dev/nvme0n1p1  # 格式化 ESP 分區為 FAT32
mkswap /dev/nvme0n1p2          # 格式化 Swap 分區
mkfs.xfs /dev/nvme0n1p3        # 格式化 Root 分區為 XFS
```

若使用 Btrfs：
```bash
mkfs.btrfs -L gentoo /dev/nvme0n1p3
```

若使用 ext4：
```bash
mkfs.ext4 /dev/nvme0n1p3
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**其他文件系統**

其他如 [F2FS](https://wiki.gentoo.org/wiki/F2FS/zh-cn) 或 [ZFS](https://wiki.gentoo.org/wiki/ZFS/zh-cn) 請參考相關 Wiki。

</div>

### 3.2 掛載（XFS 示例）

```bash
mount /dev/nvme0n1p3 /mnt/gentoo        # 掛載根分區
mkdir -p /mnt/gentoo/efi                # 創建 ESP 掛載點
mount /dev/nvme0n1p1 /mnt/gentoo/efi    # 掛載 ESP 分區
swapon /dev/nvme0n1p2                   # 啟用 Swap 分區
```

<details>
<summary><b>進階設置：Btrfs 子卷示例（點擊展開）</b></summary>

**1. 格式化**

```bash
mkfs.fat -F 32 /dev/nvme0n1p1  # 格式化 ESP
mkswap /dev/nvme0n1p2          # 格式化 Swap
mkfs.btrfs -L gentoo /dev/nvme0n1p3 # 格式化 Root (Btrfs)
```

**2. 創建子卷**

```bash
mount /dev/nvme0n1p3 /mnt/gentoo
btrfs subvolume create /mnt/gentoo/@
btrfs subvolume create /mnt/gentoo/@home
umount /mnt/gentoo
```

**3. 掛載子卷**

```bash
mount -o compress=zstd,subvol=@ /dev/nvme0n1p3 /mnt/gentoo
mkdir -p /mnt/gentoo/{efi,home}
mount -o subvol=@home /dev/nvme0n1p3 /mnt/gentoo/home
mount /dev/nvme0n1p1 /mnt/gentoo/efi    # 注意：ESP 必須是 FAT32 格式
swapon /dev/nvme0n1p2
```

**4. 驗證掛載**

```bash
lsblk
```

輸出示例：
```text
NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
nvme0n1          259:1    0 931.5G  0 disk  
├─nvme0n1p1      259:7    0     1G  0 part  /mnt/gentoo/efi
├─nvme0n1p2      259:8    0     4G  0 part  [SWAP]
└─nvme0n1p3      259:9    0 926.5G  0 part  /mnt/gentoo/home
                                            /mnt/gentoo
```

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**Btrfs 快照建議**

推薦使用 [Snapper](https://wiki.gentoo.org/wiki/Snapper) 管理快照。合理的子卷規劃（如將 `@` 和 `@home` 分開）能讓系統回滾更加輕鬆。

</div>

</details>

<details>
<summary><b>進階設置：加密分區（LUKS）（點擊展開）</b></summary>

**1. 建立加密容器**

```bash
cryptsetup luksFormat --type luks2 --pbkdf argon2id --hash sha512 --key-size 512 /dev/nvme0n1p3
```

**2. 打開加密容器**

```bash
cryptsetup luksOpen /dev/nvme0n1p3 gentoo-root
```

**3. 格式化**

```bash
mkfs.fat -F 32 /dev/nvme0n1p1       # 格式化 ESP
mkswap /dev/nvme0n1p2               # 格式化 Swap
mkfs.btrfs --label root /dev/mapper/gentoo-root # 格式化 Root (Btrfs)
```

**4. 掛載**

```bash
mount /dev/mapper/gentoo-root /mnt/gentoo
mkdir -p /mnt/gentoo/efi
mount /dev/nvme0n1p1 /mnt/gentoo/efi
swapon /dev/nvme0n1p2
```

**5. 驗證掛載**

```bash
lsblk
```

輸出示例：
```text
NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
nvme0n1          259:1    0 931.5G  0 disk  
├─nvme0n1p1      259:7    0     1G  0 part  /mnt/gentoo/efi
├─nvme0n1p2      259:8    0     4G  0 part  [SWAP]
└─nvme0n1p3      259:9    0 926.5G  0 part  
  └─gentoo-root  253:0    0 926.5G  0 crypt /mnt/gentoo
```

</details>

---

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**建議**

掛載完成後，建議使用 `lsblk` 確認掛載點是否正確。

```bash
lsblk
```

**輸出示例**（類似如下）：
```text
NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
 nvme0n1          259:1    0 931.5G  0 disk  
├─nvme0n1p1      259:7    0     1G  0 part  /efi
├─nvme0n1p2      259:8    0     4G  0 part  [SWAP]
└─nvme0n1p3      259:9    0 926.5G  0 part  /
```

</div>

## 4. 下載 Stage3 並進入 chroot {#step-4-stage3}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 安裝文件](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/zh-cn) · [Stage file](https://wiki.gentoo.org/wiki/Stage_file)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Stage3 是一個最小化的 Gentoo 基礎系統環境。我們將它解壓到硬盤上，作為新系統的"地基"，然後通過 `chroot` 進入這個新環境進行後續配置。

</div>

### 4.1 選擇 Stage3

- **OpenRC**：`stage3-amd64-openrc-*.tar.xz`
- **systemd**：`stage3-amd64-systemd-*.tar.xz`
- Desktop 變種只是預設開啟部分 USE，標準版更靈活。

### 4.2 下載與展開

```bash
cd /mnt/gentoo
# 使用 links 瀏覽器訪問鏡像站下載 Stage3
links http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/20251123T153051Z/ #以 TWAREN 鏡像站為例
# 解壓 Stage3 壓縮包
# x:解壓 p:保留權限 v:顯示過程 f:指定文件 --numeric-owner:使用數字ID
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

如果同時下載了 `.DIGESTS` 或 `.CONTENTS`，可以用 `openssl` 或 `gpg` 驗證。

### 4.3 複製 DNS 並掛載偽文件系統

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/ # 複製 DNS 配置
mount --types proc /proc /mnt/gentoo/proc          # 掛載進程信息
mount --rbind /sys /mnt/gentoo/sys                 # 綁定掛載系統信息
mount --rbind /dev /mnt/gentoo/dev                 # 綁定掛載設備節點
mount --rbind /run /mnt/gentoo/run                 # 綁定掛載運行時信息
mount --make-rslave /mnt/gentoo/sys                # 設置為從屬掛載 (防止卸載時影響宿主)
mount --make-rslave /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/run
```

> 使用 OpenRC 可以省略 `/run` 這一步。

### 4.4 進入 chroot

```bash
chroot /mnt/gentoo /bin/bash    # 切換根目錄到新系統
source /etc/profile             # 加載環境變量
export PS1="(chroot) ${PS1}"    # 修改提示符以區分環境
```

---

## 5. 初始化 Portage 與 make.conf {#step-5-portage}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 基本系統](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Portage 是 Gentoo 的套件管理系統，也是其核心特色。初始化 Portage 並配置 `make.conf` 就像為你的新系統設定了「構建藍圖」，決定了軟件如何編譯、使用哪些功能以及從哪裡下載。

</div>

### 5.1 同步樹

```bash
emerge-webrsync   # 獲取最新的 Portage 快照 (比 rsync 快)
emerge --sync     # 同步 Portage 樹 (獲取最新 ebuild)
emerge --ask app-editors/vim # 安裝 Vim 編輯器 (推薦)
eselect editor list          # 列出可用編輯器
eselect editor set vi        # 將 Vim 設置為默認編輯器 (vi 通常是指向 vim 的軟鏈接)
```

設置鏡像（擇一）：
```bash
mirrorselect -i -o >> /etc/portage/make.conf
# 或手動：
#以 TWAREN 鏡像站為例
echo 'GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"' >> /etc/portage/make.conf
```

### 5.2 make.conf 範例 {#52-makeconf-範例}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - USE 標誌](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/USE/zh-cn) · [/etc/portage/make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

</div>

編輯 `/etc/portage/make.conf`：
```bash
vim /etc/portage/make.conf
```

**懶人/新手配置（複製粘貼）**：
<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

請根據你的 CPU 核心數修改 `MAKEOPTS` 中的 `-j` 參數（例如 8 核 CPU 使用 `-j8`）。

</div>

```conf
# ========== 編譯優化參數 ==========
# -march=native: 針對當前 CPU 架構優化，獲得最佳性能
# -O2: 推薦的優化級別，平衡性能與編譯時間
# -pipe: 使用管道加速編譯過程
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"    # C 編譯器選項
CXXFLAGS="${COMMON_FLAGS}"  # C++ 編譯器選項
FCFLAGS="${COMMON_FLAGS}"   # Fortran 編譯器選項
FFLAGS="${COMMON_FLAGS}"    # Fortran 77 編譯器選項

# ========== 並行編譯設置 ==========
# -j 後面的數字 = CPU 線程數（運行 nproc 查看）
# 內存不足時可適當減少（如 -j4）
MAKEOPTS="-j8"

# ========== 語言與本機化 ==========
# LC_MESSAGES=C: 保持編譯輸出為英文，便於搜索錯誤信息
LC_MESSAGES=C
# L10N/LINGUAS: 支持的語言（影響軟件翻譯和文檔）
L10N="en en-US zh zh-CN zh-TW"
LINGUAS="en en_US zh zh_CN zh_TW"

# ========== 鏡像源設置 ==========
# 國內推薦：BFSU、TUNA、USTC 等
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# ========== USE 標誌 ==========
# systemd: 使用 systemd 作為 init（若用 OpenRC 改為 -systemd）
# dist-kernel: 使用發行版內核，新手推薦
# networkmanager: 網路管理工具
# bluetooth: 藍牙支援（若不使用藍牙可移除）
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"

# ========== 許可證設置 ==========
# "*" 接受所有許可證（包括非自由軟體/專有軟體）
# 警告：接受所有許可證意味著您同意安裝閉源軟體，如需僅使用自由軟體請改為 "@FREE"
# 詳細說明見進階篇 13.12 節
ACCEPT_LICENSE="*"
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**詳細配置說明**

如需查看包含完整註釋的 `make.conf` 配置範例，請參閱 [進階篇 13.11 節：詳細配置範例](/posts/2025-11-25-gentoo-install-advanced/#1311-詳細配置範例完整註釋版)。

該範例包含：
- 每個配置項的詳細說明和推薦值
- 針對不同硬件的調整建議
- USE 標誌的功能說明
- FEATURES 和日誌配置示例

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

- `MAKEOPTS="-j32"` 的數字應該是你的 CPU 線程數，可通過 `nproc` 命令查看
- 如果編譯時內存不足，可以減少並行任務數（如改為 `-j16`）
- USE 標誌是 Gentoo 的核心特性，決定了軟件編譯時包含哪些功能

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**進階配置**

- **ACCEPT_LICENSE 許可證管理**：詳見 [進階篇 13.12 節](/posts/2025-11-25-gentoo-install-advanced/#1312-accept_license-軟件許可證詳解)
- **CPU 指令集優化 (CPU_FLAGS_X86)**：詳見 [進階篇 13.13 節](/posts/2025-11-25-gentoo-install-advanced/#1313-cpu-指令集優化-cpu_flags_x86)

</div>

### 5.3 配置 CPU 指令集優化 {#53-配置-cpu-指令集優化}

為了讓 Portage 知道你的 CPU 支持哪些特定指令集（如 AES, AVX, SSE4.2 等），我們需要配置 `CPU_FLAGS_X86`。

安裝檢測工具：
```bash
emerge --ask app-portage/cpuid2cpuflags
```

運行檢測並寫入配置：
```bash
cpuid2cpuflags >> /etc/portage/make.conf
```

檢查 `/etc/portage/make.conf` 末尾，你應該會看到類似這樣的一行：
```conf
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**說明**

更多關於 CPU 指令集優化的詳細信息，請參閱 [進階篇 13.13 節](/posts/2025-11-25-gentoo-install-advanced/#1313-cpu-指令集優化-cpu_flags_x86)。

</div>

---

### 5.4 可選：啟用 Binary Package Host（二進制包主機）

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: Binary Package Host](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Adding_a_binary_package_host) · [Binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼使用 Binary Package Host？**

自 2023 年 12 月起，Gentoo [官方提供二進制包主機](https://www.gentoo.org/news/2023/12/29/Gentoo-binary.html)（binhost），可大幅縮短安裝時間：
- **LLVM / Clang**：從 2-3 小時縮短到 5 分鐘
- **Rust**：從 1-2 小時縮短到 3 分鐘
- **Firefox / Chromium**：從數小時縮短到 10 分鐘

所有二進制包均經過 **加密簽章驗證**，確保安全性。

</div>

#### 配置 Binary Package Host

**步驟 1：配置倉庫**

創建 binhost 配置文件：
```bash
mkdir -p /etc/portage/binrepos.conf
vim /etc/portage/binrepos.conf/gentoobinhost.conf
```

加入以下內容（根據你的 **Profile** 選擇對應路徑）：

<details>
<summary><b>OpenRC 桌面配置（點擊展開）</b></summary>

```conf
# /etc/portage/binrepos.conf/gentoobinhost.conf
[binhost]
priority = 9999
sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64/
```

</details>

<details>
<summary><b>systemd 桌面配置（點擊展開）</b></summary>

```conf
# /etc/portage/binrepos.conf/gentoobinhost.conf
[binhost]
priority = 9999
sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64-systemd/
```

</details>

<details>
<summary><b>如何選擇正確的路徑？（點擊展開）</b></summary>

查看你當前的 profile：
```bash
eselect profile show
```

根據輸出選擇對應路徑：
| Profile 類型 | sync-uri 路徑 |
|------------|--------------|
| `default/linux/amd64/23.0` | `.../23.0/x86-64/` |
| `default/linux/amd64/23.0/systemd` | `.../23.0/x86-64-systemd/` |
| `default/linux/amd64/23.0/desktop` | `.../23.0/x86-64-v3/` |
| `default/linux/amd64/23.0/desktop/systemd` | `.../23.0/x86-64-v3-systemd/` |

**注意**：桌面 profile 通常使用 `x86-64-v3`（需要 AVX、AVX2 等指令集），伺服器 profile 使用 `x86-64`。

</details>

**步驟 2：啟用二進制包功能**

編輯 `/etc/portage/make.conf`，加入：
```bash
# 啟用二進制包下載與簽章驗證
FEATURES="${FEATURES} getbinpkg binpkg-request-signature"

# emerge 默認使用二進制包（可選，推薦新手啟用）
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --getbinpkg"
```

**步驟 3：獲取簽章密鑰**

運行以下命令，讓 Portage 設置驗證所需的密鑰環：
```bash
getuto
```

#### 驗證配置

測試是否正確配置：
```bash
emerge --pretend --getbinpkg sys-apps/portage
```

若輸出包含 `[binary]` 字樣，說明配置成功：
```
[ebuild   R    ] sys-apps/portage-3.0.61::gentoo [binary]
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**使用提示**

- **優先使用二進制包**：如上配置後，emerge 會自動優先使用二進制包
- **強制從源碼編譯**：`emerge --usepkg=n <套件名>`
- **僅使用二進制包**：`emerge --usepkgonly <套件名>`
- **查看可用二進制包**：訪問 [Gentoo Binhost Browser](https://distfiles.gentoo.org/releases/amd64/binpackages/)

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1rem 0;">

**注意事項**

- 若你的 **USE 標誌**或**編譯參數**與官方預設不同，Portage 會自動回退到源碼編譯
- 二進制包使用官方的**通用配置**，可能無法完全發揮你的 CPU 性能優勢（`-march=native` 的特定優化）
- 建議**初次安裝時使用 binhost**，系統穩定後根據需要調整 USE 標誌並重新編譯關鍵套件

</div>

---

## 6. Profile、系統設置與本機化 {#step-6-system}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 基本系統](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Profile 定義了系統的基礎配置和預設 USE 旗標，是 Gentoo 靈活性的體現。配置時區、語言和網絡等基本系統參數，是讓你的 Gentoo 系統能夠正常運作並符合個人使用習慣的關鍵。

</div>

### 6.1 選擇 Profile

```bash
eselect profile list          # 列出所有可用 Profile
eselect profile set <編號>    # 設置選定的 Profile
emerge -avuDN @world          # 更新系統以匹配新 Profile (a:詢問 v:詳細 u:升級 D:深層依賴 N:新USE)
```

常見選項：
- `default/linux/amd64/23.0/desktop/plasma/systemd`
- `default/linux/amd64/23.0/desktop/gnome/systemd`
- `default/linux/amd64/23.0/desktop`（OpenRC 桌面）

### 6.2 時區與語言

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Wiki: Localization/Guide](https://wiki.gentoo.org/wiki/Localization/Guide/zh-cn)

</div>

```bash
echo "Asia/Shanghai" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen                      # 生成選定的語言環境
eselect locale set en_US.utf8   # 設置系統默認語言 (建議用英文以免亂碼)

# 重新加載環境
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

### 6.3 主機名與網絡設置

**設置主機名**：
```bash
echo "gentoo" > /etc/hostname
```

**網絡管理工具選擇**：

**方案 A：NetworkManager (推薦，通用)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[NetworkManager](https://wiki.gentoo.org/wiki/NetworkManager)

</div>

適合大多數桌面用戶，同時支持 OpenRC 和 systemd。
```bash
emerge --ask net-misc/networkmanager
# OpenRC:
rc-update add NetworkManager default
# systemd:
systemctl enable NetworkManager
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**配置提示**

**圖形界面**：運行 `nm-connection-editor`  
**命令行**：使用 `nmtui` (圖形化嚮導) 或 `nmcli`

</div>

<details>
<summary><b>進階提示：使用 iwd 後端（點擊展開）</b></summary>

NetworkManager 支持使用 `iwd` 作為後端（比 wpa_supplicant 更快）。

```bash
echo "net-misc/networkmanager iwd" >> /etc/portage/package.use/networkmanager
emerge --ask --newuse net-misc/networkmanager
```
之後編輯 `/etc/NetworkManager/NetworkManager.conf`，在 `[device]` 下添加 `wifi.backend=iwd`。

</details>

<details>
<summary><b>方案 B：輕量方案（點擊展開）</b></summary>

如果你不想使用 NetworkManager，可以選擇以下輕量級方案：

1. **有線網絡 (dhcpcd)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[dhcpcd](https://wiki.gentoo.org/wiki/Dhcpcd)

</div>

   ```bash
   emerge --ask net-misc/dhcpcd
   # OpenRC:
   rc-update add dhcpcd default
   # systemd:
   systemctl enable dhcpcd
   ```

2. **無線網絡 (iwd)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[iwd](https://wiki.gentoo.org/wiki/Iwd)

</div>

   ```bash
   emerge --ask net-wireless/iwd
   # OpenRC:
   rc-update add iwd default
   # systemd:
   systemctl enable iwd
   ```
   
> **提示**：iwd 是一個現代、輕量級的無線守護進程。

</details>

<details>
<summary><b>方案 3：原生方案（點擊展開）</b></summary>

使用 init 系統自帶的網絡管理功能，適合服務器或極簡環境。

**OpenRC 網卡服務**：
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[OpenRC](https://wiki.gentoo.org/wiki/OpenRC) · [OpenRC: Network Management](https://wiki.gentoo.org/wiki/OpenRC#Network_management)

</div>

```bash
vim /etc/conf.d/net
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

請將下文中的 `enp5s0` 替換為你實際的網卡接口名稱（通過 `ip link` 查看）。

</div>

寫入以下內容：
```conf
config_enp5s0="dhcp"
```

```bash
ln -s /etc/init.d/net.lo /etc/init.d/net.enp5s0 # 創建網卡服務軟鏈接
rc-update add net.enp5s0 default                # 設置開機自啟
```

---

**Systemd 原生網卡服務**：
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[systemd-networkd](https://wiki.gentoo.org/wiki/Systemd/systemd-networkd) · [systemd-resolved](https://wiki.gentoo.org/wiki/Systemd/systemd-resolved) · [Systemd](https://wiki.gentoo.org/wiki/Systemd) · [Systemd: Network](https://wiki.gentoo.org/wiki/Systemd#Network)

</div>

Systemd 自帶了網絡管理功能，適合服務器或極簡環境：
```bash
systemctl enable systemd-networkd
systemctl enable systemd-resolved
```
*注意：需要手動編寫 .network 配置文件。*

</details>



### 6.4 配置 fstab

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - fstab](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/zh-cn) · [Gentoo Wiki: /etc/fstab](https://wiki.gentoo.org/wiki//etc/fstab/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

系統需要知道啟動時要掛載哪些分區。`/etc/fstab` 文件就像一張"分區清單"，告訴系統：

- 哪些分區需要在啟動時自動掛載
- 每個分區掛載到哪個目錄
- 使用什麼文件系統類型

**推薦使用 UUID**：設備路徑（如 `/dev/sda1`）可能因硬件變化而改變，但 UUID 是文件系統的唯一標識符，永遠不變。

</div>

---

#### 方法 A：使用 genfstab 自動生成（推薦）

<details>
<summary><b>點擊展開查看詳細步驟</b></summary>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**安裝 genfstab**

`genfstab` 包含在 `sys-fs/genfstab` 包中（源自 Arch Linux 的 `arch-install-scripts`）。

- **Gig-OS / Arch LiveISO**：已預裝，可直接使用
- **Gentoo Minimal ISO**：需要先安裝 `emerge --ask sys-fs/genfstab`

</div>

<details>
<summary><b>genfstab 參數說明</b></summary>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

| 參數 | 說明 | 推薦度 |
|------|------|--------|
| `-U` | 使用文件系統 **UUID** 標識 | 推薦 |
| `-L` | 使用文件系統 **LABEL** 標識 | 需預設標籤 |
| `-t PARTUUID` | 使用 GPT 分區 **PARTUUID** | GPT 專用 |
| 無參數 | 使用設備路徑（`/dev/sdX`） | 不推薦 |

**推薦使用 `-U` 參數**，UUID 是文件系統的唯一標識符，不會因磁盤順序變化而改變。

</div>

</details>

**標準用法（在 chroot 外執行）：**

```bash
# 1. 確認所有分區已正確掛載
lsblk
mount | grep /mnt/gentoo

# 2. 生成 fstab（使用 UUID）
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab

# 3. 檢查生成的文件
cat /mnt/gentoo/etc/fstab
```

<details>
<summary><b>chroot 環境下的替代方案</b></summary>

如果你已經 chroot 進入了新系統（`/mnt/gentoo` 變成了 `/`），有以下幾種方法：

**方法一：在 chroot 內執行（最簡單）**

```bash
# 在 chroot 內安裝
emerge --ask sys-fs/genfstab

# 直接對根目錄生成
genfstab -U / >> /etc/fstab

# 檢查並清理多餘條目（可能包含 /proc、/sys、/dev 等）
vim /etc/fstab
```

**方法二：開啟新終端窗口（LiveGUI）**

如果使用 Gig-OS 等帶圖形界面的 Live 環境，直接開啟新終端窗口（默認在 Live 環境中）：

```bash
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```

**方法三：使用 TTY 切換（Minimal ISO）**

1. 按 `Ctrl+Alt+F2` 切換到新 TTY（Live 環境）
2. 安裝並執行：
   ```bash
   emerge --ask sys-fs/genfstab
   genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
   ```
3. 按 `Ctrl+Alt+F1` 切回 chroot 環境

</details>

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**genfstab 兼容性說明**

[`genfstab`](https://wiki.archlinux.org/title/Genfstab) 工具會自動檢測當前掛載點下的所有文件系統，[原始碼](https://github.com/glacion/genfstab/blob/master/genfstab)中明確支持：

- **Btrfs 子卷**：自動識別 `subvol=` 參數（不會誤判為 bind mount）
- **LUKS 加密分區**：自動使用解密後設備（`/dev/mapper/xxx`）的 UUID
- **普通分區**：ext4、xfs、vfat 等常規文件系統

**前提條件**：在執行 `genfstab` 之前，必須確保所有分區已正確掛載（包括 Btrfs 子卷和已解密的 LUKS 分區）。

</div>

</details>

---

#### 方法 B：手動編輯

<details>
<summary><b>點擊展開手動配置方法</b></summary>

如果不使用 `genfstab`，可以手動編輯 `/etc/fstab`。

**1. 獲取分區 UUID**

```bash
blkid
```

輸出示例：
```text
/dev/nvme0n1p1: UUID="7E91-5869" TYPE="vfat" PARTLABEL="EFI"
/dev/nvme0n1p2: UUID="7fb33b5d-..." TYPE="swap" PARTLABEL="swap"
/dev/nvme0n1p3: UUID="8c08f447-..." TYPE="xfs" PARTLABEL="root"
```

**2. 編輯 fstab**

```bash
vim /etc/fstab
```

**基礎配置示例（ext4/xfs）：**

```fstab
# <UUID>                                   <掛載點>     <類型> <選項>            <dump> <fsck>
UUID=7E91-5869                             /efi         vfat   defaults,noatime  0      2
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none         swap   sw                0      0
UUID=8c08f447-c79c-4fda-8c08-f447c79ce690  /            xfs    defaults,noatime  0      1
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

**fstab 字段說明**

| 字段 | 說明 |
|------|------|
| UUID | 分區的唯一標識符（通過 `blkid` 獲取） |
| 掛載點 | 文件系統掛載位置（swap 使用 `none`） |
| 類型 | 文件系統類型：`vfat`、`ext4`、`xfs`、`btrfs`、`swap` |
| 選項 | 掛載選項，多個用逗號分隔 |
| dump | 備份標誌，通常為 `0` |
| fsck | 啟動時檢查順序：`1`=根分區，`2`=其他，`0`=不檢查 |

</div>

</details>

---

<details>
<summary><b>Btrfs 子卷配置</b></summary>

**genfstab 自動生成：**

只要 Btrfs 子卷已正確掛載，`genfstab -U` 會自動識別並生成包含 `subvol=` 的配置。

```bash
# 確認子卷掛載情況
mount | grep btrfs
# 輸出示例：/dev/nvme0n1p3 on /mnt/gentoo type btrfs (rw,noatime,compress=zstd:3,subvol=/@)

# 自動生成
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```

**手動配置示例：**

```fstab
# Root 子卷
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /       btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@       0 0

# Home 子卷（同一 UUID，不同子卷）
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /home   btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@home   0 0

# Swap（獨立分區）
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none    swap   sw                                                                            0 0

# EFI 分區
UUID=7E91-5869                             /efi    vfat   defaults,noatime,fmask=0022,dmask=0022                                        0 2
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

**Btrfs 常用掛載選項**

| 選項 | 說明 |
|------|------|
| `compress=zstd:3` | zstd 壓縮，級別 3（推薦，平衡性能與壓縮率） |
| `discard=async` | 異步 TRIM（SSD 推薦） |
| `space_cache=v2` | v2 版空間緩存（默認啟用，性能更好） |
| `subvol=@` | 指定掛載的子卷 |
| `noatime` | 不記錄訪問時間（提升性能） |

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

- 同一 Btrfs 分區的所有子卷使用**相同的 UUID**
- 務必使用 `blkid` 獲取你實際的 UUID

</div>

</details>

<details>
<summary><b>LUKS 加密分區配置</b></summary>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**關鍵點**

fstab 必須使用**解密後映射設備**的 UUID（`/dev/mapper/xxx`），而非 LUKS 容器的 UUID。

</div>

**genfstab 自動生成：**

`genfstab` 會自動檢測解密後的設備並使用正確的 UUID：

```bash
# 確認 LUKS 已解密
lsblk
# 應看到類似：nvme0n1p3 → cryptroot → 掛載點

# 自動生成（會使用 /dev/mapper/cryptroot 的 UUID）
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```

**手動配置：區分兩種 UUID**

```bash
blkid
```

```text
# LUKS 容器（TYPE="crypto_LUKS"）- 不要用這個！
/dev/nvme0n1p3: UUID="562d0251-..." TYPE="crypto_LUKS"

# 解密後設備（TYPE="btrfs"）- 用這個！
/dev/mapper/cryptroot: UUID="7b44c5eb-..." TYPE="btrfs"
```

**手動配置示例（Btrfs on LUKS）：**

```fstab
# Root（使用解密後設備 /dev/mapper/cryptroot 的 UUID）
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /       btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@       0 0

# Home（同一加密分區的不同子卷，UUID 相同）
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /home   btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@home   0 0

# Swap（獨立分區或加密 swap）
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none    swap   sw                                                                            0 0

# EFI（不加密）
UUID=7E91-5869                             /efi    vfat   defaults,noatime,fmask=0022,dmask=0022                                        0 2
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

**常見問題**

**Q: 為什麼不能用 LUKS 容器的 UUID？**  
A: LUKS 容器是加密的原始數據，系統無法讀取其中的文件系統。必須先解密，解密後的 `/dev/mapper/xxx` 才有可識別的文件系統和 UUID。

**Q: `discard=async` 在 LUKS 上安全嗎？**  
A: LUKS2 + `discard` 是安全的。若極度在意安全性，可移除此選項（會降低 SSD 性能）。

</div>

</details>

</details>

---

## 7. 內核與韌體 {#step-7-kernel}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 配置 Linux 內核](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

內核是操作系統的核心，負責管理硬件。Gentoo 允許你手動裁剪內核，只保留你需要的驅動，從而獲得極致的性能和精簡的體積。新手也可以選擇預編譯內核快速上手。

</div>

### 7.1 快速方案：預編譯內核

```bash
emerge --ask sys-kernel/gentoo-kernel-bin
```

內核升級後記得重新生成引導程式配置。

<details>
<summary><b>進階設置：手動編譯內核 (Gentoo 核心體驗)（點擊展開）</b></summary>

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**新手提示**

編譯內核比較複雜且耗時。如果你想盡快體驗 Gentoo，可以先跳過本節，使用 7.1 的預編譯內核。

</div>

手動編譯內核能讓你完全掌控系統功能，移除不需要的驅動，獲得更精簡、高效的內核。

**快速開始**（使用 Genkernel 自動化）：
```bash
emerge --ask sys-kernel/gentoo-sources sys-kernel/genkernel
genkernel --install all  # 自動編譯並安裝內核、模塊和 initramfs
# --install: 編譯完成後自動安裝到 /boot 目錄
# all: 完整構建 (內核 + 模塊 + initramfs)
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**進階內容**

如果你想深入瞭解內核配置、使用 LLVM/Clang 編譯內核、啟用 LTO 優化等高級選項，請參考 **[Section 16.0 內核編譯進階指南](/posts/2025-11-25-gentoo-install-advanced/#section-16-kernel-advanced)**。

</div>

</details>

### 7.3 安裝韌體與微碼

```bash
mkdir -p /etc/portage/package.license
# 同意 Linux 韌體的授權條款
echo 'sys-kernel/linux-firmware linux-fw-redistributable no-source-code' > /etc/portage/package.license/linux-firmware
echo 'sys-kernel/installkernel dracut' > /etc/portage/package.use/installkernel
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-firmware/intel-microcode  # Intel CPU
```

<div style="background: linear-gradient(135deg, rgba(251, 191, 36, 0.1), rgba(245, 158, 11, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0; border-left: 3px solid rgb(251, 191, 36);">

**關於 package.license 的說明**

你可能注意到前面 make.conf 範例中已經設置了 `ACCEPT_LICENSE="*"`，為什麼這裡還要單獨為 linux-firmware 創建 package.license 文件？

- **make.conf 只是範例**：實際使用中，很多用戶會根據自己的需求修改 `ACCEPT_LICENSE`，比如設置為 `@FREE` 只接受自由軟件許可證
- **顯式聲明更清晰**：單獨的 package.license 文件明確記錄了哪些軟件包需要特殊許可證，便於日後維護和審計
- **最佳實踐**：即使全局設置了 `ACCEPT_LICENSE="*"`，為特定軟件包創建 license 文件也是 Gentoo 社區推薦的做法，這樣在將來調整全局許可證策略時，不會意外阻止關鍵軟件包的安裝

</div>

---

## 8. 基礎工具 {#step-8-base-packages}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝必要的系統工具](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Stage3 只有最基礎的命令。我們需要補充系統日誌、網絡管理、文件系統工具等必要組件，才能讓系統在重啟後正常工作。

</div>

### 8.1 系統服務工具

<details>
<summary><b>OpenRC 用戶配置（點擊展開）</b></summary>

**1. 系統日誌**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Syslog-ng](https://wiki.gentoo.org/wiki/Syslog-ng)

</div>

```bash
emerge --ask app-admin/syslog-ng
rc-update add syslog-ng default
```

**2. 定時任務**

```bash
emerge --ask sys-process/cronie
rc-update add cronie default
```

**3. 時間同步**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) · [System Time (OpenRC)](https://wiki.gentoo.org/wiki/System_time/zh-cn#OpenRC)

</div>

```bash
emerge --ask net-misc/chrony
rc-update add chronyd default
```

</details>

<details>
<summary><b>systemd 用戶配置（點擊展開）</b></summary>

systemd 已內置日誌與定時任務服務，無需額外安裝。

**時間同步**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) · [System Time (systemd)](https://wiki.gentoo.org/wiki/System_time/zh-cn#systemd)

</div>

```bash
systemctl enable --now systemd-timesyncd
```

</details>

### 8.2 文件系統工具

根據你使用的文件系統安裝對應工具（必選）：

```bash
emerge --ask sys-fs/e2fsprogs  # ext4
emerge --ask sys-fs/xfsprogs   # XFS
emerge --ask sys-fs/dosfstools # FAT/vfat (EFI 分區需要)
emerge --ask sys-fs/btrfs-progs # Btrfs
```

## 9. 建立用戶與權限 {#step-9-users}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 結束安裝](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Linux 不建議日常使用 root 賬戶。我們需要創建一個普通用戶，並賦予其使用 `sudo` 的權限，以提高系統安全性。

</div>

```bash
passwd root # 設置 root 密碼
useradd -m -G wheel,video,audio,plugdev zakk # 創建用戶並加入常用組
passwd zakk # 設置用戶密碼
emerge --ask app-admin/sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel # 允許 wheel 組使用 sudo
```

若使用 systemd，可視需求將賬號加入 `network`、`lp` 等群組。

---




## 10. 安裝引導程式 {#step-10-bootloader}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 配置引導加載程式](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader/zh-cn)

</div>

### 10.1 GRUB

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[GRUB](https://wiki.gentoo.org/wiki/GRUB/zh-cn)

</div>

```bash
emerge --ask sys-boot/grub:2
mkdir -p /efi/EFI/Gentoo
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo # 安裝 GRUB 到 ESP
# 安裝 os-prober 以支持多系統檢測
emerge --ask sys-boot/os-prober

# 啟用 os-prober（用於檢測 Windows 等其他操作系統）
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# 生成 GRUB 配置文件
grub-mkconfig -o /boot/grub/grub.cfg
```

<details>
<summary><b>進階設置：systemd-boot（僅限 UEFI）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[systemd-boot](https://wiki.gentoo.org/wiki/Systemd/systemd-boot/zh-cn)

**注意**：部分 ARM/RISC-V 設備的韌體可能不支持完整的 UEFI 規範，無法使用 systemd-boot。

</div>

```bash
bootctl --path=/efi install # 安裝 systemd-boot

# 1. 創建 Gentoo 引導項
vim /efi/loader/entries/gentoo.conf
```

寫入以下內容（**注意替換 UUID**）：
```conf
title   Gentoo Linux
linux   /vmlinuz-6.6.62-gentoo-dist
initrd  /initramfs-6.6.62-gentoo-dist.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw quiet
```
<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果你使用了 LUKS 加密，options 行需要添加 `rd.luks.uuid=...` 等參數。

</div>

**2. 更新引導項**：
每次更新內核後，需要手動更新 `gentoo.conf` 中的版本號，或者使用腳本自動化。

**2. 創建 Windows 引導項 (雙系統)**

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

如果你創建了新的 EFI 分區，請記得將原 Windows EFI 文件 (EFI/Microsoft) 複製到新分區。

</div>

```bash
vim /efi/loader/entries/windows.conf
```

寫入以下內容：
```ini
title      Windows 11
sort-key   windows-01
efi        /EFI/Microsoft/Boot/bootmgfw.efi
```

# 3. 配置默認引導
```bash
vim /efi/loader/loader.conf
```

寫入以下內容：

```ini
default gentoo.conf
timeout 3
console-mode auto
```

</details>

<details>
<summary><b>進階設置：加密支持（僅加密用戶）（點擊展開）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果你在步驟 3.4 中選擇了加密分區，才需要執行此步驟。

</div>

**步驟 1：啟用 systemd cryptsetup 支持**

```bash
mkdir -p /etc/portage/package.use
echo "sys-apps/systemd cryptsetup" >> /etc/portage/package.use/fde

# 重新編譯 systemd 以啟用 cryptsetup 支持
emerge --ask --oneshot sys-apps/systemd
```

**步驟 2：獲取 LUKS 分區的 UUID**

```bash
# 獲取 LUKS 加密容器的 UUID（不是裡面的文件系統 UUID）
blkid /dev/nvme0n1p3
```

輸出示例：
```text
/dev/nvme0n1p3: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" ...
```
記下這個 **LUKS UUID**（例如：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）。

**步驟 3：配置 GRUB 內核參數**

```bash
vim /etc/default/grub
```

加入或修改以下內容（**替換 UUID 為實際值**）：

```bash
# 完整示例（替換 UUID 為你的實際 UUID）
GRUB_CMDLINE_LINUX="rd.luks.uuid=<LUKS-UUID> rd.luks.allow-discards root=UUID=<ROOT-UUID> rootfstype=btrfs"
```

**參數說明**：
- `rd.luks.uuid=<UUID>`：LUKS 加密分區的 UUID（使用 `blkid /dev/nvme0n1p3` 獲取）
- `rd.luks.allow-discards`：允許 SSD TRIM 指令穿透加密層（提升 SSD 性能）
- `root=UUID=<UUID>`：解密後的 btrfs 文件系統 UUID（使用 `blkid /dev/mapper/gentoo-root` 獲取）
- `rootfstype=btrfs`：根文件系統類型（如果使用 ext4 改為 `ext4`）

<details>
<summary><b>步驟 3.1（替代方案）：配置內核參數 (systemd-boot 方案)（點擊展開）</b></summary>

如果你使用 systemd-boot 而不是 GRUB，請編輯 `/boot/loader/entries/` 下的配置文件（例如 `gentoo.conf`）：

```conf
title      Gentoo Linux
version    6.6.13-gentoo
options    rd.luks.name=<LUKS-UUID>=cryptroot root=/dev/mapper/cryptroot rootfstype=btrfs rd.luks.allow-discards init=/lib/systemd/systemd
linux      /vmlinuz-6.6.13-gentoo
initrd     /initramfs-6.6.13-gentoo.img
```

**參數說明**：
- `rd.luks.name=<LUKS-UUID>=cryptroot`：指定 LUKS 分區 UUID 並映射為 `cryptroot`。
- `root=/dev/mapper/cryptroot`：指定解密後的根分區設備。
- `rootfstype=btrfs`：指定根文件系統類型。

</details>

**步驟 4：安裝並配置 dracut**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Dracut](https://wiki.gentoo.org/wiki/Dracut) · [Initramfs](https://wiki.gentoo.org/wiki/Initramfs)

</div>

```bash
# 安裝 dracut（如果還沒安裝）
emerge --ask sys-kernel/dracut
```

**步驟 5：配置 dracut for LUKS 解密**

創建 dracut 配置文件：

```bash
vim /etc/dracut.conf.d/luks.conf
```

加入以下內容：

```conf
# 不要在這裡設置 kernel_cmdline，GRUB 會覆蓋它
kernel_cmdline=""
# 添加必要的模塊支持 LUKS + btrfs
add_dracutmodules+=" btrfs systemd crypt dm "
# 添加必要的工具
install_items+=" /sbin/cryptsetup /bin/grep "
# 指定文件系統（如果使用其他文件系統請修改）
filesystems+=" btrfs "
```

**配置說明**：
- `crypt` 和 `dm` 模塊提供 LUKS 解密支持
- `systemd` 模塊用於 systemd 啟動環境
- `btrfs` 模塊支持 btrfs 文件系統（如果使用 ext4 改為 `ext4`）

### 步驟 6：配置 /etc/crypttab（可選但推薦）

```bash
vim /etc/crypttab
```

加入以下內容（**替換 UUID 為你的 LUKS UUID**）：
```conf
gentoo-root UUID=<LUKS-UUID> none luks,discard
```
這樣配置後，系統會自動識別並提示解鎖加密分區。

### 步驟 7：重新生成 initramfs

```bash
# 重新生成 initramfs（包含 LUKS 解密模塊）
dracut --kver $(make -C /usr/src/linux -s kernelrelease) --force
# --kver: 指定內核版本
# $(make -C /usr/src/linux -s kernelrelease): 自動獲取當前內核版本號
# --force: 強制覆蓋已存在的 initramfs 文件
```

> **重要**：每次更新內核後，也需要重新執行此命令生成新的 initramfs！

### 步驟 8：更新 GRUB 配置

```bash
grub-mkconfig -o /boot/grub/grub.cfg

# 驗證 initramfs 被正確引用
grep initrd /boot/grub/grub.cfg
```

</details>



---

## 11. 重啟前檢查清單與重啟 {#step-11-reboot}

1. `emerge --info` 正常執行無錯誤
2. `/etc/fstab` 中的 UUID 正確（使用 `blkid` 再確認）
3. 已設定 root 與一般用戶密碼
4. 已執行 `grub-mkconfig` 或完成 `bootctl` 配置
5. 若使用 LUKS，確認 initramfs 含有 `cryptsetup`

離開 chroot 並重啟：
```bash
exit
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
swapoff -a
reboot
```

---

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**恭喜！** 你已經完成了 Gentoo 的基礎安裝。

**下一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)

</div>
