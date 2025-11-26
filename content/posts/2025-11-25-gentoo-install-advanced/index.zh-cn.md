---
title: "Gentoo Linux 安装指南 (进阶优化篇)"
date: 2025-11-25
summary: "Gentoo Linux 进阶优化教程，涵盖 make.conf 优化、LTO、Tmpfs、系统维护等。"
description: "2025 年最新 Gentoo Linux 安装指南 (进阶优化篇)，涵盖 make.conf 优化、LTO、Tmpfs、系统维护等。"
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

> **文章特别说明**
> 
> 本文是 **Gentoo Linux 安装指南** 系列的第三部分：**进阶优化**。
> 
> **系列导航**：
> 1. [基础安装](/posts/2025-11-25-gentoo-install-base/)：从零开始安装 Gentoo 基础系统
> 2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：显卡驱动、桌面环境、输入法等
> 3. **进阶优化（本文）**：make.conf 优化、LTO、系统维护
>
> **上一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)
## 13. make.conf 进阶配置指南

> **可参考**：[make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

`/etc/portage/make.conf` 是 Gentoo 的全局配置文件，控制编译器、优化参数、USE 标志等。

#### 1. 编译器配置

**基本配置 (推荐)**
```bash
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"   # Fortran
FFLAGS="${COMMON_FLAGS}"    # Fortran 77
```

**参数说明**：
- `-march=native`：针对当前 CPU 优化（推荐）
- `-O2`：优化级别 2（平衡性能与稳定性）
- `-pipe`：使用管道加速编译

#### 2. 并行编译配置

```bash
MAKEOPTS="-j<核心数> -l<负载限制>"
EMERGE_DEFAULT_OPTS="--jobs=<并行包数> --load-average=<负载>"
```

**推荐值**：
- **4核/8线程**：`MAKEOPTS="-j8 -l8"`, `EMERGE_DEFAULT_OPTS="--jobs=2"`
- **8核/16线程**：`MAKEOPTS="-j16 -l16"`, `EMERGE_DEFAULT_OPTS="--jobs=4"`
- **16核/32线程**：`MAKEOPTS="-j32 -l32"`, `EMERGE_DEFAULT_OPTS="--jobs=6"`

#### 3. USE 标志配置

```bash
# 基础 USE 示例
USE="systemd dbus policykit"
USE="${USE} wayland X gtk qt6"
USE="${USE} pulseaudio alsa"
USE="${USE} -doc -test"
```

**常用 USE 标志**：
| 类别 | USE 标志 | 说明 |
| ---- | -------- | ---- |
| **系统** | `systemd` / `openrc` | init 系统 |
| **桌面** | `wayland`, `X`, `gtk`, `qt6` | 桌面协议和工具包 |
| **音频** | `pipewire`, `pulseaudio`, `alsa` | 音频系统 |
| **视频** | `ffmpeg`, `x264`, `vpx` | 视频编解码 |
| **国际化** | `cjk`, `nls`, `icu` | 中文支持 |
| **禁用** | `-doc`, `-test`, `-examples` | 禁用不必要的功能 |


#### 4. 语言配置

```bash
L10N="en zh zh-CN zh-TW"
LINGUAS="en zh_CN zh_TW"
```

#### 5. 硬件配置

```bash
# 显卡
VIDEO_CARDS="nvidia"        # NVIDIA
# VIDEO_CARDS="amdgpu"      # AMD
# VIDEO_CARDS="intel"       # Intel

# 输入设备
INPUT_DEVICES="libinput"

# CPU 特性 (自动检测，运行: emerge --ask app-portage/cpuid2cpuflags)
CPU_FLAGS_X86="<cpuid2cpuflags 输出>"
```

> 详见：[5.3 CPU 指令集优化 (CPU_FLAGS_X86)](/posts/2025-11-25-gentoo-install-base/#step-5-portage)

#### 6. Portage 功能

```bash
FEATURES="parallel-fetch parallel-install candy ccache"
```

**常用 FEATURES**：
- `parallel-fetch`：并行下载
- `parallel-install`：并行安装
- `candy`：美化输出
- `ccache`：编译缓存（需安装 `dev-build/ccache`）

#### 7. 完整配置示例

**新手推荐配置**：
```bash
# /etc/portage/make.conf
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"

MAKEOPTS="-j4 -l4"  # 根据 CPU 调整

USE="systemd wayland pipewire -doc -test"


L10N="en zh zh-CN"
VIDEO_CARDS="intel"  # 或 nvidia/amdgpu

FEATURES="parallel-fetch candy"
ACCEPT_LICENSE="*"
```

### 13.1 日常维护：如何成为合格的系统管理员

> **可参考**：[Upgrading Gentoo](https://wiki.gentoo.org/wiki/Upgrading_Gentoo/zh-cn) 和 [Gentoo Cheat Sheet](https://wiki.gentoo.org/wiki/Gentoo_Cheat_Sheet)

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

**3. 处理配置文件更新**
软件更新后，配置文件可能也会更新。**不要忽略** `etc-update` 或 `dispatch-conf` 的提示。
```bash
dispatch-conf              # 交互式合并配置文件 (推荐)
# 或
etc-update
```

**4. 清理无用依赖**
> **可参考**：[Remove orphaned packages](https://wiki.gentoo.org/wiki/Knowledge_Base:Remove_orphaned_packages)

```bash
emerge --ask --depclean    # 移除不再需要的孤立依赖
```

**5. 定期清理源码包**
```bash
emerge --ask app-portage/gentoolkit # 安装工具包
eclean-dist                         # 清理已下载的旧源码包
```

**6. 自动处理 USE 变更**
> **可参考**：[Autounmask-write](https://wiki.gentoo.org/wiki/Knowledge_Base:Autounmask-write) 和 [Dispatch-conf](https://wiki.gentoo.org/wiki/Dispatch-conf)

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
    | `journalctl -f` | 实时跟随最新日志 (类似 tail -f) |
    | `journalctl -p err` | 仅显示错误 (Error) 级别的日志 |
    | `journalctl -u <服务名>` | 查看特定服务的日志 |
    | `journalctl --since "1 hour ago"` | 查看最近 1 小时的日志 |
    | `journalctl --disk-usage` | 查看日志占用的磁盘空间 |
    | `journalctl --vacuum-time=2weeks` | 清理 2 周前的日志 |

### 13.2 Portage 技巧与目录结构

> **可参考**：[Portage](https://wiki.gentoo.org/wiki/Portage/zh-cn) 和 [/etc/portage](https://wiki.gentoo.org/wiki//etc/portage/zh-cn)

**1. 核心目录结构 (`/etc/portage/`)**
Gentoo 的配置非常灵活，建议使用**目录**而不是单个文件来管理配置：

| 文件/目录 | 用途 |
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
| `--ask` (`-a`) | 执行前询问确认 | `emerge -a vim` |
| `--verbose` (`-v`) | 显示详细信息 (USE 标志等) | `emerge -av vim` |
| `--oneshot` (`-1`) | 安装但不加入 World 文件 (不作为系统依赖) | `emerge -1 rust` |
| `--update` (`-u`) | 更新软件包 | `emerge -u vim` |
| `--deep` (`-D`) | 深度计算依赖 (更新依赖的依赖) | `emerge -uD @world` |
| `--newuse` (`-N`) | USE 标志改变时重新编译 | `emerge -uDN @world` |
| `--depclean` (`-c`) | 清理不再需要的孤立依赖 | `emerge -c` |
| `--deselect` | 从 World 文件中移除 (不卸载) | `emerge --deselect vim` |
| `--search` (`-s`) | 搜索软件包 (推荐用 eix) | `emerge -s vim` |
| `--info` | 显示 Portage 环境信息 (调试用) | `emerge --info` |

**3. 快速搜索软件包 (Eix)**
> **可参考**：[Eix](https://wiki.gentoo.org/wiki/Eix)
> `emerge --search` 速度较慢，推荐使用 `eix` 进行毫秒级搜索。

1.  **安装与更新索引**：
    ```bash
    emerge --ask app-portage/eix
    eix-update # 安装后或同步后执行
    ```
2.  **搜索软件**：
    ```bash
    eix <关键词>        # 搜索所有软件
    eix -I <关键词>     # 仅搜索已安装软件
    eix -R <关键词>     # 搜索远程 Overlay (需配置 eix-remote)
    ```

---

## 14. 进阶编译优化 [可选]

为了提升后续的编译速度，建议配置 tmpfs 和 ccache。

### 14.1 配置 tmpfs (内存编译)

> **可参考**：[Tmpfs](https://wiki.gentoo.org/wiki/Tmpfs)

将编译临时目录挂载到内存，减少 SSD 磨损并加速编译。

<details>
<summary><b>Tmpfs 配置指南（点击展开）</b></summary>

> **注意**：`size` 大小不要超过你的物理内存大小（建议设为内存的一半），否则可能导致系统不稳定。

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

> **可参考**：[Ccache](https://wiki.gentoo.org/wiki/Ccache)

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
   编辑 `/etc/portage/package.env` (如果是目录则创建文件)：
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

详细配置请参考 **Section 15 进阶编译优化**。

---

## 15. LTO 与 Clang 编译优化 (可选)

> **风险提示**：LTO 会显著增加编译时间和内存消耗，且可能导致部分软件编译失败。**强烈不建议全局开启**，仅推荐针对特定软件（如浏览器）开启。

### 15.1 链接时优化 (LTO)
> **可参考**：[LTO](https://wiki.gentoo.org/wiki/LTO)

LTO (Link Time Optimization) 将优化推迟到链接阶段，可带来性能提升和体积减小。

<details>
<summary><b>LTO 优缺点详细分析（点击展开）</b></summary>

**优势**：
- 性能提升（通常两位数）
- 二进制体积减小
- 启动时间改善

**劣势**：
- 编译时间增加 2-3 倍
- 内存消耗巨大
- 稳定性风险
- 故障排查困难

</details>

> **新手提示**：如果你的系统是 4 核 CPU 配 4GB 内存，那么花在编译上的时间可能远超优化带来的性能提升。请根据硬件配置权衡利弊。

**1. 使用 USE 标志开启 (最推荐)**

对于 Firefox 和 Chromium 等大型软件，官方 ebuild 通常提供了经过测试的 `lto` 和 `pgo` USE 标志：

在 `/etc/portage/package.use/browser` 中启用：
```text
www-client/firefox lto pgo
www-client/chromium lto pgo  # 注意：PGO 在 Wayland 环境下可能无法使用
```

**USE="lto" 标志说明**：部分软件包需要特殊修复才能支持 LTO，可以全局或针对特定软件包启用 `lto` USE 标志：
```bash
# 在 /etc/portage/make.conf 中全局启用
USE="lto"
```

**2. 针对特定软件包启用 LTO (推荐)**

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

**3. 全局启用 LTO (GCC 系统)**

> **警告**：全局 LTO 会导致大量软件包编译失败，需要频繁维护排除列表，**不建议新手尝试**。

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
# -flto: 启用链接时优化（Full LTO）
# 注意：GCC 的 -flto 默认使用 Full LTO，适合 GCC 系统
COMMON_FLAGS="-O2 -pipe -march=native -flto ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 编译器标志
CXXFLAGS="${COMMON_FLAGS}"        # C++ 编译器标志
FCFLAGS="${COMMON_FLAGS}"         # Fortran 编译器标志
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 编译器标志
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 链接器标志

USE="lto"  # 启用 LTO 支持的 USE 标志
```

**4. 全局启用 LTO (LLVM/Clang 系统 - 推荐使用 ThinLTO)**

> **默认推荐**：如果使用 Clang，强烈推荐使用 ThinLTO (`-flto=thin`) 而非 Full LTO (`-flto`)。ThinLTO 速度更快，内存占用更少，支持并行化。

> **警告**：如果 `clang-common` 未启用 `default-lld` USE 标志，必须在 `LDFLAGS` 中添加 `-fuse-ld=lld`。

编辑 `/etc/portage/make.conf`：
```bash
# Clang 目前尚未完全实现这些诊断，但保留这些标志以备将来使用
# -Werror=odr: One Definition Rule 违规检测（Clang 部分支持）
# -Werror=strict-aliasing: 严格别名违规检测（Clang 正在开发）
WARNING_FLAGS="-Werror=odr -Werror=strict-aliasing"

# -O2: 优化级别 2（平衡性能与稳定性）
# -pipe: 使用管道加速编译
# -march=native: 针对当前 CPU 优化
# -flto=thin: 启用 ThinLTO（推荐，速度快且并行化）
COMMON_FLAGS="-O2 -pipe -march=native -flto=thin ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 编译器标志
CXXFLAGS="${COMMON_FLAGS}"        # C++ 编译器标志
FCFLAGS="${COMMON_FLAGS}"         # Fortran 编译器标志
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 编译器标志
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 链接器标志

USE="lto"  # 启用 LTO 支持的 USE 标志
```

**ThinLTO vs Full LTO（推荐新手阅读）**：

| 类型 | 标志 | 优势 | 劣势 | 推荐场景 |
|------|------|------|------|----------|
| **ThinLTO** | `-flto=thin` | • 速度快<br>• 内存占用少<br>• 支持并行化<br>• 编译速度提升 2-3 倍 | • 仅 Clang/LLVM 支持 | **默认推荐**（Clang 用户） |
| Full LTO | `-flto` | • 更深度的优化<br>• GCC 和 Clang 均支持 | • 速度慢<br>• 内存占用高<br>• 串行处理 | GCC 用户或需要极致优化时 |

> **新手提示**：如果你使用 Clang，请务必使用 `-flto=thin`。这是目前的最佳实践，能在保证性能的同时大幅减少编译时间。

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

### 15.3 进阶软件包环境配置 (package.env)

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

创建 `/etc/portage/package.env/no-lto` 文件（包含已知问题包）：

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
# 使用低内存编译设定

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

> **提示**：如果遇到其他 LTO 相关的链接错误，请先尝试禁用该包的 LTO。也可以查看 Gentoo Bugzilla 是否有相关报告。](https://bugs.gentoo.org) 搜索是否已有相关报告（搜索"软件包名 lto"）。如果是新问题，欢迎提交 bug 报告帮助改进 Gentoo。

### 15.2 使用 Clang 编译
> **可参考**：[Clang](https://wiki.gentoo.org/wiki/Clang)

**前提条件**：安装 Clang 和 LLD
```bash
emerge --ask llvm-core/clang llvm-core/lld
```

> **重要提示**：
> - 部分软件包（如 `sys-libs/glibc`, `app-emulation/wine`）无法使用 Clang 编译，仍需 GCC。
> - Gentoo 维护了 [bug #408963](https://bugs.gentoo.org/408963) 来跟踪 Clang 编译失败的软件包。

**1. 针对特定软件开启 (推荐)**

创建环境配置文件 `/etc/portage/env/clang.conf`：
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



**3. PGO 支持（配置文件引导优化）**

> **注意**：如果需要 PGO 支持（如 `dev-lang/python[pgo]`），需要安装以下包：

```bash
emerge --ask llvm-core/clang-runtime
emerge --ask llvm-runtimes/compiler-rt-sanitizers
```

在 `/etc/portage/package.use` 中启用相关 USE 标志：
```text
llvm-core/clang-runtime sanitize
llvm-runtimes/compiler-rt-sanitizers profile orc
```

> **警告**：
> - 如果没有启用 `profile` 和 `orc` USE 标志，带有 `pgo` USE 标志的软件包（如 `dev-lang/python[pgo]`）会编译失败。
> - 编译日志可能会报错：`ld.lld: error: cannot open /usr/lib/llvm/18/bin/../../../../lib/clang/18/lib/linux/libclang_rt.profile-x86_64.a`

**4. 全局开启 (不建议初学者)**

全局切换到 Clang 需要系统大部分软件支持，且需要处理大量兼容性问题，**仅建议高级用户尝试**。

如需全局启用，在 `/etc/portage/make.conf` 中添加：
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

## 16. 内核编译进阶指南 (可选) {#section-16-kernel-advanced}

> 可参考：[Kernel](https://wiki.gentoo.org/wiki/Kernel)、[Kernel/Configuration](https://wiki.gentoo.org/wiki/Kernel/Configuration)、[Genkernel](https://wiki.gentoo.org/wiki/Genkernel)

本节面向希望深入掌控内核编译的高级用户，包括使用 LLVM/Clang 编译、启用 LTO 优化、自动化配置等。

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
lscpu  # 查看 CPU 型号、核心数、架构等
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
# 这会只启用当前加载模块对应的内核选项（强烈推荐！）

# 方法 2：基于当前运行内核的配置创建
zcat /proc/config.gz > .config  # 如果当前内核支持
make olddefconfig  # 使用默认值更新配置
```

> **新手提示**：`localmodconfig` 是最安全的方法，它会确保你的硬件都能正常工作，同时移除不需要的驱动。

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
| **General setup** | 通用设置 | 本地主机名、Systemd/OpenRC 支持 |
| **Processor type and features** | 处理器类型与特性 | CPU 型号选择、微码加载 |
| **Power management and ACPI options** | 电源管理与 ACPI | 笔记本电源管理、挂起/休眠 |
| **Bus options (PCI etc.)** | 总线选项 | PCI 支持 (lspci) |
| **Virtualization** | 虚拟化 | KVM, VirtualBox 宿主/客户机支持 |
| **Enable loadable module support** | 可加载模块支持 | 允许使用内核模块 (*.ko) |
| **Networking support** | 网络支持 | TCP/IP 协议栈、防火墙 (Netfilter) |
| **Device Drivers** | 设备驱动 | 显卡、网卡、声卡、USB、NVMe 驱动 |
| **File systems** | 文件系统 | ext4, btrfs, vfat, ntfs 支持 |
| **Security options** | 安全选项 | SELinux, AppArmor |
| **Gentoo Linux** | Gentoo 特有选项 | Portage 依赖项自动选择 (推荐) |

> **重要建议**：对于手动编译，建议将**关键驱动**（如文件系统、磁盘控制器、网卡）直接编译进内核（选择 `[*]` 或 `<*>` 即 `=y`），而不是作为模块（`<M>` 即 `=m`）。这样可以避免 initramfs 缺失模块导致无法启动的问题。

**必需启用的选项**（根据你的系统）：

1. **处理器支持**：
   - `General setup → Gentoo Linux support`
   - `Processor type and features → Processor family` (选择你的 CPU)

2. **文件系统**：
   - `File systems → The Extended 4 (ext4) filesystem` (如果使用 ext4)
   - `File systems → Btrfs filesystem` (如果使用 Btrfs)

3. **设备驱动**：
   - `Device Drivers → Network device support` (网卡驱动)
   - `Device Drivers → Graphics support` (显卡驱动)

4. **Systemd 用户必需**：
   - `General setup → Control Group support`
   - `General setup → Namespaces support`

5. **Gentoo Linux 专有选项**（推荐全部启用）：
   
   进入 `Gentoo Linux --->` 菜单：
   
   ```
   [*] Gentoo Linux support
       启用 Gentoo 特定的内核功能支持
   
   [*] Linux dynamic and persistent device naming (userspace devfs) support
       启用 udev 动态设备管理支持（必需）
   
   [*] Select options required by Portage features
       自动启用 Portage 需要的内核选项（强烈推荐）
       这会自动配置必需的文件系统和内核功能
   
   Support for init systems, system and service managers --->
       ├─ [*] OpenRC support  # 如果使用 OpenRC
       └─ [*] systemd support # 如果使用 systemd
   
   [*] Kernel Self Protection Project
       启用内核自我保护机制（提高安全性）
   
   [*] Print firmware information that the kernel attempts to load
       在启动时显示固件加载信息（便于调试）
   ```

   > **新手提示**：启用 "Select options required by Portage features" 可以自动配置大部分必需选项，非常推荐！

> **提示**：在 menuconfig 中，按 `/` 可以搜索选项，按 `?` 查看帮助。

### 16.5 自动启用推荐选项

Gentoo 提供了自动化脚本来启用常见硬件和功能：

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

**启用内核 LTO 支持**：
在 `make menuconfig` 中：
```
General setup
  → Compiler optimization level → Optimize for performance  # 选择 -O2（推荐）
  → Link Time Optimization (LTO) → Clang ThinLTO (NEW)      # 启用 ThinLTO（强烈推荐）
```

> **重要警告**：内核编译时**强烈不建议使用 Full LTO**！
> - Full LTO 会导致编译极其缓慢（可能需要数小时）
> - 占用大量内存（可能需要 16GB+ RAM）
> - 容易导致链接错误
> - **请务必使用 ThinLTO**，它更快、更稳定、内存占用更少

### 16.7 内核编译选项优化

<details>
<summary><b>高级编译优化（点击展开）</b></summary>

**在 `menuconfig` 中启用**：

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
make -j$(nproc)         # 使用所有 CPU 核心
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

# 启用 LTO（需要手动配置 .config）
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
- **内核大小 (11M)**：最终内核文件大小（使用 ZSTD 压缩后）

> **优化建议**：
> - 内核大小 < 15MB：优秀（精简配置）
> - 内核大小 15-30MB：良好（标准配置）
> - 内核大小 > 30MB：考虑禁用不需要的功能

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
   # 保存当前配置到外部文件
   cp .config ~/kernel-config-backup
   
   # 恢复配置
   cp ~/kernel-config-backup /usr/src/linux/.config
   make olddefconfig
   ```

2. **查看配置差异**：
   ```bash
   # 对比两个配置文件
   scripts/diffconfig .config ../old-kernel/.config
   ```

3. **最小化配置**（仅包含必需功能）：
   ```bash
   make tinyconfig  # 创建极简配置
   make localmodconfig  # 然后添加当前硬件支持
   ```

---

## 17. 服务器与 RAID 配置 (可选) {#section-17-server-raid}

> **可参考**：[Gentoo Wiki: Mdadm](https://wiki.gentoo.org/wiki/Mdadm)

本节适用于需要配置软 RAID (mdadm) 的服务器用户。

### 17.1 内核配置 (手动编译必选)

如果你手动编译内核，必须启用以下选项（**注意：必须编译进内核 `<*>` 即 `=y`，不能是模块 `<M>`**）：

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

**1. 启用 mdraid 支持**
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
你需要找到 RAID 阵列的 UUID 并添加到内核参数中。
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

> **提示**：配置完成后，务必检查 `/boot/initramfs-*.img` 是否包含 RAID 模块：
> `lsinitrd /boot/initramfs-*.img | grep raid`

</details>

---

## 参考资料 {#reference}

### 官方文档

- **[Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)** 官方最新指南
- [Gentoo Wiki](https://wiki.gentoo.org/)
- [Portage Documentation](https://wiki.gentoo.org/wiki/Portage)

### 社区支持

**Gentoo 中文社区**：
- Telegram 群组：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 频道：[@gentoocn](https://t.me/gentoocn)
- [GitHub](https://github.com/gentoo-zh)

**官方社区**：
- [Gentoo Forums](https://forums.gentoo.org/)
- IRC: `#gentoo` @ [Libera.Chat](https://libera.chat/)

## 结语

**祝你在 Gentoo 上享受自由与灵活！**

这份指南基于官方 [Handbook:AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64) 并简化流程，标记了可选步骤，让更多人能轻松尝试。
