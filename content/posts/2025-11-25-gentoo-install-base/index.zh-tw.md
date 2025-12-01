---
title: "Gentoo Linux 安裝指南 (基础篇)"
date: 2025-11-25
summary: "Gentoo Linux 基础系統安裝教學，涵蓋分割區、Stage3、核心編譯、引導程式配置等。也突出有 LUKS 全盘加密教学。"
description: "2025 年最新 Gentoo Linux 安裝指南 (基础篇)，詳細讲解 UEFI 安裝流程、核心編譯等。适合 Linux 进阶使用者和 Gentoo 新手。也突出有 LUKS 全盘加密教学。"
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

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 文章特别说明

本文是 **Gentoo Linux 安裝指南** 系列的第一部分：**基础安裝**。

**系列導航**：
1. **基础安裝（本文）**：从零开始安裝 Gentoo 基础系統
2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：顯示卡驅動、桌面環境、输入法等
3. [进阶優化](/posts/2025-11-25-gentoo-install-advanced/)：make.conf 優化、LTO、系統維護

**建議阅读方式**：
- 按需阅读：基础安裝（0-11 节）→ 桌面配置（12 节）→ 进阶優化（13-17 节）

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 關於本指南

本文旨在提供一个完整的 Gentoo 安裝流程演示，并**密集提供可供学习的參考文献**。文章中包含大量官方 Wiki 連結和技术文件，幫助读者深入理解每个步驟的原理和配置细节。

**这不是一份简单的傻瓜式教學，而是一份引導性的学习資源**——使用 Gentoo 的第一步是学会自己阅读 Wiki 并解决问题，善用 Google 甚至 AI 工具寻找答案。遇到问题或需要深入了解时，请务必查阅官方手冊和本文提供的參考連結。

