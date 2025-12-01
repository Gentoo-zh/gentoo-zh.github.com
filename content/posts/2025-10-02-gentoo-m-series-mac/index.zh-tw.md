---
title: "在 Apple Silicon Mac 上安裝 Gentoo Linux（M1/M2/M3/M4 完整教學）"
date: 2025-10-02
categories: ["tutorial"]
authors: ["zakkaus"]
summary: "Apple Silicon Mac (M1/M2/M3/M4) Gentoo Linux 安裝全攻略，涵蓋 Asahi Linux 引導、GPU 驅動、桌面環境配置。"
description: "2025 年最新 Apple Silicon Mac (M1/M2/M3/M4) Gentoo Linux 安裝指南，基于 Asahi Linux 專案，包含 Live USB 製作、分割區、核心安裝及桌面環境配置。"
---

![Gentoo on Apple Silicon Mac](gentoo-asahi-mac.webp)

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**簡介**

本指南将引導你在 Apple Silicon Mac（M1/M2/M3/M4）上安裝原生 ARM64 Gentoo Linux。

**重要更新**：Asahi Linux 專案团队（尤其是 [chadmed](https://github.com/chadmed/gentoo-asahi-releng)）的卓越工作使得现在有了[官方 Gentoo Asahi 安裝指南](https://wiki.gentoo.org/wiki/Project:Asahi/Guide)，安裝流程已大幅簡化。

**本指南特色**：
*   基于官方最新流程（2025.10）
*   使用官方 Gentoo Asahi Live USB（無需 Fedora 中轉）
*   清楚標記可選与必选步驟
*   簡化版适合所有人（包含加密选项）

已驗證至 2025 年 11 月 20日。

**目標平台**：Apple Silicon Mac（M1/M2/M3/M4）ARM64 架構。本指南使用 Asahi Linux 引導程式进行初始設定，然后转换为完整的 Gentoo 環境。

</div>

---

## 安裝流程总览（簡化版）

**必选步驟**：
1. 下載官方 Gentoo Asahi Live USB 鏡像
2. 透過 Asahi 安裝程式設定 U-Boot 環境
3. 从 Live USB 啟動
4. 分割磁碟并掛載檔案系統
5. 展开 Stage3 并进入 chroot
6. 安裝 Asahi 支援套件（自動化腳本）
7. 重啟完成安裝

**可選步驟**：
- LUKS 加密（建議但非必須）
- 自定义核心配置（預設 dist-kernel 即可）
- 音訊設定（PipeWire，依需求）
- 桌面環境选择

整个流程会在你的 Mac 上建立双啟動環境：macOS + Gentoo Linux ARM64。

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**官方簡化**

现在可使用 [asahi-gentoosupport 自動化腳本](https://github.com/chadmed/asahi-gentoosupport) 完成大部分配置！

</div>

---

## 事前准备与注意事项 {#prerequisites}

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

### 硬體需求

*   Apple Silicon Mac（M1/M2/M3/M4 系列芯片）
*   至少 80 GB 的可用磁碟空间（建議 120 GB+）
*   穩定的網路連接（Wi-Fi 或以太网）
*   備份所有重要資料

### 重要警告

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1rem; border-radius: 0.5rem; border-left: 4px solid rgb(239, 68, 68); margin: 1rem 0;">

**本指南包含进阶操作**：
*   会调整你的分割區表
*   需要与 macOS 共存
*   涉及加密磁碟操作
*   Apple Silicon 对 Linux 的支援仍在积极開發中

</div>

**已知可运作的功能**：
*   CPU、記憶體、存储裝置
*   Wi-Fi（透過 Asahi Linux 韌體）
*   鍵盤、触控板、電池管理
*   顯示输出（内建螢幕与外接顯示器）
*   USB-C / Thunderbolt

**已知限制**：
*   Touch ID 无法使用
*   macOS 虛擬化功能受限
*   部分新硬體功能可能未完全支援
*   GPU 加速仍在開發中（OpenGL 部分支援）

</div>

---

## 0. 准备 Gentoo Asahi Live USB {#step-0-prepare}

### 0.1 下載官方 Gentoo Asahi Live USB

**官方簡化流程**：直接使用 Gentoo 提供的 ARM64 Live USB，無需透過 Fedora！

下載最新版本：
```bash
# 方法 1：作者站点下載
https://chadmed.au/pub/gentoo/

```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

官方正在整合 Asahi 支援到標準 Live USB。目前使用 chadmed 維護的版本。

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**鏡像版本相容性資訊（更新日期：2025年11月21日）**

- **社群構建版本**：由 [Zakkaus](https://github.com/zakkaus) 基于 [gentoo-asahi-releng](https://github.com/chadmed/gentoo-asahi-releng) 構建的鏡像
  - **特色**：systemd + KDE Plasma 桌面環境，预装中文支援和 Fcitx5 输入法，音訊和 Wi-Fi,flclash,firefox-bin等开箱即用
  - **下載連結**：[Google Drive](https://drive.google.com/drive/folders/1ZYGkc8uXqRFJ4jeaSbm5odeNb2qvh6CS)
  - **适用场景**：推薦新手使用，已成功在 M2 MacBook 上測試
  - 若有兴趣自行構建，可參考 [gentoo-asahi-releng](https://github.com/chadmed/gentoo-asahi-releng) 專案
- **官方版本**：
  - **推薦使用**：`install-arm64-asahi-20250603.iso`（2025年6月版本，已測試穩定）
  - **可能无法啟動**：`install-arm64-asahi-20251022.iso`（2025年10月版本）在某些裝置（如 M2 MacBook）上可能无法正常啟動
  - **建議**：如果 latest 版本无法啟動，请嘗試使用 20250603 版本或社群構建版本

</div>

### 0.2 製作啟動 USB

在 macOS 中：

```bash
# 查看 USB 裝置名称
diskutil list

# 卸載 USB（假设为 /dev/disk4）
diskutil unmountDisk /dev/disk4

# 写入鏡像（注意使用 rdisk 较快）
sudo dd if=install-arm64-asahi-*.iso of=/dev/rdisk4 bs=4m status=progress

# 完成后弹出
diskutil eject /dev/disk4
```

---

## 1. 設定 Asahi U-Boot 環境 {#step-1-asahi}

### 1.1 执行 Asahi 安裝程式

在 macOS Terminal 中执行：

```bash
curl https://alx.sh | sh
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**安全提示**

建議先前往 <https://alx.sh> 查看腳本内容，確認安全后再执行。

</div>

### 1.2 跟随安裝程式步驟

安裝程式会引導你：

1. **选择动作**：输入 `r` (Resize an existing partition to make space for a new OS)

2. **选择分割區空间**：决定分配给 Linux 的空间（建議至少 80 GB）
   - 可使用百分比（如 `50%`）或绝对大小（如 `120GB`）
   
<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

建議保留 macOS 分割區，以便日后更新韌體。

</div>

3. **选择操作系統**：选择 **UEFI environment only (m1n1 + U-Boot + ESP)**
   ```
   » OS: <选择 UEFI only 选项>
   ```
   
<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**官方建議**

选择 UEFI only 即可，不需要安裝完整发行版。

</div>

4. **設定名称**：输入 `Gentoo` 作为操作系統名称
   ```
   » OS name: Gentoo
   ```

5. **完成安裝**：记下螢幕指示，然后按 Enter 关机。

### 1.3 完成 Recovery 模式設定（關鍵步驟）

**重要的重啟步驟**：

1. **等待 25 秒**确保系統完全关机
2. **按住電源鍵**直到看到「Loading startup options...」或旋转圖示
3. **释放電源鍵**
4. 等待音量列表出现，选择 **Gentoo**
5. 你会看到 macOS Recovery 画面：
   - 若要求「Select a volume to recover」，选择你的 macOS 音量并点击 Next
   - 输入 macOS 使用者密码（FileVault 使用者）
6. 依照螢幕指示完成設定

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**故障排除**

若遇到啟動循环或要求重新安裝 macOS，请按住電源鍵完全关机，然后从步驟 1 重新开始。可選择 macOS 开机，执行 `curl https://alx.sh | sh` 并选择 `p` 选项重试。

</div>

---

## 2. 从 Live USB 啟動 {#step-2-boot}

### 2.1 連接 Live USB 并啟動

1. **插入 Live USB**（可透過 USB Hub 或 Dock）
2. **啟動 Mac**
3. **U-Boot 自動啟動**：
   - 若选择了「UEFI environment only」，U-Boot 会自動从 USB 啟動 GRUB
   - 等待 2 秒自動啟動序列
   - 若有多个系統，可能需要中断并手動选择

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

若需手動指定 USB 啟動，在 U-Boot 提示符下执行：

```bash
setenv boot_targets "usb"
setenv bootmeths "efi"
boot
```

</div>

### 2.2 設定網路（Live 環境）

Gentoo Live USB 内建網路工具：

**Wi-Fi 連接**：
```bash
net-setup
```

依照互动提示設定網路。完成后检查：

```bash
ping -c 3 www.gentoo.org
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

Apple Silicon 的 Wi-Fi 已包含在核心中，应可正常运作。若不穩定，嘗試連接 2.4 GHz 網路。

</div>

**（可選）SSH 遠端操作**：
```bash
passwd                     # 設定 root 密码
/etc/init.d/sshd start
ip a | grep inet          # 获取 IP 位址
```

---

## 3. 分割區与檔案系統設定 {#step-3-partition}

### 3.1 识别磁碟与分割區

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要警告**

**不要修改现有的 APFS 容器、EFI 分割區或 Recovery 分割區！** 只能在 Asahi 安裝程式预留的空间中操作。

</div>

查看分割區结构：
```bash
lsblk
blkid --label "EFI - GENTO"  # 查看你的 EFI 分割區
```

通常会看到：
```
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0 609.1M  1 loop /run/rootfsbase
sda           8:0    1 119.5G  0 disk /run/initramfs/live
|-sda1        8:1    1   118K  0 part 
|-sda2        8:2    1   2.8M  0 part 
`-sda3        8:3    1 670.4M  0 part 
nvme0n1     259:0    0 465.9G  0 disk 
|-nvme0n1p1 259:1    0   500M  0 part 
|-nvme0n1p2 259:2    0 307.3G  0 part 
|-nvme0n1p3 259:3    0   2.3G  0 part 
|-nvme0n1p4 259:4    0   477M  0 part 
`-nvme0n1p5 259:5    0     5G  0 part 
nvme0n2     259:6    0     3M  0 disk 
nvme0n3     259:7    0   128M  0 disk 
```

EFI 分割區识别（**不要动这个分割區！**）：
```bash
livecd ~ # blkid --label "EFI - GENTO" 
/dev/nvme0n1p4  # 这是 EFI 分割區勿动
```


<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**建議**

使用 `cfdisk` 进行分割區，它理解 Apple 分割區類別型并会保护系統分割區。

</div>

### 3.2 建立根分割區

假设空白空间从 `/dev/nvme0n1p5` 开始：

**方法 A：简单分割區（无加密）**

```bash
# 使用 cfdisk 建立新分割區
cfdisk /dev/nvme0n1
```

你会看到類別似以下的分割區表：
```
                                            Disk: /dev/nvme0n1
                         Size: 465.92 GiB, 500277792768 bytes, 122138133 sectors
                       Label: gpt, identifier: 6C5A96F2-EFC9-487C-8C3E-01FD5EA77896

    Device                      Start            End       Sectors        Size Type
    /dev/nvme0n1p1                  6         128005        128000        500M Apple Silicon boot
    /dev/nvme0n1p2             128006       80694533      80566528      307.3G Apple APFS
    /dev/nvme0n1p3           80694534       81304837        610304        2.3G Apple APFS
    /dev/nvme0n1p4           81304838       81426949        122112        477M EFI System
>>  Free space               81427200      120827418      39400219      150.3G                            
    /dev/nvme0n1p5          120827419      122138127       1310709          5G Apple Silicon recovery

                        [   New  ]  [  Quit  ]  [  Help  ]  [  Write ]  [  Dump  ]

                                   Create new partition from free space
```

操作步驟：
1. 选择 **Free space** → **New**
2. 使用全部空间（或自定义大小）
3. **Type** → 选择 **Linux filesystem**
4. **Write** → 输入 `yes` 確認
5. **Quit** 离开

**格式化分割區**：
```bash
# 格式化为 ext4 或 btrfs
mkfs.ext4 /dev/nvme0n1p6
# 或
mkfs.btrfs /dev/nvme0n1p6

# 掛載
mount /dev/nvme0n1p6 /mnt/gentoo
```

**方法 B：加密分割區（可選，建議）**

```bash
# 建立 LUKS2 加密分割區
cryptsetup luksFormat --type luks2 --pbkdf argon2id --hash sha512 --key-size 512 /dev/nvme0n1p6

# 输入 YES 確認，設定加密密码

# 打开加密分割區
cryptsetup luksOpen /dev/nvme0n1p6 gentoo-root

# 格式化
mkfs.btrfs --label root /dev/mapper/gentoo-root

# 掛載
mount /dev/mapper/gentoo-root /mnt/gentoo
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**為什麼用这些參數？**

*   `argon2id`：抗 ASIC/GPU 暴力破解
*   `aes-xts`：M1 有 AES 指令集，硬體加速
*   `luks2`：更好的安全工具

</div>

### 3.3 掛載 EFI 分割區

```bash
mkdir -p /mnt/gentoo/boot
mount /dev/nvme0n1p4 /mnt/gentoo/boot
```

---

## 4. Stage3 与 chroot {#step-4-stage3}

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**从这里开始遵循 [AMD64 Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)** 直到核心安裝章节。

</div>

### 4.1 下載并展开 Stage3

```bash
cd /mnt/gentoo

# 下載最新 ARM64 Desktop systemd Stage3
wget https://distfiles.gentoo.org/releases/arm64/autobuilds/current-stage3-arm64-desktop-systemd/stage3-arm64-desktop-systemd-*.tar.xz

# 展开（保持屬性）
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

### 4.2 設定 Portage

```bash
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

### 4.3 同步系統时间（重要）

在进入 chroot 前，确保系統时间正确（避免編譯和 SSL 证书问题）：

```bash
# 同步时间
chronyd -q

# 驗證时间是否正确
date
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**為什麼需要同步时间？**

*   編譯軟體套件时需要正确的时间戳
*   SSL/TLS 证书驗證依賴准确的系統时间
*   如果时间不正确，可能导致 emerge 失败或证书錯誤

</div>

### 4.4 进入 chroot 環境

**掛載必要檔案系統**：
```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
```

**进入 chroot**：
```bash
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```

### 4.5 基本系統配置

**設定 make.conf**（针对 Apple Silicon 優化）：

編輯 `/etc/portage/make.conf`：
```bash
nano -w /etc/portage/make.conf
```

加入或修改以下内容：
```conf
# vim: set language=bash;
CHOST="aarch64-unknown-linux-gnu"

# Apple Silicon 優化編譯參數
COMMON_FLAGS="-march=armv8.5-a+fp16+simd+crypto+i8mm -mtune=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
RUSTFLAGS="-C target-cpu=native"

# 保持構建输出为英文（報告錯誤时请保留此設定）
LC_MESSAGES=C

# 根据硬體调整（例如 M2 Max 有更多核心）
MAKEOPTS="-j4"

# Gentoo 鏡像源（推薦使用 R2 鏡像，速度较快）
GENTOO_MIRRORS="https://gentoo.rgst.io/gentoo"

# Emerge 預設选项（最多同时編譯 3 个套件）
EMERGE_DEFAULT_OPTS="--jobs 3"

# Asahi GPU 驅動
VIDEO_CARDS="asahi"

# 中文本機化支援（可選）
L10N="zh-CN zh-TW zh en"

# 檔案末尾保留换行符！重要！
```

**同步 Portage**：
```bash
emerge-webrsync
```

**設定时区**：
```bash
# 設定为台湾时区（或改为你所在的时区）
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
```

**設定语系**：
```bash
# 編輯 locale.gen，取消註釋需要的语系
nano -w /etc/locale.gen
# 取消註釋：en_US.UTF-8 UTF-8
# 取消註釋：zh_CN.UTF-8 UTF-8（如需中文）

# 生成语系
locale-gen

# 选择系統預設语系
eselect locale set en_US.utf8

# 重新加载環境
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

**建立使用者与設定密码**：
```bash
# 建立使用者（替換 <使用者名称> 为你的使用者名）
useradd -m -G wheel,audio,video,usb,input <使用者名称>

# 設定使用者密码
passwd <使用者名称>

# 設定 root 密码
passwd root
```

---

## 5. 安裝 Asahi 支援套件（核心步驟）{#step-5-asahi}

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**官方簡化流程**

这一章节取代 Handbook 的「安裝核心」章节。

</div>

### 5.1 方法 A：自動化安裝（推薦）

**步驟 1：安裝 git**

```bash
# 首次同步 Portage 树
emerge --sync

# 安裝 git（下載腳本需要）
emerge --ask dev-vcs/git
```

**步驟 2：使用 asahi-gentoosupport 腳本**（官方提供）：

```bash
cd /tmp
git clone https://github.com/chadmed/asahi-gentoosupport
cd asahi-gentoosupport
./install.sh
```

此腳本会自動完成：
- 启用 Asahi overlay
- 安裝 GRUB bootloader
- 設定 VIDEO_CARDS="asahi"
- 安裝 asahi-meta（包含核心、韌體、m1n1、U-Boot）
- 执行 `asahi-fwupdate` 和 `update-m1n1`
- 更新系統

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**如果遇到 USE flag 冲突**

腳本执行过程中可能会提示 USE flag 需要变更。解决方法：

```bash
# 当腳本提示 USE flag 冲突时，按 Ctrl+C 中断腳本
# 然后运行：
emerge --autounmask-write <出现冲突的軟體套件>

# 更新配置檔案
etc-update
# 在 etc-update 中选择合适的选项（通常选择 -3 自動合并）

# 重新运行安裝腳本
cd /tmp/asahi-gentoosupport
./install.sh
```

</div>

**腳本完成后直接跳到步驟 5.3（fstab 配置）！**

---

### 5.2 方法 B：手動安裝（进阶使用者）

**步驟 1：安裝 git 并配置 Asahi overlay**

```bash
# 首次同步 Portage 树
emerge --sync

# 安裝 git（用于 git 同步方式）
emerge --ask dev-vcs/git

# 刪除旧的 Portage 資料函式庫并切换到 git 同步
rm -rf /var/db/repos/gentoo
sudo tee /etc/portage/repos.conf/gentoo.conf << 'EOF'
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = git
sync-uri = https://mirrors.bfsu.edu.cn/git/gentoo-portage.git
auto-sync = yes
sync-depth = 1
EOF

# 配置 Asahi overlay 使用 git 同步
sudo tee /etc/portage/repos.conf/asahi.conf << 'EOF'
[asahi]
location = /var/db/repos/asahi
sync-type = git
sync-uri = https://github.com/chadmed/asahi-overlay.git
auto-sync = yes
EOF

# 同步所有倉庫
emerge --sync
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**鏡像源说明**

**繁體中文使用者推薦**：可以将上面的 `sync-uri` 改为北外源 `https://mirrors.bfsu.edu.cn/git/gentoo-portage.git` 以获得更快的同步速度

更多鏡像源选项參考：[鏡像列表](/mirrorlist/)

</div>

**步驟 2：配置 package.mask（重要！）**

防止 Gentoo 官方的 dist-kernel 覆盖 Asahi 版本：

```bash
mkdir -p /etc/portage/package.mask
cat > /etc/portage/package.mask/asahi << 'EOF'
# Mask the upstream dist-kernel virtual so it doesn't try to force kernel upgrades
virtual/dist-kernel::gentoo
EOF
```

**步驟 3：配置 package.use**

```bash
mkdir -p /etc/portage/package.use

# Asahi 专用 USE flags
cat > /etc/portage/package.use/asahi << 'EOF'
dev-lang/rust-bin rustfmt rust-src
dev-lang/rust rustfmt rust-src
EOF

# VIDEO_CARDS 設定
echo 'VIDEO_CARDS="asahi"' >> /etc/portage/make.conf

# GRUB 平台設定（必須！）
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
```

**步驟 4：配置韌體许可证**

```bash
mkdir -p /etc/portage/package.license
echo 'sys-kernel/linux-firmware linux-fw-redistributable no-source-code' > /etc/portage/package.license/firmware
```

**步驟 5：安裝 rust-bin（必須先安裝！）**

```bash
emerge -q1 dev-lang/rust-bin
```

**步驟 6：安裝 Asahi 套件**

```bash
# 一次性安裝所有必要套件
emerge -q sys-apps/asahi-meta virtual/dist-kernel:asahi sys-kernel/linux-firmware
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**提示**

如果 `etc-update` 出现配置檔案冲突，选择 `-3` 进行自動合并。

</div>

套件说明：
- `rust-bin`：編譯 Asahi 核心元件需要（必須先安裝）
- `asahi-meta`：包含 m1n1、asahi-fwupdate、U-Boot 等工具
- `virtual/dist-kernel:asahi`：Asahi 特制核心（包含未上游的补丁）
- `linux-firmware`：提供 Wi-Fi 等硬體韌體

**步驟 7：更新韌體与引導程式**

```bash
asahi-fwupdate
update-m1n1
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要**

每次更新核心、U-Boot 或 m1n1 时都必須执行 `update-m1n1`！

</div>

**步驟 8：安裝并配置 GRUB**

```bash
# 安裝 GRUB
emerge -q grub:2

# 安裝 GRUB 到 ESP（注意 --removable 标志很重要！）
grub-install --boot-directory=/boot/ --efi-directory=/boot/ --removable

# 生成 GRUB 配置
grub-mkconfig -o /boot/grub/grub.cfg
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**關鍵要点**

*   `--removable` 标志是必須的，确保系統能从 ESP 啟動
*   `--boot-directory` 和 `--efi-directory` 都必須指向 `/boot/`
*   必須在 make.conf 中設定 `GRUB_PLATFORMS="efi-64"`

</div>

**步驟 9：更新系統（可選）**

```bash
emerge --ask --update --deep --changed-use @world
```

---

### 5.3 配置 fstab

获取 UUID：
```bash
blkid $(blkid --label root)       # 根分割區（或 /dev/mapper/gentoo-root）
blkid $(blkid --label "EFI - GENTO")     # boot 分割區
```

編輯 `/etc/fstab`：
```bash
nano -w /etc/fstab
```

```fstab
# 根分割區（依你的配置调整）
UUID=<your-root-uuid>  /      ext4   defaults  0 1
# 或加密版本：
# UUID=<your-btrfs-uuid>  /      btrfs  defaults  0 1

UUID=<your-boot-uuid>  /boot  vfat   defaults  0 2
```

### 5.4 配置加密支援（仅加密使用者）

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果你在步驟 3.2 中选择了加密分割區，才需要执行此步驟。

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
blkid /dev/nvme0n1p5
```

输出範例：
```
/dev/nvme0n1p5: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" ...
```

记下这个 **LUKS UUID**（例如：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）。

**步驟 3：配置 GRUB 核心參數**

```bash
nano -w /etc/default/grub
```

加入或修改以下内容（**替換 UUID 为实际值**）：
```conf
# 完整範例（替換 UUID 为你的实际 UUID）
GRUB_CMDLINE_LINUX="rd.luks.uuid=3f5a6527-7334-4363-9e2d-e0e8c7c04488 rd.luks.allow-discards root=UUID=f3db74a5-dc70-48dd-a9a3-797a0daf5f5d rootfstype=btrfs"
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**參數说明**

- `rd.luks.uuid=<UUID>`：LUKS 加密分割區的 UUID（使用 `blkid /dev/nvme0n1p6` 获取）
- `rd.luks.allow-discards`：允许 SSD TRIM 指令穿透加密层（提升 SSD 效能）
- `root=UUID=<UUID>`：解密后的 btrfs 檔案系統 UUID（使用 `blkid /dev/mapper/gentoo-root` 获取）
- `rootfstype=btrfs`：根檔案系統類別型（如果使用 ext4 改为 `ext4`）

</div>

**步驟 4：安裝并配置 dracut**

```bash
# 安裝 dracut（如果还没安裝）
emerge --ask sys-kernel/dracut
```

**步驟 5：配置 dracut for LUKS 解密**

建立 dracut 配置檔案：
```bash
nano -w /etc/dracut.conf.d/luks.conf
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

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**配置说明**

*   `crypt` 和 `dm` 模組提供 LUKS 解密支援
*   `systemd` 模組用于 systemd 啟動環境
*   `btrfs` 模組支援 btrfs 檔案系統（如果使用 ext4 改为 `ext4`）

</div>

**步驟 6：配置 /etc/crypttab（可選但推薦）**

```bash
nano -w /etc/crypttab
```

加入以下内容（**替換 UUID 为你的 LUKS UUID**）：
```conf
gentoo-root UUID=<LUKS-UUID> none luks,discard
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

这样配置后，系統会自動识别并提示解锁加密分割區。

</div>

**步驟 7：重新生成 initramfs**

```bash
# 获取当前核心版本
dracut --kver $(make -C /usr/src/linux -s kernelrelease) --force
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要**

每次更新核心后，也需要重新执行此指令生成新的 initramfs！

</div>

**步驟 8：更新 GRUB 配置**

```bash
grub-mkconfig -o /boot/grub/grub.cfg

# 驗證 initramfs 被正确引用
grep initrd /boot/grub/grub.cfg
```

---

## 6. 完成安裝与重啟 {#step-6-finalize}

### 6.1 最后設定

**設定主机名称**：
```bash
echo "macbook" > /etc/hostname
```

**启用 NetworkManager**（桌面系統）：
```bash
systemctl enable NetworkManager
```

**設定 root 密码**（如果还没設定）：
```bash
passwd root
```

### 6.2 离开 chroot 并重啟

```bash
exit
umount -R /mnt/gentoo
# 若使用加密：
cryptsetup luksClose gentoo-root

reboot
```

### 6.3 首次啟動

1. U-Boot 会自動啟動
2. GRUB 選單出现，选择 Gentoo
3. （若加密）输入 LUKS 密码
4. 系統应成功啟動到登入提示

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**恭喜！基本系統已安裝完成！**

</div>

---

## 7. 安裝后配置（可選）{#step-7-post}

### 7.1 網路連接

```bash
# Wi-Fi
nmcli device wifi connect <SSID> password <密码>

# 或使用 nmtui（图形介面）
nmtui
```

### 7.2 安裝桌面環境（可選）

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要提示**

安裝桌面環境前，建議切换到对应的系統 profile，这会自動設定许多必要的 USE flags。

</div>

#### 步驟 1：查看并选择系統 Profile

```bash
# 列出所有可用的 profile
eselect profile list
```

输出範例：
```
Available profile symlink targets:
  [1]   default/linux/arm64/23.0 (stable)
  [2]   default/linux/arm64/23.0/systemd (stable) *
  [3]   default/linux/arm64/23.0/desktop (stable)
  [4]   default/linux/arm64/23.0/desktop/gnome (stable)
  [5]   default/linux/arm64/23.0/desktop/gnome/systemd (stable)
  [6]   default/linux/arm64/23.0/desktop/plasma (stable)
  [7]   default/linux/arm64/23.0/desktop/plasma/systemd (stable)
```

**选择合适的 profile**：

```bash
# GNOME 桌面
eselect profile set 5    # desktop/gnome/systemd

# KDE Plasma 桌面（推薦）
eselect profile set 7    # desktop/plasma/systemd

# 通用桌面環境（Xfce 等）
eselect profile set 3    # desktop (不含特定桌面)
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**Profile 说明**

*   `desktop/gnome/systemd`：自動启用 GNOME 相关 USE flags（gtk、gnome、wayland 等）
*   `desktop/plasma/systemd`：自動启用 KDE 相关 USE flags（qt5、kde、plasma 等）
*   `desktop`：基础桌面 USE flags（X、dbus、networkmanager 等）

</div>

#### 步驟 2：更新系統以應用新 Profile

切换 profile 后，需要重新編譯受影响的軟體套件：

```bash
# 更新所有軟體套件以應用新的 USE flags
emerge -avuDN @world
```

#### 步驟 3：安裝桌面環境

**选项 A：KDE Plasma（推薦）**

```bash
# 安裝 KDE Plasma 桌面
emerge --ask kde-plasma/plasma-meta kde-apps/kate kde-apps/dolphin

# 启用顯示管理器
systemctl enable sddm

# 安裝常用應用（可選）
emerge --ask kde-apps/konsole \
             kde-apps/okular \
             www-client/firefox
```

**选项 B：GNOME**

```bash
# 安裝完整 GNOME 桌面
emerge --ask gnome-base/gnome gnome-extra/gnome-tweaks

# 启用顯示管理器
systemctl enable gdm

# 安裝常用應用（可選）
emerge --ask gnome-extra/gnome-system-monitor \
             gnome-extra/gnome-calculator \
             www-client/firefox
```

**选项 C：Xfce（轻量级）**

```bash
# 先切换回通用桌面 profile
eselect profile set 3    # desktop

# 更新系統
emerge -avuDN @world

# 安裝 Xfce
emerge --ask xfce-base/xfce4-meta xfce-extra/xfce4-pulseaudio-plugin

# 安裝并启用顯示管理器
emerge --ask x11-misc/lightdm
systemctl enable lightdm
```

#### 步驟 4：優化桌面效能（可選）

**启用影片加速（Asahi GPU）**：

```bash
# 检查 VIDEO_CARDS 設定
grep VIDEO_CARDS /etc/portage/make.conf
# 应该包含：VIDEO_CARDS="asahi"

# 安裝 Mesa 与 Asahi 驅動（通常已安裝）
emerge --ask media-libs/mesa
```

**启用字型渲染**：

```bash
# 安裝基础字型
emerge --ask media-fonts/liberation-fonts \
             media-fonts/noto \
             media-fonts/noto-cjk \
             media-fonts/dejavu

# 启用字型微调
eselect fontconfig enable 10-sub-pixel-rgb.conf
eselect fontconfig enable 11-lcdfilter-default.conf
```

**中文输入法配置**：

```bash
# 安裝 Fcitx5 中文输入法
emerge --ask app-i18n/fcitx-chinese-addons
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

`app-i18n/fcitx-rime` 在当前版本实测无法正常使用，建議使用 `app-i18n/fcitx-chinese-addons` 作为替代方案。

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

*   首次安裝桌面環境预计需要 **2-4 小时**（取决于 CPU 效能）
*   建議使用 `--jobs 3` 或更少，避免記憶體不足
*   可以在 `/etc/portage/make.conf` 設定 `EMERGE_DEFAULT_OPTS="--jobs 3 --load-average 8"`

</div>

### 7.3 音訊配置（可選）

Asahi 音訊透過 PipeWire 提供。安裝并启用相关服務：

```bash
# 安裝 Asahi 音訊支援
emerge --ask media-libs/asahi-audio

# 启用 PipeWire 服務
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service
```
---

## 8. 系統維護 {#step-8-maintenance}

### 8.1 定期更新流程

```bash
# 更新 Portage 树（包含 Asahi overlay）
emerge --sync
# 或手動同步 Asahi overlay：
emaint -r asahi sync

# 更新所有套件
emerge -avuDN @world

# 清理不需要的套件
emerge --depclean

# 更新配置檔案
dispatch-conf
```

### 8.2 更新核心后必做

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**极度重要**

每次核心更新后必須执行！

</div>

```bash
# 更新 m1n1 Stage 2（包含 devicetree）
update-m1n1

# 重新生成 GRUB 配置
grub-mkconfig -o /boot/grub/grub.cfg
```

**為什麼？** m1n1 Stage 2 包含 devicetree blobs，核心需要它来识别硬體。不更新可能导致无法啟動或功能缺失。

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**自動化**

`sys-apps/asahi-scripts` 提供 installkernel hook 自動执行这些步驟。

</div>

### 8.3 更新韌體

macOS 系統更新时会包含韌體更新。**建議保留 macOS 分割區**以便获取最新韌體。

---

## 9. 常见问题与排错 {#faq}

### 问题：无法从 USB 啟動

**可能原因**：U-Boot 的 USB 驅動仍有限制。

**解决方法**：
- 嘗試不同的 USB 闪存盘
- 使用 USB 2.0 裝置（相容性较好）
- 透過 USB Hub 連接

### 问题：啟動卡住或黑屏

**原因**：m1n1/U-Boot/核心不匹配。

**解决方法**：
1. 从 macOS 重新执行 Asahi 安裝程式
2. 选择 `p` 选项重试 Recovery 流程
3. 确保在 chroot 中执行了 `update-m1n1`

### 问题：加密分割區无法解锁

**原因**：dracut 配置錯誤或 UUID 不对。

**解决方法**：
1. 检查 `/etc/default/grub` 中的 `GRUB_CMDLINE_LINUX`
2. 確認使用正确的 LUKS UUID：`blkid /dev/nvme0n1p5`
3. 重新生成 GRUB 配置：`grub-mkconfig -o /boot/grub/grub.cfg`

### 问题：Wi-Fi 不穩定

**原因**：可能是 WPA3 或 6 GHz 频段问题。

**解决方法**：
- 連接 WPA2 網路
- 使用 2.4 GHz 或 5 GHz 频段（避免 6 GHz）

### 问题：触控板无法使用

**原因**：韌體未加载或驅動问题。

**解决方法**：
```bash
# 检查韌體
dmesg | grep -i firmware

# 确保安裝了 asahi-meta
emerge --ask sys-apps/asahi-meta
```

---

## 10. 进阶技巧（可選）{#advanced}

### 10.1 刘海（Notch）配置

預設刘海区域会顯示为黑色。要启用：

```bash
# 在 GRUB 核心參數中加入
apple_dcp.show_notch=1
```

**KDE Plasma 優化**：
- 在顶部新增全宽面板，高度对齐刘海底部
- 左侧：Application Dashboard、Global menu、Spacer
- 右侧：System Tray、Bluetooth、Power、时钟

### 10.2 自定义核心（进阶）

使用 Distribution kernel 即可，但若要自定义：

```bash
emerge --ask sys-kernel/asahi-sources
cd /usr/src/linux
make menuconfig
make -j$(nproc)
make modules_install
make install
update-m1n1  # 必須！
grub-mkconfig -o /boot/grub/grub.cfg
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**记得保留可用核心作为备援**！

</div>

### 10.3 多核心切换

支援多个核心共存：

```bash
eselect kernel list
eselect kernel set <number>
update-m1n1  # 切换后必須执行！
```

---

## 11. 參考资料 {#reference}

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 官方文件

*   **[Gentoo Wiki: Project:Asahi/Guide](https://wiki.gentoo.org/wiki/Project:Asahi/Guide)**  官方最新指南
*   [Asahi Linux Official Site](https://asahilinux.org/)
*   [Asahi Linux Feature Support](https://asahilinux.org/docs/platform/feature-support/overview/)
*   [Gentoo AMD64 Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)（流程相同）

</div>

<div style="background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(5, 150, 105, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 工具与腳本

*   [asahi-gentoosupport](https://github.com/chadmed/asahi-gentoosupport) - 自動化安裝腳本
*   [Gentoo Asahi Releng](https://github.com/chadmed/gentoo-asahi-releng) - Live USB 構建工具

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 社群支援

**Gentoo 中文社群**：
*   Telegram 群组：[@gentoo_zh](https://t.me/gentoo_zh)
*   Telegram 频道：[@gentoocn](https://t.me/gentoocn)
*   [GitHub](https://github.com/gentoo-zh)

**官方社群**：
*   [Gentoo Forums](https://forums.gentoo.org/)
*   IRC: `#gentoo` 和 `#asahi` @ [Libera.Chat](https://libera.chat/)
*   [Asahi Linux Discord](https://discord.gg/asahi-linux)

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 延伸閱讀

*   [Asahi Linux Open OS Interoperability](https://asahilinux.org/docs/platform/open-os-interop/) - 理解 Apple Silicon 啟動流程
*   [Linux Kernel Devicetree](https://docs.kernel.org/devicetree/usage-model.html) - 為什麼需要 update-m1n1
*   [User:Jared/Gentoo On An M1 Mac](https://wiki.gentoo.org/wiki/User:Jared/Gentoo_On_An_M1_Mac) - 社群成员的安裝指南

</div>

</div>

---

## 結語

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; text-align: center;">

### 祝你在 Apple Silicon 上享受 Gentoo！

這份指南基于官方 [Project:Asahi/Guide](https://wiki.gentoo.org/wiki/Project:Asahi/Guide) 并簡化流程，標記了可選步驟，让更多人能輕鬆嘗試。

**記住三个關鍵点**：
1.  使用官方 Gentoo Asahi Live USB（無需 Fedora 中轉）
2.  asahi-gentoosupport 腳本可自動化大部分流程
3.  每次核心更新后必須执行 `update-m1n1`

有任何问题欢迎到社群提問！

</div>
