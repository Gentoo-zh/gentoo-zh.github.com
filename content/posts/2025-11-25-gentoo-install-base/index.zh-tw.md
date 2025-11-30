---
title: "Gentoo Linux 安裝指南 (基礎篇)"
date: 2025-11-25
summary: "Gentoo Linux 基礎系統安裝教學，涵蓋分割區、Stage3、核心編譯、引導程式配置等。也突出有 LUKS 全碟加密教學。"
description: "2025 年最新 Gentoo Linux 安裝指南 (基礎篇)，詳細講解 UEFI 安裝流程、核心編譯等。適合 Linux 進階使用者和 Gentoo 新手。也突出有 LUKS 全碟加密教學。"
keywords:
  - Gentoo Linux
  - Linux 安裝
  - 原始碼編譯
  - systemd
  - OpenRC
  - Portage
  - make.conf
  - 核心編譯
  - UEFI 安裝
tags:
  - Gentoo
  - Linux
  - 教學
  - 系統安裝
categories:
  - tutorial
authors:
  - zakkaus
---

> **文章特別說明**
>
> 本文是 **Gentoo Linux 安裝指南** 系列的第一部分：**基礎安裝**。
>
> **系列導航**：
> 1. **基礎安裝（本文）**：從零開始安裝 Gentoo 基礎系統
> 2. [桌面配置](/zh-tw/posts/2025-11-25-gentoo-install-desktop/)：顯示卡驅動、桌面環境、輸入法等
> 3. [進階優化](/zh-tw/posts/2025-11-25-gentoo-install-advanced/)：make.conf 優化、LTO、系統維護
>
> **建議閱讀方式**：
> - 按需閱讀：基礎安裝（0-11 節）→ 桌面配置（12 節）→ 進階優化（13-17 節）
>
> ---
>
> ### 關於本指南
>
> 本文旨在提供一個完整的 Gentoo 安裝流程演示，並**密集提供可供學習的參考文獻**。文章中包含大量官方 Wiki 連結和技術文件，幫助讀者深入理解每個步驟的原理和配置細節。
>
> **這不是一份簡單的傻瓜式教程，而是一份引導性的學習資源**——使用 Gentoo 的第一步是學會自己閱讀 Wiki 並解決問題，善用 Google 甚至 AI 工具尋找答案。遇到問題或需要深入了解時，請務必查閱官方手冊和本文提供的參考連結。
>
> 如果在閱讀過程中遇到疑問或發現問題，歡迎透過以下管道提出：
> - **Gentoo 中文社群**：[Telegram 群組](https://t.me/gentoo_zh) | [Telegram 頻道](https://t.me/gentoocn) | [GitHub](https://github.com/Gentoo-zh)
> - **官方社群**：[Gentoo Forums](https://forums.gentoo.org/) | IRC: #gentoo @ Libera.Chat
>
> **非常建議以官方手冊為準**：
> - [Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)
> - [Gentoo Handbook: AMD64 (簡體中文)](https://wiki.gentoo.org/wiki/Handbook:AMD64/zh-cn)

> 本文為新遷移內容，如有不足之處敬請見諒。
>
> ---

## 什麼是 Gentoo？

Gentoo Linux 是一個基於原始碼的 Linux 發行版，以其**高度可客製化**和**效能優化**著稱。與其他發行版不同，Gentoo 讓你從原始碼編譯所有軟體，這意味著：

- **極致效能**：所有軟體針對你的硬體優化編譯
- **完全掌控**：你決定系統包含什麼，不包含什麼
- **深度學習**：透過親手構建系統深入理解 Linux
- **編譯時間**：初次安裝需要較長時間（建議預留 3-6 小時）
- **學習曲線**：需要一定的 Linux 基礎知識

**適合誰？**
- 想要深入學習 Linux 的技術愛好者
- 追求系統效能和客製化的使用者
- 享受 DIY 過程的 Geek

**不適合誰？**
- 只想快速安裝使用的新手（建議先嘗試 Ubuntu、Fedora 等）
- 沒有時間折騰系統的使用者

<details>
<summary><b>核心概念速覽（點擊展開）</b></summary>

在開始安裝前，先了解幾個核心概念：

**Stage3** ([Wiki](https://wiki.gentoo.org/wiki/Stage_file))
一個最小化的 Gentoo 基礎系統壓縮包。它包含了構建完整系統的基礎工具鏈（編譯器、函式庫等）。你將解壓它到硬碟上，作為新系統的「地基」。

**Portage** ([Wiki](https://wiki.gentoo.org/wiki/Portage/zh-cn))
Gentoo 的套件管理系統。它不直接安裝預編譯的軟體包，而是下載原始碼、根據你的設定編譯，然後安裝。核心命令是 `emerge`。

**USE Flags** ([Wiki](https://wiki.gentoo.org/wiki/USE_flag/zh-cn))
控制軟體功能的開關。例如，`USE="bluetooth"` 會讓所有支援藍牙的軟體在編譯時啟用藍牙功能。這是 Gentoo 客製化的核心。

**Profile** ([Wiki](https://wiki.gentoo.org/wiki/Profile_(Portage)))
預設的系統設定範本。例如 `desktop/plasma/systemd` profile 會自動啟用適合 KDE Plasma 桌面的預設 USE flags。

**Emerge** ([Wiki](https://wiki.gentoo.org/wiki/Emerge))
Portage 的命令列工具。常用命令：
- `emerge --ask <套件名>` - 安裝軟體
- `emerge --sync` - 同步軟體倉庫
- `emerge -avuDN @world` - 更新整個系統

</details>

<details>
<summary><b>安裝時間估算（點擊展開）</b></summary>

| 步驟 | 預計時間 |
|------|----------|
| 準備安裝媒介 | 10-15 分鐘 |
| 磁碟分割與格式化 | 15-30 分鐘 |
| 下載並解壓 Stage3 | 5-10 分鐘 |
| 設定 Portage 與 Profile | 15-20 分鐘 |
| **編譯核心**（最耗時） | **30 分鐘 - 2 小時** |
| 安裝系統工具 | 20-40 分鐘 |
| 設定引導程式 | 10-15 分鐘 |
| **安裝桌面環境**（可選） | **1-3 小時** |
| **總計** | **3-6 小時**（取決於硬體效能）|

> **提示**：使用預編譯核心和二進位套件可以大幅縮短時間，但會犧牲部分客製性。

</details>

<details>
<summary><b>磁碟空間需求與開始前檢查清單（點擊展開）</b></summary>

### 磁碟空間需求

- **最小安裝**：10 GB（無桌面環境）
- **推薦空間**：30 GB（輕量桌面）
- **舒適空間**：80 GB+（完整桌面 + 編譯快取）

### 開始前的檢查清單

- 已備份所有重要資料
- 準備了 8GB+ 的 USB 隨身碟
- 確認網路連線穩定（有線網路最佳）
- 預留了充足的時間（建議完整的半天）
- 有一定的 Linux 命令列基礎
- 準備好另一台裝置查閱文件（或者使用 GUI LiveCD）

</details>

---

**簡介**

本指南將引導你在 x86_64 UEFI 平台上安裝 Gentoo Linux。

**本文將教你**：
- 從零開始安裝 Gentoo 基礎系統（分割區、Stage3、核心、引導程式）
- 配置 Portage 並優化編譯參數（make.conf、USE flags、CPU flags）
- 安裝桌面環境（KDE Plasma、GNOME、Hyprland）
- 配置中文環境（locale、字型、Fcitx5 輸入法）
- 可選進階配置（LUKS 全碟加密、LTO 優化、核心調優、RAID）
- 系統維護（SSD TRIM、電源管理、Flatpak、系統更新）


> **請先關閉 Secure Boot**
> 在開始安裝之前，請務必進入 BIOS 設定，將 **Secure Boot** 暫時關閉。
> 開啟 Secure Boot 可能會導致安裝媒介無法啟動，或者安裝後的系統無法引導。你可以在系統安裝完成並成功啟動後，再參考本指南後面的章節重新配置並開啟 Secure Boot。

> **重要**：開始前請務必備份所有重要資料！本指南涉及磁碟分割操作。

已驗證至 2025 年 11 月 25 日。

---

## 0. 準備安裝媒介 {#step-0-prepare}

> **可參考**：[Gentoo Handbook: AMD64 - 選擇安裝媒介](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media/zh-cn)

### 0.1 下載 Gentoo ISO

根據[**下載頁面**](/download/) 提供的方式獲取下載連結

> **注意**：以下連結中的日期（如 `20251123T...`）僅供參考，請務必在鏡像站中選擇**最新日期**的檔案。

下載 Minimal ISO（以 TWAREN 鏡像站為例）：
```bash
wget http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso
wget http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso.asc
```

> 如果希望安裝時能直接使用瀏覽器或更方便地連接 Wi-Fi，可以選擇 **LiveGUI USB Image**。
>
> **新手入坑推薦使用每週構建的 KDE 桌面環境的 Live ISO**： <https://iso.gig-os.org/>
> （來自 Gig-OS <https://github.com/Gig-OS> 專案）
>
> **Live ISO 登入憑據**：
> - 帳號：`live`
> - 密碼：`live`
> - Root 密碼：`live`
>
> **系統支援**：
> - 支援中文顯示和中文輸入法 (fcitx5), flclash 等

驗證簽名（可選）：
```bash
# 從密鑰伺服器取得 Gentoo 發布簽名公鑰
gpg --keyserver hkps://keys.openpgp.org --recv-keys 0xBB572E0E2D1829105A8D0F7CF7A88992
# --keyserver: 指定密鑰伺服器位址
# --recv-keys: 接收並匯入公鑰
# 0xBB...992: Gentoo Release Media 簽名密鑰指紋

# 驗證 ISO 檔案的數位簽名
gpg --verify install-amd64-minimal-20251123T153051Z.iso.asc install-amd64-minimal-20251123T153051Z.iso
# --verify: 驗證簽名檔案
# .iso.asc: 簽名檔案（ASCII armored）
# .iso: 被驗證的 ISO 檔案
```

### 0.2 製作 USB 安裝碟

**Linux：**
```bash
sudo dd if=install-amd64-minimal-20251123T153051Z.iso of=/dev/sdX bs=4M status=progress oflag=sync
# if=輸入檔案 of=輸出裝置 bs=區塊大小 status=顯示進度
```
> 請將 `sdX` 替換成 USB 裝置名稱，例如 `/dev/sdb`。

**Windows：** 推薦使用 [Rufus](https://rufus.ie/) → 選擇 ISO → 寫入時選 DD 模式。

---

## 1. 進入 Live 環境並連接網路 {#step-1-network}

> **可參考**：[Gentoo Handbook: AMD64 - 配置網路](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking/zh-cn)
>
> **為什麼需要這一步？**
> Gentoo 的安裝過程完全依賴網路來下載原始碼包 (Stage3) 和軟體倉庫 (Portage)。在 Live 環境中配置好網路是安裝的第一步。

### 1.1 有線網路

```bash
ip link        # 查看網卡介面名稱 (如 eno1, wlan0)
dhcpcd eno1    # 對有線網卡啟用 DHCP 自動獲取 IP
ping -c3 gentoo.org # 測試網路連通性
```

### 1.2 無線網路
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

> 若 WPA3 不穩定，請先退回 WPA2。

<details>
<summary><b>進階設定：啟動 SSH 方便遠端操作（點擊展開）</b></summary>

```bash
passwd                      # 設定 root 密碼 (遠端登入需要)
rc-service sshd start       # 啟動 SSH 服務
rc-update add sshd default  # 設定 SSH 開機自啟 (Live 環境中可選)
ip a | grep inet            # 查看當前 IP 位址
# 在另一台設備上：ssh root@<IP>
```

</details>


## 2. 規劃磁碟分割區 {#step-2-partition}

> **可參考**：[Gentoo Handbook: AMD64 - 準備磁碟](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn)
>
> **為什麼需要這一步？**
> 我們需要為 Linux 系統劃分獨立的儲存空間。UEFI 系統通常需要一個 ESP 分割區 (引導) 和一個根分割區 (系統)。合理的規劃能讓日後的維護更輕鬆。

### 什麼是 EFI 系統分割區 (ESP)？

在使用由 UEFI 引導（而不是 BIOS）的作業系統上安裝 Gentoo 時，建立 EFI 系統分割區 (ESP) 是必要的。ESP 必須是 FAT 變體（有時在 Linux 系統上顯示為 vfat）。官方 UEFI 規範表示 UEFI 韌體將識別 FAT12、16 或 32 檔案系統，但建議使用 FAT32。

> **警告**：如果 ESP 沒有使用 FAT 變體進行格式化，那麼系統的 UEFI 韌體將找不到引導載入程式（或 Linux 核心）並且很可能無法引導系統！


### 建議分割區方案（UEFI）

下表提供了一個可用於 Gentoo 試用安裝的推薦預設分割區表。

| 裝置路徑 | 掛載點 | 檔案系統 | 描述 |
| :--- | :--- | :--- | :--- |
| `/dev/nvme0n1p1` | `/efi` | vfat | EFI 系統分割區 (ESP) |
| `/dev/nvme0n1p2` | `swap` | swap | 交換分割區 |
| `/dev/nvme0n1p3` | `/` | xfs | 根分割區 |

### cfdisk 實戰範例（推薦）

`cfdisk` 是一個圖形化的分割區工具，操作簡單直觀。

```bash
cfdisk /dev/nvme0n1
```

**操作提示**：
1.  選擇 **GPT** 標籤類型。
2.  **建立 ESP**：新建分割區 -> 大小 `1G` -> 類型選擇 `EFI System`。
3.  **建立 Swap**：新建分割區 -> 大小 `4G` -> 類型選擇 `Linux swap`。
4.  **建立 Root**：新建分割區 -> 剩餘空間 -> 類型選擇 `Linux filesystem` (預設)。
5.  選擇 **Write** 寫入更改，輸入 `yes` 確認。
6.  選擇 **Quit** 離開。

```text
                                                                 Disk: /dev/nvme0n1
                                              Size: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
                                            Label: gpt, identifier: 9737D323-129E-4B5F-9049-8080EDD29C02

    所用裝置                                   Start                   結束                  磁區               Size 類型
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
                                   [ 刪除 ]  [Resize]  [ 離開 ]  [ 類型 ]  [ 求助 ]  [ Sort ]  [ 寫入 ]  [ Dump ]


                                                        Quit program without writing changes
```

<details>
<summary><b>進階設定：fdisk 命令列分割區教學（點擊展開）</b></summary>

`fdisk` 是一個功能強大的命令列分割區工具。

```bash
fdisk /dev/nvme0n1
```

**1. 查看當前分割區佈局**

使用 `p` 鍵來顯示磁碟當前的分割區配置。

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

**2. 建立一個新的磁碟標籤**

按下 `g` 鍵將立即刪除所有現有的磁碟分割區並建立一個新的 GPT 磁碟標籤：

```text
Command (m for help): g
Created a new GPT disklabel (GUID: ...).
```

或者，要保留現有的 GPT 磁碟標籤，可以使用 `d` 鍵逐個刪除現有分割區。

**3. 建立 EFI 系統分割區 (ESP)**

輸入 `n` 建立一個新分割區，選擇分割區號 1，起始磁區預設（2048），結束磁區輸入 `+1G`：

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

將分割區標記為 EFI 系統分割區（類型代碼 1）：

```text
Command (m for help): t
Selected partition 1
Partition type or alias (type L to list all): 1
Changed type of partition 'Linux filesystem' to 'EFI System'.
```

**4. 建立 Swap 分割區**

建立 4GB 的 Swap 分割區：

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

**5. 建立根分割區**

將剩餘空間分配給根分割區：

```text
Command (m for help): n
Partition number (3-128, default 3): 3
First sector (...): <Enter>
Last sector (...): <Enter>

Created a new partition 3 of type 'Linux filesystem' and of size 926.5 GiB.
```

> **注意**：將根分割區的類型設定為 "Linux root (x86-64)" 並不是必須的，如果將其設定為 "Linux filesystem" 類型，系統也能正常運作。只有在使用支援它的 bootloader (即 systemd-boot) 並且不需要 fstab 檔案時，才需要這種檔案系統類型。

設定分割區類型為 "Linux root (x86-64)"（類型代碼 23）：

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

    所用裝置            Start       結束      磁區    Size 類型
>>  /dev/nvme0n1p1         34      32767     32734     16M Microsoft reserved   
    /dev/nvme0n1p2	32768  879779839 879747072  419.5G Microsoft basic data
    /dev/nvme0n1p3 1416650752 1418747903   2097152	1G EFI System
    /dev/nvme0n1p4 1418747904 1437622271  18874368	9G Linux swap
    /dev/nvme0n1p5 1437622272 1953523711 515901440    246G Linux filesystem
    /dev/nvme0n1p6  879779840 1416650751 536870912    256G Linux filesystem







 ┌────────────────────────────────────────────────────────────────────────────┐
 │Partition name: Microsoft reserved partition                                │
 │Partition UUID: 035B96B8-E321-4388-9C55-9FC0700AFF46                        │
 │Partition type: Microsoft reserved (E3C9E316-0B5C-4DB8-817D-F92DF00215AE)   │
 └────────────────────────────────────────────────────────────────────────────┘
 [ 刪除 ]  [Resize]  [ 離開 ]  [ 類型 ]  [ 求助 ]  [ Sort ]  [ 寫入 ]  [ Dump ]
```

> `cfdisk` 操作提示：使用方向鍵移動，選擇 `New`、`Type`、`Write` 等操作。確認無誤後輸入 `yes` 寫入分割區表。

---

## 3. 建立檔案系統並掛載 {#step-3-filesystem}

> **可參考**：[Gentoo Handbook: AMD64 - 準備磁碟](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn)
> **可參考**：[Ext4](https://wiki.gentoo.org/wiki/Ext4/zh-cn) 和 [XFS](https://wiki.gentoo.org/wiki/XFS/zh-cn) 和 [Btrfs](https://wiki.gentoo.org/wiki/Btrfs/zh-cn)
>
> **為什麼需要這一步？**
> 磁碟分割區只是劃分了空間，但還不能儲存資料。建立檔案系統 (如 ext4, Btrfs) 才能讓作業系統管理和存取這些空間。掛載則是將這些檔案系統連接到 Linux 檔案樹的特定位置。
>


### 3.1 格式化

```bash
mkfs.fat -F 32 /dev/nvme0n1p1  # 格式化 ESP 分割區為 FAT32
mkswap /dev/nvme0n1p2          # 格式化 Swap 分割區
mkfs.xfs /dev/nvme0n1p3        # 格式化 Root 分割區為 XFS
```

若使用 Btrfs：
```bash
mkfs.btrfs -L gentoo /dev/nvme0n1p3
```

若使用 ext4：
```bash
mkfs.ext4 /dev/nvme0n1p3
```

> 其他如 [F2FS](https://wiki.gentoo.org/wiki/F2FS/zh-cn) 或 [ZFS](https://wiki.gentoo.org/wiki/ZFS/zh-cn) 請參考相關 Wiki。

### 3.2 掛載（XFS 範例）

```bash
mount /dev/nvme0n1p3 /mnt/gentoo        # 掛載根分割區
mkdir -p /mnt/gentoo/efi                # 建立 ESP 掛載點
mount /dev/nvme0n1p1 /mnt/gentoo/efi    # 掛載 ESP 分割區
swapon /dev/nvme0n1p2                   # 啟用 Swap 分割區
```

<details>
<summary><b>進階設定：Btrfs 子卷範例（點擊展開）</b></summary>

```bash
mount /dev/nvme0n1p3 /mnt/gentoo
btrfs subvolume create /mnt/gentoo/@
btrfs subvolume create /mnt/gentoo/@home
umount /mnt/gentoo

mount -o compress=zstd,subvol=@ /dev/nvme0n1p3 /mnt/gentoo
mkdir -p /mnt/gentoo/{boot,efi,home}
mount -o subvol=@home /dev/nvme0n1p3 /mnt/gentoo/home
mount /dev/nvme0n1p2 /mnt/gentoo/boot
mount /dev/nvme0n1p1 /mnt/gentoo/efi
```

> **Btrfs 快照建議**：
> 推薦使用 [Snapper](https://wiki.gentoo.org/wiki/Snapper) 管理快照。合理的子卷規劃（如將 `@` 和 `@home` 分開）能讓系統回滾更加輕鬆。

</details>

<details>
<summary><b>進階設定：加密分割區（LUKS）（點擊展開）</b></summary>

```bash
# 建立 LUKS2 加密分割區
cryptsetup luksFormat --type luks2 --pbkdf argon2id --hash sha512 --key-size 512 /dev/nvme0n1p3

# 打開加密分割區
cryptsetup luksOpen /dev/nvme0n1p3 root
# 輸入密碼後，映射為 /dev/mapper/root

# 格式化映射後的設備
mkfs.ext4 /dev/mapper/root

# 掛載
mount /dev/mapper/root /mnt/gentoo
```

> **注意**：使用加密分割區後，後續配置核心和引導載入程式時需要額外步驟（配置 initramfs 解密）。

</details>

---

> **建議**：掛載完成後，建議使用 `lsblk` 確認掛載點是否正確。
>
> ```bash
> lsblk
> ```
>
> **輸出範例**（類似如下）：
> ```text
> NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
>  nvme0n1          259:1    0 931.5G  0 disk  
> ├─nvme0n1p1      259:7    0     1G  0 part  /efi
> ├─nvme0n1p2      259:8    0     4G  0 part  [SWAP]
> └─nvme0n1p3      259:9    0 926.5G  0 part  /
> ```
                                      

## 4. 下載 Stage3 並進入 chroot {#step-4-stage3}

> **可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 安裝檔案](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/zh-cn)
> **可參考**：[Stage file](https://wiki.gentoo.org/wiki/Stage_file)
>
> **為什麼需要這一步？**
> Stage3 是一個最小化的 Gentoo 基礎系統環境。我們將它解壓到硬碟上，作為新系統的「地基」，然後通過 `chroot` 進入這個新環境進行後續配置。

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
# x:解壓 p:保留權限 v:顯示過程 f:指定檔案 --numeric-owner:使用數字ID
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

如果同時下載了 `.DIGESTS` 或 `.CONTENTS`，可以用 `openssl` 或 `gpg` 驗證。

### 4.3 複製 DNS 並掛載偽檔案系統

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/ # 複製 DNS 設定
mount --types proc /proc /mnt/gentoo/proc          # 掛載進程資訊
mount --rbind /sys /mnt/gentoo/sys                 # 綁定掛載系統資訊
mount --rbind /dev /mnt/gentoo/dev                 # 綁定掛載設備節點
mount --rbind /run /mnt/gentoo/run                 # 綁定掛載運行時資訊
mount --make-rslave /mnt/gentoo/sys                # 設定為從屬掛載 (防止卸載時影響宿主)
mount --make-rslave /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/run
```

> 使用 OpenRC 可以省略 `/run` 這一步。

### 4.4 進入 chroot

```bash
chroot /mnt/gentoo /bin/bash    # 切換根目錄到新系統
source /etc/profile             # 載入環境變數
export PS1="(chroot) ${PS1}"    # 修改提示符以區分環境
```

---

## 5. 初始化 Portage 與 make.conf {#step-5-portage}

> **可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 基本系統](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)
>
> **為什麼需要這一步？**
> Portage 是 Gentoo 的套件管理系統，也是其核心特色。初始化 Portage 並設定 `make.conf` 就像為你的新系統設定了「建構藍圖」，決定了軟體如何編譯、使用哪些功能以及從哪裡下載。

### 5.1 同步樹

```bash
emerge-webrsync   # 獲取最新的 Portage 快照 (比 rsync 快)
emerge --sync     # 同步 Portage 樹 (獲取最新 ebuild)
emerge --ask app-editors/vim # 安裝 Vim 編輯器 (推薦)
eselect editor list          # 列出可用編輯器
eselect editor set vi        # 將 Vim 設定為預設編輯器 (vi 通常是指向 vim 的軟連結)
```

設定鏡像（擇一）：
```bash
mirrorselect -i -o >> /etc/portage/make.conf
# 或手動：
#以 TWAREN 鏡像站為例
echo 'GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"' >> /etc/portage/make.conf
```

### 5.2 make.conf 範例

> **可參考**：[Gentoo Handbook: AMD64 - USE 標誌](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/USE/zh-cn) 和 [/etc/portage/make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf/zh-cn)

編輯 `/etc/portage/make.conf`：
```bash
vim /etc/portage/make.conf
```

**懶人/新手配置（複製貼上）**：
> **提示**：請根據你的 CPU 核心數修改 `MAKEOPTS` 中的 `-j` 參數（例如 8 核 CPU 使用 `-j8`）。

```conf
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# 請根據 CPU 核心數修改 -j 後面的數字
MAKEOPTS="-j8"

# 語言設定
LC_MESSAGES=C
L10N="en en-US zh zh-CN zh-TW"
LINGUAS="en en_US zh zh_CN zh_TW"

# 鏡像源 (TWAREN)
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# 常用 USE 旗標 (systemd 使用者推薦)
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"
ACCEPT_LICENSE="*"
```

<details>
<summary><b>詳細配置範例（建議閱讀並調整）（點擊展開）</b></summary>

```conf
# vim: set language=bash;  # 告訴 Vim 使用 bash 語法突顯
CHOST="x86_64-pc-linux-gnu"  # 目標系統架構（不要手動修改）

# ========== 編譯最佳化參數 ==========
# -march=native: 針對當前 CPU 最佳化（推薦，效能最佳）
# -O2: 最佳化等級 2（平衡效能與穩定性，推薦）
# -pipe: 使用管道傳遞資料，加速編譯（不影響最終程式）
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"    # C 程式編譯選項
CXXFLAGS="${COMMON_FLAGS}"  # C++ 程式編譯選項
FCFLAGS="${COMMON_FLAGS}"   # Fortran 程式編譯選項
FFLAGS="${COMMON_FLAGS}"    # Fortran 77 程式編譯選項

# CPU 指令集最佳化（見下文 5.3，執行 cpuid2cpuflags 自動生成）
# CPU_FLAGS_X86="aes avx avx2 ..."

# ========== 語言與本地化設定 ==========
# 保持建置輸出為英文（便於除錯和搜尋解決方案）
LC_MESSAGES=C

# L10N: 本地化支援（影響文件、翻譯等）
L10N="en en-US zh zh-CN zh-TW"
# LINGUAS: 舊式本地化變數（部分軟體仍需要）
LINGUAS="en en_US zh zh_CN zh_TW"

# ========== 並行編譯設定 ==========
# -j 後面的數字 = CPU 執行緒數（例如 32 核心 CPU 用 -j32）
# 推薦值：CPU 執行緒數（可透過 nproc 指令查看）
MAKEOPTS="-j32"  # 請根據實際硬體調整

# ========== 鏡像源設定 ==========
# Gentoo 軟體套件下載鏡像（台灣地區建議使用台灣學術網路鏡像）
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# ========== Emerge 預設選項 ==========
# --ask: 執行前詢問確認
# --verbose: 顯示詳細資訊（USE 旗標變化等）
# --with-bdeps=y: 包含建置時依賴
# --complete-graph=y: 完整依賴圖分析
EMERGE_DEFAULT_OPTS="--ask --verbose --with-bdeps=y --complete-graph=y"

# ========== USE 旗標（全域功能開關）==========
# systemd: 使用 systemd 作為 init 系統（若用 OpenRC 則改為 -systemd）
# udev: 裝置管理支援
# dbus: 行程間通訊（桌面環境必需）
# policykit: 權限管理（桌面環境必需）
# networkmanager: 網路管理器（推薦）
# bluetooth: 藍牙支援
# git: Git 版本控制
# dist-kernel: 使用發行版核心（新手推薦，可用預編譯核心）
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"

# ========== 許可證接受 ==========
# "*" 表示接受所有許可證（包括非自由軟體許可證）
# 可選擇性接受：ACCEPT_LICENSE="@FREE"（僅自由軟體）
ACCEPT_LICENSE="*"

# 檔案末尾保留換行符！重要！
```

</details>

> **新手提示**：
> - `MAKEOPTS="-j32"` 的數字應該是你的 CPU 執行緒數，可透過 `nproc` 指令查看
> - 如果編譯時記憶體不足，可以減少並行任務數（如改為 `-j16`）
> - USE 旗標是 Gentoo 的核心特性，決定了軟體編譯時包含哪些功能
---

<details>
<summary><b>進階設定：CPU 指令集優化 (CPU_FLAGS_X86)（點擊展開）</b></summary>

> **可參考**：[CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn)

為了讓 Portage 知道你的 CPU 支援哪些特定指令集（如 AES, AVX, SSE4.2 等），我們需要設定 `CPU_FLAGS_X86`。

安裝檢測工具：
```bash
emerge --ask app-portage/cpuid2cpuflags # 安裝檢測工具
```

執行檢測並寫入設定：
```bash
cpuid2cpuflags >> /etc/portage/make.conf # 將檢測結果追加到設定檔
```

檢查 `/etc/portage/make.conf` 末尾，你應該會看到類似這樣的一行：
```conf
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

</details>

---

## 6. Profile、系統設定與本地化 {#step-6-system}

> **可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 基本系統](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)
>
> **為什麼需要這一步？**
> Profile 定義了系統的基礎配置和預設 USE 旗標，是 Gentoo 靈活性的體現。設定時區、語言和網路等基本系統參數，是讓你的 Gentoo 系統能夠正常運作並符合個人使用習慣的關鍵。

### 6.1 選擇 Profile

```bash
eselect profile list          # 列出所有可用 Profile
eselect profile set <編號>    # 設定選定的 Profile
emerge -avuDN @world          # 更新系統以匹配新 Profile (a:詢問 v:詳細 u:升級 D:深層依賴 N:新USE)
```

常見選項：
- `default/linux/amd64/23.0/desktop/plasma/systemd`
- `default/linux/amd64/23.0/desktop/gnome/systemd`
- `default/linux/amd64/23.0/desktop`（OpenRC 桌面）

### 6.2 時區與語言

> **可參考**：[Gentoo Wiki: Localization/Guide](https://wiki.gentoo.org/wiki/Localization/Guide/zh-cn)

```bash
echo "Asia/Taipei" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "zh_TW.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen                      # 生成選定的語言環境
eselect locale set en_US.utf8   # 設定系統預設語言 (建議用英文以免亂碼)

# 重新載入環境
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

### 6.3 主機名與網路設定

**設定主機名**：
```bash
echo "gentoo" > /etc/hostname
```

**網路管理工具選擇**：

**方案 A：NetworkManager (推薦，通用)**
> **可參考**：[NetworkManager](https://wiki.gentoo.org/wiki/NetworkManager)

適合大多數桌面使用者，同時支援 OpenRC 和 systemd。
```bash
emerge --ask net-misc/networkmanager
# OpenRC:
rc-update add NetworkManager default
# systemd:
systemctl enable NetworkManager
```

> **設定提示**：
> - **圖形介面**：執行 `nm-connection-editor`
> - **命令列**：使用 `nmtui` (圖形化嚮導) 或 `nmcli`

<details>
<summary><b>進階提示：使用 iwd 後端（點擊展開）</b></summary>

NetworkManager 支援使用 `iwd` 作為後端（比 wpa_supplicant 更快）。

```bash
echo "net-misc/networkmanager iwd" >> /etc/portage/package.use/networkmanager
emerge --ask --newuse net-misc/networkmanager
```
之後編輯 `/etc/NetworkManager/NetworkManager.conf`，在 `[device]` 下添加 `wifi.backend=iwd`。

</details>

<details>
<summary><b>方案 B：輕量方案（點擊展開）</b></summary>

如果你不想使用 NetworkManager，可以選擇以下輕量級方案：

1. **有線網路 (dhcpcd)**
   > **可參考**：[dhcpcd](https://wiki.gentoo.org/wiki/Dhcpcd)
   ```bash
   emerge --ask net-misc/dhcpcd
   # OpenRC:
   rc-update add dhcpcd default
   # systemd:
   systemctl enable dhcpcd
   ```

2. **無線網路 (iwd)**
   > **可參考**：[iwd](https://wiki.gentoo.org/wiki/Iwd)
   ```bash
   emerge --ask net-wireless/iwd
   # OpenRC:
   rc-update add iwd default
   # systemd:
   systemctl enable iwd
   ```
   > **提示**：iwd 是一個現代、輕量級的無線守護行程。

</details>

<details>
<summary><b>方案 3：原生方案（點擊展開）</b></summary>

使用 init 系統自帶的網路管理功能，適合伺服器或極簡環境。

**OpenRC 網卡服務**：
> **可參考**：[OpenRC](https://wiki.gentoo.org/wiki/OpenRC) 和 [OpenRC: Network Management](https://wiki.gentoo.org/wiki/OpenRC#Network_management)

```bash
vim /etc/conf.d/net
```

> **注意**：請將下文中的 `enp5s0` 替換為你實際的網卡介面名稱（透過 `ip link` 查看）。

寫入以下內容：
```conf
config_enp5s0="dhcp"
```

```bash
ln -s /etc/init.d/net.lo /etc/init.d/net.enp5s0 # 建立網卡服務軟連結
rc-update add net.enp5s0 default                # 設定開機自啟
```

---

**Systemd 原生網卡服務**：
> **可參考**：[systemd-networkd](https://wiki.gentoo.org/wiki/Systemd/systemd-networkd)、[systemd-resolved](https://wiki.gentoo.org/wiki/Systemd/systemd-resolved)、[Systemd](https://wiki.gentoo.org/wiki/Systemd)、[Systemd: Network](https://wiki.gentoo.org/wiki/Systemd#Network)

Systemd 自帶了網路管理功能，適合伺服器或極簡環境：
```bash
systemctl enable systemd-networkd
systemctl enable systemd-resolved
```
*注意：需要手動編寫 .network 設定檔。*

</details>

### 6.4 設定 fstab

> **可參考**：[Gentoo Handbook: AMD64 - fstab](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/zh-cn) 和 [Gentoo Wiki: /etc/fstab](https://wiki.gentoo.org/wiki//etc/fstab/zh-cn)

獲取 UUID：
```bash
blkid
```

**方法 A：自動生成（推薦 LiveGUI 使用者）**
> **注意**：`genfstab` 工具通常包含在 `arch-install-scripts` 套件中。如果你使用的是 Gig-OS 或其他基於 Arch 的 LiveISO，可以直接使用。官方 Minimal ISO 可能需要手動安裝或使用方法 B。

```bash
emerge --ask sys-fs/genfstab # 如果沒有該命令
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```
檢查生成的檔案：
```bash
cat /mnt/gentoo/etc/fstab
```

**方法 B：手動編輯**

編輯 `/etc/fstab`：
```bash
vim /etc/fstab
```

```fstab
UUID=<ESP-UUID>   /efi   vfat    defaults,noatime  0 2
UUID=<BOOT-UUID>  /boot  ext4    defaults,noatime  0 2
UUID=<ROOT-UUID>  /      ext4    defaults,noatime  0 1
UUID=<HOME-UUID>  /home  ext4    defaults,noatime  0 2
UUID=<SWAP-UUID>  none   swap    sw               0 0
```

---

## 7. 核心與韌體 {#step-7-kernel}

> **可參考**：[Gentoo Handbook: AMD64 - 配置 Linux 核心](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/zh-cn)
>
> **為什麼需要這一步？**
> 核心是作業系統的核心，負責管理硬體。Gentoo 允許你手動裁剪核心，只保留你需要的驅動，從而獲得極致的效能和精簡的體積。新手也可以選擇預編譯核心快速上手。

### 7.1 快速方案：預編譯核心

```bash
emerge --ask sys-kernel/gentoo-kernel-bin
```

核心升級後記得重新生成引導程式設定。

<details>
<summary><b>進階設定：手動編譯核心 (Gentoo 核心體驗)（點擊展開）</b></summary>

> **新手提示**：
> 編譯核心比較複雜且耗時。如果你想盡快體驗 Gentoo，可以先跳過本節，使用 7.1 的預編譯核心。

手動編譯核心能讓你完全掌控系統功能，移除不需要的驅動，獲得更精簡、高效的核心。

**快速開始**（使用 Genkernel 自動化）：
```bash
emerge --ask sys-kernel/gentoo-sources sys-kernel/genkernel
genkernel --install all  # 自動編譯並安裝核心、模組和 initramfs
# --install: 編譯完成後自動安裝到 /boot 目錄
# all: 完整構建 (核心 + 模組 + initramfs)
```

> **進階內容**：如果你想深入了解核心配置、使用 LLVM/Clang 編譯核心、啟用 LTO 最佳化等進階選項，請參考 **[Section 16.0 核心編譯進階指南](/zh-tw/posts/2025-11-25-gentoo-install-advanced/#section-16-kernel-advanced)**。

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

---

## 8. 基礎工具 {#step-8-base-packages}

> **可參考**：[Gentoo Handbook: AMD64 - 安裝必要的系統工具](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools/zh-cn)
>
> **為什麼需要這一步？**
> Stage3 只有最基礎的指令。我們需要補充系統日誌、網路管理、檔案系統工具等必要組件，才能讓系統在重啟後正常工作。

### 8.1 系統服務工具

**OpenRC 使用者**（必選）：

**1. 系統日誌**
> **可參考**：[Syslog-ng](https://wiki.gentoo.org/wiki/Syslog-ng)
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
> **可參考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) 和 [System Time (OpenRC)](https://wiki.gentoo.org/wiki/System_time/zh-cn#OpenRC)
```bash
emerge --ask net-misc/chrony
rc-update add chronyd default
```

**systemd 使用者**：
systemd 已內建日誌與時間同步服務。

**時間同步**
> **可參考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) 和 [System Time (systemd)](https://wiki.gentoo.org/wiki/System_time/zh-cn#systemd)
```bash
systemctl enable --now systemd-timesyncd
```

### 8.3 檔案系統工具

根據你使用的檔案系統安裝對應工具（必選）：
```bash
emerge --ask sys-fs/e2fsprogs  # ext4
emerge --ask sys-fs/xfsprogs   # XFS
emerge --ask sys-fs/dosfstools # FAT/vfat (EFI 分割區需要)
emerge --ask sys-fs/btrfs-progs # Btrfs
```

## 9. 建立使用者與權限 {#step-9-users}

> **可參考**：[Gentoo Handbook: AMD64 - 結束安裝](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing/zh-cn)
>
> **為什麼需要這一步？**
> Linux 不建議日常使用 root 帳戶。我們需要建立一個普通使用者，並賦予其使用 `sudo` 的權限，以提高系統安全性。

```bash
passwd root # 設定 root 密碼
useradd -m -G wheel,video,audio,plugdev zakk # 建立使用者並加入常用群組
passwd zakk # 設定使用者密碼
emerge --ask app-admin/sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel # 允許 wheel 群組使用 sudo
```

若使用 systemd，可視需求將帳號加入 `network`、`lp` 等群組。

---

<details>
<summary><b>進階設定：設定加密支援（僅加密使用者）（點擊展開）</b></summary>

> **可參考**：[Dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt/zh-cn)

> **注意**：如果你在步驟 3.4 中選擇了加密分割區，才需要執行此步驟。

### 步驟 1：啟用 systemd cryptsetup 支援

```bash
mkdir -p /etc/portage/package.use
echo "sys-apps/systemd cryptsetup" >> /etc/portage/package.use/fde

# 重新編譯 systemd 以啟用 cryptsetup 支援
emerge --ask --oneshot sys-apps/systemd
```

### 步驟 2：取得 LUKS 分割區的 UUID

```bash
# 取得 LUKS 加密容器的 UUID（不是裡面的檔案系統 UUID）
blkid /dev/nvme0n1p3
```

輸出範例：
```text
/dev/nvme0n1p3: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" ...
```
記下這個 **LUKS UUID**（例如：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）。

### 步驟 3：設定 GRUB 核心參數

```bash
vim /etc/default/grub
```

加入或修改以下內容（**替換 UUID 為實際值**）：
```conf
# 完整範例（替換 UUID 為你的實際 UUID）
GRUB_CMDLINE_LINUX="rd.luks.uuid=<LUKS-UUID> rd.luks.allow-discards root=UUID=<ROOT-UUID> rootfstype=btrfs"
```

**參數說明**：
- `rd.luks.uuid=<UUID>`：LUKS 加密分割區的 UUID（使用 `blkid /dev/nvme0n1p3` 取得）
- `rd.luks.allow-discards`：允許 SSD TRIM 指令穿透加密層（提升 SSD 效能）
- `root=UUID=<UUID>`：解密後的 btrfs 檔案系統 UUID（使用 `blkid /dev/mapper/gentoo-root` 取得）
- `rootfstype=btrfs`：根檔案系統類型（如果使用 ext4 改為 `ext4`）

### 步驟 3.1（替代方案）：設定核心參數 (systemd-boot 方案)

如果你使用 systemd-boot 而不是 GRUB，請編輯 `/boot/loader/entries/` 下的設定檔（例如 `gentoo.conf`）：

```conf
title      Gentoo Linux
version    6.6.13-gentoo
options    rd.luks.name=<LUKS-UUID>=cryptroot root=/dev/mapper/cryptroot rootfstype=btrfs rd.luks.allow-discards init=/lib/systemd/systemd
linux      /vmlinuz-6.6.13-gentoo
initrd     /initramfs-6.6.13-gentoo.img
```

**參數說明**：
- `rd.luks.name=<LUKS-UUID>=cryptroot`：指定 LUKS 分割區 UUID 並映射為 `cryptroot`。
- `root=/dev/mapper/cryptroot`：指定解密後的根分割區設備。
- `rootfstype=btrfs`：指定根檔案系統類型。

### 步驟 4：安裝並設定 dracut

> **可參考**：[Dracut](https://wiki.gentoo.org/wiki/Dracut) 和 [Initramfs](https://wiki.gentoo.org/wiki/Initramfs)

```bash
# 安裝 dracut（如果還沒安裝）
emerge --ask sys-kernel/dracut
```

### 步驟 5：設定 dracut for LUKS 解密

建立 dracut 設定檔：
```bash
vim /etc/dracut.conf.d/luks.conf
```

加入以下內容：
```conf
# 不要在這裡設定 kernel_cmdline，GRUB 會覆蓋它
kernel_cmdline=""
# 新增必要的模組支援 LUKS + btrfs
add_dracutmodules+=" btrfs systemd crypt dm "
# 新增必要的工具
install_items+=" /sbin/cryptsetup /bin/grep "
# 指定檔案系統（如果使用其他檔案系統請修改）
filesystems+=" btrfs "
```

**設定說明**：
- `crypt` 和 `dm` 模組提供 LUKS 解密支援
- `systemd` 模組用於 systemd 啟動環境
- `btrfs` 模組支援 btrfs 檔案系統（如果使用 ext4 改為 `ext4`）

### 步驟 6：設定 /etc/crypttab（可選但推薦）

```bash
vim /etc/crypttab
```

加入以下內容（**替換 UUID 為你的 LUKS UUID**）：
```conf
gentoo-root UUID=<LUKS-UUID> none luks,discard
```
這樣設定後，系統會自動識別並提示解鎖加密分割區。

### 步驟 7：重新生成 initramfs

```bash
# 重新生成 initramfs（包含 LUKS 解密模組）
dracut --kver $(make -C /usr/src/linux -s kernelrelease) --force
# --kver: 指定核心版本
# $(make -C /usr/src/linux -s kernelrelease): 自動取得當前核心版本號
# --force: 強制覆蓋已存在的 initramfs 檔案
```

> **重要**：每次更新核心後，也需要重新執行此命令生成新的 initramfs！

### 步驟 8：更新 GRUB 設定

```bash
grub-mkconfig -o /boot/grub/grub.cfg

# 驗證 initramfs 被正確引用
grep initrd /boot/grub/grub.cfg
```

</details>



## 10. 安裝引導程式 {#step-10-bootloader}

> **可參考**：[Gentoo Handbook: AMD64 - 設定引導程式](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader/zh-cn)

### 10.1 GRUB

> **可參考**：[GRUB](https://wiki.gentoo.org/wiki/GRUB/zh-cn)

```bash
emerge --ask sys-boot/grub:2
mkdir -p /efi/EFI/Gentoo
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo # 安裝 GRUB 到 ESP
# 安裝 os-prober 以支援多系統檢測
emerge --ask sys-boot/os-prober

# 啟用 os-prober（用於檢測 Windows 等其他作業系統）
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# 生成 GRUB 設定檔
grub-mkconfig -o /boot/grub/grub.cfg
```

<details>
<summary><b>進階設定：systemd-boot (僅限 UEFI)（點擊展開）</b></summary>

> **可參考**：[systemd-boot](https://wiki.gentoo.org/wiki/Systemd/systemd-boot/zh-cn)

```bash
bootctl --path=/efi install # 安裝 systemd-boot

# 1. 建立 Gentoo 引導項
vim /efi/loader/entries/gentoo.conf
```

寫入以下內容（**注意替換 UUID**）：
```conf
title   Gentoo Linux
linux   /vmlinuz-6.6.62-gentoo-dist
initrd  /initramfs-6.6.62-gentoo-dist.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw quiet
```
> **注意**：如果你使用了 LUKS 加密，options 行需要添加 `rd.luks.uuid=...` 等參數。

**2. 更新引導項**：
每次更新核心後，需要手動更新 `gentoo.conf` 中的版本號，或者使用腳本自動化。

**2. 建立 Windows 引導項 (雙系統)**

> 如果你建立了新的 EFI 分割區，請記得將原 Windows EFI 檔案 (EFI/Microsoft) 複製到新分割區。

```bash
vim /efi/loader/entries/windows.conf
```

寫入以下內容：
```ini
title      Windows 11
sort-key   windows-01
efi        /EFI/Microsoft/Boot/bootmgfw.efi
```

# 3. 設定預設引導
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



---

## 11. 重啟前檢查清單與重啟 {#step-11-reboot}

1. `emerge --info` 正常執行無錯誤
2. `/etc/fstab` 中的 UUID 正確（使用 `blkid` 再確認）
3. 已設定 root 與一般使用者密碼
4. 已執行 `grub-mkconfig` 或完成 `bootctl` 設定
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


> **恭喜！** 你已經完成了 Gentoo 的基礎安裝。
>
> **下一步**：[桌面配置](/zh-tw/posts/2025-11-25-gentoo-install-desktop/)