如果在阅读过程中遇到疑问或发现问题，欢迎透過以下渠道提出：
- **Gentoo 中文社群**：[Telegram 群组](https://t.me/gentoo_zh) | [Telegram 频道](https://t.me/gentoocn) | [GitHub](https://github.com/Gentoo-zh)
- **官方社群**：[Gentoo Forums](https://forums.gentoo.org/) | IRC: #gentoo @ Libera.Chat

**非常建議以官方手冊为准**：
- [Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [Gentoo Handbook: AMD64 (繁體中文)](https://wiki.gentoo.org/wiki/Handbook:AMD64/zh-tw)

<p style="opacity: 0.8; margin-top: 1rem;">✓ 已驗證至 2025 年 11 月 25 日</p>

</div>

## 什么是 Gentoo？

Gentoo Linux 是一个基于原始碼的 Linux 发行版，以其**高度可定制性**和**效能優化**著称。与其他发行版不同，Gentoo 让你从源程式碼編譯所有軟體，这意味着：

- **极致效能**：所有軟體针对你的硬體優化編譯
- **完全掌控**：你决定系統包含什么，不包含什么
- **深度學習**：透過亲手構建系統深入理解 Linux
- **編譯时间**：初次安裝需要较长时间（建議预留 3-6 小时）
- **学习曲线**：需要一定的 Linux 基础知识

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94);">

**适合谁？**
- 想要深入学习 Linux 的技术爱好者
- 追求系統效能和定制化的使用者
- 享受 DIY 过程的 Geek

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11);">

**不适合谁？**
- 只想快速安裝使用的新手（建議先嘗試 Ubuntu、Fedora 等）
- 没有时间折腾系統的使用者

</div>

</div>

<details>
<summary><b>核心概念速览（点击展开）</b></summary>

在开始安裝前，先了解几个核心概念：

**Stage3** ([Wiki](https://wiki.gentoo.org/wiki/Stage_file))
一个最小化的 Gentoo 基础系統壓縮套件。它包含了構建完整系統的基础工具链（編譯器、函式庫等）。你将解壓它到硬碟上，作为新系統的"地基"。

**Portage** ([Wiki](https://wiki.gentoo.org/wiki/Portage/zh-tw))
Gentoo 的套件管理系統。它不直接安裝预編譯的軟體套件，而是下載源程式碼、根据你的配置編譯，然后安裝。核心指令是 `emerge`。

**USE Flags** ([Wiki](https://wiki.gentoo.org/wiki/USE_flag/zh-tw))
控制軟體功能的开关。例如，`USE="bluetooth"` 会让所有支援蓝牙的軟體在編譯时启用蓝牙功能。这是 Gentoo 定制化的核心。

**Profile** ([Wiki](https://wiki.gentoo.org/wiki/Profile_(Portage)))
预设的系統配置模板。例如 `desktop/plasma/systemd` profile 会自動启用适合 KDE Plasma 桌面的預設 USE flags。

**Emerge** ([Wiki](https://wiki.gentoo.org/wiki/Emerge))
Portage 的指令行工具。常用指令：
- `emerge --ask <套件名>` - 安裝軟體
- `emerge --sync` - 同步軟體倉庫
- `emerge -avuDN @world` - 更新整个系統

</details>

<details>
<summary><b>安裝时间估算（点击展开）</b></summary>

| 步驟 | 预计时间 |
|---|----------|
| 准备安裝媒介 | 10-15 分钟 |
| 磁碟分割區与格式化 | 15-30 分钟 |
| 下載并解壓 Stage3 | 5-10 分钟 |
| 配置 Portage 与 Profile | 15-20 分钟 |
| **編譯核心**（最耗时） | **30 分钟 - 2 小时** |
| 安裝系統工具 | 20-40 分钟 |
| 配置引導程式 | 10-15 分钟 |
| **安裝桌面環境**（可選） | **1-3 小时** |
| **总计** | **3-6 小时**（取决于硬體效能）|

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

使用预編譯核心和二进制套件可以大幅缩短时间，但会牺牲部分定制性。

</div>

</details>

<details>
<summary><b>磁碟空间需求与开始前检查清单（点击展开）</b></summary>

### 磁碟空间需求

- **最小安裝**：10 GB（无桌面環境）
- **推薦空间**：30 GB（轻量桌面）
- **舒适空间**：80 GB+（完整桌面 + 編譯快取）

### 开始前的检查清单

- 已備份所有重要資料
- 准备了 8GB+ 的 USB 闪存盘
- 確認網路連接穩定（有线網路最佳）
- 预留了充足的时间（建議完整的半天）
- 有一定的 Linux 指令行基础
- 准备好另一台裝置查阅文件（或者使用 GUI LiveCD）

</details>

---

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 本指南内容概览

本指南将引導你在 x86_64 UEFI 平台上安裝 Gentoo Linux。

**本文将教你**：
- 从零开始安裝 Gentoo 基础系統（分割區、Stage3、核心、引導程式）
- 配置 Portage 并優化編譯參數（make.conf、USE flags、CPU flags）
- 安裝桌面環境（KDE Plasma、GNOME、Hyprland）
- 配置中文環境（locale、字型、Fcitx5 输入法）
- 可選进阶配置（LUKS 全盘加密、LTO 優化、核心调优、RAID）
- 系統維護（SSD TRIM、電源管理、Flatpak、系統更新）

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要提醒**

**请先關閉 Secure Boot**  
在开始安裝之前，请务必进入 BIOS 設定，将 **Secure Boot** 暂时關閉。開啟 Secure Boot 可能会导致安裝介质无法啟動，或者安裝后的系統无法引導。你可以在系統安裝完成并成功啟動后，再參考本指南后面的章节重新配置并開啟 Secure Boot。

**備份所有重要資料！**  
本指南涉及磁碟分割區操作，请务必在开始前備份所有重要資料！

</div>

---

## 0. 准备安裝媒介 {#step-0-prepare}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 选择安裝媒介](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media/zh-tw)

</div>

### 0.1 下載 Gentoo ISO

根据[**下載页面**](/download/) 提供的方式获取下載連結

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

以下連結中的日期（如 `20251123T...`）仅供參考，请务必在鏡像站中选择**最新日期**的檔案。

</div>

下載 Minimal ISO（以 BFSU 鏡像站为例）：
```bash
wget https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso
wget https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso.asc
```

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**新手推薦：使用 LiveGUI USB Image**

如果希望安裝时能直接使用瀏覽器或更方便地連接 Wi-Fi，可以选择 **LiveGUI USB Image**。

**新手入坑推薦使用每周構建的 KDE 桌面環境的 Live ISO**： <https://iso.gig-os.org/>  
（来自 Gig-OS <https://github.com/Gig-OS> 專案）

**Live ISO 登入凭据**：
- 账号：`live`
- 密码：`live`
- Root 密码：`live`

**系統支援**：
- 支援中文顯示和中文输入法 (fcitx5), flclash 等

</div>

驗證签名（可選）：
```bash
# 从密钥伺服器获取 Gentoo 發布签名公钥
gpg --keyserver hkps://keys.openpgp.org --recv-keys 0xBB572E0E2D1829105A8D0F7CF7A88992
# --keyserver: 指定密钥伺服器位址
# --recv-keys: 接收并导入公钥
# 0xBB...992: Gentoo Release Media 签名密钥指纹

# 驗證 ISO 檔案的數位签名
gpg --verify install-amd64-minimal-20251123T153051Z.iso.asc install-amd64-minimal-20251123T153051Z.iso
# --verify: 驗證签名檔案
# .iso.asc: 签名檔案（ASCII armored）
# .iso: 被驗證的 ISO 檔案
```

### 0.2 製作 USB 安裝盘

**Linux：**
```bash
sudo dd if=install-amd64-minimal-20251123T153051Z.iso of=/dev/sdX bs=4M status=progress oflag=sync
# if=输入檔案 of=输出裝置 bs=块大小 status=顯示进度
```
<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

请将 `sdX` 替換成 USB 装置名称，例如 `/dev/sdb`。

</div>

**Windows：** 推薦使用 [Rufus](https://rufus.ie/) → 选择 ISO → 写入时选 DD 模式。

---

## 1. 进入 Live 環境并連接網路 {#step-1-network}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 配置網路](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Gentoo 的安裝过程完全依賴網路来下載原始碼套件 (Stage3) 和軟體倉庫 (Portage)。在 Live 環境中配置好網路是安裝的第一步。

</div>

### 1.1 有线網路

```bash
ip link        # 查看網卡介面名称 (如 eno1, wlan0)
dhcpcd eno1    # 对有线網卡启用 DHCP 自動获取 IP
ping -c3 gentoo.org # 測試網路连通性
```

### 1.2 无线網路
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

若 WPA3 不穩定，请先退回 WPA2。

</div>

<details>
<summary><b>进阶設定：啟動 SSH 方便遠端操作（点击展开）</b></summary>

```bash
passwd                      # 设定 root 密码 (遠端登入需要)
rc-service sshd start       # 啟動 SSH 服務
rc-update add sshd default  # 設定 SSH 开机自启 (Live 環境中可選)
ip a | grep inet            # 查看当前 IP 位址
# 在另一台裝置上：ssh root@<IP>
```

</details>


## 2. 规划磁碟分割區 {#step-2-partition}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 准备磁碟](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

我们需要为 Linux 系統划分独立的存储空间。UEFI 系統通常需要一个 ESP 分割區 (引導) 和一个根分割區 (系統)。合理的规划能让日后的維護更輕鬆。

### 什么是 EFI 系統分割區 (ESP)？

在使用由 UEFI 引導（而不是 BIOS）的操作系統上安裝 Gentoo 时，建立 EFI 系統分割區 (ESP) 是必要的。ESP 必須是 FAT 变体（有时在 Linux 系統上顯示为 vfat）。官方 UEFI 規範表示 UEFI 韌體将识别 FAT12、16 或 32 檔案系統，但建議使用 FAT32。

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**  
如果 ESP 没有使用 FAT 变体进行格式化，那么系統的 UEFI 韌體将找不到引導加载程式（或 Linux 核心）并且很可能无法引導系統！

</div>

### 建議分割區方案（UEFI）

下表提供了一个可用于 Gentoo 试用安裝的推薦預設分割區表。

| 裝置路径 | 掛載点 | 檔案系統 | 描述 |
| :--- | :--- | :--- | :--- |
| `/dev/nvme0n1p1` | `/efi` | vfat | EFI 系統分割區 (ESP) |
| `/dev/nvme0n1p2` | `swap` | swap | 交换分割區 |
| `/dev/nvme0n1p3` | `/` | xfs | 根分割區 |

### cfdisk 实战範例（推薦）

`cfdisk` 是一个图形化的分割區工具，操作简单直观。

```bash
cfdisk /dev/nvme0n1
```

**操作提示**：
1.  选择 **GPT** 標籤類別型。
2.  **建立 ESP**：新建分割區 -> 大小 `1G` -> 類別型选择 `EFI System`。
3.  **建立 Swap**：新建分割區 -> 大小 `4G` -> 類別型选择 `Linux swap`。
4.  **建立 Root**：新建分割區 -> 剩余空间 -> 類別型选择 `Linux filesystem` (預設)。
5.  选择 **Write** 写入更改，输入 `yes` 確認。
6.  选择 **Quit** 退出。

```text
                                                                 Disk: /dev/nvme0n1
                                              Size: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
                                            Label: gpt, identifier: 9737D323-129E-4B5F-9049-8080EDD29C02

    裝置                                       Start                   终点                  扇区               Size 類別型
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
                                   [ 刪除 ]  [Resize]  [ 退出 ]  [ 類別型 ]  [ 幫助 ]  [ 排序 ]  [ 写入 ]  [ 导出 ]


                                                        Quit program without writing changes
```

<details>
<summary><b>进阶設定：fdisk 指令行分割區教學（点击展开）</b></summary>

`fdisk` 是一个功能强大的指令行分割區工具。

```bash
fdisk /dev/nvme0n1
```

**1. 查看当前分割區佈局**

使用 `p` 鍵来顯示磁碟当前的分割區配置。

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

**2. 建立一个新的磁碟標籤**

按下 `g` 鍵将立即刪除所有现有的磁碟分割區并建立一个新的 GPT 磁碟標籤：

```text
Command (m for help): g
Created a new GPT disklabel (GUID: ...).
```

或者，要保留现有的 GPT 磁碟標籤，可以使用 `d` 鍵逐个刪除现有分割區。

**3. 建立 EFI 系統分割區 (ESP)**

输入 `n` 建立一个新分割區，选择分割區号 1，起始扇区預設（2048），结束扇区输入 `+1G`：

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

将分割區標記为 EFI 系統分割區（類別型程式碼 1）：

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
*(注：Type 19 是 Linux swap)*

**5. 建立根分割區**

将剩余空间分配给根分割區：

```text
Command (m for help): n
Partition number (3-128, default 3): 3
First sector (...): <Enter>
Last sector (...): <Enter>

Created a new partition 3 of type 'Linux filesystem' and of size 926.5 GiB.
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

将根分割區的類別型設定为 "Linux root (x86-64)" 并不是必須的，如果将其設定为 "Linux filesystem" 類別型，系統也能正常运行。只有在使用支援它的 bootloader (即 systemd-boot) 并且不需要 fstab 檔案时，才需要这种檔案系統類別型。

</div>

設定分割區類別型为 "Linux root (x86-64)"（類別型程式碼 23）：

```text
Command (m for help): t
Partition number (1-3, default 3): 3
Partition type or alias (type L to list all): 23
Changed type of partition 'Linux filesystem' to 'Linux root (x86-64)'.
```

**6. 写入更改**

检查无误后，输入 `w` 写入更改并退出：

```text
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

</details>

---

## 3. 建立檔案系統并掛載 {#step-3-filesystem}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 准备磁碟](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-tw) · [Ext4](https://wiki.gentoo.org/wiki/Ext4/zh-tw) · [XFS](https://wiki.gentoo.org/wiki/XFS/zh-tw) · [Btrfs](https://wiki.gentoo.org/wiki/Btrfs/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

磁碟分割區只是划分了空间，但还不能存储資料。建立檔案系統 (如 ext4, Btrfs) 才能让操作系統管理和访问这些空间。掛載则是将这些檔案系統連接到 Linux 檔案树的特定位置。

</div>

### 3.1 格式化

```bash
mkfs.fat -F 32 /dev/nvme0n1p1  # 格式化 ESP 分割區为 FAT32
mkswap /dev/nvme0n1p2          # 格式化 Swap 分割區
mkfs.xfs /dev/nvme0n1p3        # 格式化 Root 分割區为 XFS
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

**其他檔案系統**

其他如 [F2FS](https://wiki.gentoo.org/wiki/F2FS/zh-tw) 或 [ZFS](https://wiki.gentoo.org/wiki/ZFS/zh-tw) 请參考相关 Wiki。

</div>

### 3.2 掛載（XFS 範例）

```bash
mount /dev/nvme0n1p3 /mnt/gentoo        # 掛載根分割區
mkdir -p /mnt/gentoo/efi                # 建立 ESP 掛載点
mount /dev/nvme0n1p1 /mnt/gentoo/efi    # 掛載 ESP 分割區
swapon /dev/nvme0n1p2                   # 启用 Swap 分割區
```

<details>
<summary><b>进阶設定：Btrfs 子卷範例（点击展开）</b></summary>

**1. 格式化**

```bash
mkfs.fat -F 32 /dev/nvme0n1p1  # 格式化 ESP
mkswap /dev/nvme0n1p2          # 格式化 Swap
mkfs.btrfs -L gentoo /dev/nvme0n1p3 # 格式化 Root (Btrfs)
```

**2. 建立子卷**

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

输出範例：
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

推薦使用 [Snapper](https://wiki.gentoo.org/wiki/Snapper) 管理快照。合理的子卷规划（如将 `@` 和 `@home` 分开）能让系統回滚更加輕鬆。

</div>

</details>

<details>
<summary><b>进阶設定：加密分割區（LUKS）（点击展开）</b></summary>

**1. 建立加密容器**

```bash
cryptsetup luksFormat --type luks2 --pbkdf argon2id --hash sha512 --key-size 512 /dev/nvme0n1p3
```

**2. 打开加密容器**

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

输出範例：
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

掛載完成后，建議使用 `lsblk` 確認掛載点是否正确。

```bash
lsblk
```

**输出範例**（類別似如下）：
```text
NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
 nvme0n1          259:1    0 931.5G  0 disk  
├─nvme0n1p1      259:7    0     1G  0 part  /efi
├─nvme0n1p2      259:8    0     4G  0 part  [SWAP]
└─nvme0n1p3      259:9    0 926.5G  0 part  /
```

</div>

## 4. 下載 Stage3 并进入 chroot {#step-4-stage3}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 安裝檔案](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/zh-tw) · [Stage file](https://wiki.gentoo.org/wiki/Stage_file)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Stage3 是一个最小化的 Gentoo 基础系統環境。我们将它解壓到硬碟上，作为新系統的"地基"，然后透過 `chroot` 进入这个新環境进行后续配置。

</div>

### 4.1 选择 Stage3

- **OpenRC**：`stage3-amd64-openrc-*.tar.xz`
- **systemd**：`stage3-amd64-systemd-*.tar.xz`
- Desktop 变种只是预设開啟部分 USE，標準版更灵活。

### 4.2 下載与展开

```bash
cd /mnt/gentoo
# 使用 links 瀏覽器访问鏡像站下載 Stage3
links https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/ #以 BFSU 鏡像站为例
# 解壓 Stage3 壓縮套件
# x:解壓 p:保留权限 v:顯示过程 f:指定檔案 --numeric-owner:使用數位ID
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

如果同时下載了 `.DIGESTS` 或 `.CONTENTS`，可以用 `openssl` 或 `gpg` 驗證。

### 4.3 複製 DNS 并掛載伪檔案系統

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/ # 複製 DNS 配置
mount --types proc /proc /mnt/gentoo/proc          # 掛載进程資訊
mount --rbind /sys /mnt/gentoo/sys                 # 绑定掛載系統資訊
mount --rbind /dev /mnt/gentoo/dev                 # 绑定掛載裝置节点
mount --rbind /run /mnt/gentoo/run                 # 绑定掛載运行时資訊
mount --make-rslave /mnt/gentoo/sys                # 設定为从属掛載 (防止卸載时影响宿主)
mount --make-rslave /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/run
```

> 使用 OpenRC 可以省略 `/run` 這一步。

### 4.4 进入 chroot

```bash
chroot /mnt/gentoo /bin/bash    # 切换根目錄到新系統
source /etc/profile             # 加载環境變數
export PS1="(chroot) ${PS1}"    # 修改提示符以区分環境
```

---

## 5. 初始化 Portage 与 make.conf {#step-5-portage}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 基本系統](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Portage 是 Gentoo 的套件管理系統，也是其核心特色。初始化 Portage 并配置 `make.conf` 就像为你的新系統设定了「構建蓝图」，决定了軟體如何編譯、使用哪些功能以及从哪里下載。

</div>

### 5.1 同步树

```bash
emerge-webrsync   # 获取最新的 Portage 快照 (比 rsync 快)
emerge --sync     # 同步 Portage 树 (获取最新 ebuild)
emerge --ask app-editors/vim # 安裝 Vim 編輯器 (推薦)
eselect editor list          # 列出可用編輯器
eselect editor set vi        # 将 Vim 設定为預設編輯器 (vi 通常是指向 vim 的软連結)
```

設定鏡像（择一）：
```bash
mirrorselect -i -o >> /etc/portage/make.conf
# 或手動：
#以 BFSU 鏡像站为例
echo 'GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"' >> /etc/portage/make.conf
```

### 5.2 make.conf 范例

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - USE 标志](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/USE/zh-tw) · [/etc/portage/make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

</div>

編輯 `/etc/portage/make.conf`：
```bash
vim /etc/portage/make.conf
```

**懒人/新手配置（複製貼上）**：
<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

请根据你的 CPU 核心数修改 `MAKEOPTS` 中的 `-j` 參數（例如 8 核 CPU 使用 `-j8`）。

</div>

```conf
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# 请根据 CPU 核心数修改 -j 后面的數位
MAKEOPTS="-j8"

# 语言設定
LC_MESSAGES=C
L10N="en en-US zh zh-CN zh-TW"
LINGUAS="en en_US zh zh_CN zh_TW"

# 鏡像源 (BFSU)
GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"

# 常用 USE 标志 (systemd 使用者推薦)
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"
ACCEPT_LICENSE="*"
```

<details>
<summary><b>詳細配置范例（建議阅读并调整）（点击展开）</b></summary>

```conf
# vim: set language=bash;  # 告诉 Vim 使用 bash 语法高亮
CHOST="x86_64-pc-linux-gnu"  # 目標系統架構（不要手動修改）

# ========== 編譯優化參數 ==========
# -march=native: 针对当前 CPU 優化（推薦，效能最佳）
# -O2: 優化级别 2（平衡效能与穩定性，推薦）
# -pipe: 使用管道传递資料，加速編譯（不影响最终程式）
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"    # C 程式編譯选项
CXXFLAGS="${COMMON_FLAGS}"  # C++ 程式編譯选项
FCFLAGS="${COMMON_FLAGS}"   # Fortran 程式編譯选项
FFLAGS="${COMMON_FLAGS}"    # Fortran 77 程式編譯选项

# CPU 指令集優化（见下文 5.3，运行 cpuid2cpuflags 自動生成）
# CPU_FLAGS_X86="aes avx avx2 ..."

# ========== 语言与本機化設定 ==========
# 保持構建输出为英文（便于排错和搜尋解决方案）
LC_MESSAGES=C

# L10N: 本機化支援（影响文件、翻译等）
L10N="en en-US zh zh-CN zh-TW"
# LINGUAS: 旧式本機化變數（部分軟體仍需要）
LINGUAS="en en_US zh zh_CN zh_TW"

# ========== 并行編譯設定 ==========
# -j 后面的數位 = CPU 线程数（例如 32 核心 CPU 用 -j32）
# 推薦值：CPU 线程数（可透過 nproc 指令查看）
MAKEOPTS="-j32"  # 请根据实际硬體调整

# ========== 鏡像源設定 ==========
# Gentoo 軟體套件下載鏡像（建議选择国内鏡像加速）
GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"

# ========== Emerge 預設选项 ==========
# --ask: 执行前询问確認
# --verbose: 顯示詳細資訊（USE 标志变化等）
# --with-bdeps=y: 包含構建时依賴
# --complete-graph=y: 完整依賴图分析
EMERGE_DEFAULT_OPTS="--ask --verbose --with-bdeps=y --complete-graph=y"

# ========== USE 标志（全局功能开关）==========
# systemd: 使用 systemd 作为 init 系統（若用 OpenRC 则改为 -systemd）
# udev: 裝置管理支援
# dbus: 进程间通信（桌面環境必需）
# policykit: 权限管理（桌面環境必需）
# networkmanager: 網路管理器（推薦）
# bluetooth: 蓝牙支援
# git: Git 版本控制
# dist-kernel: 使用发行版核心（新手推薦，可用预編譯核心）
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"

# ========== 许可证接受 ==========
# "*" 表示接受所有许可证（包括非自由軟體许可证）
# 可選择性接受：ACCEPT_LICENSE="@FREE"（仅自由軟體）
ACCEPT_LICENSE="*"

# 檔案末尾保留换行符！重要！
```

</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

- `MAKEOPTS="-j32"` 的數位应该是你的 CPU 线程数，可透過 `nproc` 指令查看
- 如果編譯时記憶體不足，可以减少并行任務数（如改为 `-j16`）
- USE 标志是 Gentoo 的核心特性，决定了軟體編譯时包含哪些功能

</div>

<details>
<summary><b>进阶設定：CPU 指令集優化 (CPU_FLAGS_X86)（点击展开）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-tw)

</div>

为了让 Portage 知道你的 CPU 支援哪些特定指令集（如 AES, AVX, SSE4.2 等），我们需要配置 `CPU_FLAGS_X86`。

安裝检测工具：
```bash
emerge --ask app-portage/cpuid2cpuflags # 安裝检测工具
```

运行检测并写入配置：
```bash
cpuid2cpuflags >> /etc/portage/make.conf # 将检测結果追加到配置檔案
```

检查 `/etc/portage/make.conf` 末尾，你应该会看到類別似这样的一行：
```conf
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

</details>

---

## 6. Profile、系統設定与本機化 {#step-6-system}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝 Gentoo 基本系統](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Profile 定义了系統的基础配置和预设 USE 旗标，是 Gentoo 灵活性的体现。配置时区、语言和網路等基本系統參數，是让你的 Gentoo 系統能够正常运作并符合個人使用习惯的關鍵。

</div>

### 6.1 选择 Profile

```bash
eselect profile list          # 列出所有可用 Profile
eselect profile set <编号>    # 設定选定的 Profile
emerge -avuDN @world          # 更新系統以匹配新 Profile (a:询问 v:詳細 u:升級 D:深层依賴 N:新USE)
```

常见选项：
- `default/linux/amd64/23.0/desktop/plasma/systemd`
- `default/linux/amd64/23.0/desktop/gnome/systemd`
- `default/linux/amd64/23.0/desktop`（OpenRC 桌面）

### 6.2 时区与语言

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Wiki: Localization/Guide](https://wiki.gentoo.org/wiki/Localization/Guide/zh-tw)

</div>

```bash
echo "Asia/Shanghai" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen                      # 生成选定的语言環境
eselect locale set en_US.utf8   # 設定系統預設语言 (建議用英文以免乱码)

# 重新加载環境
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

### 6.3 主机名与網路設定

**設定主机名**：
```bash
echo "gentoo" > /etc/hostname
```

**網路管理工具选择**：

**方案 A：NetworkManager (推薦，通用)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[NetworkManager](https://wiki.gentoo.org/wiki/NetworkManager)

</div>

适合大多数桌面使用者，同时支援 OpenRC 和 systemd。
```bash
emerge --ask net-misc/networkmanager
# OpenRC:
rc-update add NetworkManager default
# systemd:
systemctl enable NetworkManager
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**配置提示**

**图形介面**：运行 `nm-connection-editor`  
**指令行**：使用 `nmtui` (图形化向导) 或 `nmcli`

</div>

<details>
<summary><b>进阶提示：使用 iwd 后端（点击展开）</b></summary>

NetworkManager 支援使用 `iwd` 作为后端（比 wpa_supplicant 更快）。

```bash
echo "net-misc/networkmanager iwd" >> /etc/portage/package.use/networkmanager
emerge --ask --newuse net-misc/networkmanager
```
之后編輯 `/etc/NetworkManager/NetworkManager.conf`，在 `[device]` 下新增 `wifi.backend=iwd`。

</details>

<details>
<summary><b>方案 B：轻量方案（点击展开）</b></summary>

如果你不想使用 NetworkManager，可以选择以下轻量级方案：

1. **有线網路 (dhcpcd)**
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

2. **无线網路 (iwd)**
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
   
> **提示**：iwd 是一个现代、轻量级的无线守护进程。

</details>

<details>
<summary><b>方案 3：原生方案（点击展开）</b></summary>

使用 init 系統自带的網路管理功能，适合伺服器或极简環境。

**OpenRC 網卡服務**：
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[OpenRC](https://wiki.gentoo.org/wiki/OpenRC) · [OpenRC: Network Management](https://wiki.gentoo.org/wiki/OpenRC#Network_management)

</div>

```bash
vim /etc/conf.d/net
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

请将下文中的 `enp5s0` 替換为你实际的網卡介面名称（透過 `ip link` 查看）。

</div>

写入以下内容：
```conf
config_enp5s0="dhcp"
```

```bash
ln -s /etc/init.d/net.lo /etc/init.d/net.enp5s0 # 建立網卡服務软連結
rc-update add net.enp5s0 default                # 設定开机自启
```

---

**Systemd 原生網卡服務**：
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[systemd-networkd](https://wiki.gentoo.org/wiki/Systemd/systemd-networkd) · [systemd-resolved](https://wiki.gentoo.org/wiki/Systemd/systemd-resolved) · [Systemd](https://wiki.gentoo.org/wiki/Systemd) · [Systemd: Network](https://wiki.gentoo.org/wiki/Systemd#Network)

</div>

Systemd 自带了網路管理功能，适合伺服器或极简環境：
```bash
systemctl enable systemd-networkd
systemctl enable systemd-resolved
```
*注意：需要手動编写 .network 配置檔案。*

</details>



### 6.4 配置 fstab

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - fstab](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/zh-tw) · [Gentoo Wiki: /etc/fstab](https://wiki.gentoo.org/wiki//etc/fstab/zh-tw)

</div>

获取 UUID：
```bash
blkid
```

**方法 A：自動生成（推薦 LiveGUI 使用者）**
<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

`genfstab` 工具通常包含在 `arch-install-scripts` 套件中。如果你使用的是 Gig-OS 或其他基于 Arch 的 LiveISO，可以直接使用。官方 Minimal ISO 可能需要手動安裝或使用方法 B。

</div>

```bash
emerge --ask sys-fs/genfstab # 如果没有该指令
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```
检查生成的檔案：
```bash
cat /mnt/gentoo/etc/fstab
```

**方法 B：手動編輯**

編輯 `/etc/fstab`：
```bash
vim /etc/fstab
```

```fstab
# <fs>                                     <mountpoint> <type> <opts>            <dump/pass>
UUID=7E91-5869                             /efi         vfat   defaults,noatime  0 2
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none         swap   sw                0 0
UUID=8c08f447-c79c-4fda-8c08-f447c79ce690  /            xfs    defaults,noatime  0 1
```

<details>
<summary><b>进阶設定：Btrfs fstab 範例（点击展开）</b></summary>

```fstab
# Root Subvolume
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /            btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,commit=60,subvol=@              0 0

# Home Subvolume
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /home        btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,commit=60,subvol=@home          0 0

# Swap
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none         swap   sw                                                      0 0

# ESP (UEFI)
UUID=7E91-5869                             /efi         vfat   defaults,noatime,fmask=0022,dmask=0022                  0 2
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**注意**

请务必使用 `blkid` 指令获取你实际的 UUID 并替換上面的範例值。

</div>

</details>

<details>
<summary><b>进阶設定：LUKS 加密分割區 fstab 範例（点击展开）</b></summary>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**關鍵点**

在 `fstab` 中，必須使用 **解密后映射裝置** (Mapped Device) 的 UUID，而不是物理分割區 (LUKS Container) 的 UUID。

</div>

**1. 查看 UUID 区别**

```bash
blkid
```

输出範例（注意区分 `crypto_LUKS` 和 `btrfs`）：

```text
# 这是物理分割區 (LUKS 容器)，不要在 fstab 中使用这个 UUID！
/dev/nvme0n1p5: UUID="562d0251-..." TYPE="crypto_LUKS" ...

# 这是解密后的映射裝置 (檔案系統)，fstab 应该用这个 UUID！
/dev/mapper/cryptroot: UUID="7b44c5eb-..." TYPE="btrfs" ...
```

**2. fstab 配置範例**

```fstab
# Root (Btrfs inside LUKS) - 使用 /dev/mapper/cryptroot 的 UUID
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /            btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,commit=60,subvol=@              0 0

# Home (Btrfs inside LUKS) - 使用 /dev/mapper/crypthomevar 的 UUID
UUID=4ad44bb7-9843-470b-9a88-f008367b63a3  /home        btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,commit=60,subvol=@home          0 0

# Swap
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none         swap   sw                                                      0 0

# ESP (UEFI)
UUID=7E91-5869                             /efi         vfat   defaults,noatime,fmask=0022,dmask=0022                  0 2
```

</details>

---

## 7. 核心与韌體 {#step-7-kernel}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 配置 Linux 核心](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

核心是操作系統的核心，负责管理硬體。Gentoo 允许你手動裁剪核心，只保留你需要的驅動，从而获得极致的效能和精简的体积。新手也可以选择预編譯核心快速上手。

</div>

### 7.1 快速方案：预編譯核心

```bash
emerge --ask sys-kernel/gentoo-kernel-bin
```

核心升級后记得重新生成引導程式配置。

<details>
<summary><b>进阶設定：手動編譯核心 (Gentoo 核心體驗)（点击展开）</b></summary>

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**新手提示**

編譯核心比较复杂且耗时。如果你想尽快體驗 Gentoo，可以先跳过本节，使用 7.1 的预編譯核心。

</div>

手動編譯核心能让你完全掌控系統功能，移除不需要的驅動，获得更精简、高效的核心。

**快速开始**（使用 Genkernel 自動化）：
```bash
emerge --ask sys-kernel/gentoo-sources sys-kernel/genkernel
genkernel --install all  # 自動編譯并安裝核心、模組和 initramfs
# --install: 編譯完成后自動安裝到 /boot 目錄
# all: 完整構建 (核心 + 模組 + initramfs)
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**进阶内容**

如果你想深入了解核心配置、使用 LLVM/Clang 編譯核心、启用 LTO 優化等高级选项，请參考 **[Section 16.0 核心編譯进阶指南](/posts/2025-11-25-gentoo-install-advanced/#section-16-kernel-advanced)**。

</div>

</details>

### 7.3 安裝韌體与微码

```bash
mkdir -p /etc/portage/package.license
# 同意 Linux 韌體的授權条款
echo 'sys-kernel/linux-firmware linux-fw-redistributable no-source-code' > /etc/portage/package.license/linux-firmware
echo 'sys-kernel/installkernel dracut' > /etc/portage/package.use/installkernel
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-firmware/intel-microcode  # Intel CPU
```

---

## 8. 基础工具 {#step-8-base-packages}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 安裝必要的系統工具](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Stage3 只有最基础的指令。我们需要补充系統日誌、網路管理、檔案系統工具等必要元件，才能让系統在重啟后正常工作。

</div>

### 8.1 系統服務工具

**OpenRC 使用者**（必选）：

**1. 系統日誌**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Syslog-ng](https://wiki.gentoo.org/wiki/Syslog-ng)

</div>

```bash
emerge --ask app-admin/syslog-ng
rc-update add syslog-ng default
```

**2. 定时任務**
```bash
emerge --ask sys-process/cronie
rc-update add cronie default
```

**3. 时间同步**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-tw) · [System Time (OpenRC)](https://wiki.gentoo.org/wiki/System_time/zh-tw#OpenRC)

</div>

```bash
emerge --ask net-misc/chrony
rc-update add chronyd default
```

**systemd 使用者**：
systemd 已内置日誌与时间同步服務。

**时间同步**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-tw) · [System Time (systemd)](https://wiki.gentoo.org/wiki/System_time/zh-tw#systemd)

</div>

```bash
systemctl enable --now systemd-timesyncd
```

### 8.3 檔案系統工具

根据你使用的檔案系統安裝对应工具（必选）：
```bash
emerge --ask sys-fs/e2fsprogs  # ext4
emerge --ask sys-fs/xfsprogs   # XFS
emerge --ask sys-fs/dosfstools # FAT/vfat (EFI 分割區需要)
emerge --ask sys-fs/btrfs-progs # Btrfs
```

## 9. 建立使用者与权限 {#step-9-users}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 结束安裝](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**為什麼需要這一步？**

Linux 不建議日常使用 root 帳戶。我们需要建立一个普通使用者，并赋予其使用 `sudo` 的权限，以提高系統安全性。

</div>

```bash
passwd root # 設定 root 密码
useradd -m -G wheel,video,audio,plugdev zakk # 建立使用者并加入常用组
passwd zakk # 設定使用者密码
emerge --ask app-admin/sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel # 允许 wheel 组使用 sudo
```

若使用 systemd，可视需求将账号加入 `network`、`lp` 等群组。

---




## 10. 安裝引導程式 {#step-10-bootloader}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: AMD64 - 配置引導加载程式](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader/zh-tw)

</div>

### 10.1 GRUB

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[GRUB](https://wiki.gentoo.org/wiki/GRUB/zh-tw)

</div>

```bash
emerge --ask sys-boot/grub:2
mkdir -p /efi/EFI/Gentoo
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo # 安裝 GRUB 到 ESP
# 安裝 os-prober 以支援多系統检测
emerge --ask sys-boot/os-prober

# 启用 os-prober（用于检测 Windows 等其他操作系統）
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# 生成 GRUB 配置檔案
grub-mkconfig -o /boot/grub/grub.cfg
```

<details>
<summary><b>进阶設定：systemd-boot (仅限 UEFI)（点击展开）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[systemd-boot](https://wiki.gentoo.org/wiki/Systemd/systemd-boot/zh-tw)

</div>

```bash
bootctl --path=/efi install # 安裝 systemd-boot

# 1. 建立 Gentoo 引導项
vim /efi/loader/entries/gentoo.conf
```

写入以下内容（**注意替換 UUID**）：
```conf
title   Gentoo Linux
linux   /vmlinuz-6.6.62-gentoo-dist
initrd  /initramfs-6.6.62-gentoo-dist.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw quiet
```
<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果你使用了 LUKS 加密，options 行需要新增 `rd.luks.uuid=...` 等參數。

</div>

**2. 更新引導项**：
每次更新核心后，需要手動更新 `gentoo.conf` 中的版本号，或者使用腳本自動化。

**2. 建立 Windows 引導项 (双系統)**

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

如果你建立了新的 EFI 分割區，请记得将原 Windows EFI 檔案 (EFI/Microsoft) 複製到新分割區。

</div>

```bash
vim /efi/loader/entries/windows.conf
```

写入以下内容：
```ini
title      Windows 11
sort-key   windows-01
efi        /EFI/Microsoft/Boot/bootmgfw.efi
```

# 3. 配置預設引導
```bash
vim /efi/loader/loader.conf
```

写入以下内容：

```ini
default gentoo.conf
timeout 3
console-mode auto
```

</details>

<details>
<summary><b>进阶設定：加密支援（仅加密使用者）（点击展开）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt/zh-tw)

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果你在步驟 3.4 中选择了加密分割區，才需要执行此步驟。

</div>

**步驟 1：启用 systemd cryptsetup 支援**

```bash
mkdir -p /etc/portage/package.use
echo "sys-apps/systemd cryptsetup" >> /etc/portage/package.use/fde

# 重新編譯 systemd 以启用 cryptsetup 支援
emerge --ask --oneshot sys-apps/systemd
```

**步驟 2：获取 LUKS 分割區的 UUID**

```bash
# 获取 LUKS 加密容器的 UUID（不是里面的檔案系統 UUID）
blkid /dev/nvme0n1p3
```

输出範例：
```text
/dev/nvme0n1p3: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" ...
```
记下这个 **LUKS UUID**（例如：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）。

**步驟 3：配置 GRUB 核心參數**

```bash
vim /etc/default/grub
```

加入或修改以下内容（**替換 UUID 为实际值**）：

```bash
# 完整範例（替換 UUID 为你的实际 UUID）
GRUB_CMDLINE_LINUX="rd.luks.uuid=<LUKS-UUID> rd.luks.allow-discards root=UUID=<ROOT-UUID> rootfstype=btrfs"
```

**參數说明**：
- `rd.luks.uuid=<UUID>`：LUKS 加密分割區的 UUID（使用 `blkid /dev/nvme0n1p3` 获取）
- `rd.luks.allow-discards`：允许 SSD TRIM 指令穿透加密层（提升 SSD 效能）
- `root=UUID=<UUID>`：解密后的 btrfs 檔案系統 UUID（使用 `blkid /dev/mapper/gentoo-root` 获取）
- `rootfstype=btrfs`：根檔案系統類別型（如果使用 ext4 改为 `ext4`）

<details>
<summary><b>步驟 3.1（替代方案）：配置核心參數 (systemd-boot 方案)（点击展开）</b></summary>

如果你使用 systemd-boot 而不是 GRUB，请編輯 `/boot/loader/entries/` 下的配置檔案（例如 `gentoo.conf`）：

```conf
title      Gentoo Linux
version    6.6.13-gentoo
options    rd.luks.name=<LUKS-UUID>=cryptroot root=/dev/mapper/cryptroot rootfstype=btrfs rd.luks.allow-discards init=/lib/systemd/systemd
linux      /vmlinuz-6.6.13-gentoo
initrd     /initramfs-6.6.13-gentoo.img
```

**參數说明**：
- `rd.luks.name=<LUKS-UUID>=cryptroot`：指定 LUKS 分割區 UUID 并映射为 `cryptroot`。
- `root=/dev/mapper/cryptroot`：指定解密后的根分割區裝置。
- `rootfstype=btrfs`：指定根檔案系統類別型。

</details>

**步驟 4：安裝并配置 dracut**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Dracut](https://wiki.gentoo.org/wiki/Dracut) · [Initramfs](https://wiki.gentoo.org/wiki/Initramfs)

</div>

```bash
# 安裝 dracut（如果还没安裝）
emerge --ask sys-kernel/dracut
```

**步驟 5：配置 dracut for LUKS 解密**

建立 dracut 配置檔案：

```bash
vim /etc/dracut.conf.d/luks.conf
```

加入以下内容：

```conf
# 不要在这里設定 kernel_cmdline，GRUB 会覆盖它
kernel_cmdline=""
# 新增必要的模組支援 LUKS + btrfs
add_dracutmodules+=" btrfs systemd crypt dm "
# 新增必要的工具
install_items+=" /sbin/cryptsetup /bin/grep "
# 指定檔案系統（如果使用其他檔案系統请修改）
filesystems+=" btrfs "
```

**配置说明**：
- `crypt` 和 `dm` 模組提供 LUKS 解密支援
- `systemd` 模組用于 systemd 啟動環境
- `btrfs` 模組支援 btrfs 檔案系統（如果使用 ext4 改为 `ext4`）

### 步驟 6：配置 /etc/crypttab（可選但推薦）

```bash
vim /etc/crypttab
```

加入以下内容（**替換 UUID 为你的 LUKS UUID**）：
```conf
gentoo-root UUID=<LUKS-UUID> none luks,discard
```
这样配置后，系統会自動识别并提示解锁加密分割區。

### 步驟 7：重新生成 initramfs

```bash
# 重新生成 initramfs（包含 LUKS 解密模組）
dracut --kver $(make -C /usr/src/linux -s kernelrelease) --force
# --kver: 指定核心版本
# $(make -C /usr/src/linux -s kernelrelease): 自動获取当前核心版本号
# --force: 强制覆盖已存在的 initramfs 檔案
```

> **重要**：每次更新核心后，也需要重新执行此指令生成新的 initramfs！

### 步驟 8：更新 GRUB 配置

```bash
grub-mkconfig -o /boot/grub/grub.cfg

# 驗證 initramfs 被正确引用
grep initrd /boot/grub/grub.cfg
```

</details>



---

## 11. 重啟前检查清单与重啟 {#step-11-reboot}

1. `emerge --info` 正常执行无錯誤
2. `/etc/fstab` 中的 UUID 正确（使用 `blkid` 再確認）
3. 已设定 root 与一般使用者密码
4. 已执行 `grub-mkconfig` 或完成 `bootctl` 配置
5. 若使用 LUKS，確認 initramfs 含有 `cryptsetup`

离开 chroot 并重啟：
```bash
exit
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
swapoff -a
reboot
```

---

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**恭喜！** 你已经完成了 Gentoo 的基础安裝。

**下一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)

</div>
