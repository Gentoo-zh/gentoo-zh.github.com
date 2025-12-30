---
title: "Gentoo Linux 安装指南 (基础篇)"
date: 2025-11-25
summary: "Gentoo Linux 基础系统安装教程，涵盖分区、Stage3、内核编译、引导程序配置等。也突出有 LUKS 全盘加密教学。"
description: "2025 年最新 Gentoo Linux 安装指南 (基础篇)，详细讲解 UEFI 安装流程、内核编译等。适合 Linux 进阶用户和 Gentoo 新手。也突出有 LUKS 全盘加密教学。"
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

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 文章特别说明

本文是 **Gentoo Linux 安装指南** 系列的第一部分：**基础安装**。

**系列导航**：
1. **基础安装（本文）**：从零开始安装 Gentoo 基础系统
2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：显卡驱动、桌面环境、输入法等
3. [进阶优化](/posts/2025-11-25-gentoo-install-advanced/)：make.conf 优化、LTO、系统维护

**建议阅读方式**：
- 按需阅读：基础安装（0-11 节）→ 桌面配置（12 节）→ 进阶优化（13-17 节）

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 关于本指南

本文旨在提供一个完整的 Gentoo 安装流程演示，并**密集提供可供学习的参考文献**。文章中包含大量官方 Wiki 链接和技术文档，帮助读者深入理解每个步骤的原理和配置细节。

**这不是一份简单的傻瓜式教程，而是一份引导性的学习资源**——使用 Gentoo 的第一步是学会自己阅读 Wiki 并解决问题，善用 Google 甚至 AI 工具寻找答案。遇到问题或需要深入了解时，请务必查阅官方手册和本文提供的参考链接。

