---
title: "Gentoo Linux 安装指南 (高端优化篇)"
date: 2025-11-25
summary: "Gentoo Linux 高端优化教程，涵盖 make.conf 优化、LTO、Tmpfs、系统维护等。"
description: "2025 年最新 Gentoo Linux 安装指南 (高端优化篇)，涵盖 make.conf 优化、LTO、Tmpfs、系统维护等。"
keywords:
  - Gentoo Linux
  - make.conf
  - LTO
  - Tmpfs
  - 系统维护
  - 编译优化
tags:
  - Gentoo
  - Linux
  - 教程
  - 系统优化
categories:
  - tutorial
authors:
  - zakkaus
---

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 文章特别说明

本文是 **Gentoo Linux 安装指南** 系列的第三部分：**高端优化**。

**系列导航**：
1. [基础安装](/posts/2025-11-25-gentoo-install-base/)：从零开始安装 Gentoo 基础系统
2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：显卡驱动、桌面环境、输入法等
3. **高端优化（本文）**：make.conf 优化、LTO、系统维护

**上一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)

</div>

## 13. make.conf 高端配置指南

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**官方文档**：[make.conf - Gentoo Wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf) · [基础篇 5.2 节：make.conf 范例](/posts/2025-11-25-gentoo-install-base/#52-makeconf-范例)

</div>

`/etc/portage/make.conf` 是 Gentoo 的内核配置文档，控制着软件包的编译方式、系统功能和优化参数。本章将深入讲解各个配置项的含义与最佳实践。

---

### 13.1 编译器优化参数

这些参数决定了软件包的编译方式，直接影响系统性能。

#### COMMON_FLAGS：编译器通用标志

```bash
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
```

**参数详解**：

| 参数 | 说明 | 注意事项 |
|------|------|----------|
| `-march=native` | 针对当前 CPU 架构优化 | 编译的程序可能无法在其他 CPU 上运行 |
| `-O2` | 优化级别 2（推荐） | 平衡性能、稳定性与编译时间 |
| `-O3` | 激进优化（不推荐） | 可能导致部分软件编译失败或运行异常 |
| `-pipe` | 使用管道传递数据 | 加速编译，略微增加内存占用 |

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**推荐配置**

对于大多数用户，使用 `-march=native -O2 -pipe` 已经足够。除非你明确知道自己在做什么，否则不要使用 `-O3` 或其他激进优化参数。

</div>

#### CPU 指令集优化 (CPU_FLAGS_X86)

CPU 指令集标志建议使用 `app-portage/cpuid2cpuflags` 自动检测并写入 `CPU_FLAGS_X86`。

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**快速上手**：请参考 [基础篇 5.3 节：CPU 指令集优化](/posts/2025-11-25-gentoo-install-base/#53-配置-cpu-指令集优化)

**完整说明（推荐）**：请参考 [13.13 节：CPU 指令集优化 (CPU_FLAGS_X86)](#1313-cpu-指令集优化-cpu_flags_x86)

</div>

---

### 13.2 并行编译配置

控制编译过程的并行化程度，合理配置可大幅加速软件包安装。

#### MAKEOPTS：单个包的并行编译

```bash
MAKEOPTS="-j<线程数> -l<负载限制>"
```

**推荐配置**（根据 CPU 线程数和内存容量）：

| 硬件配置 | MAKEOPTS | 说明 |
|---------|----------|------|
| 4核8线程 + 16GB 内存 | `-j8 -l8` | 标准配置 |
| 8核16线程 + 32GB 内存 | `-j16 -l16` | 主流配置 |
| 16核32线程 + 64GB 内存 | `-j32 -l32` | 高端配置 |
| 内存不足（< 8GB） | `-j<线程数/2>` | 减半避免内存耗尽 |

**参数说明**：
- `-j<N>`：同时运行的编译任务数（建议 = CPU 线程数）
- `-l<N>`：系统负载上限，超过此值暂停新任务

#### EMERGE_DEFAULT_OPTS：多包并行编译

```bash
EMERGE_DEFAULT_OPTS="--ask --verbose --jobs=<并行包数> --load-average=<负载>"
```

**推荐配置**：

| CPU 线程数 | --jobs 值 | 说明 |
|-----------|----------|------|
| 4-8 线程 | 2 | 同时编译 2 个包 |
| 12-16 线程 | 3-4 | 同时编译 3-4 个包 |
| 24+ 线程 | 4-6 | 同时编译 4-6 个包 |

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意事项**

- `--jobs` 会显著增加内存占用，内存不足时请谨慎使用
- 推荐先使用默认单包编译，稳定后再激活多包并行
- Chrome、LLVM 等大型软件包单独编译时已占用大量内存

</div>

---

### 13.3 USE 标志管理

USE 标志控制软件功能的开关，是 Gentoo 定制化的内核。

#### 全局 USE 标志

```bash
USE="systemd dbus policykit networkmanager bluetooth"
USE="${USE} wayland X gtk qt6"
USE="${USE} pipewire pulseaudio alsa"
USE="${USE} -doc -test -examples"
```

**分类说明**：

<details>
<summary><b>系统与初始化（点击展开）</b></summary>

| USE 标志 | 说明 | 推荐 |
|---------|------|------|
| `systemd` | 使用 systemd init 系统 | 新手推荐 |
| `openrc` | 使用 OpenRC init 系统 | 传统用户 |
| `udev` | 现代设备管理 | 必需 |
| `dbus` | 进程间通信（桌面必需） | 桌面必需 |
| `policykit` | 权限管理（桌面必需） | 桌面必需 |

</details>

<details>
<summary><b>桌面环境与显示（点击展开）</b></summary>

| USE 标志 | 说明 | 推荐 |
|---------|------|------|
| `wayland` | Wayland 显示协议 | 现代桌面推荐 |
| `X` | X11 显示协议 | 兼容性好 |
| `gtk` | GTK+ 工具包（GNOME/Xfce） | GNOME 用户 |
| `qt6` / `qt5` | Qt 工具包（KDE Plasma） | KDE 用户 |
| `kde` | KDE 集成 | KDE 用户 |
| `gnome` | GNOME 集成 | GNOME 用户 |

</details>

<details>
<summary><b>多媒体与音频（点击展开）</b></summary>

| USE 标志 | 说明 | 推荐 |
|---------|------|------|
| `pipewire` | 现代音频/视频服务器 | 现代桌面推荐 |
| `pulseaudio` | PulseAudio 音频服务器 | 传统桌面 |
| `alsa` | ALSA 音频支持 | 底层必需 |
| `ffmpeg` | FFmpeg 编解码支持 | 推荐 |
| `x264` / `x265` | H.264/H.265 视频编码 | 视频处理 |
| `vaapi` / `vdpau` | 硬件视频加速 | 有显卡推荐 |

</details>

<details>
<summary><b>网络与连接（点击展开）</b></summary>

| USE 标志 | 说明 | 推荐 |
|---------|------|------|
| `networkmanager` | 图形化网络管理 | 桌面用户推荐 |
| `bluetooth` | 蓝牙支持 | 需要时激活 |
| `wifi` | 无线网络支持 | 笔记本必需 |

</details>

<details>
<summary><b>国际化与文档（点击展开）</b></summary>

| USE 标志 | 说明 | 推荐 |
|---------|------|------|
| `cjk` | 中日韩字体与输入法支持 | 中文用户必需 |
| `nls` | 本机化支持（软件翻译） | 推荐 |
| `icu` | Unicode 支持 | 推荐 |
| `-doc` | 禁用文档安装 | 节省空间 |
| `-test` | 禁用测试套件 | 加速编译 |
| `-examples` | 禁用示例文档 | 节省空间 |

</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**USE 标志策略建议**

1. **最小化原则**：只激活你需要的功能，禁用不需要的（使用 `-` 前缀）
2. **分类管理**：用 `USE="${USE} ......"` 分类添加，便于维护
3. **单包覆盖**：特定软件包的 USE 标志放在 `/etc/portage/package.use/` 中

</div>

---

### 13.4 语言与本机化

```bash
# 软件翻译与文档支持
L10N="en en-US zh zh-CN zh-TW"

# 旧式本机化变量（部分软件仍需要）
LINGUAS="en en_US zh zh_CN zh_TW"

# 保持编译输出为英文（便于搜索错误信息）
LC_MESSAGES=C
```

---

### 13.5 许可证管理 (ACCEPT_LICENSE)

控制系统可以安装哪些许可证的软件。

#### 常见配置方式

```bash
# 方式 1：接受所有许可证（新手推荐）
ACCEPT_LICENSE="*"

# 方式 2：仅自由软件
ACCEPT_LICENSE="@FREE"

# 方式 3：自由软件 + 可再分发的二进制
ACCEPT_LICENSE="@FREE @BINARY-REDISTRIBUTABLE"

# 方式 4：严格控制（拒绝所有，再显式允许）
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"
```

#### 许可证组说明

| 许可证组 | 说明 |
|---------|------|
| `@FREE` | 所有自由软件（OSI/FSF 认证） |
| `@BINARY-REDISTRIBUTABLE` | 允许再分发的二进制软件 |
| `@GPL-COMPATIBLE` | GPL 兼容许可证 |

#### 單包許可證配置（推薦方式）

```bash
# /etc/portage/package.license/firmware
sys-kernel/linux-firmware linux-fw-redistributable
sys-firmware/intel-microcode intel-ucode

# /etc/portage/package.license/nvidia
x11-drivers/nvidia-drivers NVIDIA-r2
```

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**詳見**：[13.12 節：ACCEPT_LICENSE 軟體許可證詳解](#1312-accept_license-軟體許可證詳解)

</div>

---

### 13.6 Portage 功能增强 (FEATURES)

```bash
FEATURES="parallel-fetch candy"
```

**常用 FEATURES**：

| 功能 | 说明 | 推荐 |
|-----|------|------|
| `parallel-fetch` | 并行下载源码包 | 推荐 |
| `candy` | 美化 emerge 输出（彩色进度条） | 推荐 |
| `ccache` | 编译缓存（需安装 `dev-build/ccache`） | 频繁重编译时推荐 |
| `parallel-install` | 并行安装（实验性） | 不推荐 |
| `splitdebug` | 分离调试信息 | 调试时使用 |

---

### 13.7 镜像源配置 (GENTOO_MIRRORS)

```bash
# 中国大陆镜像（推荐）
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# 或使用其他镜像：
# GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"
# GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"
```

---

### 13.8 编译日志配置

```bash
# 记录哪些级别的日志
PORTAGE_ELOG_CLASSES="warn error log qa"

# 日志保存方式
PORTAGE_ELOG_SYSTEM="save"  # 保存到 /var/log/portage/elog/
```

**日志级别说明**：
- `warn`：警告信息（配置问题）
- `error`：错误信息（编译失败）
- `log`：普通日志
- `qa`：质量保证警告（安全问题）

---

### 13.9 显卡与输入设备

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**重要提示**

`VIDEO_CARDS` 和 `INPUT_DEVICES` **不建议**在 make.conf 中全局配置。

推荐使用 `/etc/portage/package.use/` 方式针对特定软件包配置，详见 [桌面配置篇 12.1 节](/posts/2025-11-25-gentoo-install-desktop/#121-全局配置)。

</div>

---

### 13.10 完整配置示例

<details>
<summary><b>新手推荐配置（点击展开）</b></summary>

```bash
# /etc/portage/make.conf
# vim: set filetype=bash

# ========== 编译器优化 ==========
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# ========== 并行编译 ==========
MAKEOPTS="-j8"  # 根据 CPU 线程数调整

# ========== USE 标志 ==========
USE="systemd dbus policykit networkmanager bluetooth"
USE="${USE} wayland pipewire"
USE="${USE} -doc -test"

# ========== 语言与本机化 ==========
L10N="en zh zh-CN"
LINGUAS="en zh_CN"
LC_MESSAGES=C

# ========== 镜像源 ==========
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# ========== Portage 配置 ==========
FEATURES="parallel-fetch candy"
EMERGE_DEFAULT_OPTS="--ask --verbose"

# ========== 许可证 ==========
ACCEPT_LICENSE="*"

# ========== 编译日志 ==========
PORTAGE_ELOG_CLASSES="warn error log"
PORTAGE_ELOG_SYSTEM="save"
```

</details>

<details>
<summary><b>高性能配置（点击展开）</b></summary>

```bash
# /etc/portage/make.conf
# vim: set filetype=bash

# ========== 编译器优化 ==========
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# ========== 并行编译（高端硬件） ==========
MAKEOPTS="-j32 -l32"
EMERGE_DEFAULT_OPTS="--ask --verbose --jobs=4 --load-average=32"

# ========== USE 标志（完整桌面） ==========
USE="systemd udev dbus policykit"
USE="${USE} networkmanager bluetooth wifi"
USE="${USE} wayland X gtk qt6 kde"
USE="${USE} pipewire pulseaudio alsa"
USE="${USE} ffmpeg x264 x265 vaapi vulkan"
USE="${USE} cjk nls icu"
USE="${USE} -doc -test -examples"

# ========== 语言与本机化 ==========
L10N="en en-US zh zh-CN zh-TW"
LINGUAS="en en_US zh zh_CN zh_TW"
LC_MESSAGES=C

# ========== 镜像源 ==========
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/ http://ftp.twaren.net/Linux/Gentoo/"

# ========== Portage 配置 ==========
FEATURES="parallel-fetch candy ccache"
CCACHE_DIR="/var/cache/ccache"

# ========== 许可证 ==========
ACCEPT_LICENSE="*"

# ========== 编译日志 ==========
PORTAGE_ELOG_CLASSES="warn error log qa"
PORTAGE_ELOG_SYSTEM="save"
```

</details>

---

### 13.11 详细配置范例（完整注释版）

<details>
<summary><b>详细配置范例（建议阅读并调整）（点击展开）</b></summary>

```conf
# vim: set filetype=bash  # 告诉 Vim 使用 bash 语法高亮

# ========== 系统架构（勿手动修改） ==========
# 由 Stage3 缺省，表示目标系统架构（通常无需修改）
CHOST="x86_64-pc-linux-gnu"

# ========== 编译优化参数 ==========
# -march=native    针对当前 CPU 架构优化，性能最佳
#                  注意：编译出的程序可能无法在其他 CPU 上运行
# -O2              推荐的优化级别（平衡性能、稳定性、编译时间）
#                  注意：避免使用 -O3，可能导致软件编译失败或运行异常
# -pipe            使用管道代替临时文档，加速编译过程
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"      # C 语言编译器选项
CXXFLAGS="${COMMON_FLAGS}"    # C++ 语言编译器选项
FCFLAGS="${COMMON_FLAGS}"     # Fortran 编译器选项
FFLAGS="${COMMON_FLAGS}"      # Fortran 77 编译器选项

# CPU 指令集优化（自动生成，见下文 13.13 节）
# 运行: emerge --ask app-portage/cpuid2cpuflags && cpuid2cpuflags >> /etc/portage/make.conf
# CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"

# ========== 并行编译设置 ==========
# MAKEOPTS: 控制 make 的并行任务数
#   -j<N>   同时运行的编译任务数，推荐值 = CPU 线程数（运行 nproc 查看）
#   -l<N>   系统负载限制，防止系统重载（可选，一般与 -j 值相同）
MAKEOPTS="-j8"  # 示例：8 线程 CPU

# 内存不足时的调整建议：
#    16GB 内存 + 8 核 CPU → MAKEOPTS="-j4 -l8"  (减半并行数)
#    32GB 内存 + 16 核 CPU → MAKEOPTS="-j16 -l16"

# ========== 语言与本机化设置 ==========
# LC_MESSAGES: 保持编译输出为英文，便于搜索错误信息和社区求助
LC_MESSAGES=C

# L10N: 本机化语言支持（影响软件翻译、帮助文档、拼写检查等）
L10N="en en-US zh zh-CN zh-TW"

# LINGUAS: 旧式本机化变量（部分软件仍依赖此变量）
LINGUAS="en en_US zh zh_CN zh_TW"

# ========== 镜像源设置 ==========
# 台湾常用镜像（任选其一）：
#   TWAREN (台湾学术网络): http://ftp.twaren.net/Linux/Gentoo/
#   NCHC (国家高速网络中心):       http://ftp.twaren.net/Linux/Gentoo/
#   : http://ftp.twaren.net/Linux/Gentoo/
#   :   http://ftp.twaren.net/Linux/Gentoo/
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# ========== Emerge 默认选项 ==========
# --ask              运行前询问确认（推荐保留，防止误操作）
# --verbose          显示详细信息（USE 标志变化、依赖关系等）
# --with-bdeps=y     更新时也检查构建时依赖（避免依赖过时）
# --complete-graph=y 完整的依赖图分析（解决复杂依赖冲突）
EMERGE_DEFAULT_OPTS="--ask --verbose --with-bdeps=y --complete-graph=y"

# 高级用户可选配置（需要充足内存）：
#    --jobs=N           并行编译多个软件包（内存充足时建议 2-4）
#    --load-average=N   系统负载上限（建议与 CPU 内核数相同）
# EMERGE_DEFAULT_OPTS="--ask --verbose --jobs=2 --load-average=8"

# ========== USE 标志（全局功能开关） ==========
# 控制所有软件包的编译选项，影响功能可用性和依赖关系
#
# 系统基础：
#   systemd        使用 systemd init 系统（若用 OpenRC 改为 -systemd）
#   udev           现代设备管理（推荐保留）
#   dbus           进程间通信（桌面环境必需）
#   policykit      权限管理（桌面环境必需）
#
# 网络与硬件：
#   networkmanager 图形化网络管理（桌面用户推荐）
#   bluetooth      蓝牙支持
#
# 开发工具：
#   git            Git 版本控制（开发者必备）
#
# 内核选择：
#   dist-kernel    使用发行版预配置内核（新手强烈推荐）
#                  不使用此标志则需手动配置内核（见第 7 章）
#
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"

# 常用的可选 USE 标志：
#   音频：pulseaudio / pipewire（音频服务器，二选一）
#   显示：wayland / X（显示协议，桌面环境需要）
#   图形：vulkan, opengl（现代图形 API）
#   视频：vaapi, vdpau（硬件视频加速）
#   打印：cups（打印系统）
#   容器：flatpak, appimage（第三方应用支持）
#   禁用：-doc, -test, -examples（节省编译时间和磁盘空间）

# ========== 许可证设置 ==========
# ACCEPT_LICENSE: 控制可安装软件的许可证类型
#
# 常见配置：
#   "*"                接受所有许可证（新手推荐，避免许可证问题阻止安装）
#   "@FREE"            仅接受自由软件（严格的开源政策）
#   "@BINARY-REDISTRIBUTABLE"  允许自由再分发的二进制软件
#   "-* @FREE"         拒绝所有后显式允许（最严格控制）
#
# 推荐策略：
#   - 新手/桌面用户：使用 "*" 避免许可证问题
#   - 开源软件坚持者：使用 "@FREE"，需要闭源软件时单独配置
#   - 详细说明见下方「13.12 ACCEPT_LICENSE 详解」
ACCEPT_LICENSE="*"

# 针对特定软件包的许可证配置（推荐方式）：
#    创建 /etc/portage/package.license/ 目录并添加配置文档
#    示例见下方「13.12 ACCEPT_LICENSE 详解」

# ========== Portage 功能配置（可选） ==========
# FEATURES: 激活 Portage 的高级功能
#   parallel-fetch    并行下载源码包（加速更新）
#   parallel-install  并行安装多个包（实验性，可能不稳定）
#   candy             美化 emerge 输出（彩色进度条）
#   ccache            编译缓存（需安装 dev-build/ccache，加速重复编译）
#   splitdebug        分离调试信息到独立文档（节省空间，便于调试）
# FEATURES="parallel-fetch candy"

# ========== 编译日志配置（推荐激活） ==========
# PORTAGE_ELOG_CLASSES: 要记录的日志级别
#   info     一般信息（安装成功消息等）
#   warn     警告信息（配置问题、不推荐的操作）
#   error    错误信息（编译失败、依赖问题）
#   log      普通日志（所有输出）
#   qa       质量保证警告（ebuild 问题、安全警告）
PORTAGE_ELOG_CLASSES="warn error log qa"

# PORTAGE_ELOG_SYSTEM: 日志输出方式
#   save          保存到 /var/log/portage/elog/（推荐，便于事后查看）
#   echo          编译后直接显示在终端
#   mail          通过邮件发送（需配置邮件系统）
#   syslog        发送到系统日志
#   custom        自定义处理脚本
PORTAGE_ELOG_SYSTEM="save"

# 注意：文档末尾必须保留空行（POSIX 标准要求）
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**配置说明**

这是一个带有详细注释的完整 `make.conf` 范例。实际使用时：
1. **必须调整**：`MAKEOPTS`（根据你的 CPU 线程数）、`GENTOO_MIRRORS`（选择就近镜像）
2. **建议调整**：`USE` 标志（根据需要的桌面环境和功能）
3. **可选配置**：`FEATURES`、日志配置等（按需激活）
4. **VIDEO_CARDS / INPUT_DEVICES** 已移至 [桌面配置篇](/posts/2025-11-25-gentoo-install-desktop/)

</div>

</details>

---

### 13.12 ACCEPT_LICENSE 软件许可证详解

<details>
<summary><b>ACCEPT_LICENSE 软件许可证管理（点击展开）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**参考文档**：[Gentoo Handbook: ACCEPT_LICENSE](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Configure_the_ACCEPT_LICENSE_variable) · [GLEP 23](https://www.gentoo.org/glep/glep-0023.html) · [License Groups](https://gitweb.gentoo.org/proj/portage.git/tree/cnf/license_groups)

</div>

#### 什么是 ACCEPT_LICENSE？

根据 [GLEP 23](https://www.gentoo.org/glep/glep-0023.html)（Gentoo Linux Enhancement Proposal 23），Gentoo 提供了一个机制，允许系统管理员"控制他们安装的软件的许可证类型"。`ACCEPT_LICENSE` 变量决定了 Portage 可以安装哪些许可证的软件。

**为什么需要这个？**
- Gentoo 软件仓库包含数千个软件包，涉及数百种不同的软件许可证
- 你可能只想使用自由软件（OSI 认证）或需要接受某些闭源许可证
- 无需逐一审批每个许可证 —— GLEP 23 引入了**许可证组 (License Groups)** 概念

#### 常用许可证组

许可证组使用 `@` 符号前缀，便于与单个许可证区分：

| 许可证组 | 说明 |
|---------|------|
| `@GPL-COMPATIBLE` | FSF 认可的 GPL 兼容许可证 [[1]](https://www.gnu.org/licenses/license-list.html) |
| `@FSF-APPROVED` | FSF 认可的自由软件许可证（包含 `@GPL-COMPATIBLE`）|
| `@OSI-APPROVED` | OSI（Open Source Initiative）认可的开源许可证 [[2]](https://www.opensource.org/licenses) |
| `@MISC-FREE` | 其他可能符合自由软件定义的许可证（未经 FSF/OSI 认证）[[3]](https://www.gnu.org/philosophy/free-sw.html) |
| `@FREE-SOFTWARE` | 合并 `@FSF-APPROVED` + `@OSI-APPROVED` + `@MISC-FREE` |
| `@FSF-APPROVED-OTHER` | FSF 认可的"自由文档"和"实用作品"许可证（包括字体）|
| `@MISC-FREE-DOCS` | 其他自由文档许可证（未列入 `@FSF-APPROVED-OTHER`）[[4]](https://freedomdefined.org/) |
| `@FREE-DOCUMENTS` | 合并 `@FSF-APPROVED-OTHER` + `@MISC-FREE-DOCS` |
| `@FREE` | **所有自由软件和文档**（合并 `@FREE-SOFTWARE` + `@FREE-DOCUMENTS`）|
| `@BINARY-REDISTRIBUTABLE` | 至少允许自由再分发二进制文档的许可证（包含 `@FREE`）|
| `@EULA` | 试图剥夺用户权利的许可协议（比"保留所有权利"更严格）|

#### 查看当前系统设置

```bash
portageq envvar ACCEPT_LICENSE
```

输出示例（默认值）：
```
@FREE
```

这表示系统默认只允许安装 `@FREE` 组的软件（自由软件）。

#### 配置 ACCEPT_LICENSE

可以在以下位置设置：

**1. 系统全局设置（`/etc/portage/make.conf`）**
覆盖 profile 的默认值：

```conf
# 接受所有许可证（包括闭源软件）
ACCEPT_LICENSE="*"

# 或：仅接受自由软件 + 可自由再分发的二进制文档
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"

# 或：仅自由软件（默认值）
ACCEPT_LICENSE="@FREE"
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**推荐做法**

- **新手/桌面用户**：使用 `ACCEPT_LICENSE="*"` 避免许可证问题导致软件安装失败
- **纯自由软件用户**：使用 `ACCEPT_LICENSE="@FREE"`，需要闭源软件时单独为包配置
- 前缀 `-*` 表示先拒绝所有，再显式允许指定组（更严格的控制）

</div>

**2. 针对单个包设置（`/etc/portage/package.license`）**

某些软件包可能需要特定许可证（例如固件、显卡驱动）：

```bash
# 创建目录（如果不存在）
mkdir -p /etc/portage/package.license
```

编辑 `/etc/portage/package.license/kernel`：
```conf
# unrar 压缩工具
app-arch/unrar unRAR

# Linux 固件（包含非自由固件）
sys-kernel/linux-firmware linux-fw-redistributable

# Intel 微码
sys-firmware/intel-microcode intel-ucode
```

#### LICENSE 变量的免责声明

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要提示**

ebuild 中的 `LICENSE` 变量仅是开发者和用户的**参考指南**，不是法律声明，也不保证 100% 准确。请勿仅依赖 ebuild 的许可证标识，建议深入检查软件包本身及其安装的所有文档。

参考：[Gentoo Handbook: ACCEPT_LICENSE](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Configure_the_ACCEPT_LICENSE_variable)

</div>

#### 实际应用建议

在本指南的 `make.conf` 范例中，我们使用了 `ACCEPT_LICENSE="*"`（接受所有许可证）。如果你希望严格控制：

1. 先将 `make.conf` 中的设置改为 `ACCEPT_LICENSE="@FREE"`
2. 安装软件时，如果遇到许可证阻止，Portage 会提示需要哪个许可证
3. 根据需要，在 `/etc/portage/package.license/` 中为特定软件包添加例外

示例（安装闭源 NVIDIA 驱动时的提示）：
```
The following license changes are necessary to proceed:
 x11-drivers/nvidia-drivers NVIDIA-r2
```

解决方式：
```bash
echo "x11-drivers/nvidia-drivers NVIDIA-r2" >> /etc/portage/package.license/nvidia
```

</details>

---

### 13.13 CPU 指令集优化 (CPU_FLAGS_X86)

<details>
<summary><b>CPU 指令集优化 (CPU_FLAGS_X86)（点击展开）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn)

</div>

`CPU_FLAGS_X86` 是 Gentoo 用来描述“你的 CPU 实际支持哪些 x86 指令集”的变量。部分软件包会依据它来开启（或关闭）对应的优化，例如 AES、AVX、SSE4.2 等。

这里刻意不再重复“如何生成并写入 `CPU_FLAGS_X86`”的操作步骤（基础篇已经给了最短可用流程）：

- **快速设置步骤**：请直接按照基础篇 [5.3 配置 CPU 指令集优化](/posts/2025-11-25-gentoo-install-base/#53-配置-cpu-指令集优化) 完成。

完成后，你通常会在 `/etc/portage/make.conf` 看到像这样的一行：
```conf
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

#### 注意事项

1. **避免重复追加**：`cpuid2cpuflags >> /etc/portage/make.conf` 会“追加”到文件末尾。如果你重复执行多次，可能出现多行 `CPU_FLAGS_X86=...`。建议保留最后一行（或你想用的那一行），把其余重复行删掉，避免日后自己看不懂。
2. **跨机器可携性**：如果你会把同一份配置同步到不同主机（或机器会更换 CPU），`CPU_FLAGS_X86` 最好不要“直接复制”。建议在每台机器上各自跑一次检测工具，让结果匹配该主机。
3. **不是所有架构都用它**：`CPU_FLAGS_X86` 顾名思义只适用于 x86（amd64/x86）。
   - 如果你装的是 **ARM64（arm64）/ ARM（arm）/ RISC-V** 等架构：通常**不要设置** `CPU_FLAGS_X86`。
   - 请改为查阅 Gentoo Wiki 的 [CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn) 页面，按你的架构使用对应的 `CPU_FLAGS_…` 变量与检测方式（不同架构用的变量名与工具可能不同，用 x86 的 `cpuid2cpuflags` 不一定适用）。

#### 说明：我改了之后，哪些软件包会受影响？

一般来说，这类变更会影响到需要基于 CPU 指令集做条件编译的软件包；要让改动生效，通常需要重新编译受影响的软件包（或跑一次 world 更新让 Portage 自行判断）。具体策略与细节会依你当前的 USE/FEATURES 与软件包版本而异。

</details>

---

### 13.14 延伸阅读

- [Gentoo Wiki: make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)
- [Gentoo Wiki: ACCEPT_LICENSE](https://wiki.gentoo.org/wiki/ACCEPT_LICENSE)
- [Gentoo Wiki: USE flag](https://wiki.gentoo.org/wiki/USE_flag)
- [桌面配置篇 12.1 节：VIDEO_CARDS 配置](/posts/2025-11-25-gentoo-install-desktop/#121-全局配置)
- [GLEP 23: License Groups](https://www.gentoo.org/glep/glep-0023.html)

---

## 13.15 日常维护：如何成为合格的系统管理员

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Upgrading Gentoo](https://wiki.gentoo.org/wiki/Upgrading_Gentoo/zh-cn) · [Gentoo Cheat Sheet](https://wiki.gentoo.org/wiki/Gentoo_Cheat_Sheet)

</div>

Gentoo 是滚动发行版，维护系统是使用体验的重要组成部分。

**1. 保持系统更新**
建议每一到两周更新一次系统，避免积压过多更新导致依赖冲突。
```bash
emerge --sync              # 同步软件仓库
emerge -avuDN @world       # 更新所有软件
```

**2. 关注官方新闻 (重要)**
在更新前或遇到问题时，务必检查是否有官方新闻推送。
```bash
eselect news list          # 列出新闻
eselect news read          # 阅读新闻
```

**3. 处理配置文档更新**
软件更新后，配置文档可能也会更新。**不要忽略** `etc-update` 或 `dispatch-conf` 的提示。
```bash
dispatch-conf              # 交互式合并配置文档 (推荐)
# 或
etc-update
```

**4. 清理无用依赖**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Remove orphaned packages](https://wiki.gentoo.org/wiki/Knowledge_Base:Remove_orphaned_packages)

</div>

```bash
emerge --ask --depclean    # 移除不再需要的孤立依赖
```

**5. 定期清理源码包**
```bash
emerge --ask app-portage/gentoolkit # 安装工具包
eclean-dist                         # 清理已下载的旧源码包
```

**6. 自动处理 USE 变更**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Autounmask-write](https://wiki.gentoo.org/wiki/Knowledge_Base:Autounmask-write) · [Dispatch-conf](https://wiki.gentoo.org/wiki/Dispatch-conf)

</div>

当安装或更新软件提示 "The following USE changes are necessary" 时：
1.  **让 Portage 自动写入配置**：`emerge --ask --autounmask-write <包名>`
2.  **确认并更新配置**：`dispatch-conf` (按 u 确认，q 退出)
3.  **再次尝试操作**：`emerge --ask <包名>`

**7. 处理软件冲突 (Blocked Packages)**
如果遇到 "Error: The above package list contains packages which cannot be installed at the same time..."：
- **解决方法**：根据提示，手动卸载冲突软件 (`emerge --deselect <包名>` 后 `emerge --depclean`)。

**8. 安全检查 (GLSA)**
Gentoo 发布安全公告 (GLSA) 来通知用户潜在的安全漏洞。
```bash
glsa-check -l      # 列出所有未修复的安全公告
glsa-check -t all  # 测试所有受影响的软件包
```

**9. 系统日志与服务状态**
定期检查系统日志和服务状态，确保系统健康运行。
- **OpenRC**:
    ```bash
    rc-status      # 查看服务状态
    tail -f /var/log/messages # 查看系统日志 (需安装 syslog-ng 等)
    ```
- **Systemd (Journalctl 常用指令)**:
    | 指令 | 作用 |
    | ---- | ---- |
    | `systemctl --failed` | 查看启动失败的服务 |
    | `journalctl -b` | 查看本次启动的日志 |
    | `journalctl -b -1` | 查看上一次启动的日志 |
    | `journalctl -f` | 即时跟随最新日志 (类似 tail -f) |
    | `journalctl -p err` | 仅显示错误 (Error) 级别的日志 |
    | `journalctl -u <服务名>` | 查看特定服务的日志 |
    | `journalctl --since "1 hour ago"` | 查看最近 1 小时的日志 |
    | `journalctl --disk-usage` | 查看日志占用的磁盘空间 |
    | `journalctl --vacuum-time=2weeks` | 清理 2 周前的日志 |

### 13.2 Portage 技巧与目录结构

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Portage](https://wiki.gentoo.org/wiki/Portage/zh-cn) · [/etc/portage](https://wiki.gentoo.org/wiki//etc/portage)

</div>

**1. 内核目录结构 (`/etc/portage/`)**
Gentoo 的配置非常灵活，建议使用**目录**而不是单个文档来管理配置：

| 文档/目录 | 用途 |
| --------- | ---- |
| `make.conf` | 全局编译参数 (CFLAGS, MAKEOPTS, USE, GENTOO_MIRRORS) |
| `package.use/` | 针对特定软件的 USE 标志配置 |
| `package.accept_keywords/` | 允许安装测试版 (keyword) 软件 |
| `package.mask/` | 屏蔽特定版本的软件 |
| `package.unmask/` | 解除屏蔽特定版本的软件 |
| `package.license/` | 接受特定软件的许可证 |
| `package.env/` | 针对特定软件的环境变量 (如使用不同的编译器参数) |

**2. 常用 Emerge 指令速查**
> 完整手册请运行 `man emerge`

| 参数 (缩写) | 作用 | 示例 |
| ----------- | ---- | ---- |
| `--ask` (`-a`) | 运行前询问确认 | `emerge -a vim` |
| `--verbose` (`-v`) | 显示详细信息 (USE 标志等) | `emerge -av vim` |
| `--oneshot` (`-1`) | 安装但不加入 World 文档 (不作为系统依赖) | `emerge -1 rust` |
| `--update` (`-u`) | 更新软件包 | `emerge -u vim` |
| `--deep` (`-D`) | 深度计算依赖 (更新依赖的依赖) | `emerge -uD @world` |
| `--newuse` (`-N`) | USE 标志改变时重新编译 | `emerge -uDN @world` |
| `--depclean` (`-c`) | 清理不再需要的孤立依赖 | `emerge -c` |
| `--deselect` | 从 World 文档中移除 (不卸载) | `emerge --deselect vim` |
| `--search` (`-s`) | 搜索软件包 (推荐用 eix) | `emerge -s vim` |
| `--info` | 显示 Portage 环境信息 (调试用) | `emerge --info` |

**3. 快速搜索软件包 (Eix)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Eix](https://wiki.gentoo.org/wiki/Eix)

</div>
> `emerge --search` 速度较慢，推荐使用 `eix` 进行毫秒级搜索。

1.  **安装与更新索引**：
    ```bash
    emerge --ask app-portage/eix
    eix-update # 安装后或同步后运行
    ```
2.  **搜索软件**：
    ```bash
    eix <关键词>        # 搜索所有软件
    eix -I <关键词>     # 仅搜索已安装软件
    eix -R <关键词>     # 搜索远程 Overlay (需配置 eix-remote)
    ```

---

## 14. 高端编译优化 [可选]

为了提升后续的编译速度，建议配置 tmpfs 和 ccache。

### 14.1 配置 tmpfs (内存编译)

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Tmpfs](https://wiki.gentoo.org/wiki/Tmpfs)

</div>

将编译临时目录挂载到内存，减少 SSD 磨损并加速编译。

<details>
<summary><b>Tmpfs 配置指南（点击展开）</b></summary>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

`size` 大小不要超过你的物理内存大小（建议设为内存的一半），否则可能导致系统不稳定。

</div>

编辑 `/etc/fstab`，添加以下行（size 建议设置为内存的一半，例如 16G）：
```fstab
tmpfs   /var/tmp/portage   tmpfs   size=16G,uid=portage,gid=portage,mode=775,noatime   0 0
```
挂载目录：
```bash
mount /var/tmp/portage
```
</details>

### 14.2 配置 ccache (编译缓存)

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Ccache](https://wiki.gentoo.org/wiki/Ccache)

</div>

缓存编译中间产物，加快重新编译速度。
```bash
emerge --ask dev-build/ccache
ccache -M 20G  # 设置缓存大小为 20GB
```

### 14.3 处理大型软件编译 (避免 tmpfs 爆满)

Firefox、LibreOffice 等大型软件编译时可能会耗尽 tmpfs 空间。我们可以配置 Portage 让这些特定软件使用硬盘进行编译。

<details>
<summary><b>Notmpfs 配置指南（点击展开）</b></summary>

1. 创建配置目录：
   ```bash
   mkdir -p /etc/portage/env
   mkdir -p /var/tmp/notmpfs
   ```

2. 创建 `notmpfs.conf`：
   ```bash
   echo 'PORTAGE_TMPDIR="/var/tmp/notmpfs"' > /etc/portage/env/notmpfs.conf
   ```

3. 针对特定软件应用配置：
   编辑 `/etc/portage/package.env` (如果是目录则创建文档)：
   ```bash
   vim /etc/portage/package.env
   ```
   写入：
   ```conf
   www-client/chromium notmpfs.conf
   app-office/libreoffice notmpfs.conf
   dev-qt/qtwebengine notmpfs.conf
   ```

</details>

### 14.4 LTO 与 Clang 优化

详细配置请参考 **Section 15 高端编译优化**。

---

## 15. LTO 与 Clang 编译优化 (可选)

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**风险提示**

LTO 会显著增加编译时间和内存消耗，且可能导致部分软件编译失败。**强烈不建议全局打开**，仅推荐针对特定软件（如浏览器）打开。

</div>

### 15.1 链接时优化 (LTO)
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[LTO](https://wiki.gentoo.org/wiki/LTO)

</div>

LTO (Link Time Optimization) 将优化推迟到链接阶段，可带来性能提升和体积减小。

<details style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1rem; border-radius: 0.75rem; margin: 1rem 0; border: 1px solid rgba(59, 130, 246, 0.2);">
<summary style="cursor: pointer; font-weight: bold; color: #1d4ed8;">LTO 优缺点详细分析（点击展开）</summary>

<div style="margin-top: 1rem;">

**优势**：
*   性能提升（通常两位数）
*   二进制体积减小
*   启动时间改善

**劣势**：
*   编译时间增加 2-3 倍
*   内存消耗巨大
*   稳定性风险
*   故障排查困难

</div>

</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

如果你的系统是 4 核 CPU 配 4GB 内存，那么花在编译上的时间可能远超优化带来的性能提升。请根据硬件配置权衡利弊。

</div>

**1. 使用 USE 标志打开 (最推荐)**

对于 Firefox 和 Chromium 等大型软件，官方 ebuild 通常提供了经过测试的 `lto` 和 `pgo` USE 标志：

在 `/etc/portage/package.use/browser` 中激活：
```text
www-client/firefox lto pgo
www-client/chromium lto pgo  # 注意：PGO 在 Wayland 环境下可能无法使用
```

**USE="lto" 标志说明**：部分软件包需要特殊修复才能支持 LTO，可以全局或针对特定软件包激活 `lto` USE 标志：
```bash
# 在 /etc/portage/make.conf 中全局激活
USE="lto"
```

**2. 针对特定软件包激活 LTO (推荐)**

创建 `/etc/portage/env/lto.conf`：
```bash
CFLAGS="${CFLAGS} -flto"
CXXFLAGS="${CXXFLAGS} -flto"
```

在 `/etc/portage/package.env` 中应用：
```text
www-client/firefox lto.conf
app-editors/vim lto.conf
```

**3. 全局激活 LTO (GCC 系统)**

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

全局 LTO 会导致大量软件包编译失败，需要频繁维护排除列表，**不建议新手尝试**。

</div>

编辑 `/etc/portage/make.conf`：
```bash
# 这些警告指示 LTO 可能导致的运行时问题，将其提升为错误
# -Werror=odr: One Definition Rule 违规（多次定义同一符号）
# -Werror=lto-type-mismatch: LTO 类型不匹配
# -Werror=strict-aliasing: 严格别名违规
WARNING_FLAGS="-Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing"

# -O2: 优化级别 2（推荐）
# -pipe: 使用管道加速编译
# -march=native: 针对当前 CPU 优化
# -flto: 激活链接时优化（Full LTO）
# 注意：GCC 的 -flto 默认使用 Full LTO，适合 GCC 系统
COMMON_FLAGS="-O2 -pipe -march=native -flto ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 编译器标志
CXXFLAGS="${COMMON_FLAGS}"        # C++ 编译器标志
FCFLAGS="${COMMON_FLAGS}"         # Fortran 编译器标志
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 编译器标志
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 链接器标志

USE="lto"  # 激活 LTO 支持的 USE 标志
```

**4. 全局激活 LTO (LLVM/Clang 系统 - 推荐使用 ThinLTO)**

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**默认推荐**

如果使用 Clang，强烈推荐使用 ThinLTO (`-flto=thin`) 而非 Full LTO (`-flto`)。ThinLTO 速度更快，内存占用更少，支持并行化。

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

如果 `clang-common` 未激活 `default-lld` USE 标志，必须在 `LDFLAGS` 中添加 `-fuse-ld=lld`。

</div>

编辑 `/etc/portage/make.conf`：
```bash
# Clang 目前尚未完全实现这些诊断，但保留这些标志以备将来使用
# -Werror=odr: One Definition Rule 违规检测（Clang 部分支持）
# -Werror=strict-aliasing: 严格别名违规检测（Clang 正在开发）
WARNING_FLAGS="-Werror=odr -Werror=strict-aliasing"

# -O2: 优化级别 2（平衡性能与稳定性）
# -pipe: 使用管道加速编译
# -march=native: 针对当前 CPU 优化
# -flto=thin: 激活 ThinLTO（推荐，速度快且并行化）
COMMON_FLAGS="-O2 -pipe -march=native -flto=thin ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 编译器标志
CXXFLAGS="${COMMON_FLAGS}"        # C++ 编译器标志
FCFLAGS="${COMMON_FLAGS}"         # Fortran 编译器标志
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 编译器标志
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 链接器标志

USE="lto"  # 激活 LTO 支持的 USE 标志
```

**ThinLTO vs Full LTO（推荐新手阅读）**：

| 类型 | 标志 | 优势 | 劣势 | 推荐场景 |
|------|------|------|------|----------|
| **ThinLTO** | `-flto=thin` | • 速度快<br>• 内存占用少<br>• 支持并行化<br>• 编译速度提升 2-3 倍 | • 仅 Clang/LLVM 支持 | **默认推荐**（Clang 用户） |
| Full LTO | `-flto` | • 更深度的优化<br>• GCC 和 Clang 均支持 | • 速度慢<br>• 内存占用高<br>• 串行处理 | GCC 用户或需要极致优化时 |

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

如果你使用 Clang，请务必使用 `-flto=thin`。这是目前的最佳实践，能在保证性能的同时大幅减少编译时间。

</div>

**5. Rust LTO 配置**

**在 LLVM 系统上**：
```bash
# 在 /etc/portage/make.conf 中添加
RUSTFLAGS="${RUSTFLAGS} -Clinker-plugin-lto"
```

**在 GCC 系统上**（需要使用 Clang 编译 Rust 代码）：
创建 `/etc/portage/env/llvm-lto.conf`：
```bash
WARNING_FLAGS="-Werror=odr -Werror=strict-aliasing"
COMMON_FLAGS="-march=native -O2 -flto=thin -pipe ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

RUSTFLAGS="-C target-cpu=native -C strip=debuginfo -C opt-level=3 \
-Clinker=clang -Clinker-plugin-lto -Clink-arg=-fuse-ld=lld"

LDFLAGS="${COMMON_FLAGS} ${LDFLAGS} -fuse-ld=lld"
CC="clang"
CXX="clang++"
CPP="clang-cpp"
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"

USE="lto"
```

在 `/etc/portage/package.env` 中为 Rust 软件包指定：
```text
dev-lang/rust llvm-lto.conf
```

### 15.3 高端软件包环境配置 (package.env)

针对特定软件包的特殊配置（如禁用 LTO 或低内存模式），可以使用 `package.env` 进行精细控制。

<details>
<summary><b>配置 1：禁用 LTO 的软件包列表 (no-lto) - 点击展开</b></summary>

某些软件包已知与 LTO 不兼容。建议创建 `/etc/portage/env/nolto.conf`：

```bash
# 禁用 LTO 及相关警告
DISABLE_LTO="-Wno-error=odr -Wno-error=lto-type-mismatch -Wno-error=strict-aliasing -fno-lto"
CFLAGS="${CFLAGS} ${DISABLE_LTO}"
CXXFLAGS="${CXXFLAGS} ${DISABLE_LTO}"
FCFLAGS="${FCFLAGS} ${DISABLE_LTO}"
FFLAGS="${FFLAGS} ${DISABLE_LTO}"
LDFLAGS="${LDFLAGS} ${DISABLE_LTO}"
```

创建 `/etc/portage/package.env/no-lto` 文档（包含已知问题包）：

```bash
# 已知与 LTO 有兼容性问题的套件
# 仍使用 Clang 编译，但禁用 LTO

app-misc/jq no-lto.conf
app-shells/zsh no-lto.conf
dev-build/ninja no-lto.conf
dev-cpp/abseil-cpp no-lto.conf
dev-lang/perl no-lto.conf
dev-lang/spidermonkey no-lto.conf
dev-lang/tcl no-lto.conf
dev-libs/jemalloc no-lto.conf
dev-libs/libportal no-lto.conf
dev-python/jq no-lto.conf
dev-qt/qtbase no-lto.conf
dev-qt/qtdeclarative no-lto.conf
dev-tcltk/expect no-lto.conf
dev-util/dejagnu no-lto.conf
gnome-base/gnome-shell no-lto.conf
gui-libs/libadwaita no-lto.conf
llvm-core/clang no-lto.conf
llvm-core/llvm no-lto.conf
media-libs/clutter no-lto.conf
media-libs/libsdl2 no-lto.conf
media-libs/libsdl3 no-lto.conf
media-libs/libsdl no-lto.conf
media-libs/webrtc-audio-processing no-lto.conf
media-video/ffmpeg no-lto.conf
media-video/pipewire no-lto.conf
net-libs/libnma no-lto.conf
net-print/cups no-lto.conf
sys-devel/clang no-lto.conf
sys-devel/llvm no-lto.conf
x11-drivers/nvidia-drivers no-lto.conf
x11-libs/cairo no-lto.conf
dev-python/pillow no-lto.conf
media-libs/gexiv2 no-lto.conf
x11-wm/mutter no-lto.conf
```
</details>

<details>
<summary><b>配置 2：低内存编译模式 (low-memory) - 点击展开</b></summary>

对于大型项目（如 Chromium, Rust），建议使用低内存配置以防止 OOM。

创建 `/etc/portage/env/low-memory.conf`：
```bash
# 减少并行任务数，例如改为 -j2 或 -j4
MAKEOPTS="-j4"
# 可选：移除一些耗内存的优化标志
COMMON_FLAGS="-O2 -pipe"
```

创建 `/etc/portage/package.env/low-memory`：
```bash
# 容易导致系统卡死的大型套件
# 使用低内存编译设置

# 浏览器类 (极大型项目)
www-client/chromium low-memory.conf
mail-client/thunderbird low-memory.conf

# 办公套件
app-office/libreoffice low-memory.conf

# 虚拟化
app-emulation/qemu low-memory.conf

# Rust 大型项目
dev-lang/rust low-memory.conf
virtual/rust low-memory.conf
```
</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

如果遇到其他 LTO 相关的链接错误，请先尝试禁用该包的 LTO。也可以查看 [Gentoo Bugzilla](https://bugs.gentoo.org) 搜索是否已有相关报告（搜索"软件包名 lto"）。如果是新问题，欢迎提交 bug 报告帮助改进 Gentoo。

</div>

### 15.2 使用 Clang 编译
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Clang](https://wiki.gentoo.org/wiki/Clang)

</div>

**前提条件**：安装 Clang 和 LLD
```bash
emerge --ask llvm-core/clang llvm-core/lld
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**重要提示**

- 部分软件包（如 `sys-libs/glibc`, `app-emulation/wine`）无法使用 Clang 编译，仍需 GCC。
- Gentoo 维护了 [bug #408963](https://bugs.gentoo.org/408963) 来跟踪 Clang 编译失败的软件包。

</div>

**1. 针对特定软件打开 (推荐)**

创建环境配置文档 `/etc/portage/env/clang.conf`：
```bash
CC="clang"
CXX="clang++"
CPP="clang-cpp"  # 某些软件包（如 xorg-server）需要
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```

应用到特定软件（例如 `app-editors/neovim`），在 `/etc/portage/package.env` 中添加：
```text
app-editors/neovim clang.conf
```



**3. PGO 支持（配置文档引导优化）**

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果需要 PGO 支持（如 `dev-lang/python[pgo]`），需要安装以下包：

</div>

```bash
emerge --ask llvm-core/clang-runtime
emerge --ask llvm-runtimes/compiler-rt-sanitizers
```

在 `/etc/portage/package.use` 中激活相关 USE 标志：
```text
llvm-core/clang-runtime sanitize
llvm-runtimes/compiler-rt-sanitizers profile orc
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

- 如果没有激活 `profile` 和 `orc` USE 标志，带有 `pgo` USE 标志的软件包（如 `dev-lang/python[pgo]`）会编译失败。
- 编译日志可能会报错：`ld.lld: error: cannot open /usr/lib/llvm/18/bin/../../../../lib/clang/18/lib/linux/libclang_rt.profile-x86_64.a`

</div>

**4. 全局打开 (不建议初学者)**

全局切换到 Clang 需要系统大部分软件支持，且需要处理大量兼容性问题，**仅建议高级用户尝试**。

如需全局激活，在 `/etc/portage/make.conf` 中添加：
```bash
CC="clang"
CXX="clang++"
CPP="clang-cpp"
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```

**GCC 回退环境**

对于无法使用 Clang 编译的软件包，创建 `/etc/portage/env/gcc.conf`：
```bash
CC="gcc"
CXX="g++"
CPP="gcc -E"
AR="ar"
NM="nm"
RANLIB="ranlib"
```

在 `/etc/portage/package.env` 中为特定软件指定使用 GCC：
```text
sys-libs/glibc gcc.conf
app-emulation/wine gcc.conf
```



---

## 16. 内核编译高端指南 (可选) {#section-16-kernel-advanced}

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1rem; border-radius: 0.5rem; border-left: 4px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Kernel](https://wiki.gentoo.org/wiki/Kernel)、[Kernel/Configuration](https://wiki.gentoo.org/wiki/Kernel/Configuration)、[Genkernel](https://wiki.gentoo.org/wiki/Genkernel)

</div>

本节面向希望深入掌控内核编译的高级用户，包括使用 LLVM/Clang 编译、激活 LTO 优化、自动化配置等。

### 16.1 准备工作

安装必要工具：
```bash
# 安装内核源码和构建工具
emerge --ask sys-kernel/gentoo-sources

# （可选）安装 Genkernel 用于自动化
emerge --ask sys-kernel/genkernel

# （可选）使用 LLVM/Clang 编译需要
emerge --ask llvm-core/llvm \
    llvm-core/clang llvm-core/lld
```

### 16.2 查看系统信息（硬件检测）

在配置内核前，了解你的硬件非常重要：

**查看 CPU 信息**：
```bash
lscpu  # 查看 CPU 型号、内核数、架构等
cat /proc/cpuinfo | grep "model name" | head -1  # CPU 型号
```

**查看 PCI 设备（显卡、网卡等）**：
```bash
lspci -k  # 列出所有 PCI 设备及当前使用的驱动
lspci | grep -i vga  # 查看显卡
lspci | grep -i network  # 查看网卡
```

**查看 USB 设备**：
```bash
lsusb  # 列出所有 USB 设备
```

**查看已加载的内核模块**：
```bash
lsmod  # 列出当前加载的所有模块
lsmod | wc -l  # 模块数量
```

### 16.3 根据当前模块自动配置内核

如果你想保留当前系统（如 LiveCD）所有正常工作的硬件支持：

```bash
cd /usr/src/linux

# 方法 1：基于当前加载的模块创建最小化配置
make localmodconfig
# 这会只激活当前加载模块对应的内核选项（强烈推荐！）

# 方法 2：基于当前运行内核的配置创建
zcat /proc/config.gz > .config  # 如果当前内核支持
make olddefconfig  # 使用默认值更新配置
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

`localmodconfig` 是最安全的方法，它会确保你的硬件都能正常工作，同时移除不需要的驱动。

</div>

### 16.4 手动配置内核选项

**进入配置界面**：
```bash
cd /usr/src/linux
make menuconfig  # 文本界面（推荐）
```

```text
  ┌────────────── Linux/x86 6.17.9-gentoo Kernel Configuration ──────────────┐
  │  Arrow keys navigate the menu.  <Enter> selects submenus ---> (or empty  │  
  │  submenus ----).  Highlighted letters are hotkeys.  Pressing <Y>         │  
  │  includes, <N> excludes, <M> modularizes features.  Press <Esc><Esc> to  │  
  │  exit, <?> for Help, </> for Search.  Legend: [*] built-in  [ ] excluded │  
  │ ┌──────────────────────────────────────────────────────────────────────┐ │  
  │ │        General setup  --->                                           │ │  
  │ │    [*] 64-bit kernel                                                 │ │  
  │ │        Processor type and features  --->                             │ │  
  │ │    [ ] Mitigations for CPU vulnerabilities  ----                     │ │  
  │ │        Power management and ACPI options  --->                       │ │  
  │ │        Bus options (PCI etc.)  --->                                  │ │  
  │ │        Binary Emulations  --->                                       │ │  
  │ │    [*] Virtualization  --->                                          │ │  
  │ │        General architecture-dependent options  --->                  │ │  
  │ │    [*] Enable loadable module support  --->                          │ │  
  │ │    -*- Enable the block layer  --->                                  │ │  
  │ │        Executable file formats  --->                                 │ │  
  │ │        Memory Management options  --->                               │ │  
  │ │    -*- Networking support  --->                                      │ │  
  │ │        Device Drivers  --->                                          │ │  
  │ │        File systems  --->                                            │ │  
  │ │        Security options  --->                                        │ │  
  │ │    -*- Cryptographic API  --->                                       │ │  
  │ │        Library routines  --->                                        │ │  
  │ │        Kernel hacking  --->                                          │ │  
  │ │        Gentoo Linux  --->                                            │ │  
  │ │                                                                      │ │  
  │ │                                                                      │ │  
  │ └──────────────────────────────────────────────────────────────────────┘ │  
  ├──────────────────────────────────────────────────────────────────────────┤  
  │         <Select>    < Exit >    < Help >    < Save >    < Load >         │  
  └──────────────────────────────────────────────────────────────────────────┘  
```

**常用选项对照表**：

| 英文选项 | 中文说明 | 关键配置 |
| :--- | :--- | :--- |
| **General setup** | 通用设置 | 本机主机名、Systemd/OpenRC 支持 |
| **Processor type and features** | 处理器类型与特性 | CPU 型号选择、微码加载 |
| **Power management and ACPI options** | 电源管理与 ACPI | 笔记本电源管理、挂起/休眠 |
| **Bus options (PCI etc.)** | 总线选项 | PCI 支持 (lspci) |
| **Virtualization** | 虚拟化 | KVM, VirtualBox 宿主/客户机支持 |
| **Enable loadable module support** | 可加载模块支持 | 允许使用内核模块 (*.ko) |
| **Networking support** | 网络支持 | TCP/IP 协议栈、防火墙 (Netfilter) |
| **Device Drivers** | 设备驱动 | 显卡、网卡、声卡、USB、NVMe 驱动 |
| **File systems** | 文档系统 | ext4, btrfs, vfat, ntfs 支持 |
| **Security options** | 安全选项 | SELinux, AppArmor |
| **Gentoo Linux** | Gentoo 特有选项 | Portage 依赖项自动选择 (推荐) |

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**重要建议**

对于手动编译，建议将**关键驱动**（如文档系统、磁盘控制器、网卡）直接编译进内核（选择 `[*]` 或 `<*>` 即 `=y`），而不是作为模块（`<M>` 即 `=m`）。这样可以避免 initramfs 缺失模块导致无法启动的问题。

</div>

**必需激活的选项**（根据你的系统）：

1. **处理器支持**：
   - `General setup → Gentoo Linux support`
   - `Processor type and features → Processor family` (选择你的 CPU)

2. **文档系统**：
   - `File systems → The Extended 4 (ext4) filesystem` (如果使用 ext4)
   - `File systems → Btrfs filesystem` (如果使用 Btrfs)

3. **设备驱动**：
   - `Device Drivers → Network device support` (网卡驱动)
   - `Device Drivers → Graphics support` (显卡驱动)

4. **Systemd 用户必需**：
   - `General setup → Control Group support`
   - `General setup → Namespaces support`

5. **Gentoo Linux 专有选项**（推荐全部激活）：
   
   进入 `Gentoo Linux --->` 菜单：
   
   ```
   [*] Gentoo Linux support
       激活 Gentoo 特定的内核功能支持
   
   [*] Linux dynamic and persistent device naming (userspace devfs) support
       激活 udev 动态设备管理支持（必需）
   
   [*] Select options required by Portage features
       自动激活 Portage 需要的内核选项（强烈推荐）
       这会自动配置必需的文档系统和内核功能
   
   Support for init systems, system and service managers --->
       ├─ [*] OpenRC support  # 如果使用 OpenRC
       └─ [*] systemd support # 如果使用 systemd
   
   [*] Kernel Self Protection Project
       激活内核自我保护机制（提高安全性）
   
   [*] Print firmware information that the kernel attempts to load
       在启动时显示固件加载信息（便于调试）
   ```

 <div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

激活 "Select options required by Portage features" 可以自动配置大部分必需选项，非常推荐！

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

在 menuconfig 中，按 `/` 可以搜索选项，按 `?` 查看帮助。

</div>

### 16.5 自动激活推荐选项

Gentoo 提供了自动化脚本来激活常见硬件和功能：

```bash
cd /usr/src/linux

# 使用 Genkernel 的默认配置（包含大多数硬件支持）
genkernel --kernel-config=/usr/share/genkernel/arch/x86_64/kernel-config all

# 或者使用发行版默认配置作为基础
make defconfig  # 内核默认配置
# 然后再根据需要调整
make menuconfig
```

### 16.6 使用 LLVM/Clang 编译内核

使用 LLVM/Clang 编译内核可以获得更好的优化和更快的编译速度（支持 ThinLTO）。

**方法 1：指定编译器**（一次性）：
```bash
cd /usr/src/linux

# 使用 Clang 编译
make LLVM=1 -j$(nproc)

# 使用 Clang + LTO（推荐）
make LLVM=1 LLVM_IAS=1 -j$(nproc)
```

**方法 2：设置环境变量**（永久）：
在 `/etc/portage/make.conf` 中添加（仅影响内核编译）：
```bash
# 使用 LLVM/Clang 编译内核
KERNEL_CC="clang"
KERNEL_LD="ld.lld"
```

**激活内核 LTO 支持**：
在 `make menuconfig` 中：
```
General setup
  → Compiler optimization level → Optimize for performance  # 选择 -O2（推荐）
  → Link Time Optimization (LTO) → Clang ThinLTO (NEW)      # 激活 ThinLTO（强烈推荐）
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要警告：内核编译时强烈不建议使用 Full LTO！**

*   Full LTO 会导致编译极其缓慢（可能需要数小时）
*   占用大量内存（可能需要 16GB+ RAM）
*   容易导致链接错误
*   **请务必使用 ThinLTO**，它更快、更稳定、内存占用更少

</div>

### 16.7 内核编译选项优化

<details>
<summary><b>高级编译优化（点击展开）</b></summary>

**在 `menuconfig` 中激活**：

```
General setup
  → Compiler optimization level
     → [*] Optimize for performance (-O2)  # 或 -O3，但可能不稳定

  → Link Time Optimization (LTO)
     → [*] Clang ThinLTO                   # 需要 LLVM=1

Kernel hacking
  → Compile-time checks and compiler options
     → [*] Optimize harder
```

**内核压缩方式**（影响启动速度和体积）：

```
General setup
  → Kernel compression mode
     → [*] ZSTD  # 推荐：压缩率高且解压快
     # 其他选项：LZ4（最快）、XZ（最小）、GZIP（兼容性最好）
```

</details>

### 16.8 编译和安装内核

**手动编译**：
```bash
cd /usr/src/linux

# 编译内核和模块
make -j$(nproc)         # 使用所有 CPU 内核
make modules_install    # 安装模块到 /lib/modules/
make install            # 安装内核到 /boot/

# （可选）使用 LLVM/Clang + LTO
make LLVM=1 -j$(nproc)
make LLVM=1 modules_install
make LLVM=1 install
```

**使用 Genkernel 自动化**：
```bash
# 基本用法
genkernel --install all

# 使用 LLVM/Clang
genkernel --kernel-cc=clang --utils-cc=clang --install all

# 激活 LTO（需要手动配置 .config）
genkernel --kernel-make-opts="LLVM=1" --install all
```

### 16.9 内核统计与分析

编译完成后，使用以下脚本查看内核统计信息：

```bash
cd /usr/src/linux

echo "=== 内核统计 ==="
echo "Built-in: $(grep -c '=y$' .config)"
echo "模块: $(grep -c '=m$' .config)"
echo "总配置: $(wc -l < .config)"
echo "内核大小: $(ls -lh arch/x86/boot/bzImage 2>/dev/null | awk '{print $5}')"
echo "压缩方式: $(grep '^CONFIG_KERNEL_' .config | grep '=y' | sed 's/CONFIG_KERNEL_//;s/=y//')"
```

**示例输出**：
```
=== 内核统计 ===
Built-in: 1723
模块: 201
总配置: 6687
内核大小: 11M
压缩方式: ZSTD
```

**解读**：
- **Built-in (1723)**：编译进内核本体的功能数量
- **模块 (201)**：作为可加载模块的驱动数量
- **内核大小 (11M)**：最终内核文档大小（使用 ZSTD 压缩后）

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**优化建议**

*   内核大小 < 15MB：优秀（精简配置）
*   内核大小 15-30MB：良好（标准配置）
*   内核大小 > 30MB：考虑禁用不需要的功能

</div>

### 16.10 常见问题排查

<details>
<summary><b>编译错误与解决方案（点击展开）</b></summary>

**错误 1：缺少依赖**
```
*** No rule to make target 'debian/canonical-certs.pem'
```
解决：禁用签名证书
```bash
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
make olddefconfig
```

**错误 2：LTO 编译失败**
```
ld.lld: error: undefined symbol
```
解决：某些模块不兼容 LTO，禁用 LTO 或将问题模块设为 `=y`（而非 `=m`）

**错误 3：clang 版本过旧**
```
error: unknown argument: '-mretpoline-external-thunk'
```
解决：升级 LLVM/Clang 或使用 GCC 编译

</details>

### 16.11 内核配置最佳实践

1. **保存配置**：
   ```bash
   # 保存当前配置到外部文档
   cp .config ~/kernel-config-backup
   
   # 恢复配置
   cp ~/kernel-config-backup /usr/src/linux/.config
   make olddefconfig
   ```

2. **查看配置差异**：
   ```bash
   # 对比两个配置文档
   scripts/diffconfig .config ../old-kernel/.config
   ```

3. **最小化配置**（仅包含必需功能）：
   ```bash
   make tinyconfig  # 创建极简配置
   make localmodconfig  # 然后添加当前硬件支持
   ```

---

## 17. 服务器与 RAID 配置 (可选) {#section-17-server-raid}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Wiki: Mdadm](https://wiki.gentoo.org/wiki/Mdadm)

</div>

本节适用于需要配置软 RAID (mdadm) 的服务器用户。

### 17.1 内核配置 (手动编译必选)

如果你手动编译内核，必须激活以下选项（**注意：必须编译进内核 `<*>` 即 `=y`，不能是模块 `<M>`**）：

```
Device Drivers  --->
    <*> Multiple devices driver support (RAID and LVM)
        <*> RAID support
            [*] Autodetect RAID arrays during kernel boot

            # 根据你的 RAID 级别选择（必须选 Y）：
            <*> Linear (append) mode                   # 线性模式
            <*> RAID-0 (striping) mode                 # RAID 0
            <*> RAID-1 (mirroring) mode                # RAID 1
            <*> RAID-10 (mirrored striping) mode       # RAID 10
            <*> RAID-4/RAID-5/RAID-6 mode              # RAID 5/6
```

### 17.2 配置 Dracut 加载 RAID 模块 (dist-kernel 必选)

如果你使用 `dist-kernel`（发行版内核）或者将 RAID 驱动编译为了模块，**必须**通过 Dracut 强制加载 RAID 驱动，否则无法开机。

<details>
<summary><b>Dracut RAID 配置指南（点击展开）</b></summary>

**1. 激活 mdraid 支持**
创建 `/etc/dracut.conf.d/mdraid.conf`：
```bash
# Enable mdraid support for RAID arrays
add_dracutmodules+=" mdraid "
mdadmconf="yes"
```

**2. 强制加载 RAID 驱动**
创建 `/etc/dracut.conf.d/raid-modules.conf`：
```bash
# Ensure RAID modules are included and loaded
add_drivers+=" raid1 raid0 raid10 raid456 "
force_drivers+=" raid1 "
# Install modprobe configuration
install_items+=" /usr/lib/modules-load.d/ /etc/modules-load.d/ "
```

**3. 配置内核命令行参数 (UUID)**
你需要找到 RAID 数组的 UUID 并添加到内核参数中。
创建 `/etc/dracut.conf.d/mdraid-cmdline.conf`：
```bash
# Kernel command line parameters for RAID arrays
# 请替换为你实际的 RAID UUID (通过 mdadm --detail --scan 查看)
kernel_cmdline="rd.md.uuid=68b53b0a:c6bd2ca0:caed4380:1cd75aeb rd.md.uuid=c8f92d69:59d61271:e8ffa815:063390ed"
```

**4. 重新生成 initramfs**
```bash
dracut --force
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

配置完成后，务必检查 `/boot/initramfs-*.img` 是否包含 RAID 模块：

</div>
> `lsinitrd /boot/initramfs-*.img | grep raid`

</details>

---

## 18. Secure Boot 配置 (可选) {#section-18-secure-boot}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可参考**：[Gentoo Handbook: Secure Boot](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Alternative:_Secure_Boot) · [Signed kernel module support](https://wiki.gentoo.org/wiki/Signed_kernel_module_support)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**什么是 Secure Boot？**

Secure Boot（安全启动）是 UEFI 固件的一项安全功能，通过验证启动加载器和内核的数字签名，防止未经授权的代码在启动阶段运行。激活 Secure Boot 后，系统仅会加载经过信任的签名文档。

**为何需要配置？**

Gentoo 默认安装**不支持 Secure Boot**，若你的主板激活了 Secure Boot，系统将无法启动。本节介绍如何配置 Secure Boot。

</div>

### 18.1 使用 sbctl 自动化管理（推荐） {#sbctl}

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**sbctl** 是一个 Secure Boot 管理工具,能自动化处理密钥生成、签名和注册流程,相比手动使用 OpenSSL 配置更为简便。

</div>

**步骤 1：安装 sbctl**

```bash
emerge --ask app-crypt/sbctl
```

**步骤 2：检查当前状态**

```bash
sbctl status
```

预期输出（安装前）：
```
Installed:	✘ Sbctl is not installed
Setup Mode:	✘ Enabled
Secure Boot:	✘ Disabled
```

<details>
<summary><b>如果 Setup Mode 显示为 Disabled（关闭）怎么办？</b></summary>

**Setup Mode** 是 UEFI 固件的一个特殊模式，允许修改 Secure Boot 密钥。如果显示为 `Disabled`，你需要：

**方法 1：清除现有的 Secure Boot 密钥（推荐）**

在 BIOS/UEFI 设置中找到以下选项（不同主板命名可能略有不同）：
- **Clear Secure Boot Keys** / **清除安全启动密钥**
- **Reset to Setup Mode** / **重置为设置模式**
- **Delete All Keys** / **删除所有密钥**

清除后，Setup Mode 会自动切换为 `Enabled`。

> **注意**：必须清除密钥才能进入 Setup Mode！单纯关闭 Secure Boot（设为 Disabled）**不会**启用 Setup Mode，因为密钥仍然存在，固件不允许写入新密钥。

**验证 Setup Mode**

重启后再次检查：
```bash
sbctl status
```

确认 `Setup Mode: ✘ Enabled` 后，再继续下一步。

</details>

**步骤 3：生成密钥（自动完成）**

```bash
sbctl create-keys
```

输出：
```
Created Owner UUID a9fbbdb7-a05f-48d5-b63a-08c5df45ee70
Creating secure boot keys...✔
Secure boot keys created!
```

密钥自动生成到 `/var/lib/sbctl/keys/`，无需手动操作！

**步骤 4：注册密钥到 UEFI 固件**

```bash
sbctl enroll-keys -m
```

- `-m` 参数表示**保留 Microsoft 供应商密钥**（推荐），这样可以启动 Windows 和其他已签名的 EFI 程序

输出：
```
Enrolling keys to EFI variables...
With vendor keys from microsoft...✔
Enrolled keys to the EFI variables!
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1rem 0;">

**警告**

如果你的系统没有集成显卡（iGPU），**不要使用 `-m` 参数**，否则可能导致系统无法启动。这种情况下使用：
```bash
sbctl enroll-keys  # 不加 -m
```

</div>

**步骤 5：配置 Portage 自动签名**

编辑 `/etc/portage/make.conf`，添加 sbctl 的密钥路径：

```bash
# Secure Boot: 使用 sbctl 的密钥自动签名
USE="${USE} secureboot modules-sign"

MODULES_SIGN_KEY="/var/lib/sbctl/keys/db/db.key"
MODULES_SIGN_CERT="/var/lib/sbctl/keys/db/db.pem"
SECUREBOOT_SIGN_KEY="/var/lib/sbctl/keys/db/db.key"
SECUREBOOT_SIGN_CERT="/var/lib/sbctl/keys/db/db.pem"
```

**步骤 6：重新编译内核**

```bash
emerge --ask sys-kernel/gentoo-kernel-bin  # 或你使用的内核包
```

Portage 会自动使用 sbctl 的密钥签名内核和模块！

**步骤 7：签名启动加载器**

根据你使用的启动加载器，运行对应命令：

<details>
<summary><b>使用 GRUB</b></summary>

```bash
sbctl sign -s /efi/EFI/gentoo/grubx64.efi
```

</details>

<details>
<summary><b>使用 systemd-boot</b></summary>

```bash
sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi
```

</details>

<details>
<summary><b>使用 EFI Stub（直接启动）</b></summary>

```bash
sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
```

</details>

<details>
<summary><b>使用 Unified Kernel Image (UKI)</b></summary>

```bash
sbctl sign -s /efi/EFI/Linux/gentoo-*.efi
```

</details>

**步骤 8：验证签名状态**

```bash
sbctl verify
```

预期输出（所有文档都应显示 ✔）：
```
Verifying file database and EFI images in /efi...
✔ /efi/EFI/gentoo/grubx64.efi is signed
✔ /boot/vmlinuz is signed
✔ /efi/EFI/Linux/gentoo-6.x.x.efi is signed
```

**步骤 9：激活 Secure Boot**

1. 重启进入 BIOS/UEFI 设置
2. 找到 **Secure Boot** 选项
3. 将其设置为 **Enabled**
4. 保存并重启

**步骤 10：确认 Secure Boot 已激活**

启动后检查状态：
```bash
sbctl status
```

成功输出：
```
Installed:	✓ sbctl is installed
Owner GUID:	a9fbbdb7-a05f-48d5-b63a-08c5df45ee70
Setup Mode:	✓ Disabled
Secure Boot:	✓ Enabled
Vendor Keys:	microsoft
```

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**sbctl 的优势**

1. **自动化**：一条命令生成所有密钥
2. **简单**：无需手动管理 PEM/DER 格式转换
3. **智能**：自动跟踪需要签名的文档（`/var/lib/sbctl/files.json`）
4. **安全**：密钥默认权限为 600，自动保护
5. **可验证**：随时用 `sbctl verify` 检查签名状态

如果你希望用更少的步骤完成配置，通常可以优先考虑使用 sbctl；如需完全掌控证书与签名流程，则使用本节的手动 OpenSSL 方式。

</div>

---

### 18.2 高端：手动 OpenSSL 方式（可选）

<details>
<summary><b>展开查看手动配置方法（适合高端用户/企业环境）</b></summary>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**适用场景**

- 需要自定义证书参数（如有效期、密钥长度）
- 企业环境需要使用现有 PKI 基础设施
- 对密钥管理有特殊安全要求
- 学习 Secure Boot 底层原理

**如果你已使用 sbctl 完成配置，可以跳过本节。**

</div>

#### 18.2.1 生成自签名证书

**步骤 1：安装必要工具**

```bash
emerge --ask app-crypt/sbsigntools sys-apps/kmod[openssl]
```

**步骤 2：生成证书**

创建密钥目录：
```bash
mkdir -p /etc/kernel/certs
cd /etc/kernel/certs
```

生成 RSA 私钥和证书：
```bash
# 生成私钥 (2048 位 RSA)
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt \
  -days 36500 -nodes -subj "/CN=My Kernel Signing Key/"

# 转换为 DER 格式 (内核需要)
openssl x509 -in MOK.crt -outform DER -out MOK.der

# 设置安全权限
chmod 600 MOK.key
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1rem 0;">

**重要提示**

- **密钥安全**：`MOK.key` 是私钥，必须妥善保管（建议备份到脱机存储）
- **证书有效期**：此处设置为 36500 天（约 100 年），可根据需要调整
- **CN 名称**：可自定义为任意描述性名称

</div>

#### 18.2.2 配置内核模块签名

#### 18.2.2 配置内核模块签名

**步骤 1：激活内核模块签名支持**

编辑 `/etc/portage/package.use/kernel`，为 `dist-kernel` 添加 `modules-sign` USE 标志：
```bash
# /etc/portage/package.use/kernel
virtual/dist-kernel modules-sign
sys-kernel/installkernel dracut
```

**步骤 2：配置签名参数**

编辑 `/etc/portage/make.conf`，添加以下内容：
```bash
# Secure Boot: 内核模块签名配置
MODULES_SIGN_KEY="/etc/kernel/certs/MOK.key"
MODULES_SIGN_CERT="/etc/kernel/certs/MOK.der"
MODULES_SIGN_HASH="sha512"
```

**步骤 3：重新编译内核**

重新安装内核，使签名生效：
```bash
emerge --ask @module-rebuild
emerge --ask sys-kernel/gentoo-kernel-bin  # 或你使用的内核包
```

编译完成后，验证模块签名：
```bash
modinfo /lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amdgpu/amdgpu.ko | grep sig
```

预期输出应包含：
```
sig_id:         PKCS#7
signer:         My Kernel Signing Key
sig_key:        XX:XX:XX:XX:...
sig_hashalgo:   sha512
```

#### 18.2.3 配置内核映像签名（Unified Kernel Image）

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**Unified Kernel Image (UKI)**

将内核、initramfs、命令行参数打包为单一 EFI 可运行文档，并进行整体签名。这是 Secure Boot 的推荐方式。

</div>

**步骤 1：激活 secureboot USE 标志**

编辑 `/etc/portage/package.use/kernel`：
```bash
# /etc/portage/package.use/kernel
virtual/dist-kernel modules-sign secureboot
sys-kernel/installkernel dracut uki
```

**步骤 2：配置签名参数**

编辑 `/etc/portage/make.conf`，添加内核映像签名配置：
```bash
# Secure Boot: 内核映像签名配置
SECUREBOOT_SIGN_KEY="/etc/kernel/certs/MOK.key"
SECUREBOOT_SIGN_CERT="/etc/kernel/certs/MOK.crt"
```

**步骤 3：配置 installkernel**

创建 `/etc/kernel/install.conf`：
```bash
# /etc/kernel/install.conf
layout=uki
uki_generator=dracut
initrd_generator=dracut
```

**步骤 4：重新生成内核**

```bash
emerge --ask sys-kernel/gentoo-kernel-bin  # 或你使用的内核包
```

生成的 UKI 文档位于：
```
/efi/EFI/Linux/gentoo-6.x.x.efi
```

#### 18.2.4 注册 MOK (Machine Owner Key)

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**MOK 管理**

由于 Gentoo 使用自签名证书，你需要将证书注册到 UEFI 固件的 MOK（Machine Owner Key）列表中，以便 Secure Boot 信任你的签名。

</div>

**步骤 1：安装 Shim**

```bash
emerge --ask sys-boot/shim
```

**步骤 2：拷贝 Shim 到 EFI 分区**

```bash
cp /usr/share/shim/shimx64.efi /efi/EFI/gentoo/
cp /usr/share/shim/mmx64.efi /efi/EFI/gentoo/
```

**步骤 3：导入 MOK 证书**

使用 `mokutil` 导入证书（需要在启动后的 MOK Manager 中确认）：
```bash
mokutil --import /etc/kernel/certs/MOK.der
```

设置一个临时密码（重启后在 MOK Manager 中输入）：
```
input password:
input password again:
```

**步骤 4：配置启动项**

使用 `efibootmgr` 创建启动项（指向 Shim）：
```bash
efibootmgr --create --disk /dev/nvme0n1 --part 1 \
  --label "Gentoo Secure Boot" \
  --loader '\EFI\gentoo\shimx64.efi'
```

**步骤 5：重启并注册 MOK**

1. 重启系统
2. 进入 **MOK Manager**（蓝色界面）
3. 选择 **Enroll MOK** → **Continue** → **Yes**
4. 输入之前设置的临时密码
5. 选择 **Reboot**

#### 18.2.5 验证 Secure Boot 状态

重启后，检查 Secure Boot 是否正常工作：
```bash
# 检查 Secure Boot 状态
bootctl status | grep "Secure Boot"

# 预期输出：
# Secure Boot: enabled (user)
```

查看已加载的密钥：
```bash
mokutil --list-enrolled
```

#### 18.2.6 常见问题排查

<details>
<summary><b>问题 1：系统无法启动，显示 "Verification failed: (0x1A) Security Violation"</b></summary>

**原因**：内核或启动加载器未正确签名。

**解决方法**：
1. 在 BIOS 中**临时关闭 Secure Boot**
2. 进入系统后，重新运行签名步骤（18.2.2 和 18.2.3）
3. 确认 `/efi/EFI/Linux/*.efi` 文件存在
4. 重启并重新注册 MOK（步骤 18.2.4）

</details>

<details>
<summary><b>问题 2：模块加载失败，dmesg 显示 "module verification failed: signature and/or required key missing"</b></summary>

**原因**：内核模块未签名或签名不匹配。

**解决方法**：
```bash
# 重新编译并签名所有模块
emerge --ask @module-rebuild
emerge --ask sys-kernel/gentoo-kernel-bin
```

</details>

<details>
<summary><b>问题 3：如何临时禁用 Secure Boot？</b></summary>

**方法 1（推荐）**：在 BIOS/UEFI 设置中关闭 Secure Boot

**方法 2**：删除已注册的 MOK 证书
```bash
mokutil --reset
# 重启后在 MOK Manager 中确认删除
```

</details>

</details>

---

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**Secure Boot 配置总结**

推荐方式：
- **新手用户**：使用 **sbctl**（18.1 节）—— 简单快速，几条命令完成
- **高端用户**：使用**手动 OpenSSL 方式**（18.2 节）—— 完全自定义控制

完成后，系统将拥有与商业发行版同等的安全启动保护。

</div>

---

## 参考数据 {#reference}

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 官方文档

- **[Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)** 官方最新指南
- [Gentoo Wiki](https://wiki.gentoo.org/)
- [Portage Documentation](https://wiki.gentoo.org/wiki/Portage)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 社区支持

**Gentoo 中文社区**：
- Telegram 群组：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 频道：[@gentoocn](https://t.me/gentoocn)
- [GitHub](https://github.com/gentoo-zh)

**官方社区**：
- [Gentoo Forums](https://forums.gentoo.org/)
- IRC: `#gentoo` @ [Libera.Chat](https://libera.chat/)

</div>

</div>

## 结语

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; text-align: center;">

### 祝你在 Gentoo 上享受自由与灵活！

这份指南基于官方 [Handbook:AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64) 并简化流程，标记了可选步骤，让更多人能轻松尝试。

</div>
