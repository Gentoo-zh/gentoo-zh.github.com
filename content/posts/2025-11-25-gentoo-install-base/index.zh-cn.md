---
title: "Gentoo Linux 安装指南 (基础篇)"
date: 2025-11-25
summary: "Gentoo Linux 基础系统安装教程，涵盖分区、Stage3、内核编译、引导程序配置等。"
description: "2025 年最新 Gentoo Linux 安装指南 (基础篇)，详细讲解 UEFI 安装流程、内核编译等。适合 Linux 进阶用户和 Gentoo 新手。"
keywords:
  - Gentoo Linux
  - Linux 安装
  - 源码编译
  - systemd
  - OpenRC
  - Portage
  - make.conf
  - 内核编译
  - UEFI 安装
tags:
  - Gentoo
  - Linux
  - 教程
  - 系统安装
categories:
  - tutorial
authors:
  - zakkaus
---

> **文章特别说明**
>
> 本文是 **Gentoo Linux 安装指南** 系列的第一部分：**基础安装**。
>
> **系列导航**：
> 1. **基础安装（本文）**：从零开始安装 Gentoo 基础系统
> 2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：显卡驱动、桌面环境、输入法等
> 3. [进阶优化](/posts/2025-11-25-gentoo-install-advanced/)：make.conf 优化、LTO、系统维护
>
> **建议阅读方式**：
> - 按需阅读：基础安装（0-11 节）→ 桌面配置（12 节）→ 进阶优化（13-17 节）
>
> ---
>
> ### 关于本指南
>
> 本文旨在提供一个完整的 Gentoo 安装流程演示，并**密集提供可供学习的参考文献**。文章中包含大量官方 Wiki 链接和技术文档，帮助读者深入理解每个步骤的原理和配置细节。
>
> **这不是一份简单的傻瓜式教程，而是一份引导性的学习资源**——使用 Gentoo 的第一步是学会自己阅读 Wiki 并解决问题，善用 Google 甚至 AI 工具寻找答案。遇到问题或需要深入了解时，请务必查阅官方手册和本文提供的参考链接。
>
> 如果在阅读过程中遇到疑问或发现问题，欢迎通过以下渠道提出：
> - **Gentoo 中文社区**：[Telegram 群组](https://t.me/gentoo_zh) | [Telegram 频道](https://t.me/gentoocn) | [GitHub](https://github.com/Gentoo-zh)
> - **官方社区**：[Gentoo Forums](https://forums.gentoo.org/) | IRC: #gentoo @ Libera.Chat
>
> **非常建议以官方手册为准**：
> - [Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)
> - [Gentoo Handbook: AMD64 (简体中文)](https://wiki.gentoo.org/wiki/Handbook:AMD64/zh-cn)
>
> 本文为新迁移内容，如有不足之处敬请见谅。
>
> ---

## 什么是 Gentoo？

Gentoo Linux 是一个基于源码的 Linux 发行版，以其**高度可定制性**和**性能优化**著称。与其他发行版不同，Gentoo 让你从源代码编译所有软件，这意味着：

- **极致性能**：所有软件针对你的硬件优化编译
- **完全掌控**：你决定系统包含什么，不包含什么
- **深度学习**：通过亲手构建系统深入理解 Linux
- **编译时间**：初次安装需要较长时间（建议预留 3-6 小时）
- **学习曲线**：需要一定的 Linux 基础知识

**适合谁？**
- 想要深入学习 Linux 的技术爱好者
- 追求系统性能和定制化的用户
- 享受 DIY 过程的 Geek

**不适合谁？**
- 只想快速安装使用的新手（建议先尝试 Ubuntu、Fedora 等）
- 没有时间折腾系统的用户

<details>
<summary><b>核心概念速览（点击展开）</b></summary>

在开始安装前，先了解几个核心概念：

**Stage3** ([Wiki](https://wiki.gentoo.org/wiki/Stage_file))
一个最小化的 Gentoo 基础系统压缩包。它包含了构建完整系统的基础工具链（编译器、库等）。你将解压它到硬盘上，作为新系统的"地基"。

**Portage** ([Wiki](https://wiki.gentoo.org/wiki/Portage/zh-cn))
Gentoo 的包管理系统。它不直接安装预编译的软件包，而是下载源代码、根据你的配置编译，然后安装。核心命令是 `emerge`。

**USE Flags** ([Wiki](https://wiki.gentoo.org/wiki/USE_flag/zh-cn))
控制软件功能的开关。例如，`USE="bluetooth"` 会让所有支持蓝牙的软件在编译时启用蓝牙功能。这是 Gentoo 定制化的核心。

**Profile** ([Wiki](https://wiki.gentoo.org/wiki/Profile_(Portage)))
预设的系统配置模板。例如 `desktop/plasma/systemd` profile 会自动启用适合 KDE Plasma 桌面的默认 USE flags。

**Emerge** ([Wiki](https://wiki.gentoo.org/wiki/Emerge))
Portage 的命令行工具。常用命令：
- `emerge --ask <包名>` - 安装软件
- `emerge --sync` - 同步软件仓库
- `emerge -avuDN @world` - 更新整个系统

</details>

<details>
<summary><b>安装时间估算（点击展开）</b></summary>

| 步骤 | 预计时间 |
|---|----------|
| 准备安装媒介 | 10-15 分钟 |
| 磁盘分区与格式化 | 15-30 分钟 |
| 下载并解压 Stage3 | 5-10 分钟 |
| 配置 Portage 与 Profile | 15-20 分钟 |
| **编译内核**（最耗时） | **30 分钟 - 2 小时** |
| 安装系统工具 | 20-40 分钟 |
| 配置引导程序 | 10-15 分钟 |
| **安装桌面环境**（可选） | **1-3 小时** |
| **总计** | **3-6 小时**（取决于硬件性能）|

> **提示**：使用预编译内核和二进制包可以大幅缩短时间，但会牺牲部分定制性。

</details>

<details>
<summary><b>磁盘空间需求与开始前检查清单（点击展开）</b></summary>

### 磁盘空间需求

- **最小安装**：10 GB（无桌面环境）
- **推荐空间**：30 GB（轻量桌面）
- **舒适空间**：80 GB+（完整桌面 + 编译缓存）

### 开始前的检查清单

- 已备份所有重要数据
- 准备了 8GB+ 的 USB 闪存盘
- 确认网络连接稳定（有线网络最佳）
- 预留了充足的时间（建议完整的半天）
- 有一定的 Linux 命令行基础
- 准备好另一台设备查阅文档（或者使用 GUI LiveCD）

</details>

---

**简介**

本指南将引导你在 x86_64 UEFI 平台上安装 Gentoo Linux。

**本文将教你**：
- 从零开始安装 Gentoo 基础系统（分区、Stage3、内核、引导程序）
- 配置 Portage 并优化编译参数（make.conf、USE flags、CPU flags）
- 安装桌面环境（KDE Plasma、GNOME、Hyprland）
- 配置中文环境（locale、字体、Fcitx5 输入法）
- 可选进阶配置（加密分区、LTO 优化、内核调优、RAID）
- 系统维护（SSD TRIM、电源管理、Flatpak、系统更新）

> **请先关闭 Secure Boot**
> 在开始安装之前，请务必进入 BIOS 设置，将 **Secure Boot** 暂时关闭。
> 开启 Secure Boot 可能会导致安装介质无法启动，或者安装后的系统无法引导。你可以在系统安装完成并成功启动后，再参考本指南后面的章节重新配置并开启 Secure Boot。

> **重要**：开始前请务必备份所有重要数据！本指南涉及磁盘分区操作。

已验证至 2025 年 11 月 25 日。

---

## 0. 准备安装媒介 {#step-0-prepare}

> **可参考**：[Gentoo Handbook: AMD64 - 选择安装媒介](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media/zh-cn)

### 0.1 下载 Gentoo ISO

根据[**下载页面**](/download/) 提供的方式获取下载链接

> **注意**：以下链接中的日期（如 `20251123T...`）仅供参考，请务必在镜像站中选择**最新日期**的文件。

下载 Minimal ISO（以 BFSU 镜像站为例）：
```bash
wget https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso
wget https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso.asc
```

> 如果希望安装时能直接使用浏览器或更方便地连接 Wi-Fi，可以选择 **LiveGUI USB Image**。
>
> **新手入坑推荐使用每周构建的 KDE 桌面环境的 Live ISO**： <https://iso.gig-os.org/>
> （来自 Gig-OS <https://github.com/Gig-OS> 项目）
>
> **Live ISO 登录凭据**：
> - 账号：`live`
> - 密码：`live`
> - Root 密码：`live`
>
> **系统支持**：
> - 支持中文显示和中文输入法 (fcitx5), flclash 等

验证签名（可选）：
```bash
# 从密钥服务器获取 Gentoo 发布签名公钥
gpg --keyserver hkps://keys.openpgp.org --recv-keys 0xBB572E0E2D1829105A8D0F7CF7A88992
# --keyserver: 指定密钥服务器地址
# --recv-keys: 接收并导入公钥
# 0xBB...992: Gentoo Release Media 签名密钥指纹

# 验证 ISO 文件的数字签名
gpg --verify install-amd64-minimal-20251123T153051Z.iso.asc install-amd64-minimal-20251123T153051Z.iso
# --verify: 验证签名文件
# .iso.asc: 签名文件（ASCII armored）
# .iso: 被验证的 ISO 文件
```

### 0.2 制作 USB 安装盘

**Linux：**
```bash
sudo dd if=install-amd64-minimal-20251123T153051Z.iso of=/dev/sdX bs=4M status=progress oflag=sync
# if=输入文件 of=输出设备 bs=块大小 status=显示进度
```
> 请将 `sdX` 替换成 USB 装置名称，例如 `/dev/sdb`。

**Windows：** 推荐使用 [Rufus](https://rufus.ie/) → 选择 ISO → 写入时选 DD 模式。

---

## 1. 进入 Live 环境并连接网络 {#step-1-network}

> **可参考**：[Gentoo Handbook: AMD64 - 配置网络](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking/zh-cn)
>
> **为什么需要这一步？**
> Gentoo 的安装过程完全依赖网络来下载源码包 (Stage3) 和软件仓库 (Portage)。在 Live 环境中配置好网络是安装的第一步。

### 1.1 有线网络

```bash
ip link        # 查看网卡接口名称 (如 eno1, wlan0)
dhcpcd eno1    # 对有线网卡启用 DHCP 自动获取 IP
ping -c3 gentoo.org # 测试网络连通性
```

### 1.2 无线网络
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

> 若 WPA3 不稳定，请先退回 WPA2。

<details>
<summary><b>进阶设置：启动 SSH 方便远程操作（点击展开）</b></summary>

```bash
passwd                      # 设定 root 密码 (远程登录需要)
rc-service sshd start       # 启动 SSH 服务
rc-update add sshd default  # 设置 SSH 开机自启 (Live 环境中可选)
ip a | grep inet            # 查看当前 IP 地址
# 在另一台设备上：ssh root@<IP>
```

</details>


## 2. 规划磁盘分区 {#step-2-partition}

> **可参考**：[Gentoo Handbook: AMD64 - 准备磁盘](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn)
>
> **为什么需要这一步？**
> 我们需要为 Linux 系统划分独立的存储空间。UEFI 系统通常需要一个 ESP 分区 (引导) 和一个根分区 (系统)。合理的规划能让日后的维护更轻松。

检查磁盘：
```bash
lsblk -o NAME,SIZE,TYPE
```

启动 `cfdisk` 或 `gdisk`：
```bash
cfdisk /dev/nvme0n1
```

### 建议分区方案（UEFI）

| 分区 | 大小 | 文件系统 | 挂载点 | 备注 |
| ---- | ---- | -------- | ------ | ---- |
| ESP | 512 MB | FAT32 | /efi | `type EF00` |
| Boot | 1 GB | ext4 | /boot | 存放 kernel / initramfs |
| Root | 80~120 GB | ext4 / XFS / Btrfs | / | 系统与应用 |
| Home | 余量 | ext4 / XFS / Btrfs | /home | 用户资料 |
| Swap（可选） | 内存的 1~2 倍 | swap | swap | SSD 可改用 zram |

> 如果你想要最简配置，可以只保留 `/efi` + `/` 两个分区。

> **服务器/RAID 用户**：如果需要配置软件 RAID (mdadm)，请参考 **[Section 17. 服务器与 RAID 配置](/posts/2025-11-25-gentoo-install-advanced/#section-17-server-raid)**。RAID 配置需要在格式化之前完成。

### cfdisk 实战示例

```text
                               Disk: /dev/nvme0n1
           Size: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
          Label: gpt, identifier: 9737D323-129E-4B5F-9049-8080EDD29C02

    设备                Start       结束      扇区    Size 类型
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
 [ 删除 ]  [Resize]  [ 退出 ]  [ 类型 ]  [ 帮助 ]  [ Sort ]  [ 写入 ]  [ Dump ]
```

> `cfdisk` 操作提示：使用方向键移动，选择 `New`、`Type`、`Write` 等操作。确认无误后输入 `yes` 写入分区表。

---

## 3. 建立文件系统并挂载 {#step-3-filesystem}

> **可参考**：[Gentoo Handbook: AMD64 - 准备磁盘](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn)
> **可参考**：[Ext4](https://wiki.gentoo.org/wiki/Ext4/zh-cn) 和 [XFS](https://wiki.gentoo.org/wiki/XFS/zh-cn) 和 [Btrfs](https://wiki.gentoo.org/wiki/Btrfs/zh-cn)
>
> **为什么需要这一步？**
> 磁盘分区只是划分了空间，但还不能存储数据。建立文件系统 (如 ext4, Btrfs) 才能让操作系统管理和访问这些空间。挂载则是将这些文件系统连接到 Linux 文件树的特定位置。

### 3.1 格式化

```bash
mkfs.vfat -F32 /dev/nvme0n1p1  # 格式化 ESP 分区为 FAT32
mkfs.ext4 /dev/nvme0n1p2       # 格式化 Boot 分区为 ext4
mkfs.ext4 /dev/nvme0n1p3       # 格式化 Root 分区为 ext4
mkfs.ext4 /dev/nvme0n1p4       # 格式化 Home 分区为 ext4
mkswap /dev/nvme0n1p5          # 格式化 Swap 分区
```

若使用 Btrfs：
```bash
mkfs.btrfs -L gentoo /dev/nvme0n1p3
```

若使用 XFS：
```bash
mkfs.xfs /dev/nvme0n1p3
```

> 其他如 [F2FS](https://wiki.gentoo.org/wiki/F2FS/zh-cn) 或 [ZFS](https://wiki.gentoo.org/wiki/ZFS/zh-cn) 请参考相关 Wiki。

### 3.2 挂载（ext4 示例）

```bash
mount /dev/nvme0n1p3 /mnt/gentoo        # 挂载根分区
mkdir -p /mnt/gentoo/{boot,efi,home}    # 创建挂载点目录
mount /dev/nvme0n1p2 /mnt/gentoo/boot   # 挂载 Boot 分区
mount /dev/nvme0n1p1 /mnt/gentoo/efi    # 挂载 ESP 分区
mount /dev/nvme0n1p4 /mnt/gentoo/home   # 挂载 Home 分区
swapon /dev/nvme0n1p5                   # 启用 Swap 分区
```

<details>
<summary><b>进阶设置：Btrfs 子卷示例（点击展开）</b></summary>

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

> **Btrfs 快照建议**：
> 推荐使用 [Snapper](https://wiki.gentoo.org/wiki/Snapper) 管理快照。合理的子卷规划（如将 `@` 和 `@home` 分开）能让系统回滚更加轻松。

</details>

<details>
<summary><b>进阶设置：加密分区（LUKS）（点击展开）</b></summary>

```bash
# 建立 LUKS2 加密分区
cryptsetup luksFormat --type luks2 --pbkdf argon2id --hash sha512 --key-size 512 /dev/nvme0n1p3

# 打开加密分区
cryptsetup luksOpen /dev/nvme0n1p3 gentoo-root

# 格式化
mkfs.btrfs --label root /dev/mapper/gentoo-root

# 挂载
mount /dev/mapper/gentoo-root /mnt/gentoo
```

</details>

---

> **建议**：挂载完成后，建议使用 `lsblk` 确认挂载点是否正确。
>
> ```bash
> lsblk
> ```
>
> **输出示例**（类似如下）：
> ```text
> NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
>  nvme0n1          259:1    0 931.5G  0 disk  
> ├─nvme0n1p1      259:7    0    16M  0 part  
> ├─nvme0n1p2      259:8    0 419.5G  0 part  
> ├─nvme0n1p3      259:9    0     1G  0 part  /boot
> ├─nvme0n1p4      259:10   0     9G  0 part  [SWAP]
> ├─nvme0n1p5      259:11   0   246G  0 part  
> │ └─cryptroot    253:0    0   246G  0 crypt /snapshots/root
> │                                           /
> ```

## 4. 下载 Stage3 并进入 chroot {#step-4-stage3}

> **可参考**：[Gentoo Handbook: AMD64 - 安装 Gentoo 安装文件](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/zh-cn)
> **可参考**：[Stage file](https://wiki.gentoo.org/wiki/Stage_file)
>
> **为什么需要这一步？**
> Stage3 是一个最小化的 Gentoo 基础系统环境。我们将它解压到硬盘上，作为新系统的"地基"，然后通过 `chroot` 进入这个新环境进行后续配置。

### 4.1 选择 Stage3

- **OpenRC**：`stage3-amd64-openrc-*.tar.xz`
- **systemd**：`stage3-amd64-systemd-*.tar.xz`
- Desktop 变种只是预设开启部分 USE，标准版更灵活。

### 4.2 下载与展开

```bash
cd /mnt/gentoo
# 使用 links 浏览器访问镜像站下载 Stage3
links https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/ #以 BFSU 镜像站为例
# 解压 Stage3 压缩包
# x:解压 p:保留权限 v:显示过程 f:指定文件 --numeric-owner:使用数字ID
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

如果同时下载了 `.DIGESTS` 或 `.CONTENTS`，可以用 `openssl` 或 `gpg` 验证。

### 4.3 复制 DNS 并挂载伪文件系统

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/ # 复制 DNS 配置
mount --types proc /proc /mnt/gentoo/proc          # 挂载进程信息
mount --rbind /sys /mnt/gentoo/sys                 # 绑定挂载系统信息
mount --rbind /dev /mnt/gentoo/dev                 # 绑定挂载设备节点
mount --rbind /run /mnt/gentoo/run                 # 绑定挂载运行时信息
mount --make-rslave /mnt/gentoo/sys                # 设置为从属挂载 (防止卸载时影响宿主)
mount --make-rslave /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/run
```

> 使用 OpenRC 可以省略 `/run` 这一步。

### 4.4 进入 chroot

```bash
chroot /mnt/gentoo /bin/bash    # 切换根目录到新系统
source /etc/profile             # 加载环境变量
export PS1="(chroot) ${PS1}"    # 修改提示符以区分环境
```

---

## 5. 初始化 Portage 与 make.conf {#step-5-portage}

> **可参考**：[Gentoo Handbook: AMD64 - 安装 Gentoo 基本系统](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)
>
> **为什么需要这一步？**
> Portage 是 Gentoo 的包管理系统，也是其核心特色。初始化 Portage 并配置 `make.conf` 就像为你的新系统设定了「构建蓝图」，决定了软件如何编译、使用哪些功能以及从哪里下载。

### 5.1 同步树

```bash
emerge-webrsync   # 获取最新的 Portage 快照 (比 rsync 快)
emerge --sync     # 同步 Portage 树 (获取最新 ebuild)
emerge --ask app-editors/vim # 安装 Vim 编辑器 (推荐)
eselect editor list          # 列出可用编辑器
eselect editor set vi        # 将 Vim 设置为默认编辑器 (vi 通常是指向 vim 的软链接)
```

设置镜像（择一）：
```bash
mirrorselect -i -o >> /etc/portage/make.conf
# 或手动：
#以 BFSU 镜像站为例
echo 'GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"' >> /etc/portage/make.conf
```

### 5.2 make.conf 范例

> **可参考**：[Gentoo Handbook: AMD64 - USE 标志](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/USE/zh-cn) 和 [/etc/portage/make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf/zh-cn)

编辑 `/etc/portage/make.conf`：
```bash
vim /etc/portage/make.conf
```

**懒人/新手配置（复制粘贴）**：
> **提示**：请根据你的 CPU 核心数修改 `MAKEOPTS` 中的 `-j` 参数（例如 8 核 CPU 使用 `-j8`）。

```conf
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# 请根据 CPU 核心数修改 -j 后面的数字
MAKEOPTS="-j8"

# 语言设置
LC_MESSAGES=C
L10N="en en-US zh zh-CN zh-TW"
LINGUAS="en en_US zh zh_CN zh_TW"

# 镜像源 (BFSU)
GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"

# 常用 USE 标志 (systemd 用户推荐)
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"
ACCEPT_LICENSE="*"
```

<details>
<summary><b>详细配置范例（建议阅读并调整）（点击展开）</b></summary>

```conf
# vim: set language=bash;  # 告诉 Vim 使用 bash 语法高亮
CHOST="x86_64-pc-linux-gnu"  # 目标系统架构（不要手动修改）

# ========== 编译优化参数 ==========
# -march=native: 针对当前 CPU 优化（推荐，性能最佳）
# -O2: 优化级别 2（平衡性能与稳定性，推荐）
# -pipe: 使用管道传递数据，加速编译（不影响最终程序）
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"    # C 程序编译选项
CXXFLAGS="${COMMON_FLAGS}"  # C++ 程序编译选项
FCFLAGS="${COMMON_FLAGS}"   # Fortran 程序编译选项
FFLAGS="${COMMON_FLAGS}"    # Fortran 77 程序编译选项

# CPU 指令集优化（见下文 5.3，运行 cpuid2cpuflags 自动生成）
# CPU_FLAGS_X86="aes avx avx2 ..."

# ========== 语言与本地化设置 ==========
# 保持构建输出为英文（便于排错和搜索解决方案）
LC_MESSAGES=C

# L10N: 本地化支持（影响文档、翻译等）
L10N="en en-US zh zh-CN zh-TW"
# LINGUAS: 旧式本地化变量（部分软件仍需要）
LINGUAS="en en_US zh zh_CN zh_TW"

# ========== 并行编译设置 ==========
# -j 后面的数字 = CPU 线程数（例如 32 核心 CPU 用 -j32）
# 推荐值：CPU 线程数（可通过 nproc 命令查看）
MAKEOPTS="-j32"  # 请根据实际硬件调整

# ========== 镜像源设置 ==========
# Gentoo 软件包下载镜像（建议选择国内镜像加速）
GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"

# ========== Emerge 默认选项 ==========
# --ask: 执行前询问确认
# --verbose: 显示详细信息（USE 标志变化等）
# --with-bdeps=y: 包含构建时依赖
# --complete-graph=y: 完整依赖图分析
EMERGE_DEFAULT_OPTS="--ask --verbose --with-bdeps=y --complete-graph=y"

# ========== USE 标志（全局功能开关）==========
# systemd: 使用 systemd 作为 init 系统（若用 OpenRC 则改为 -systemd）
# udev: 设备管理支持
# dbus: 进程间通信（桌面环境必需）
# policykit: 权限管理（桌面环境必需）
# networkmanager: 网络管理器（推荐）
# bluetooth: 蓝牙支持
# git: Git 版本控制
# dist-kernel: 使用发行版内核（新手推荐，可用预编译内核）
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"

# ========== 许可证接受 ==========
# "*" 表示接受所有许可证（包括非自由软件许可证）
# 可选择性接受：ACCEPT_LICENSE="@FREE"（仅自由软件）
ACCEPT_LICENSE="*"

# 文件末尾保留换行符！重要！
```

</details>

> **新手提示**：
> - `MAKEOPTS="-j32"` 的数字应该是你的 CPU 线程数，可通过 `nproc` 命令查看
> - 如果编译时内存不足，可以减少并行任务数（如改为 `-j16`）
> - USE 标志是 Gentoo 的核心特性，决定了软件编译时包含哪些功能
---

<details>
<summary><b>进阶设置：CPU 指令集优化 (CPU_FLAGS_X86)（点击展开）</b></summary>

> **可参考**：[CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn)

为了让 Portage 知道你的 CPU 支持哪些特定指令集（如 AES, AVX, SSE4.2 等），我们需要配置 `CPU_FLAGS_X86`。

安装检测工具：
```bash
emerge --ask app-portage/cpuid2cpuflags # 安装检测工具
```

运行检测并写入配置：
```bash
cpuid2cpuflags >> /etc/portage/make.conf # 将检测结果追加到配置文件
```

检查 `/etc/portage/make.conf` 末尾，你应该会看到类似这样的一行：
```conf
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

</details>

---

## 6. Profile、系统设置与本地化 {#step-6-system}

> **可参考**：[Gentoo Handbook: AMD64 - 安装 Gentoo 基本系统](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)
>
> **为什么需要这一步？**
> Profile 定义了系统的基础配置和预设 USE 旗标，是 Gentoo 灵活性的体现。配置时区、语言和网络等基本系统参数，是让你的 Gentoo 系统能够正常运作并符合个人使用习惯的关键。

### 6.1 选择 Profile

```bash
eselect profile list          # 列出所有可用 Profile
eselect profile set <编号>    # 设置选定的 Profile
emerge -avuDN @world          # 更新系统以匹配新 Profile (a:询问 v:详细 u:升级 D:深层依赖 N:新USE)
```

常见选项：
- `default/linux/amd64/23.0/desktop/plasma/systemd`
- `default/linux/amd64/23.0/desktop/gnome/systemd`
- `default/linux/amd64/23.0/desktop`（OpenRC 桌面）

### 6.2 时区与语言

> **可参考**：[Gentoo Wiki: Localization/Guide](https://wiki.gentoo.org/wiki/Localization/Guide/zh-cn)

```bash
echo "Asia/Shanghai" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen                      # 生成选定的语言环境
eselect locale set en_US.utf8   # 设置系统默认语言 (建议用英文以免乱码)

# 重新加载环境
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

### 6.3 主机名与网络设置

**设置主机名**：
```bash
echo "gentoo" > /etc/hostname
```

**网络管理工具选择**：

**方案 A：NetworkManager (推荐，通用)**
> **可参考**：[NetworkManager](https://wiki.gentoo.org/wiki/NetworkManager)

适合大多数桌面用户，同时支持 OpenRC 和 systemd。
```bash
emerge --ask net-misc/networkmanager
# OpenRC:
rc-update add NetworkManager default
# systemd:
systemctl enable NetworkManager
```

> **配置提示**：
> - **图形界面**：运行 `nm-connection-editor`
> - **命令行**：使用 `nmtui` (图形化向导) 或 `nmcli`

<details>
<summary><b>进阶提示：使用 iwd 后端（点击展开）</b></summary>

NetworkManager 支持使用 `iwd` 作为后端（比 wpa_supplicant 更快）。

```bash
echo "net-misc/networkmanager iwd" >> /etc/portage/package.use/networkmanager
emerge --ask --newuse net-misc/networkmanager
```
之后编辑 `/etc/NetworkManager/NetworkManager.conf`，在 `[device]` 下添加 `wifi.backend=iwd`。

</details>

<details>
<summary><b>方案 B：轻量方案（点击展开）</b></summary>

如果你不想使用 NetworkManager，可以选择以下轻量级方案：

1. **有线网络 (dhcpcd)**
   > **可参考**：[dhcpcd](https://wiki.gentoo.org/wiki/Dhcpcd)
   ```bash
   emerge --ask net-misc/dhcpcd
   # OpenRC:
   rc-update add dhcpcd default
   # systemd:
   systemctl enable dhcpcd
   ```

2. **无线网络 (iwd)**
   > **可参考**：[iwd](https://wiki.gentoo.org/wiki/Iwd)
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

使用 init 系统自带的网络管理功能，适合服务器或极简环境。

**OpenRC 网卡服务**：
> **可参考**：[OpenRC](https://wiki.gentoo.org/wiki/OpenRC) 和 [OpenRC: Network Management](https://wiki.gentoo.org/wiki/OpenRC#Network_management)

```bash
vim /etc/conf.d/net
```

> **注意**：请将下文中的 `enp5s0` 替换为你实际的网卡接口名称（通过 `ip link` 查看）。

写入以下内容：
```conf
config_enp5s0="dhcp"
```

```bash
ln -s /etc/init.d/net.lo /etc/init.d/net.enp5s0 # 创建网卡服务软链接
rc-update add net.enp5s0 default                # 设置开机自启
```

---

**Systemd 原生网卡服务**：
> **可参考**：[systemd-networkd](https://wiki.gentoo.org/wiki/Systemd/systemd-networkd)、[systemd-resolved](https://wiki.gentoo.org/wiki/Systemd/systemd-resolved)、[Systemd](https://wiki.gentoo.org/wiki/Systemd)、[Systemd: Network](https://wiki.gentoo.org/wiki/Systemd#Network)

Systemd 自带了网络管理功能，适合服务器或极简环境：
```bash
systemctl enable systemd-networkd
systemctl enable systemd-resolved
```
*注意：需要手动编写 .network 配置文件。*

</details>



### 6.4 配置 fstab

> **可参考**：[Gentoo Handbook: AMD64 - fstab](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/zh-cn) 和 [Gentoo Wiki: /etc/fstab](https://wiki.gentoo.org/wiki//etc/fstab/zh-cn)

获取 UUID：
```bash
blkid
```

**方法 A：自动生成（推荐 LiveGUI 用户）**
> **注意**：`genfstab` 工具通常包含在 `arch-install-scripts` 包中。如果你使用的是 Gig-OS 或其他基于 Arch 的 LiveISO，可以直接使用。官方 Minimal ISO 可能需要手动安装或使用方法 B。

```bash
emerge --ask sys-fs/genfstab # 如果没有该命令
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```
检查生成的文件：
```bash
cat /mnt/gentoo/etc/fstab
```

**方法 B：手动编辑**

编辑 `/etc/fstab`：
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

## 7. 内核与固件 {#step-7-kernel}

> **可参考**：[Gentoo Handbook: AMD64 - 配置 Linux 内核](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/zh-cn)
>
> **为什么需要这一步？**
> 内核是操作系统的核心，负责管理硬件。Gentoo 允许你手动裁剪内核，只保留你需要的驱动，从而获得极致的性能和精简的体积。新手也可以选择预编译内核快速上手。

### 7.1 快速方案：预编译内核

```bash
emerge --ask sys-kernel/gentoo-kernel-bin
```

内核升级后记得重新生成引导程序配置。

<details>
<summary><b>进阶设置：手动编译内核 (Gentoo 核心体验)（点击展开）</b></summary>

> **新手提示**：
> 编译内核比较复杂且耗时。如果你想尽快体验 Gentoo，可以先跳过本节，使用 7.1 的预编译内核。

手动编译内核能让你完全掌控系统功能，移除不需要的驱动，获得更精简、高效的内核。

**快速开始**（使用 Genkernel 自动化）：
```bash
emerge --ask sys-kernel/gentoo-sources sys-kernel/genkernel
genkernel --install all  # 自动编译并安装内核、模块和 initramfs
# --install: 编译完成后自动安装到 /boot 目录
# all: 完整构建 (内核 + 模块 + initramfs)
```

> **进阶内容**：如果你想深入了解内核配置、使用 LLVM/Clang 编译内核、启用 LTO 优化等高级选项，请参考 **[Section 16.0 内核编译进阶指南](/posts/2025-11-25-gentoo-install-advanced/#section-16-kernel-advanced)**。

</details>

### 7.3 安装固件与微码

```bash
mkdir -p /etc/portage/package.license
# 同意 Linux 固件的授权条款
echo 'sys-kernel/linux-firmware linux-fw-redistributable no-source-code' > /etc/portage/package.license/linux-firmware
echo 'sys-kernel/installkernel dracut' > /etc/portage/package.use/installkernel
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-firmware/intel-microcode  # Intel CPU
```

---

## 8. 基础工具 {#step-8-base-packages}

> **可参考**：[Gentoo Handbook: AMD64 - 安装必要的系统工具](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools/zh-cn)
>
> **为什么需要这一步？**
> Stage3 只有最基础的命令。我们需要补充系统日志、网络管理、文件系统工具等必要组件，才能让系统在重启后正常工作。

### 8.1 系统服务工具

**OpenRC 用户**（必选）：

**1. 系统日志**
> **可参考**：[Syslog-ng](https://wiki.gentoo.org/wiki/Syslog-ng)
```bash
emerge --ask app-admin/syslog-ng
rc-update add syslog-ng default
```

**2. 定时任务**
```bash
emerge --ask sys-process/cronie
rc-update add cronie default
```

**3. 时间同步**
> **可参考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) 和 [System Time (OpenRC)](https://wiki.gentoo.org/wiki/System_time/zh-cn#OpenRC)
```bash
emerge --ask net-misc/chrony
rc-update add chronyd default
```

**systemd 用户**：
systemd 已内置日志与时间同步服务。

**时间同步**
> **可参考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) 和 [System Time (systemd)](https://wiki.gentoo.org/wiki/System_time/zh-cn#systemd)
```bash
systemctl enable --now systemd-timesyncd
```

### 8.3 文件系统工具

根据你使用的文件系统安装对应工具（必选）：
```bash
emerge --ask sys-fs/e2fsprogs  # ext4
emerge --ask sys-fs/xfsprogs   # XFS
emerge --ask sys-fs/dosfstools # FAT/vfat (EFI 分区需要)
emerge --ask sys-fs/btrfs-progs # Btrfs
```

## 9. 建立用户与权限 {#step-9-users}

> **可参考**：[Gentoo Handbook: AMD64 - 结束安装](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing/zh-cn)
>
> **为什么需要这一步？**
> Linux 不建议日常使用 root 账户。我们需要创建一个普通用户，并赋予其使用 `sudo` 的权限，以提高系统安全性。

```bash
passwd root # 设置 root 密码
useradd -m -G wheel,video,audio,plugdev zakk # 创建用户并加入常用组
passwd zakk # 设置用户密码
emerge --ask app-admin/sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel # 允许 wheel 组使用 sudo
```

若使用 systemd，可视需求将账号加入 `network`、`lp` 等群组。

---

<details>
<summary><b>进阶设置：加密支持（仅加密用户）（点击展开）</b></summary>

> **可参考**：[Dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt/zh-cn)

> **注意**：如果你在步骤 3.4 中选择了加密分区，才需要执行此步骤。

### 步骤 1：启用 systemd cryptsetup 支持

```bash
mkdir -p /etc/portage/package.use
echo "sys-apps/systemd cryptsetup" >> /etc/portage/package.use/fde

# 重新编译 systemd 以启用 cryptsetup 支持
emerge --ask --oneshot sys-apps/systemd
```

### 步骤 2：获取 LUKS 分区的 UUID

```bash
# 获取 LUKS 加密容器的 UUID（不是里面的文件系统 UUID）
blkid /dev/nvme0n1p3
```

输出示例：
```text
/dev/nvme0n1p3: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" ...
```
记下这个 **LUKS UUID**（例如：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）。

### 步骤 3：配置 GRUB 内核参数

```bash
vim /etc/default/grub
```

加入或修改以下内容（**替换 UUID 为实际值**）：
```conf
# 完整示例（替换 UUID 为你的实际 UUID）
GRUB_CMDLINE_LINUX="rd.luks.uuid=<LUKS-UUID> rd.luks.allow-discards root=UUID=<ROOT-UUID> rootfstype=btrfs"
```

**参数说明**：
- `rd.luks.uuid=<UUID>`：LUKS 加密分区的 UUID（使用 `blkid /dev/nvme0n1p3` 获取）
- `rd.luks.allow-discards`：允许 SSD TRIM 指令穿透加密层（提升 SSD 性能）
- `root=UUID=<UUID>`：解密后的 btrfs 文件系统 UUID（使用 `blkid /dev/mapper/gentoo-root` 获取）
- `rootfstype=btrfs`：根文件系统类型（如果使用 ext4 改为 `ext4`）

### 步骤 3.1（替代方案）：配置内核参数 (systemd-boot 方案)

如果你使用 systemd-boot 而不是 GRUB，请编辑 `/boot/loader/entries/` 下的配置文件（例如 `gentoo.conf`）：

```conf
title      Gentoo Linux
version    6.6.13-gentoo
options    rd.luks.name=<LUKS-UUID>=cryptroot root=/dev/mapper/cryptroot rootfstype=btrfs rd.luks.allow-discards init=/lib/systemd/systemd
linux      /vmlinuz-6.6.13-gentoo
initrd     /initramfs-6.6.13-gentoo.img
```

**参数说明**：
- `rd.luks.name=<LUKS-UUID>=cryptroot`：指定 LUKS 分区 UUID 并映射为 `cryptroot`。
- `root=/dev/mapper/cryptroot`：指定解密后的根分区设备。
- `rootfstype=btrfs`：指定根文件系统类型。

### 步骤 4：安装并配置 dracut

> **可参考**：[Dracut](https://wiki.gentoo.org/wiki/Dracut) 和 [Initramfs](https://wiki.gentoo.org/wiki/Initramfs)

```bash
# 安装 dracut（如果还没安装）
emerge --ask sys-kernel/dracut
```

### 步骤 5：配置 dracut for LUKS 解密

创建 dracut 配置文件：
```bash
vim /etc/dracut.conf.d/luks.conf
```

加入以下内容：
```conf
# 不要在这里设置 kernel_cmdline，GRUB 会覆盖它
kernel_cmdline=""
# 添加必要的模块支持 LUKS + btrfs
add_dracutmodules+=" btrfs systemd crypt dm "
# 添加必要的工具
install_items+=" /sbin/cryptsetup /bin/grep "
# 指定文件系统（如果使用其他文件系统请修改）
filesystems+=" btrfs "
```

**配置说明**：
- `crypt` 和 `dm` 模块提供 LUKS 解密支持
- `systemd` 模块用于 systemd 启动环境
- `btrfs` 模块支持 btrfs 文件系统（如果使用 ext4 改为 `ext4`）

### 步骤 6：配置 /etc/crypttab（可选但推荐）

```bash
vim /etc/crypttab
```

加入以下内容（**替换 UUID 为你的 LUKS UUID**）：
```conf
gentoo-root UUID=<LUKS-UUID> none luks,discard
```
这样配置后，系统会自动识别并提示解锁加密分区。

### 步骤 7：重新生成 initramfs

```bash
# 重新生成 initramfs（包含 LUKS 解密模块）
dracut --kver $(make -C /usr/src/linux -s kernelrelease) --force
# --kver: 指定内核版本
# $(make -C /usr/src/linux -s kernelrelease): 自动获取当前内核版本号
# --force: 强制覆盖已存在的 initramfs 文件
```

> **重要**：每次更新内核后，也需要重新执行此命令生成新的 initramfs！

### 步骤 8：更新 GRUB 配置

```bash
grub-mkconfig -o /boot/grub/grub.cfg

# 验证 initramfs 被正确引用
grep initrd /boot/grub/grub.cfg
```

</details>


## 10. 安装引导程序 {#step-10-bootloader}

> **可参考**：[Gentoo Handbook: AMD64 - 配置引导加载程序](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader/zh-cn)

### 10.1 GRUB

> **可参考**：[GRUB](https://wiki.gentoo.org/wiki/GRUB/zh-cn)

```bash
emerge --ask sys-boot/grub:2
mkdir -p /efi/EFI/Gentoo
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo # 安装 GRUB 到 ESP
# 安装 os-prober 以支持多系统检测
emerge --ask sys-boot/os-prober

# 启用 os-prober（用于检测 Windows 等其他操作系统）
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# 生成 GRUB 配置文件
grub-mkconfig -o /boot/grub/grub.cfg
```

<details>
<summary><b>进阶设置：systemd-boot (仅限 UEFI)（点击展开）</b></summary>

> **可参考**：[systemd-boot](https://wiki.gentoo.org/wiki/Systemd/systemd-boot/zh-cn)

```bash
bootctl --path=/efi install # 安装 systemd-boot

# 1. 创建 Gentoo 引导项
vim /efi/loader/entries/gentoo.conf
```

写入以下内容（**注意替换 UUID**）：
```conf
title   Gentoo Linux
linux   /vmlinuz-6.6.62-gentoo-dist
initrd  /initramfs-6.6.62-gentoo-dist.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw quiet
```
> **注意**：如果你使用了 LUKS 加密，options 行需要添加 `rd.luks.uuid=...` 等参数。

**2. 更新引导项**：
每次更新内核后，需要手动更新 `gentoo.conf` 中的版本号，或者使用脚本自动化。

**2. 创建 Windows 引导项 (双系统)**

> 如果你创建了新的 EFI 分区，请记得将原 Windows EFI 文件 (EFI/Microsoft) 复制到新分区。

```bash
vim /efi/loader/entries/windows.conf
```

写入以下内容：
```ini
title      Windows 11
sort-key   windows-01
efi        /EFI/Microsoft/Boot/bootmgfw.efi
```

# 3. 配置默认引导
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



---

## 11. 重启前检查清单与重启 {#step-11-reboot}

1. `emerge --info` 正常执行无错误
2. `/etc/fstab` 中的 UUID 正确（使用 `blkid` 再确认）
3. 已设定 root 与一般用户密码
4. 已执行 `grub-mkconfig` 或完成 `bootctl` 配置
5. 若使用 LUKS，确认 initramfs 含有 `cryptsetup`

离开 chroot 并重启：
```bash
exit
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
swapoff -a
reboot
```

---


> **恭喜！** 你已经完成了 Gentoo 的基础安装。
>
> **下一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)
