---
title: "下载"
---

Gentoo Linux 提供多种安装介质供用户下载。本页面列出官方下载源和中国内陆推荐的快速下载源。

**新手入坑推荐使用每周构建的 KDE 桌面环境的 Live ISO：** <https://iso.gig-os.org/>  
（来自 [Gig-OS](https://github.com/Gig-OS) 项目）

**Live ISO 登录凭据：**
- 账号：`live`
- 密码：`live`
- Root 密码：`live`

**系统支持：**
- 支持中文显示和中文输入法(fcixt5),flclash等

## 官方下载页面

**Gentoo 官方下载页：** <https://www.gentoo.org/downloads/>

官方提供了以下安装介质：
- **Minimal Installation CD**：最小化安装光盘，适合有经验的用户
- **LiveGUI**：带图形界面的 Live 系统，适合新用户
- **Stage Archives**：Stage3 压缩包，Stage3 是一个预先编译好的最小化 Linux 使用者空间环境，它内含了完整的编译工具链（GCC）与 Portage 套件管理器，作为使用者从原始码构建个性化 Gentoo 系统的标准起点
## 架构选择

Gentoo 支持多种 CPU 架构：
- **amd64** - 64 位 x86 架构（最常用，支持 Intel 和 AMD 处理器）
- **x86** - 32 位 x86 架构
- **arm64** - 64 位 ARM 架构
- **arm** - 32 位 ARM 架构
- 其他架构请参考官方下载页

>  **Apple Silicon Mac (M1/M2/M3/M4) 用户注意**：
>
> 本页面列出的标准镜像**暂不支持 Apple Silicon Mac**。如果您使用 M 系列 MacBook，请访问：
>
>  **[Apple Silicon Mac 安装指南 - 下载 Asahi Live USB](/posts/2025-10-02-gentoo-m-series-mac/#01-%e4%b8%8b%e8%bd%bd%e5%ae%98%e6%96%b9-gentoo-asahi-live-usb)**

## 中国内陆镜像源

以下镜像源提供 Gentoo 安装介质的快速下载（推荐中国内陆用户使用）：

### 清华大学开源镜像站
- **下载地址：** <https://mirrors.tuna.tsinghua.edu.cn/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等
- 稳定快速，推荐使用

### 中国科学技术大学（USTC）
- **下载地址：** <https://mirrors.ustc.edu.cn/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等
- 教育网和公网访问速度都很快

### 浙江大学
- **下载地址：** <https://mirrors.zju.edu.cn/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

### 北京外国语大学
- **下载地址：** <https://mirrors.bfsu.edu.cn/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

### 网易开源镜像
- **下载地址：** <https://mirrors.163.com/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

### 南京大学 eScience Center
- **下载地址：** <https://mirrors.nju.edu.cn/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

## 其他亚洲地区镜像

### 香港地区

**CICKU 镜像**
- **下载地址：** <https://hk.mirrors.cicku.me/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

**PlanetUnix Networks**
- **下载地址：** <https://hippocamp.cn.ext.planetunix.net/pub/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

### 台湾地区

**国家高速网络与计算中心（NCHC）**
- **下载地址：** <http://ftp.twaren.net/Linux/Gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

**CICKU 台湾镜像**
- **下载地址：** <https://tw.mirrors.cicku.me/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

### 新加坡地区

**Freedif**
- **下载地址：** <https://mirror.freedif.org/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

**CICKU 新加坡镜像**
- **下载地址：** <https://sg.mirrors.cicku.me/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

**PlanetUnix Networks**
- **下载地址：** <https://enceladus.sg.ext.planetunix.net/pub/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

### 日本地区

**北陆尖端科学技术大学院大学（JAIST）**
- **下载地址：** <https://ftp.iij.ad.jp/pub/linux/gentoo/releases/>
- 支持架构：amd64, x86, arm64 等

## 下载文件说明

在镜像站的 `releases/` 目录下，选择您的架构（如 `amd64/`），然后选择：

### 安装 ISO 镜像
- 目录：`autobuilds/current-install-amd64-minimal/`
  - `install-amd64-minimal-*.iso` - 最小化安装 ISO
  - `install-amd64-minimal-*.iso.DIGESTS` - 校验文件

- 目录：`autobuilds/current-livegui-amd64/`
  - `livegui-amd64-*.iso` - 图形化 Live ISO

### Stage3 压缩包
- 目录：`autobuilds/current-stage3-amd64-*/`
  - `stage3-amd64-*.tar.xz` - Stage3 压缩包
  - `stage3-amd64-*.tar.xz.DIGESTS` - 校验文件

**重要提示：** 下载后请验证文件完整性（使用 DIGESTS 文件）。

## 验证下载文件

下载完成后，建议验证文件的完整性：

```bash
# 计算 SHA512 校验和
sha512sum install-amd64-minimal-*.iso

# 与 DIGESTS 文件中的值对比
cat install-amd64-minimal-*.iso.DIGESTS
```

## 安装指南

下载安装介质后，请参考：
- **Gentoo 官方手册：** <https://wiki.gentoo.org/wiki/Handbook:AMD64/zh-cn>
- **中文社区文档：** 正在建设中