如果在阅读过程中遇到疑问或发现问题，欢迎通过以下渠道提出：
- **Gentoo 中文社区**：[Telegram 群组](https://t.me/gentoo_zh) | [Telegram 频道](https://t.me/gentoocn) | [GitHub](https://github.com/Gentoo-zh)
- **官方社区**：[Gentoo Forums](https://forums.gentoo.org/) | IRC: #gentoo @ Libera.Chat

**非常建议以官方手册为准**：
- [Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [Gentoo Handbook: AMD64 (简体中文)](https://wiki.gentoo.org/wiki/Handbook:AMD64/zh-cn)

<p style="opacity: 0.8; margin-top: 1rem;">✓ 已验证至 2025 年 11 月 25 日</p>

</div>

## 什么是 Gentoo？

Gentoo Linux 是一个基于源码的 Linux 发行版，以其**高度可定制性**和**性能优化**著称。与其他发行版不同，Gentoo 让你从源代码编译所有软件，这意味着：

- **极致性能**：所有软件针对你的硬件优化编译
- **完全掌控**：你决定系统包含什么，不包含什么
- **深度学习**：通过亲手构建系统深入理解 Linux
- **编译时间**：初次安装需要较长时间（建议预留 3-6 小时）
- **学习曲线**：需要一定的 Linux 基础知识

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94);">

**适合谁？**
- 想要深入学习 Linux 的技术爱好者
- 追求系统性能和定制化的用户
- 享受 DIY 过程的 Geek

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11);">

**不适合谁？**
- 只想快速安装使用的新手（建议先尝试 Ubuntu、Fedora 等）
- 没有时间折腾系统的用户

</div>

</div>

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

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

使用预编译内核和二进制包可以大幅缩短时间，但会牺牲部分定制性。

</div>

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

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 本指南内容概览

本指南将引导你在 x86_64 UEFI 平台上安装 Gentoo Linux。

**本文将教你**：
- 从零开始安装 Gentoo 基础系统（分区、Stage3、内核、引导程序）
- 配置 Portage 并优化编译参数（make.conf、USE flags、CPU flags）
- 启用 Binary Package Host（二进制包主机，大幅缩短安装时间）
- 安装桌面环境（KDE Plasma、GNOME、Hyprland）
- 配置中文环境（locale、字体、Fcitx5 输入法）
- 可选进阶配置（LUKS 全盘加密、Secure Boot 安全启动、LTO 优化、内核调优、RAID）
- 系统维护（SSD TRIM、电源管理、Flatpak、系统更新）

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要提醒**

**请先关闭 Secure Boot**  
在开始安装之前，请务必进入 BIOS 设置，将 **Secure Boot** 暂时关闭。开启 Secure Boot 可能会导致安装介质无法启动，或者安装后的系统无法引导。你可以在系统安装完成并成功启动后，再参考本指南后面的章节重新配置并开启 Secure Boot。

**备份所有重要数据！**  
本指南涉及磁盘分区操作，请务必在开始前备份所有重要数据！

</div>

---

## 0. 准备安装媒介 {#step-0-prepare}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 选择安装媒介](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media/zh-cn)

</div>

### 0.1 下载 Gentoo ISO

根据[**下载页面**](/download/) 提供的方式获取下载链接

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

以下链接中的日期（如 `20251123T...`）仅供参考，请务必在镜像站中选择**最新日期**的文件。

</div>

下载 Minimal ISO（以 BFSU 镜像站为例）：
```bash
wget https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso
wget https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20251123T153051Z/install-amd64-minimal-20251123T153051Z.iso.asc
```

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**新手推荐：使用 LiveGUI USB Image**

如果希望安装时能直接使用浏览器或更方便地连接 Wi-Fi，可以选择 **LiveGUI USB Image**。

**新手入坑推荐使用每周构建的 KDE 桌面环境的 Live ISO**： <https://iso.gig-os.org/>  
（来自 Gig-OS <https://github.com/Gig-OS> 项目）

**Live ISO 登录凭据**：
- 账号：`live`
- 密码：`live`
- Root 密码：`live`

**系统支持**：
- 支持中文显示和中文输入法 (fcitx5), flclash 等

</div>

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
<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

请将 `sdX` 替换成 USB 装置名称，例如 `/dev/sdb`。

</div>

**Windows：** 推荐使用 [Rufus](https://rufus.ie/) → 选择 ISO → 写入时选 DD 模式。

---

## 1. 进入 Live 环境并连接网络 {#step-1-network}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 配置网络](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

Gentoo 的安装过程完全依赖网络来下载源码包 (Stage3) 和软件仓库 (Portage)。在 Live 环境中配置好网络是安装的第一步。

</div>

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

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

若 WPA3 不稳定，请先退回 WPA2。

</div>

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

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 准备磁盘](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

我们需要为 Linux 系统划分独立的存储空间。UEFI 系统通常需要一个 ESP 分区 (引导) 和一个根分区 (系统)。合理的规划能让日后的维护更轻松。

### 什么是 EFI 系统分区 (ESP)？

在使用由 UEFI 引导（而不是 BIOS）的操作系统上安装 Gentoo 时，创建 EFI 系统分区 (ESP) 是必要的。ESP 必须是 FAT 变体（有时在 Linux 系统上显示为 vfat）。官方 UEFI 规范表示 UEFI 固件将识别 FAT12、16 或 32 文件系统，但建议使用 FAT32。

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**  
如果 ESP 没有使用 FAT 变体进行格式化，那么系统的 UEFI 固件将找不到引导加载程序（或 Linux 内核）并且很可能无法引导系统！

</div>

### 建议分区方案（UEFI）

下表提供了一个可用于 Gentoo 试用安装的推荐默认分区表。

| 设备路径 | 挂载点 | 文件系统 | 描述 |
| :--- | :--- | :--- | :--- |
| `/dev/nvme0n1p1` | `/efi` | vfat | EFI 系统分区 (ESP) |
| `/dev/nvme0n1p2` | `swap` | swap | 交换分区 |
| `/dev/nvme0n1p3` | `/` | xfs | 根分区 |

### cfdisk 实战示例（推荐）

`cfdisk` 是一个图形化的分区工具，操作简单直观。

```bash
cfdisk /dev/nvme0n1
```

**操作提示**：
1.  选择 **GPT** 标签类型。
2.  **创建 ESP**：新建分区 -> 大小 `1G` -> 类型选择 `EFI System`。
3.  **创建 Swap**：新建分区 -> 大小 `4G` -> 类型选择 `Linux swap`。
4.  **创建 Root**：新建分区 -> 剩余空间 -> 类型选择 `Linux filesystem` (默认)。
5.  选择 **Write** 写入更改，输入 `yes` 确认。
6.  选择 **Quit** 退出。

```text
                                                                 Disk: /dev/nvme0n1
                                              Size: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
                                            Label: gpt, identifier: 9737D323-129E-4B5F-9049-8080EDD29C02

    设备                                       Start                   终点                  扇区               Size 类型
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
                                   [ 删除 ]  [Resize]  [ 退出 ]  [ 类型 ]  [ 帮助 ]  [ 排序 ]  [ 写入 ]  [ 导出 ]


                                                        Quit program without writing changes
```

<details>
<summary><b>进阶设置：fdisk 命令行分区教程（点击展开）</b></summary>

`fdisk` 是一个功能强大的命令行分区工具。

```bash
fdisk /dev/nvme0n1
```

**1. 查看当前分区布局**

使用 `p` 键来显示磁盘当前的分区配置。

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

**2. 创建一个新的磁盘标签**

按下 `g` 键将立即删除所有现有的磁盘分区并创建一个新的 GPT 磁盘标签：

```text
Command (m for help): g
Created a new GPT disklabel (GUID: ...).
```

或者，要保留现有的 GPT 磁盘标签，可以使用 `d` 键逐个删除现有分区。

**3. 创建 EFI 系统分区 (ESP)**

输入 `n` 创建一个新分区，选择分区号 1，起始扇区默认（2048），结束扇区输入 `+1G`：

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

将分区标记为 EFI 系统分区（类型代码 1）：

```text
Command (m for help): t
Selected partition 1
Partition type or alias (type L to list all): 1
Changed type of partition 'Linux filesystem' to 'EFI System'.
```

**4. 创建 Swap 分区**

创建 4GB 的 Swap 分区：

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

**5. 创建根分区**

将剩余空间分配给根分区：

```text
Command (m for help): n
Partition number (3-128, default 3): 3
First sector (...): <Enter>
Last sector (...): <Enter>

Created a new partition 3 of type 'Linux filesystem' and of size 926.5 GiB.
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

将根分区的类型设置为 "Linux root (x86-64)" 并不是必须的，如果将其设置为 "Linux filesystem" 类型，系统也能正常运行。只有在使用支持它的 bootloader (即 systemd-boot) 并且不需要 fstab 文件时，才需要这种文件系统类型。

</div>

设置分区类型为 "Linux root (x86-64)"（类型代码 23）：

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

## 3. 建立文件系统并挂载 {#step-3-filesystem}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 准备磁盘](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/zh-cn) · [Ext4](https://wiki.gentoo.org/wiki/Ext4/zh-cn) · [XFS](https://wiki.gentoo.org/wiki/XFS/zh-cn) · [Btrfs](https://wiki.gentoo.org/wiki/Btrfs/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

磁盘分区只是划分了空间，但还不能存储数据。建立文件系统 (如 ext4, Btrfs) 才能让操作系统管理和访问这些空间。挂载则是将这些文件系统连接到 Linux 文件树的特定位置。

</div>

### 3.1 格式化

```bash
mkfs.fat -F 32 /dev/nvme0n1p1  # 格式化 ESP 分区为 FAT32
mkswap /dev/nvme0n1p2          # 格式化 Swap 分区
mkfs.xfs /dev/nvme0n1p3        # 格式化 Root 分区为 XFS
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

**其他文件系统**

其他如 [F2FS](https://wiki.gentoo.org/wiki/F2FS/zh-cn) 或 [ZFS](https://wiki.gentoo.org/wiki/ZFS/zh-cn) 请参考相关 Wiki。

</div>

### 3.2 挂载（XFS 示例）

```bash
mount /dev/nvme0n1p3 /mnt/gentoo        # 挂载根分区
mkdir -p /mnt/gentoo/efi                # 创建 ESP 挂载点
mount /dev/nvme0n1p1 /mnt/gentoo/efi    # 挂载 ESP 分区
swapon /dev/nvme0n1p2                   # 启用 Swap 分区
```

<details>
<summary><b>进阶设置：Btrfs 子卷示例（点击展开）</b></summary>

**1. 格式化**

```bash
mkfs.fat -F 32 /dev/nvme0n1p1  # 格式化 ESP
mkswap /dev/nvme0n1p2          # 格式化 Swap
mkfs.btrfs -L gentoo /dev/nvme0n1p3 # 格式化 Root (Btrfs)
```

**2. 创建子卷**

```bash
mount /dev/nvme0n1p3 /mnt/gentoo
btrfs subvolume create /mnt/gentoo/@
btrfs subvolume create /mnt/gentoo/@home
umount /mnt/gentoo
```

**3. 挂载子卷**

```bash
mount -o compress=zstd,subvol=@ /dev/nvme0n1p3 /mnt/gentoo
mkdir -p /mnt/gentoo/{efi,home}
mount -o subvol=@home /dev/nvme0n1p3 /mnt/gentoo/home
mount /dev/nvme0n1p1 /mnt/gentoo/efi    # 注意：ESP 必须是 FAT32 格式
swapon /dev/nvme0n1p2
```

**4. 验证挂载**

```bash
lsblk
```

输出示例：
```text
NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
nvme0n1          259:1    0 931.5G  0 disk  
├─nvme0n1p1      259:7    0     1G  0 part  /mnt/gentoo/efi
├─nvme0n1p2      259:8    0     4G  0 part  [SWAP]
└─nvme0n1p3      259:9    0 926.5G  0 part  /mnt/gentoo/home
                                            /mnt/gentoo
```

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**Btrfs 快照建议**

推荐使用 [Snapper](https://wiki.gentoo.org/wiki/Snapper) 管理快照。合理的子卷规划（如将 `@` 和 `@home` 分开）能让系统回滚更加轻松。

</div>

</details>

<details>
<summary><b>进阶设置：加密分区（LUKS）（点击展开）</b></summary>

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

**4. 挂载**

```bash
mount /dev/mapper/gentoo-root /mnt/gentoo
mkdir -p /mnt/gentoo/efi
mount /dev/nvme0n1p1 /mnt/gentoo/efi
swapon /dev/nvme0n1p2
```

**5. 验证挂载**

```bash
lsblk
```

输出示例：
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

**建议**

挂载完成后，建议使用 `lsblk` 确认挂载点是否正确。

```bash
lsblk
```

**输出示例**（类似如下）：
```text
NAME             MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
 nvme0n1          259:1    0 931.5G  0 disk  
├─nvme0n1p1      259:7    0     1G  0 part  /efi
├─nvme0n1p2      259:8    0     4G  0 part  [SWAP]
└─nvme0n1p3      259:9    0 926.5G  0 part  /
```

</div>

## 4. 下载 Stage3 并进入 chroot {#step-4-stage3}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 安装 Gentoo 安装文件](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/zh-cn) · [Stage file](https://wiki.gentoo.org/wiki/Stage_file)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

Stage3 是一个最小化的 Gentoo 基础系统环境。我们将它解压到硬盘上，作为新系统的"地基"，然后通过 `chroot` 进入这个新环境进行后续配置。

</div>

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

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 安装 Gentoo 基本系统](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

Portage 是 Gentoo 的包管理系统，也是其核心特色。初始化 Portage 并配置 `make.conf` 就像为你的新系统设定了「构建蓝图」，决定了软件如何编译、使用哪些功能以及从哪里下载。

</div>

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

### 5.2 make.conf 范例 {#52-makeconf-范例}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - USE 标志](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/USE/zh-cn) · [/etc/portage/make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

</div>

编辑 `/etc/portage/make.conf`：
```bash
vim /etc/portage/make.conf
```

**懒人/新手配置（复制粘贴）**：
<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

请根据你的 CPU 核心数修改 `MAKEOPTS` 中的 `-j` 参数（例如 8 核 CPU 使用 `-j8`）。

</div>

```conf
# ========== 编译优化参数 ==========
# -march=native: 针对当前 CPU 架构优化，获得最佳性能
# -O2: 推荐的优化级别，平衡性能与编译时间
# -pipe: 使用管道加速编译过程
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"    # C 编译器选项
CXXFLAGS="${COMMON_FLAGS}"  # C++ 编译器选项
FCFLAGS="${COMMON_FLAGS}"   # Fortran 编译器选项
FFLAGS="${COMMON_FLAGS}"    # Fortran 77 编译器选项

# ========== 并行编译设置 ==========
# -j 后面的数字 = CPU 线程数（运行 nproc 查看）
# 内存不足时可适当减少（如 -j4）
MAKEOPTS="-j8"

# ========== 语言与本地化 ==========
# LC_MESSAGES=C: 保持编译输出为英文，便于搜索错误信息
LC_MESSAGES=C
# L10N/LINGUAS: 支持的语言（影响软件翻译和文档）
L10N="en en-US zh zh-CN zh-TW"
LINGUAS="en en_US zh zh_CN zh_TW"

# ========== 镜像源设置 ==========
# 国内推荐：BFSU、TUNA、USTC 等
GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"

# ========== USE 标志 ==========
# systemd: 使用 systemd 作为 init（若用 OpenRC 改为 -systemd）
# dist-kernel: 使用发行版内核，新手推荐
# networkmanager: 网络管理工具
# bluetooth: 蓝牙支持（若不使用蓝牙可移除）
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"

# ========== 许可证设置 ==========
# "*" 接受所有许可证（包括非自由软件/专有软件）
# 警告：接受所有许可证意味着您同意安装闭源软件，如需仅使用自由软件请改为 "@FREE"
# 详细说明见进阶篇 13.12 节
ACCEPT_LICENSE="*"
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**详细配置说明**

如需查看包含完整注释的 `make.conf` 配置范例，请参阅 [进阶篇 13.11 节：详细配置范例](/posts/2025-11-25-gentoo-install-advanced/#1311-详细配置范例完整注释版)。

该范例包含：
- 每个配置项的详细说明和推荐值
- 针对不同硬件的调整建议
- USE 标志的功能说明
- FEATURES 和日志配置示例

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

- `MAKEOPTS="-j32"` 的数字应该是你的 CPU 线程数，可通过 `nproc` 命令查看
- 如果编译时内存不足，可以减少并行任务数（如改为 `-j16`）
- USE 标志是 Gentoo 的核心特性，决定了软件编译时包含哪些功能

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**进阶配置**

- **ACCEPT_LICENSE 许可证管理**：详见 [进阶篇 13.12 节](/posts/2025-11-25-gentoo-install-advanced/#1312-accept_license-软件许可证详解)
- **CPU 指令集优化 (CPU_FLAGS_X86)**：详见 [进阶篇 13.13 节](/posts/2025-11-25-gentoo-install-advanced/#1313-cpu-指令集优化-cpu_flags_x86)

</div>

### 5.3 配置 CPU 指令集优化 {#53-配置-cpu-指令集优化}

为了让 Portage 知道你的 CPU 支持哪些特定指令集（如 AES, AVX, SSE4.2 等），我们需要配置 `CPU_FLAGS_X86`。

安装检测工具：
```bash
emerge --ask app-portage/cpuid2cpuflags
```

运行检测并写入配置：
```bash
cpuid2cpuflags >> /etc/portage/make.conf
```

检查 `/etc/portage/make.conf` 末尾，你应该会看到类似这样的一行：
```conf
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**说明**

更多关于 CPU 指令集优化的详细信息，请参阅 [进阶篇 13.13 节](/posts/2025-11-25-gentoo-install-advanced/#1313-cpu-指令集优化-cpu_flags_x86)。

</div>

---

### 5.4 可选：启用 Binary Package Host（二进制包主机）

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: Binary Package Host](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Adding_a_binary_package_host) · [Binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么使用 Binary Package Host？**

自 2023 年 12 月起，Gentoo [官方提供二进制包主机](https://www.gentoo.org/news/2023/12/29/Gentoo-binary.html)（binhost），可大幅缩短安装时间：
- **LLVM / Clang**：从 2-3 小时缩短到 5 分钟
- **Rust**：从 1-2 小时缩短到 3 分钟
- **Firefox / Chromium**：从数小时缩短到 10 分钟

所有二进制包均经过 **加密签章验证**，确保安全性。

</div>

#### 配置 Binary Package Host

**步骤 1：配置仓库**

创建 binhost 配置文件：
```bash
mkdir -p /etc/portage/binrepos.conf
vim /etc/portage/binrepos.conf/gentoobinhost.conf
```

加入以下内容（根据你的 **Profile** 选择对应路径）：

<details>
<summary><b>OpenRC 桌面配置（点击展开）</b></summary>

```conf
# /etc/portage/binrepos.conf/gentoobinhost.conf
[binhost]
priority = 9999
sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64/
```

</details>

<details>
<summary><b>systemd 桌面配置（点击展开）</b></summary>

```conf
# /etc/portage/binrepos.conf/gentoobinhost.conf
[binhost]
priority = 9999
sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64-systemd/
```

</details>

<details>
<summary><b>如何选择正确的路径？（点击展开）</b></summary>

查看你当前的 profile：
```bash
eselect profile show
```

根据输出选择对应路径：
| Profile 类型 | sync-uri 路径 |
|------------|--------------|
| `default/linux/amd64/23.0` | `.../23.0/x86-64/` |
| `default/linux/amd64/23.0/systemd` | `.../23.0/x86-64-systemd/` |
| `default/linux/amd64/23.0/desktop` | `.../23.0/x86-64-v3/` |
| `default/linux/amd64/23.0/desktop/systemd` | `.../23.0/x86-64-v3-systemd/` |

**注意**：桌面 profile 通常使用 `x86-64-v3`（需要 AVX、AVX2 等指令集），伺服器 profile 使用 `x86-64`。

</details>

**步骤 2：启用二进制包功能**

编辑 `/etc/portage/make.conf`，加入：
```bash
# 启用二进制包下载与签章验证
FEATURES="${FEATURES} getbinpkg binpkg-request-signature"

# emerge 默认使用二进制包（可选，推荐新手启用）
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --getbinpkg"
```

**步骤 3：获取签章密钥**

运行以下命令，让 Portage 设置验证所需的密钥环：
```bash
getuto
```

#### 验证配置

测试是否正确配置：
```bash
emerge --pretend --getbinpkg sys-apps/portage
```

若输出包含 `[binary]` 字样，说明配置成功：
```
[ebuild   R    ] sys-apps/portage-3.0.61::gentoo [binary]
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**使用提示**

- **优先使用二进制包**：如上配置后，emerge 会自动优先使用二进制包
- **强制从源码编译**：`emerge --usepkg=n <套件名>`
- **仅使用二进制包**：`emerge --usepkgonly <套件名>`
- **查看可用二进制包**：访问 [Gentoo Binhost Browser](https://distfiles.gentoo.org/releases/amd64/binpackages/)

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1rem 0;">

**注意事项**

- 若你的 **USE 标志**或**编译参数**与官方预设不同，Portage 会自动回退到源码编译
- 二进制包使用官方的**通用配置**，可能无法完全发挥你的 CPU 性能优势（`-march=native` 的特定优化）
- 建议**初次安装时使用 binhost**，系统稳定后根据需要调整 USE 标志并重新编译关键套件

</div>

---

## 6. Profile、系统设置与本地化 {#step-6-system}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 安装 Gentoo 基本系统](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

Profile 定义了系统的基础配置和预设 USE 旗标，是 Gentoo 灵活性的体现。配置时区、语言和网络等基本系统参数，是让你的 Gentoo 系统能够正常运作并符合个人使用习惯的关键。

</div>

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

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Wiki: Localization/Guide](https://wiki.gentoo.org/wiki/Localization/Guide/zh-cn)

</div>

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
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[NetworkManager](https://wiki.gentoo.org/wiki/NetworkManager)

</div>

适合大多数桌面用户，同时支持 OpenRC 和 systemd。
```bash
emerge --ask net-misc/networkmanager
# OpenRC:
rc-update add NetworkManager default
# systemd:
systemctl enable NetworkManager
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**配置提示**

**图形界面**：运行 `nm-connection-editor`  
**命令行**：使用 `nmtui` (图形化向导) 或 `nmcli`

</div>

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
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[dhcpcd](https://wiki.gentoo.org/wiki/Dhcpcd)

</div>

   ```bash
   emerge --ask net-misc/dhcpcd
   # OpenRC:
   rc-update add dhcpcd default
   # systemd:
   systemctl enable dhcpcd
   ```

2. **无线网络 (iwd)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[iwd](https://wiki.gentoo.org/wiki/Iwd)

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

使用 init 系统自带的网络管理功能，适合服务器或极简环境。

**OpenRC 网卡服务**：
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[OpenRC](https://wiki.gentoo.org/wiki/OpenRC) · [OpenRC: Network Management](https://wiki.gentoo.org/wiki/OpenRC#Network_management)

</div>

```bash
vim /etc/conf.d/net
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

请将下文中的 `enp5s0` 替换为你实际的网卡接口名称（通过 `ip link` 查看）。

</div>

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
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[systemd-networkd](https://wiki.gentoo.org/wiki/Systemd/systemd-networkd) · [systemd-resolved](https://wiki.gentoo.org/wiki/Systemd/systemd-resolved) · [Systemd](https://wiki.gentoo.org/wiki/Systemd) · [Systemd: Network](https://wiki.gentoo.org/wiki/Systemd#Network)

</div>

Systemd 自带了网络管理功能，适合服务器或极简环境：
```bash
systemctl enable systemd-networkd
systemctl enable systemd-resolved
```
*注意：需要手动编写 .network 配置文件。*

</details>



### 6.4 配置 fstab

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - fstab](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/zh-cn) · [Gentoo Wiki: /etc/fstab](https://wiki.gentoo.org/wiki//etc/fstab/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

系统需要知道启动时要挂载哪些分区。`/etc/fstab` 文件就像一张"分区清单"，告诉系统：

- 哪些分区需要在启动时自动挂载
- 每个分区挂载到哪个目录
- 使用什么文件系统类型

**推荐使用 UUID**：设备路径（如 `/dev/sda1`）可能因硬件变化而改变，但 UUID 是文件系统的唯一标识符，永远不变。

</div>

---

#### 方法 A：使用 genfstab 自动生成（推荐）

<details>
<summary><b>点击展开查看详细步骤</b></summary>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**安装 genfstab**

`genfstab` 包含在 `sys-fs/genfstab` 包中（源自 Arch Linux 的 `arch-install-scripts`）。

- **Gig-OS / Arch LiveISO**：已预装，可直接使用
- **Gentoo Minimal ISO**：需要先安装 `emerge --ask sys-fs/genfstab`

</div>

<details>
<summary><b>genfstab 参数说明</b></summary>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

| 参数 | 说明 | 推荐度 |
|------|------|--------|
| `-U` | 使用文件系统 **UUID** 标识 | 推荐 |
| `-L` | 使用文件系统 **LABEL** 标识 | 需预设标签 |
| `-t PARTUUID` | 使用 GPT 分区 **PARTUUID** | GPT 专用 |
| 无参数 | 使用设备路径（`/dev/sdX`） | 不推荐 |

**推荐使用 `-U` 参数**，UUID 是文件系统的唯一标识符，不会因磁盘顺序变化而改变。

</div>

</details>

**标准用法（在 chroot 外执行）：**

```bash
# 1. 确认所有分区已正确挂载
lsblk
mount | grep /mnt/gentoo

# 2. 生成 fstab（使用 UUID）
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab

# 3. 检查生成的文件
cat /mnt/gentoo/etc/fstab
```

<details>
<summary><b>chroot 环境下的替代方案</b></summary>

如果你已经 chroot 进入了新系统（`/mnt/gentoo` 变成了 `/`），有以下几种方法：

**方法一：在 chroot 内执行（最简单）**

```bash
# 在 chroot 内安装
emerge --ask sys-fs/genfstab

# 直接对根目录生成
genfstab -U / >> /etc/fstab

# 检查并清理多余条目（可能包含 /proc、/sys、/dev 等）
vim /etc/fstab
```

**方法二：开启新终端窗口（LiveGUI）**

如果使用 Gig-OS 等带图形界面的 Live 环境，直接开启新终端窗口（默认在 Live 环境中）：

```bash
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```

**方法三：使用 TTY 切换（Minimal ISO）**

1. 按 `Ctrl+Alt+F2` 切换到新 TTY（Live 环境）
2. 安装并执行：
   ```bash
   emerge --ask sys-fs/genfstab
   genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
   ```
3. 按 `Ctrl+Alt+F1` 切回 chroot 环境

</details>

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**genfstab 兼容性说明**

[`genfstab`](https://wiki.archlinux.org/title/Genfstab) 工具会自动检测当前挂载点下的所有文件系统，[原始码](https://github.com/glacion/genfstab/blob/master/genfstab)中明确支持：

- **Btrfs 子卷**：自动识别 `subvol=` 参数（不会误判为 bind mount）
- **LUKS 加密分区**：自动使用解密后设备（`/dev/mapper/xxx`）的 UUID
- **普通分区**：ext4、xfs、vfat 等常规文件系统

**前提条件**：在执行 `genfstab` 之前，必须确保所有分区已正确挂载（包括 Btrfs 子卷和已解密的 LUKS 分区）。

</div>

</details>

---

#### 方法 B：手动编辑

<details>
<summary><b>点击展开手动配置方法</b></summary>

如果不使用 `genfstab`，可以手动编辑 `/etc/fstab`。

**1. 获取分区 UUID**

```bash
blkid
```

输出示例：
```text
/dev/nvme0n1p1: UUID="7E91-5869" TYPE="vfat" PARTLABEL="EFI"
/dev/nvme0n1p2: UUID="7fb33b5d-..." TYPE="swap" PARTLABEL="swap"
/dev/nvme0n1p3: UUID="8c08f447-..." TYPE="xfs" PARTLABEL="root"
```

**2. 编辑 fstab**

```bash
vim /etc/fstab
```

**基础配置示例（ext4/xfs）：**

```fstab
# <UUID>                                   <挂载点>     <类型> <选项>            <dump> <fsck>
UUID=7E91-5869                             /efi         vfat   defaults,noatime  0      2
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none         swap   sw                0      0
UUID=8c08f447-c79c-4fda-8c08-f447c79ce690  /            xfs    defaults,noatime  0      1
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

**fstab 字段说明**

| 字段 | 说明 |
|------|------|
| UUID | 分区的唯一标识符（通过 `blkid` 获取） |
| 挂载点 | 文件系统挂载位置（swap 使用 `none`） |
| 类型 | 文件系统类型：`vfat`、`ext4`、`xfs`、`btrfs`、`swap` |
| 选项 | 挂载选项，多个用逗号分隔 |
| dump | 备份标志，通常为 `0` |
| fsck | 启动时检查顺序：`1`=根分区，`2`=其他，`0`=不检查 |

</div>

</details>

---

<details>
<summary><b>Btrfs 子卷配置</b></summary>

**genfstab 自动生成：**

只要 Btrfs 子卷已正确挂载，`genfstab -U` 会自动识别并生成包含 `subvol=` 的配置。

```bash
# 确认子卷挂载情况
mount | grep btrfs
# 输出示例：/dev/nvme0n1p3 on /mnt/gentoo type btrfs (rw,noatime,compress=zstd:3,subvol=/@)

# 自动生成
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```

**手动配置示例：**

```fstab
# Root 子卷
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /       btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@       0 0

# Home 子卷（同一 UUID，不同子卷）
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /home   btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@home   0 0

# Swap（独立分区）
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none    swap   sw                                                                            0 0

# EFI 分区
UUID=7E91-5869                             /efi    vfat   defaults,noatime,fmask=0022,dmask=0022                                        0 2
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

**Btrfs 常用挂载选项**

| 选项 | 说明 |
|------|------|
| `compress=zstd:3` | zstd 压缩，级别 3（推荐，平衡性能与压缩率） |
| `discard=async` | 异步 TRIM（SSD 推荐） |
| `space_cache=v2` | v2 版空间缓存（默认启用，性能更好） |
| `subvol=@` | 指定挂载的子卷 |
| `noatime` | 不记录访问时间（提升性能） |

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

- 同一 Btrfs 分区的所有子卷使用**相同的 UUID**
- 务必使用 `blkid` 获取你实际的 UUID

</div>

</details>

<details>
<summary><b>LUKS 加密分区配置</b></summary>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**关键点**

fstab 必须使用**解密后映射设备**的 UUID（`/dev/mapper/xxx`），而非 LUKS 容器的 UUID。

</div>

**genfstab 自动生成：**

`genfstab` 会自动检测解密后的设备并使用正确的 UUID：

```bash
# 确认 LUKS 已解密
lsblk
# 应看到类似：nvme0n1p3 → cryptroot → 挂载点

# 自动生成（会使用 /dev/mapper/cryptroot 的 UUID）
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
```

**手动配置：区分两种 UUID**

```bash
blkid
```

```text
# LUKS 容器（TYPE="crypto_LUKS"）- 不要用这个！
/dev/nvme0n1p3: UUID="562d0251-..." TYPE="crypto_LUKS"

# 解密后设备（TYPE="btrfs"）- 用这个！
/dev/mapper/cryptroot: UUID="7b44c5eb-..." TYPE="btrfs"
```

**手动配置示例（Btrfs on LUKS）：**

```fstab
# Root（使用解密后设备 /dev/mapper/cryptroot 的 UUID）
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /       btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@       0 0

# Home（同一加密分区的不同子卷，UUID 相同）
UUID=7b44c5eb-caa0-413b-9b7e-a991e1697465  /home   btrfs  defaults,noatime,compress=zstd:3,discard=async,space_cache=v2,subvol=@home   0 0

# Swap（独立分区或加密 swap）
UUID=7fb33b5d-4cff-47ff-ab12-7b461b5d6e13  none    swap   sw                                                                            0 0

# EFI（不加密）
UUID=7E91-5869                             /efi    vfat   defaults,noatime,fmask=0022,dmask=0022                                        0 2
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(59, 130, 246); margin: 1.5rem 0;">

**常见问题**

**Q: 为什么不能用 LUKS 容器的 UUID？**  
A: LUKS 容器是加密的原始数据，系统无法读取其中的文件系统。必须先解密，解密后的 `/dev/mapper/xxx` 才有可识别的文件系统和 UUID。

**Q: `discard=async` 在 LUKS 上安全吗？**  
A: LUKS2 + `discard` 是安全的。若极度在意安全性，可移除此选项（会降低 SSD 性能）。

</div>

</details>

</details>

---

## 7. 内核与固件 {#step-7-kernel}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 配置 Linux 内核](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

内核是操作系统的核心，负责管理硬件。Gentoo 允许你手动裁剪内核，只保留你需要的驱动，从而获得极致的性能和精简的体积。新手也可以选择预编译内核快速上手。

</div>

### 7.1 快速方案：预编译内核

```bash
emerge --ask sys-kernel/gentoo-kernel-bin
```

内核升级后记得重新生成引导程序配置。

<details>
<summary><b>进阶设置：手动编译内核 (Gentoo 核心体验)（点击展开）</b></summary>

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**新手提示**

编译内核比较复杂且耗时。如果你想尽快体验 Gentoo，可以先跳过本节，使用 7.1 的预编译内核。

</div>

手动编译内核能让你完全掌控系统功能，移除不需要的驱动，获得更精简、高效的内核。

**快速开始**（使用 Genkernel 自动化）：
```bash
emerge --ask sys-kernel/gentoo-sources sys-kernel/genkernel
genkernel --install all  # 自动编译并安装内核、模块和 initramfs
# --install: 编译完成后自动安装到 /boot 目录
# all: 完整构建 (内核 + 模块 + initramfs)
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**进阶内容**

如果你想深入了解内核配置、使用 LLVM/Clang 编译内核、启用 LTO 优化等高级选项，请参考 **[Section 16.0 内核编译进阶指南](/posts/2025-11-25-gentoo-install-advanced/#section-16-kernel-advanced)**。

</div>

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

<div style="background: linear-gradient(135deg, rgba(251, 191, 36, 0.1), rgba(245, 158, 11, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0; border-left: 3px solid rgb(251, 191, 36);">

**关于 package.license 的说明**

你可能注意到前面 make.conf 范例中已经设置了 `ACCEPT_LICENSE="*"`，为什么这里还要单独为 linux-firmware 创建 package.license 文件？

- **make.conf 只是范例**：实际使用中，很多用户会根据自己的需求修改 `ACCEPT_LICENSE`，比如设置为 `@FREE` 只接受自由软件许可证
- **显式声明更清晰**：单独的 package.license 文件明确记录了哪些软件包需要特殊许可证，便于日后维护和审计
- **最佳实践**：即使全局设置了 `ACCEPT_LICENSE="*"`，为特定软件包创建 license 文件也是 Gentoo 社区推荐的做法，这样在将来调整全局许可证策略时，不会意外阻止关键软件包的安装

</div>

---

## 8. 基础工具 {#step-8-base-packages}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 安装必要的系统工具](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

Stage3 只有最基础的命令。我们需要补充系统日志、网络管理、文件系统工具等必要组件，才能让系统在重启后正常工作。

</div>

### 8.1 系统服务工具

<details>
<summary><b>OpenRC 用户配置（点击展开）</b></summary>

**1. 系统日志**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Syslog-ng](https://wiki.gentoo.org/wiki/Syslog-ng)

</div>

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

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) · [System Time (OpenRC)](https://wiki.gentoo.org/wiki/System_time/zh-cn#OpenRC)

</div>

```bash
emerge --ask net-misc/chrony
rc-update add chronyd default
```

</details>

<details>
<summary><b>systemd 用户配置（点击展开）</b></summary>

systemd 已内置日志与定时任务服务，无需额外安装。

**时间同步**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[System Time](https://wiki.gentoo.org/wiki/System_time/zh-cn) · [System Time (systemd)](https://wiki.gentoo.org/wiki/System_time/zh-cn#systemd)

</div>

```bash
systemctl enable --now systemd-timesyncd
```

</details>

### 8.2 文件系统工具

根据你使用的文件系统安装对应工具（必选）：

```bash
emerge --ask sys-fs/e2fsprogs  # ext4
emerge --ask sys-fs/xfsprogs   # XFS
emerge --ask sys-fs/dosfstools # FAT/vfat (EFI 分区需要)
emerge --ask sys-fs/btrfs-progs # Btrfs
```

## 9. 建立用户与权限 {#step-9-users}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 结束安装](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**为什么需要这一步？**

Linux 不建议日常使用 root 账户。我们需要创建一个普通用户，并赋予其使用 `sudo` 的权限，以提高系统安全性。

</div>

```bash
passwd root # 设置 root 密码
useradd -m -G wheel,video,audio,plugdev zakk # 创建用户并加入常用组
passwd zakk # 设置用户密码
emerge --ask app-admin/sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel # 允许 wheel 组使用 sudo
```

若使用 systemd，可视需求将账号加入 `network`、`lp` 等群组。

---




## 10. 安装引导程序 {#step-10-bootloader}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: AMD64 - 配置引导加载程序](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader/zh-cn)

</div>

### 10.1 GRUB

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[GRUB](https://wiki.gentoo.org/wiki/GRUB/zh-cn)

</div>

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
<summary><b>进阶设置：systemd-boot（仅限 UEFI）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[systemd-boot](https://wiki.gentoo.org/wiki/Systemd/systemd-boot/zh-cn)

**注意**：部分 ARM/RISC-V 设备的固件可能不支持完整的 UEFI 规范，无法使用 systemd-boot。

</div>

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
<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果你使用了 LUKS 加密，options 行需要添加 `rd.luks.uuid=...` 等参数。

</div>

**2. 更新引导项**：
每次更新内核后，需要手动更新 `gentoo.conf` 中的版本号，或者使用脚本自动化。

**2. 创建 Windows 引导项 (双系统)**

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

如果你创建了新的 EFI 分区，请记得将原 Windows EFI 文件 (EFI/Microsoft) 复制到新分区。

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

<details>
<summary><b>进阶设置：加密支持（仅加密用户）（点击展开）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt/zh-cn)

</div>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果你在步骤 3.4 中选择了加密分区，才需要执行此步骤。

</div>

**步骤 1：启用 systemd cryptsetup 支持**

```bash
mkdir -p /etc/portage/package.use
echo "sys-apps/systemd cryptsetup" >> /etc/portage/package.use/fde

# 重新编译 systemd 以启用 cryptsetup 支持
emerge --ask --oneshot sys-apps/systemd
```

**步骤 2：获取 LUKS 分区的 UUID**

```bash
# 获取 LUKS 加密容器的 UUID（不是里面的文件系统 UUID）
blkid /dev/nvme0n1p3
```

输出示例：
```text
/dev/nvme0n1p3: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="crypto_LUKS" ...
```
记下这个 **LUKS UUID**（例如：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）。

**步骤 3：配置 GRUB 内核参数**

```bash
vim /etc/default/grub
```

加入或修改以下内容（**替换 UUID 为实际值**）：

```bash
# 完整示例（替换 UUID 为你的实际 UUID）
GRUB_CMDLINE_LINUX="rd.luks.uuid=<LUKS-UUID> rd.luks.allow-discards root=UUID=<ROOT-UUID> rootfstype=btrfs"
```

**参数说明**：
- `rd.luks.uuid=<UUID>`：LUKS 加密分区的 UUID（使用 `blkid /dev/nvme0n1p3` 获取）
- `rd.luks.allow-discards`：允许 SSD TRIM 指令穿透加密层（提升 SSD 性能）
- `root=UUID=<UUID>`：解密后的 btrfs 文件系统 UUID（使用 `blkid /dev/mapper/gentoo-root` 获取）
- `rootfstype=btrfs`：根文件系统类型（如果使用 ext4 改为 `ext4`）

<details>
<summary><b>步骤 3.1（替代方案）：配置内核参数 (systemd-boot 方案)（点击展开）</b></summary>

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

</details>

**步骤 4：安装并配置 dracut**

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Dracut](https://wiki.gentoo.org/wiki/Dracut) · [Initramfs](https://wiki.gentoo.org/wiki/Initramfs)

</div>

```bash
# 安装 dracut（如果还没安装）
emerge --ask sys-kernel/dracut
```

**步骤 5：配置 dracut for LUKS 解密**

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

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**恭喜！** 你已经完成了 Gentoo 的基础安装。

**下一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)

</div>
