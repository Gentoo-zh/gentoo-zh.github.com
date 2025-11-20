---
title: "在 Apple Silicon Mac 上安裝 Gentoo Linux（M1/M2/M3/M4 完整教學）"
date: 2025-10-02
categories: ["tutorial"]
authors: ["zakkaus"]
---

![Gentoo on Apple Silicon Mac](gentoo-asahi-mac.webp)

**簡介**

本指南將引導你在 Apple Silicon Mac（M1/M2/M3/M4）上安裝原生 ARM64 Gentoo Linux。

**重要更新**：Asahi Linux 專案團隊（尤其是 [chadmed](https://github.com/chadmed/gentoo-asahi-releng)）的卓越工作使得現在有了[官方 Gentoo Asahi 安裝指南](https://wiki.gentoo.org/wiki/Project:Asahi/Guide)，安裝流程已大幅簡化。

**本指南特色**：
- 基於官方最新流程（2025.10）
- 使用官方 Gentoo Asahi Live USB（無需 Fedora 中轉）
- 清楚標記可選與必選步驟
- 簡化版適合所有人（包含加密選項）

已驗證至 2025 年 11 月 20 日。


> **目標平台**：Apple Silicon Mac（M1/M2/M3/M4）ARM64 架構。本指南使用 Asahi Linux 引導程式進行初始設置，然後轉換為完整的 Gentoo 環境。

---

## 安裝流程總覽（簡化版）

**必選步驟**：
1. 下載官方 Gentoo Asahi Live USB 映像
2. 透過 Asahi 安裝程式設置 U-Boot 環境
3. 從 Live USB 啟動
4. 分割磁碟並掛載檔案系統
5. 展開 Stage3 並進入 chroot
6. 安裝 Asahi 支援套件（自動化腳本）
7. 重開機完成安裝

**可選步驟**：
- LUKS 加密（建議但非必須）
- 自訂內核配置（預設 dist-kernel 即可）
- 音訊設定（PipeWire，依需求）
- 桌面環境選擇

整個流程會在你的 Mac 上建立雙啟動環境：macOS + Gentoo Linux ARM64。

> **官方簡化**：現在可使用 [asahi-gentoosupport 自動化腳本](https://github.com/chadmed/asahi-gentoosupport) 完成大部分配置！

---

## 事前準備與注意事項 {#prerequisites}

### 硬體需求

- Apple Silicon Mac（M1/M2/M3/M4 系列晶片）
- 至少 80 GB 的可用磁碟空間（建議 120 GB+）
- 穩定的網路連線（Wi-Fi 或乙太網路）
- 備份所有重要資料

### 重要警告

**本指南包含進階操作**：
- 會調整你的分割表
- 需要與 macOS 共存
- 涉及加密磁碟操作
- Apple Silicon 對 Linux 的支援仍在積極開發中

**已知可運作的功能**：
- CPU、記憶體、儲存裝置
- Wi-Fi（透過 Asahi Linux 韌體）
- 鍵盤、觸控板、電池管理
- 顯示輸出（內建螢幕與外接顯示器）
- USB-C / Thunderbolt

**已知限制**：
- Touch ID 無法使用
- macOS 虛擬化功能受限
- 部分新硬體功能可能未完全支援
- GPU 加速仍在開發中（OpenGL 部分支援）

---

## 0. 準備 Gentoo Asahi Live USB {#step-0-prepare}

### 0.1 下載官方 Gentoo Asahi Live USB

**官方簡化流程**：直接使用 Gentoo 提供的 ARM64 Live USB，無需透過 Fedora！

下載最新版本：
```bash
# 方法 1：從官方臨時站點下載（官方釋出前）
https://chadmed.au/pub/gentoo/

# 方法 2：（官方正式釋出後）
# 前往 https://www.gentoo.org/downloads/ 下載 ARM64 Asahi 版本
```

> **提示**：官方正在整合 Asahi 支援到標準 Live USB。目前使用 chadmed 維護的版本。

> **映像版本相容性警告**：
> - **推薦使用**：`install-arm64-asahi-20250603.iso`（2025年6月版本，已測試穩定）
> - **可能無法啟動**：`install-arm64-asahi-20251022.iso`（2025年10月版本）在某些裝置（如 M2 MacBook）上可能無法正常啟動
> - **建議**：如果 latest 版本無法啟動，請嘗試使用 20250603 版本
> - 可用映像列表：
>   ```
>   install-arm64-asahi-20250603.iso    (穩定，推薦)
>   install-arm64-asahi-20251022.iso    (較新，可能不穩定)
>   install-arm64-asahi-latest.iso      (指向最新版本)
>   ```

### 0.2 製作啟動 USB

在 macOS 中：

```bash
# 查看 USB 裝置名稱
diskutil list

# 卸載 USB（假設為 /dev/disk4）
diskutil unmountDisk /dev/disk4

# 寫入映像（注意使用 rdisk 較快）
sudo dd if=install-arm64-asahi-*.iso of=/dev/rdisk4 bs=4m status=progress

# 完成後彈出
diskutil eject /dev/disk4
```

---

## 1. 設置 Asahi U-Boot 環境 {#step-1-asahi}

### 1.1 執行 Asahi 安裝程式

在 macOS Terminal 中執行：

```bash
curl https://alx.sh | sh
```

> **安全提示**：建議先前往 <https://alx.sh> 檢視腳本內容，確認安全後再執行。

### 1.2 跟隨安裝程式步驟

安裝程式會引導你：

1. **選擇動作**：輸入 `r` (Resize an existing partition to make space for a new OS)

2. **選擇分割空間**：決定分配給 Linux 的空間（建議至少 80 GB）
   - 可使用百分比（如 `50%`）或絕對大小（如 `120GB`）
   
   > **提示**：建議保留 macOS 分割，以便日後更新韌體。

3. **選擇作業系統**：選擇 **UEFI environment only (m1n1 + U-Boot + ESP)**
   ```
   » OS: <選擇 UEFI only 選項>
   ```
   
   > **官方建議**：選擇 UEFI only 即可，不需要安裝完整發行版。

4. **設定名稱**：輸入 `Gentoo` 作為作業系統名稱
   ```
   » OS name: Gentoo
   ```

5. **完成安裝**：記下螢幕指示，然後按 Enter 關機。

### 1.3 完成 Recovery 模式設置（關鍵步驟）

**重要的重啟步驟**：

1. **等待 25 秒**確保系統完全關機
2. **按住電源鍵**直到看到「Loading startup options...」或旋轉圖示
3. **釋放電源鍵**
4. 等待音量列表出現，選擇 **Gentoo**
5. 你會看到 macOS Recovery 畫面：
   - 若要求「Select a volume to recover」，選擇你的 macOS 音量並點擊 Next
   - 輸入 macOS 使用者密碼（FileVault 使用者）
6. 依照螢幕指示完成設定

> **故障排除**：若遇到啟動迴圈或要求重新安裝 macOS，請按住電源鍵完全關機，然後從步驟 1 重新開始。可選擇 macOS 開機，執行 `curl https://alx.sh | sh` 並選擇 `p` 選項重試。

---

## 2. 從 Live USB 啟動 {#step-2-boot}

### 2.1 連接 Live USB 並啟動

1. **插入 Live USB**（可透過 USB Hub 或 Dock）
2. **啟動 Mac**
3. **U-Boot 自動啟動**：
   - 若選擇了「UEFI environment only」，U-Boot 會自動從 USB 啟動 GRUB
   - 等待 2 秒自動啟動序列
   - 若有多個系統，可能需要中斷並手動選擇

> **提示**：若需手動指定 USB 啟動，在 U-Boot 提示符下執行：
> ```
> setenv boot_targets "usb"
> setenv bootmeths "efi"
> boot
> ```

### 2.2 設定網路（Live 環境）

Gentoo Live USB 內建網路工具：

**Wi-Fi 連線**：
```bash
net-setup
```

依照互動提示設定網路。完成後檢查：

```bash
ping -c 3 www.gentoo.org
```

> **提示**：Apple Silicon 的 Wi-Fi 已包含在內核中，應可正常運作。若不穩定，嘗試連接 2.4 GHz 網路。

**（可選）SSH 遠端操作**：
```bash
passwd                     # 設定 root 密碼
/etc/init.d/sshd start
ip a | grep inet          # 取得 IP 位址
```

---

## 3. 分割與檔案系統設置 {#step-3-partition}

### 3.1 識別磁碟與分割

> **重要警告**：**不要修改現有的 APFS 容器、EFI 分割或 Recovery 分割！** 只能在 Asahi 安裝程式預留的空間中操作。

查看分割結構：
```bash
lsblk
blkid --label "EFI - GENTO"  # 查看你的 EFI 分區
```

通常會看到：
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

EFI 分區識別（**不要動這個分區！**）：
```bash
livecd ~ # blkid --label "EFI - GENTO" 
/dev/nvme0n1p4  # 這是 EFI 分區勿動
```


> **建議**：使用 `cfdisk` 進行分割，它理解 Apple 分割類型並會保護系統分割。

### 3.2 建立根分割

假設空白空間從 `/dev/nvme0n1p5` 開始：

**方法 A：簡單分割（無加密）**

```bash
# 使用 cfdisk 建立新分割
cfdisk /dev/nvme0n1
```

你會看到類似以下的分割表：
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
1. 選擇 **Free space** → **New**
2. 使用全部空間（或自訂大小）
3. **Type** → 選擇 **Linux filesystem**
4. **Write** → 輸入 `yes` 確認
5. **Quit** 離開

**格式化分區**：
```bash
# 格式化為 ext4 或 btrfs
mkfs.ext4 /dev/nvme0n1p6
# 或
mkfs.btrfs /dev/nvme0n1p6

# 掛載
mount /dev/nvme0n1p6 /mnt/gentoo
```

**方法 B：加密分割（可選，建議）**

```bash
# 建立 LUKS2 加密分割
cryptsetup luksFormat --type luks2 --pbkdf argon2id --hash sha512 --key-size 512 /dev/nvme0n1p6

# 輸入 YES 確認，設定加密密碼

# 開啟加密分割
cryptsetup luksOpen /dev/nvme0n1p6 gentoo-root

# 格式化
mkfs.btrfs --label root /dev/mapper/gentoo-root

# 掛載
mount /dev/mapper/gentoo-root /mnt/gentoo
```

> **為什麼用這些參數？**
> - `argon2id`：抗 ASIC/GPU 暴力破解
> - `aes-xts`：M1 有 AES 指令集，硬體加速
> - `luks2`：更好的安全工具

### 3.3 掛載 EFI 分割

```bash
mkdir -p /mnt/gentoo/boot
mount /dev/nvme0n1p4 /mnt/gentoo/boot
```

---

## 4. Stage3 與 chroot {#step-4-stage3}

> **從這裡開始遵循 [AMD64 Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)** 直到內核安裝章節。

### 4.1 下載並展開 Stage3

```bash
cd /mnt/gentoo

# 下載最新 ARM64 Desktop systemd Stage3
wget https://distfiles.gentoo.org/releases/arm64/autobuilds/current-stage3-arm64-desktop-systemd/stage3-arm64-desktop-systemd-*.tar.xz

# 展開（保持屬性）
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

### 4.2 設定 Portage

```bash
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

### 4.3 同步系統時間（重要）

在進入 chroot 前，確保系統時間正確（避免編譯和 SSL 憑證問題）：

```bash
# 同步時間
chronyd -q

# 驗證時間是否正確
date
```

> **為什麼需要同步時間？**
> - 編譯套件時需要正確的時間戳記
> - SSL/TLS 憑證驗證依賴準確的系統時間
> - 如果時間不正確，可能導致 emerge 失敗或憑證錯誤

### 4.4 進入 chroot 環境

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

**進入 chroot**：
```bash
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```

### 4.5 基本系統配置

**設定 make.conf**（針對 Apple Silicon 最佳化）：

編輯 `/etc/portage/make.conf`：
```bash
nano -w /etc/portage/make.conf
```

加入或修改以下內容：
```conf
# vim: set language=bash;
CHOST="aarch64-unknown-linux-gnu"

# Apple Silicon 最佳化編譯參數
COMMON_FLAGS="-march=armv8.5-a+fp16+simd+crypto+i8mm -mtune=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
RUSTFLAGS="-C target-cpu=native"

# 保持建置輸出為英文（回報錯誤時請保留此設定）
LC_MESSAGES=C

# 根據硬體調整（例如 M2 Max 有更多核心）
MAKEOPTS="-j4"

# Gentoo 鏡像源（推薦使用 R2 鏡像，速度較快）
GENTOO_MIRRORS="https://gentoo.rgst.io/gentoo"

# Emerge 預設選項（最多同時編譯 3 個套件）
EMERGE_DEFAULT_OPTS="--jobs 3"

# Asahi GPU 驅動
VIDEO_CARDS="asahi"

# 中文本地化支援（可選）
L10N="zh-CN zh-TW zh en"

# 檔案末尾保留換行符號！重要！
```

**同步 Portage**：
```bash
emerge-webrsync
```

**設定時區**：
```bash
# 設定為台灣時區（或改為你所在的時區）
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
```

**設定語系**：
```bash
# 編輯 locale.gen，取消註解需要的語系
nano -w /etc/locale.gen
# 取消註解：en_US.UTF-8 UTF-8
# 取消註解：zh_TW.UTF-8 UTF-8（如需中文）

# 生成語系
locale-gen

# 選擇系統預設語系
eselect locale set en_US.utf8

# 重新載入環境
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

**建立使用者與設定密碼**：
```bash
# 建立使用者（替換 <使用者名稱> 為你的使用者名）
useradd -m -G wheel,audio,video,usb,input <使用者名稱>

# 設定使用者密碼
passwd <使用者名稱>

# 設定 root 密碼
passwd root
```

---

## 5. 安裝 Asahi 支援套件（核心步驟）{#step-5-asahi}

> **官方簡化流程**：這一章節取代 Handbook 的「安裝內核」章節。

### 5.1 方法 A：自動化安裝（推薦）

**步驟 1：安裝 git**

```bash
# 首次同步 Portage 樹
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

此腳本會自動完成：
- 啟用 Asahi overlay
- 安裝 GRUB bootloader
- 設定 VIDEO_CARDS="asahi"
- 安裝 asahi-meta（包含內核、韌體、m1n1、U-Boot）
- 執行 `asahi-fwupdate` 和 `update-m1n1`
- 更新系統

> **如果遇到 USE flag 衝突**：
> 腳本執行過程中可能會提示 USE flag 需要變更。解決方法：
> ```bash
> # 當腳本提示 USE flag 衝突時，按 Ctrl+C 中斷腳本
> # 然後執行：
> emerge --autounmask-write <出現衝突的套件>
>
> # 更新設定檔
> etc-update
> # 在 etc-update 中選擇適合的選項（通常選擇 -3 自動合併）
>
> # 重新執行安裝腳本
> cd /tmp/asahi-gentoosupport
> ./install.sh
> ```

**腳本完成後直接跳到步驟 6（fstab 配置）！**

---

### 5.2 方法 B：手動安裝（進階使用者）

**步驟 1：安裝 git 並配置 Asahi overlay**

```bash
# 首次同步 Portage 樹
emerge --sync

# 安裝 git（用於 git 同步方式）
emerge --ask dev-vcs/git

# 刪除舊的 Portage 資料庫並切換到 git 同步
rm -rf /var/db/repos/gentoo
sudo tee /etc/portage/repos.conf/gentoo.conf << 'EOF'
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = git
sync-uri = https://github.com/gentoo-mirror/gentoo.git
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

> **鏡像源說明**：
> - 使用 GitHub 鏡像（如上）通常已經足夠快速
> - 更多鏡像源選項參考：[鏡像列表](/mirrorlist/)

**步驟 2：配置 package.mask（重要！）**

防止 Gentoo 官方的 dist-kernel 覆蓋 Asahi 版本：

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

# Asahi 專用 USE flags
cat > /etc/portage/package.use/asahi << 'EOF'
dev-lang/rust-bin rustfmt rust-src
dev-lang/rust rustfmt rust-src
EOF

# VIDEO_CARDS 設定
echo 'VIDEO_CARDS="asahi"' >> /etc/portage/make.conf

# GRUB 平台設定（必須！）
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
```

**步驟 4：配置固件許可證**

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

> 如果 `etc-update` 出現配置文件衝突，選擇 `-3` 進行自動合併。

套件說明：
- `rust-bin`：編譯 Asahi 內核組件需要（必須先安裝）
- `asahi-meta`：包含 m1n1、asahi-fwupdate、U-Boot 等工具
- `virtual/dist-kernel:asahi`：Asahi 特製內核（包含未上游的補丁）
- `linux-firmware`：提供 Wi-Fi 等硬體固件

**步驟 7：更新韌體與引導程式**

```bash
asahi-fwupdate
update-m1n1
```

> **重要**：每次更新內核、U-Boot 或 m1n1 時都必須執行 `update-m1n1`！

**步驟 8：安裝並配置 GRUB**

```bash
# 安裝 GRUB
emerge -q grub:2

# 安裝 GRUB 到 ESP（注意 --removable 標誌很重要！）
grub-install --boot-directory=/boot/ --efi-directory=/boot/ --removable

# 生成 GRUB 配置
grub-mkconfig -o /boot/grub/grub.cfg
```

> **關鍵要點**：
> - `--removable` 標誌是必須的，確保系統能從 ESP 啟動
> - `--boot-directory` 和 `--efi-directory` 都必須指向 `/boot/`
> - 必須在 make.conf 中設定 `GRUB_PLATFORMS="efi-64"`

**步驟 9：更新系統（可選）**

```bash
emerge --ask --update --deep --changed-use @world
```

---

### 5.3 配置 fstab

取得 UUID：
```bash
blkid $(blkid --label root)       # 根分割（或 /dev/mapper/gentoo-root）
blkid $(blkid --label "EFI - GENTO")     # boot 分割
```

編輯 `/etc/fstab`：
```bash
nano -w /etc/fstab
```

```fstab
# 根分割（依你的配置調整）
UUID=<your-root-uuid>  /      ext4   defaults  0 1
# 或加密版本：
# UUID=<your-btrfs-uuid>  /      btrfs  defaults  0 1

UUID=<your-boot-uuid>  /boot  vfat   defaults  0 2
```

### 5.4 配置加密支援（僅加密用戶）

> **注意**：如果你在步驟 3.2 中選擇了加密分割，才需要執行此步驟。

**步驟 1：啟用 systemd cryptsetup 支援**

```bash
mkdir -p /etc/portage/package.use
echo "sys-apps/systemd cryptsetup" >> /etc/portage/package.use/fde

# 重新編譯 systemd 以啟用 cryptsetup 支援
emerge --ask --oneshot sys-apps/systemd
```

**步驟 2：取得 LUKS 分割的 UUID**

```bash
# 取得 LUKS 加密容器的 UUID（不是裡面的檔案系統 UUID）
blkid /dev/nvme0n1p5
```

輸出範例：
```
/dev/nvme0n1p5: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" ...
```

記下這個 **LUKS UUID**（例如：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）。

**步驟 3：配置 GRUB 內核參數**

```bash
nano -w /etc/default/grub
```

加入或修改以下內容（**替換 UUID 為實際值**）：
```conf
# 完整範例（替換 UUID 為你的實際 UUID）
GRUB_CMDLINE_LINUX="rd.luks.uuid=3f5a6527-7334-4363-9e2d-e0e8c7c04488 rd.luks.allow-discards root=UUID=f3db74a5-dc70-48dd-a9a3-797a0daf5f5d rootfstype=btrfs"
```

> **參數說明**：
> - `rd.luks.uuid=<UUID>`：LUKS 加密分割的 UUID（使用 `blkid /dev/nvme0n1p6` 取得）
> - `rd.luks.allow-discards`：允許 SSD TRIM 指令穿透加密層（提升 SSD 效能）
> - `root=UUID=<UUID>`：解密後的 btrfs 檔案系統 UUID（使用 `blkid /dev/mapper/gentoo-root` 取得）
> - `rootfstype=btrfs`：根檔案系統類型（如果使用 ext4 改為 `ext4`）

**步驟 4：安裝並配置 dracut**

```bash
# 安裝 dracut（如果還沒安裝）
emerge --ask sys-kernel/dracut
```

**步驟 5：配置 dracut for LUKS 解密**

建立 dracut 配置檔：
```bash
nano -w /etc/dracut.conf.d/luks.conf
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

> **配置說明**：
> - `crypt` 和 `dm` 模組提供 LUKS 解密支援
> - `systemd` 模組用於 systemd 啟動環境
> - `btrfs` 模組支援 btrfs 檔案系統（如果使用 ext4 改為 `ext4`）

**步驟 6：配置 /etc/crypttab（可選但推薦）**

```bash
nano -w /etc/crypttab
```

加入以下內容（**替換 UUID 為你的 LUKS UUID**）：
```conf
gentoo-root UUID=<LUKS-UUID> none luks,discard
```

> 這樣配置後，系統會自動識別並提示解鎖加密分割。

**步驟 7：重新產生 initramfs**

```bash
# 取得目前內核版本
dracut --kver $(make -C /usr/src/linux -s kernelrelease) --force
```

> **重要**：每次更新內核後，也需要重新執行此命令產生新的 initramfs！

**步驟 8：更新 GRUB 配置**

```bash
grub-mkconfig -o /boot/grub/grub.cfg

# 驗證 initramfs 被正確引用
grep initrd /boot/grub/grub.cfg
```

---

## 6. 完成安裝與重開機 {#step-6-finalize}

### 6.1 最後設定

**設定主機名稱**：
```bash
echo "macbook" > /etc/hostname
```

**啟用 NetworkManager**（桌面系統）：
```bash
systemctl enable NetworkManager
```

**設定 root 密碼**（如果還沒設定）：
```bash
passwd root
```

### 6.2 離開 chroot 並重開機

```bash
exit
umount -R /mnt/gentoo
# 若使用加密：
cryptsetup luksClose gentoo-root

reboot
```

### 6.3 首次啟動

1. U-Boot 會自動啟動
2. GRUB 選單出現，選擇 Gentoo
3. （若加密）輸入 LUKS 密碼
4. 系統應成功啟動到登入提示

> **恭喜！基本系統已安裝完成！**

---

## 7. 安裝後配置（可選）{#step-7-post}

### 7.1 網路連線

```bash
# Wi-Fi
nmcli device wifi connect <SSID> password <密碼>

# 或使用 nmtui（圖形界面）
nmtui
```

### 7.2 安裝桌面環境（可選）

> **重要提示**：安裝桌面環境前，建議切換到對應的系統 profile，這會自動設定許多必要的 USE flags。

#### 步驟 1：查看並選擇系統 Profile

```bash
# 列出所有可用的 profile
eselect profile list
```

輸出範例：
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

**選擇適合的 profile**：

```bash
# GNOME 桌面
eselect profile set 5    # desktop/gnome/systemd

# KDE Plasma 桌面（推薦）
eselect profile set 7    # desktop/plasma/systemd

# 通用桌面環境（Xfce 等）
eselect profile set 3    # desktop (不含特定桌面)
```

> **Profile 說明**：
> - `desktop/gnome/systemd`：自動啟用 GNOME 相關 USE flags（gtk、gnome、wayland 等）
> - `desktop/plasma/systemd`：自動啟用 KDE 相關 USE flags（qt5、kde、plasma 等）
> - `desktop`：基礎桌面 USE flags（X、dbus、networkmanager 等）

#### 步驟 2：更新系統以套用新 Profile

切換 profile 後，需要重新編譯受影響的套件：

```bash
# 更新所有套件以套用新的 USE flags
emerge -avuDN @world
```

#### 步驟 3：安裝桌面環境

**選項 A：KDE Plasma（推薦）**

```bash
# 安裝 KDE Plasma 桌面
emerge --ask kde-plasma/plasma-meta kde-apps/kate kde-apps/dolphin

# 啟用顯示管理器
systemctl enable sddm

# 安裝常用應用（可選）
emerge --ask kde-apps/konsole \
             kde-apps/okular \
             www-client/firefox
```

**選項 B：GNOME**

```bash
# 安裝完整 GNOME 桌面
emerge --ask gnome-base/gnome gnome-extra/gnome-tweaks

# 啟用顯示管理器
systemctl enable gdm

# 安裝常用應用（可選）
emerge --ask gnome-extra/gnome-system-monitor \
             gnome-extra/gnome-calculator \
             www-client/firefox
```

**選項 C：Xfce（輕量級）**

```bash
# 先切換回通用桌面 profile
eselect profile set 3    # desktop

# 更新系統
emerge -avuDN @world

# 安裝 Xfce
emerge --ask xfce-base/xfce4-meta xfce-extra/xfce4-pulseaudio-plugin

# 安裝並啟用顯示管理器
emerge --ask x11-misc/lightdm
systemctl enable lightdm
```

#### 步驟 4：優化桌面性能（可選）

**啟用視訊加速（Asahi GPU）**：

```bash
# 檢查 VIDEO_CARDS 設定
grep VIDEO_CARDS /etc/portage/make.conf
# 應該包含：VIDEO_CARDS="asahi"

# 安裝 Mesa 與 Asahi 驅動（通常已安裝）
emerge --ask media-libs/mesa
```

**啟用字型渲染**：

```bash
# 安裝基礎字型
emerge --ask media-fonts/liberation-fonts \
             media-fonts/noto \
             media-fonts/noto-cjk \
             media-fonts/dejavu

# 啟用字型微調
eselect fontconfig enable 10-sub-pixel-rgb.conf
eselect fontconfig enable 11-lcdfilter-default.conf
```

**中文輸入法配置**：

```bash
# 安裝 Fcitx5 中文輸入法
emerge --ask app-i18n/fcitx-chinese-addons
```

> **注意**：`app-i18n/fcitx-rime` 在當前版本實測無法正常使用，建議使用 `app-i18n/fcitx-chinese-addons` 作為替代方案。

> **提示**：
> - 首次安裝桌面環境預計需要 **2-4 小時**（取決於 CPU 效能）
> - 建議使用 `--jobs 3` 或更少，避免記憶體不足
> - 可以在 `/etc/portage/make.conf` 設定 `EMERGE_DEFAULT_OPTS="--jobs 3 --load-average 8"`

### 7.3 音訊配置（可選）

Asahi 音訊透過 PipeWire 提供。安裝並啟用相關服務：

```bash
# 安裝 Asahi 音訊支援
emerge --ask media-libs/asahi-audio

# 啟用 PipeWire 服務
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service
```
---

## 8. 系統維護 {#step-8-maintenance}

### 8.1 定期更新流程

```bash
# 更新 Portage 樹（包含 Asahi overlay）
emerge --sync
# 或手動同步 Asahi overlay：
emaint -r asahi sync

# 更新所有套件
emerge -avuDN @world

# 清理不需要的套件
emerge --depclean

# 更新設定檔
dispatch-conf
```

### 8.2 更新內核後必做

> **極度重要**：每次內核更新後必須執行！

```bash
# 更新 m1n1 Stage 2（包含 devicetree）
update-m1n1

# 重新生成 GRUB 配置
grub-mkconfig -o /boot/grub/grub.cfg
```

**為什麼？** m1n1 Stage 2 包含 devicetree blobs，內核需要它來識別硬體。不更新可能導致無法啟動或功能缺失。

> **自動化**：`sys-apps/asahi-scripts` 提供 installkernel hook 自動執行這些步驟。

### 8.3 更新韌體

macOS 系統更新時會包含韌體更新。**建議保留 macOS 分割**以便取得最新韌體。

---

## 9. 常見問題與排錯 {#faq}

### 問題：無法從 USB 啟動

**可能原因**：U-Boot 的 USB 驅動仍有限制。

**解決方法**：
- 嘗試不同的 USB 隨身碟
- 使用 USB 2.0 裝置（相容性較好）
- 透過 USB Hub 連接

### 問題：啟動卡住或黑屏

**原因**：m1n1/U-Boot/內核不匹配。

**解決方法**：
1. 從 macOS 重新執行 Asahi 安裝程式
2. 選擇 `p` 選項重試 Recovery 流程
3. 確保在 chroot 中執行了 `update-m1n1`

### 問題：加密分割無法解鎖

**原因**：dracut 配置錯誤或 UUID 不對。

**解決方法**：
1. 檢查 `/etc/default/grub` 中的 `GRUB_CMDLINE_LINUX`
2. 確認使用正確的 LUKS UUID：`blkid /dev/nvme0n1p5`
3. 重新生成 GRUB 配置：`grub-mkconfig -o /boot/grub/grub.cfg`

### 問題：Wi-Fi 不穩定

**原因**：可能是 WPA3 或 6 GHz 頻段問題。

**解決方法**：
- 連接 WPA2 網路
- 使用 2.4 GHz 或 5 GHz 頻段（避免 6 GHz）

### 問題：觸控板無法使用

**原因**：韌體未載入或驅動問題。

**解決方法**：
```bash
# 檢查韌體
dmesg | grep -i firmware

# 確保安裝了 asahi-meta
emerge --ask sys-apps/asahi-meta
```

---

## 10. 進階技巧（可選）{#advanced}

### 10.1 瀏海（Notch）配置

預設瀏海區域會顯示為黑色。要啟用：

```bash
# 在 GRUB 內核參數中加入
apple_dcp.show_notch=1
```

**KDE Plasma 最佳化**：
- 在頂部新增全寬面板，高度對齊瀏海底部
- 左側：Application Dashboard、Global menu、Spacer
- 右側：System Tray、Bluetooth、Power、時鐘

### 10.2 自訂內核（進階）

使用 Distribution kernel 即可，但若要自訂：

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

> **記得保留可用內核作為備援**！

### 10.3 多內核切換

支援多個內核共存：

```bash
eselect kernel list
eselect kernel set <number>
update-m1n1  # 切換後必須執行！
```

---

## 11. 參考資料 {#reference}

### 官方文件

- **[Gentoo Wiki: Project:Asahi/Guide](https://wiki.gentoo.org/wiki/Project:Asahi/Guide)** ⭐ 官方最新指南
- [Asahi Linux Official Site](https://asahilinux.org/)
- [Asahi Linux Feature Support](https://asahilinux.org/docs/platform/feature-support/overview/)
- [Gentoo AMD64 Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)（流程相同）

### 工具與腳本

- [asahi-gentoosupport](https://github.com/chadmed/asahi-gentoosupport) - 自動化安裝腳本
- [Gentoo Asahi Releng](https://github.com/chadmed/gentoo-asahi-releng) - Live USB 建置工具

### 社群支援

**Gentoo 中文社群**：
- Telegram 群組：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 頻道：[@gentoocn](https://t.me/gentoocn)
- [GitHub](https://github.com/gentoo-zh)

**官方社群**：
- [Gentoo Forums](https://forums.gentoo.org/)
- IRC: `#gentoo` 和 `#asahi` @ [Libera.Chat](https://libera.chat/)
- [User:Jared/Gentoo On An M1 Mac](https://wiki.gentoo.org/wiki/User:Jared/Gentoo_On_An_M1_Mac)
- [Asahi Linux Discord](https://discord.gg/asahi-linux)

### 延伸閱讀

- [Asahi Linux Open OS Interoperability](https://asahilinux.org/docs/platform/open-os-interop/) - 理解 Apple Silicon 啟動流程
- [Linux Kernel Devicetree](https://docs.kernel.org/devicetree/usage-model.html) - 為什麼需要 update-m1n1

---

## 結語

**祝你在 Apple Silicon 上享受 Gentoo！**

這份指南基於官方 [Project:Asahi/Guide](https://wiki.gentoo.org/wiki/Project:Asahi/Guide) 並簡化流程，標記了可選步驟，讓更多人能輕鬆嘗試。

**記住三個關鍵點**：
1. 使用官方 Gentoo Asahi Live USB（無需 Fedora 中轉）
2. asahi-gentoosupport 腳本可自動化大部分流程
3. 每次內核更新後必須執行 `update-m1n1`

有任何問題歡迎到社群提問！
