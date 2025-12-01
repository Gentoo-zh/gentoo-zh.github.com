---
title: "Gentoo Linux 安裝指南 (进阶優化篇)"
date: 2025-11-25
summary: "Gentoo Linux 进阶優化教學，涵蓋 make.conf 優化、LTO、Tmpfs、系統維護等。"
description: "2025 年最新 Gentoo Linux 安裝指南 (进阶優化篇)，涵蓋 make.conf 優化、LTO、Tmpfs、系統維護等。"
keywords:
  - Gentoo Linux
  - make.conf
  - LTO
  - Tmpfs
  - 系統維護
  - 編譯優化
tags:
  - Gentoo
  - Linux
  - 教學
  - 系統優化
categories:
  - tutorial
authors:
  - zakkaus
---

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 文章特别说明

本文是 **Gentoo Linux 安裝指南** 系列的第三部分：**进阶優化**。

**系列導航**：
1. [基础安裝](/posts/2025-11-25-gentoo-install-base/)：从零开始安裝 Gentoo 基础系統
2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：顯示卡驅動、桌面環境、输入法等
3. **进阶優化（本文）**：make.conf 優化、LTO、系統維護

**上一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)

</div>

## 13. make.conf 进阶配置指南

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

</div>

`/etc/portage/make.conf` 是 Gentoo 的全局配置檔案，控制編譯器、優化參數、USE 标志等。

#### 1. 編譯器配置

**基本配置 (推薦)**
```bash
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"   # Fortran
FFLAGS="${COMMON_FLAGS}"    # Fortran 77
```

**參數说明**：
- `-march=native`：针对当前 CPU 優化（推薦）
- `-O2`：優化级别 2（平衡效能与穩定性）
- `-pipe`：使用管道加速編譯

#### 2. 并行編譯配置

```bash
MAKEOPTS="-j<核心数> -l<负载限制>"
EMERGE_DEFAULT_OPTS="--jobs=<并行套件数> --load-average=<负载>"
```

**推薦值**：
- **4核/8线程**：`MAKEOPTS="-j8 -l8"`, `EMERGE_DEFAULT_OPTS="--jobs=2"`
- **8核/16线程**：`MAKEOPTS="-j16 -l16"`, `EMERGE_DEFAULT_OPTS="--jobs=4"`
- **16核/32线程**：`MAKEOPTS="-j32 -l32"`, `EMERGE_DEFAULT_OPTS="--jobs=6"`

#### 3. USE 标志配置

```bash
# 基础 USE 範例
USE="systemd dbus policykit"
USE="${USE} wayland X gtk qt6"
USE="${USE} pulseaudio alsa"
USE="${USE} -doc -test"
```

**常用 USE 标志**：
| 類別别 | USE 标志 | 说明 |
| ---- | -------- | ---- |
| **系統** | `systemd` / `openrc` | init 系統 |
| **桌面** | `wayland`, `X`, `gtk`, `qt6` | 桌面協議和工具套件 |
| **音訊** | `pipewire`, `pulseaudio`, `alsa` | 音訊系統 |
| **影片** | `ffmpeg`, `x264`, `vpx` | 影片编解码 |
| **国际化** | `cjk`, `nls`, `icu` | 中文支援 |
| **禁用** | `-doc`, `-test`, `-examples` | 禁用不必要的功能 |


#### 4. 语言配置

```bash
L10N="en zh zh-CN zh-TW"
LINGUAS="en zh_CN zh_TW"
```

#### 5. 硬體配置

```bash
# 顯示卡
VIDEO_CARDS="nvidia"        # NVIDIA
# VIDEO_CARDS="amdgpu"      # AMD
# VIDEO_CARDS="intel"       # Intel

# 输入裝置
INPUT_DEVICES="libinput"

# CPU 特性 (自動检测，运行: emerge --ask app-portage/cpuid2cpuflags)
CPU_FLAGS_X86="<cpuid2cpuflags 输出>"
```

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**詳見**：[5.3 CPU 指令集優化 (CPU_FLAGS_X86)](/posts/2025-11-25-gentoo-install-base/#step-5-portage)

</div>

#### 6. Portage 功能

```bash
FEATURES="parallel-fetch parallel-install candy ccache"
```

**常用 FEATURES**：
- `parallel-fetch`：并行下載
- `parallel-install`：并行安裝
- `candy`：美化输出
- `ccache`：編譯快取（需安裝 `dev-build/ccache`）

#### 7. 完整配置範例

**新手推薦配置**：
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

### 13.1 日常維護：如何成为合格的系統管理员

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Upgrading Gentoo](https://wiki.gentoo.org/wiki/Upgrading_Gentoo/zh-tw) · [Gentoo Cheat Sheet](https://wiki.gentoo.org/wiki/Gentoo_Cheat_Sheet)

</div>

Gentoo 是滚动发行版，維護系統是使用體驗的重要组成部分。

**1. 保持系統更新**
建議每一到两周更新一次系統，避免积压过多更新导致依賴冲突。
```bash
emerge --sync              # 同步軟體倉庫
emerge -avuDN @world       # 更新所有軟體
```

**2. 关注官方新闻 (重要)**
在更新前或遇到问题时，务必检查是否有官方新闻推送。
```bash
eselect news list          # 列出新闻
eselect news read          # 阅读新闻
```

**3. 处理配置檔案更新**
軟體更新后，配置檔案可能也会更新。**不要忽略** `etc-update` 或 `dispatch-conf` 的提示。
```bash
dispatch-conf              # 互動式合并配置檔案 (推薦)
# 或
etc-update
```

**4. 清理无用依賴**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Remove orphaned packages](https://wiki.gentoo.org/wiki/Knowledge_Base:Remove_orphaned_packages)

</div>

```bash
emerge --ask --depclean    # 移除不再需要的孤立依賴
```

**5. 定期清理原始碼套件**
```bash
emerge --ask app-portage/gentoolkit # 安裝工具套件
eclean-dist                         # 清理已下載的旧原始碼套件
```

**6. 自動处理 USE 变更**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Autounmask-write](https://wiki.gentoo.org/wiki/Knowledge_Base:Autounmask-write) · [Dispatch-conf](https://wiki.gentoo.org/wiki/Dispatch-conf)

</div>

当安裝或更新軟體提示 "The following USE changes are necessary" 时：
1.  **让 Portage 自動写入配置**：`emerge --ask --autounmask-write <套件名>`
2.  **確認并更新配置**：`dispatch-conf` (按 u 確認，q 退出)
3.  **再次嘗試操作**：`emerge --ask <套件名>`

**7. 处理軟體冲突 (Blocked Packages)**
如果遇到 "Error: The above package list contains packages which cannot be installed at the same time..."：
- **解决方法**：根据提示，手動卸載冲突軟體 (`emerge --deselect <套件名>` 后 `emerge --depclean`)。

**8. 安全检查 (GLSA)**
Gentoo 發布安全公告 (GLSA) 来通知使用者潜在的安全漏洞。
```bash
glsa-check -l      # 列出所有未修复的安全公告
glsa-check -t all  # 測試所有受影响的軟體套件
```

**9. 系統日誌与服務狀態**
定期检查系統日誌和服務狀態，确保系統健康运行。
- **OpenRC**:
    ```bash
    rc-status      # 查看服務狀態
    tail -f /var/log/messages # 查看系統日誌 (需安裝 syslog-ng 等)
    ```
- **Systemd (Journalctl 常用指令)**:
    | 指令 | 作用 |
    | ---- | ---- |
    | `systemctl --failed` | 查看啟動失败的服務 |
    | `journalctl -b` | 查看本次啟動的日誌 |
    | `journalctl -b -1` | 查看上一次啟動的日誌 |
    | `journalctl -f` | 实时跟随最新日誌 (類別似 tail -f) |
    | `journalctl -p err` | 仅顯示錯誤 (Error) 级别的日誌 |
    | `journalctl -u <服務名>` | 查看特定服務的日誌 |
    | `journalctl --since "1 hour ago"` | 查看最近 1 小时的日誌 |
    | `journalctl --disk-usage` | 查看日誌占用的磁碟空间 |
    | `journalctl --vacuum-time=2weeks` | 清理 2 周前的日誌 |

### 13.2 Portage 技巧与目錄结构

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Portage](https://wiki.gentoo.org/wiki/Portage/zh-tw) · [/etc/portage](https://wiki.gentoo.org/wiki//etc/portage)

</div>

**1. 核心目錄结构 (`/etc/portage/`)**
Gentoo 的配置非常灵活，建議使用**目錄**而不是单个檔案来管理配置：

| 檔案/目錄 | 用途 |
| --------- | ---- |
| `make.conf` | 全局編譯參數 (CFLAGS, MAKEOPTS, USE, GENTOO_MIRRORS) |
| `package.use/` | 针对特定軟體的 USE 标志配置 |
| `package.accept_keywords/` | 允许安裝測試版 (keyword) 軟體 |
| `package.mask/` | 屏蔽特定版本的軟體 |
| `package.unmask/` | 解除屏蔽特定版本的軟體 |
| `package.license/` | 接受特定軟體的许可证 |
| `package.env/` | 针对特定軟體的環境變數 (如使用不同的編譯器參數) |

**2. 常用 Emerge 指令速查**
> 完整手冊请运行 `man emerge`

| 參數 (缩写) | 作用 | 範例 |
| ----------- | ---- | ---- |
| `--ask` (`-a`) | 执行前询问確認 | `emerge -a vim` |
| `--verbose` (`-v`) | 顯示詳細資訊 (USE 标志等) | `emerge -av vim` |
| `--oneshot` (`-1`) | 安裝但不加入 World 檔案 (不作为系統依賴) | `emerge -1 rust` |
| `--update` (`-u`) | 更新軟體套件 | `emerge -u vim` |
| `--deep` (`-D`) | 深度计算依賴 (更新依賴的依賴) | `emerge -uD @world` |
| `--newuse` (`-N`) | USE 标志改变时重新編譯 | `emerge -uDN @world` |
| `--depclean` (`-c`) | 清理不再需要的孤立依賴 | `emerge -c` |
| `--deselect` | 从 World 檔案中移除 (不卸載) | `emerge --deselect vim` |
| `--search` (`-s`) | 搜尋軟體套件 (推薦用 eix) | `emerge -s vim` |
| `--info` | 顯示 Portage 環境資訊 (除錯用) | `emerge --info` |

**3. 快速搜尋軟體套件 (Eix)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Eix](https://wiki.gentoo.org/wiki/Eix)

</div>
> `emerge --search` 速度较慢，推薦使用 `eix` 进行毫秒级搜尋。

1.  **安裝与更新索引**：
    ```bash
    emerge --ask app-portage/eix
    eix-update # 安裝后或同步后执行
    ```
2.  **搜尋軟體**：
    ```bash
    eix <關鍵词>        # 搜尋所有軟體
    eix -I <關鍵词>     # 仅搜尋已安裝軟體
    eix -R <關鍵词>     # 搜尋遠端 Overlay (需配置 eix-remote)
    ```

---

## 14. 进阶編譯優化 [可選]

为了提升后续的編譯速度，建議配置 tmpfs 和 ccache。

### 14.1 配置 tmpfs (記憶體編譯)

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Tmpfs](https://wiki.gentoo.org/wiki/Tmpfs)

</div>

将編譯临时目錄掛載到記憶體，减少 SSD 磨损并加速編譯。

<details>
<summary><b>Tmpfs 配置指南（点击展开）</b></summary>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

`size` 大小不要超过你的物理記憶體大小（建議设为記憶體的一半），否则可能导致系統不穩定。

</div>

編輯 `/etc/fstab`，新增以下行（size 建議設定为記憶體的一半，例如 16G）：
```fstab
tmpfs   /var/tmp/portage   tmpfs   size=16G,uid=portage,gid=portage,mode=775,noatime   0 0
```
掛載目錄：
```bash
mount /var/tmp/portage
```
</details>

### 14.2 配置 ccache (編譯快取)

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Ccache](https://wiki.gentoo.org/wiki/Ccache)

</div>

快取編譯中间产物，加快重新編譯速度。
```bash
emerge --ask dev-build/ccache
ccache -M 20G  # 設定快取大小为 20GB
```

### 14.3 处理大型軟體編譯 (避免 tmpfs 爆满)

Firefox、LibreOffice 等大型軟體編譯时可能会耗尽 tmpfs 空间。我们可以配置 Portage 让这些特定軟體使用硬碟进行編譯。

<details>
<summary><b>Notmpfs 配置指南（点击展开）</b></summary>

1. 建立配置目錄：
   ```bash
   mkdir -p /etc/portage/env
   mkdir -p /var/tmp/notmpfs
   ```

2. 建立 `notmpfs.conf`：
   ```bash
   echo 'PORTAGE_TMPDIR="/var/tmp/notmpfs"' > /etc/portage/env/notmpfs.conf
   ```

3. 针对特定軟體應用配置：
   編輯 `/etc/portage/package.env` (如果是目錄则建立檔案)：
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

### 14.4 LTO 与 Clang 優化

詳細配置请參考 **Section 15 进阶編譯優化**。

---

## 15. LTO 与 Clang 編譯優化 (可選)

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**风险提示**

LTO 会显著增加編譯时间和記憶體消耗，且可能导致部分軟體編譯失败。**强烈不建議全局開啟**，仅推薦针对特定軟體（如瀏覽器）開啟。

</div>

### 15.1 連結时優化 (LTO)
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[LTO](https://wiki.gentoo.org/wiki/LTO)

</div>

LTO (Link Time Optimization) 将優化推迟到連結阶段，可带来效能提升和体积减小。

<details style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1rem; border-radius: 0.75rem; margin: 1rem 0; border: 1px solid rgba(59, 130, 246, 0.2);">
<summary style="cursor: pointer; font-weight: bold; color: #1d4ed8;">LTO 優缺點詳細分析（点击展开）</summary>

<div style="margin-top: 1rem;">

**优势**：
*   效能提升（通常两位数）
*   二进制体积减小
*   啟動时间改善

**劣势**：
*   編譯时间增加 2-3 倍
*   記憶體消耗巨大
*   穩定性风险
*   故障排查困难

</div>

</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

如果你的系統是 4 核 CPU 配 4GB 記憶體，那么花在編譯上的时间可能远超優化带来的效能提升。请根据硬體配置权衡利弊。

</div>

**1. 使用 USE 标志開啟 (最推薦)**

对于 Firefox 和 Chromium 等大型軟體，官方 ebuild 通常提供了经过測試的 `lto` 和 `pgo` USE 标志：

在 `/etc/portage/package.use/browser` 中启用：
```text
www-client/firefox lto pgo
www-client/chromium lto pgo  # 注意：PGO 在 Wayland 環境下可能无法使用
```

**USE="lto" 标志说明**：部分軟體套件需要特殊修复才能支援 LTO，可以全局或针对特定軟體套件启用 `lto` USE 标志：
```bash
# 在 /etc/portage/make.conf 中全局启用
USE="lto"
```

**2. 针对特定軟體套件启用 LTO (推薦)**

建立 `/etc/portage/env/lto.conf`：
```bash
CFLAGS="${CFLAGS} -flto"
CXXFLAGS="${CXXFLAGS} -flto"
```

在 `/etc/portage/package.env` 中應用：
```text
www-client/firefox lto.conf
app-editors/vim lto.conf
```

**3. 全局启用 LTO (GCC 系統)**

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

全局 LTO 会导致大量軟體套件編譯失败，需要频繁維護排除列表，**不建議新手嘗試**。

</div>

編輯 `/etc/portage/make.conf`：
```bash
# 这些警告指示 LTO 可能导致的运行时问题，将其提升为錯誤
# -Werror=odr: One Definition Rule 违规（多次定义同一符号）
# -Werror=lto-type-mismatch: LTO 類別型不匹配
# -Werror=strict-aliasing: 严格别名违规
WARNING_FLAGS="-Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing"

# -O2: 優化级别 2（推薦）
# -pipe: 使用管道加速編譯
# -march=native: 针对当前 CPU 優化
# -flto: 启用連結时優化（Full LTO）
# 注意：GCC 的 -flto 預設使用 Full LTO，适合 GCC 系統
COMMON_FLAGS="-O2 -pipe -march=native -flto ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 編譯器标志
CXXFLAGS="${COMMON_FLAGS}"        # C++ 編譯器标志
FCFLAGS="${COMMON_FLAGS}"         # Fortran 編譯器标志
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 編譯器标志
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 連結器标志

USE="lto"  # 启用 LTO 支援的 USE 标志
```

**4. 全局启用 LTO (LLVM/Clang 系統 - 推薦使用 ThinLTO)**

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**預設推薦**

如果使用 Clang，强烈推薦使用 ThinLTO (`-flto=thin`) 而非 Full LTO (`-flto`)。ThinLTO 速度更快，記憶體占用更少，支援并行化。

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

如果 `clang-common` 未启用 `default-lld` USE 标志，必須在 `LDFLAGS` 中新增 `-fuse-ld=lld`。

</div>

編輯 `/etc/portage/make.conf`：
```bash
# Clang 目前尚未完全实现这些诊断，但保留这些标志以备将来使用
# -Werror=odr: One Definition Rule 违规检测（Clang 部分支援）
# -Werror=strict-aliasing: 严格别名违规检测（Clang 正在開發）
WARNING_FLAGS="-Werror=odr -Werror=strict-aliasing"

# -O2: 優化级别 2（平衡效能与穩定性）
# -pipe: 使用管道加速編譯
# -march=native: 针对当前 CPU 優化
# -flto=thin: 启用 ThinLTO（推薦，速度快且并行化）
COMMON_FLAGS="-O2 -pipe -march=native -flto=thin ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 編譯器标志
CXXFLAGS="${COMMON_FLAGS}"        # C++ 編譯器标志
FCFLAGS="${COMMON_FLAGS}"         # Fortran 編譯器标志
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 編譯器标志
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 連結器标志

USE="lto"  # 启用 LTO 支援的 USE 标志
```

**ThinLTO vs Full LTO（推薦新手阅读）**：

| 類別型 | 标志 | 优势 | 劣势 | 推薦场景 |
|------|------|------|------|----------|
| **ThinLTO** | `-flto=thin` | • 速度快<br>• 記憶體占用少<br>• 支援并行化<br>• 編譯速度提升 2-3 倍 | • 仅 Clang/LLVM 支援 | **預設推薦**（Clang 使用者） |
| Full LTO | `-flto` | • 更深度的優化<br>• GCC 和 Clang 均支援 | • 速度慢<br>• 記憶體占用高<br>• 串行处理 | GCC 使用者或需要极致優化时 |

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

如果你使用 Clang，请务必使用 `-flto=thin`。这是目前的最佳实践，能在保证效能的同时大幅减少編譯时间。

</div>

**5. Rust LTO 配置**

**在 LLVM 系統上**：
```bash
# 在 /etc/portage/make.conf 中新增
RUSTFLAGS="${RUSTFLAGS} -Clinker-plugin-lto"
```

**在 GCC 系統上**（需要使用 Clang 編譯 Rust 程式碼）：
建立 `/etc/portage/env/llvm-lto.conf`：
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

在 `/etc/portage/package.env` 中为 Rust 軟體套件指定：
```text
dev-lang/rust llvm-lto.conf
```

### 15.3 进阶軟體套件環境配置 (package.env)

针对特定軟體套件的特殊配置（如禁用 LTO 或低記憶體模式），可以使用 `package.env` 进行精细控制。

<details>
<summary><b>配置 1：禁用 LTO 的軟體套件列表 (no-lto) - 点击展开</b></summary>

某些軟體套件已知与 LTO 不相容。建議建立 `/etc/portage/env/nolto.conf`：

```bash
# 禁用 LTO 及相关警告
DISABLE_LTO="-Wno-error=odr -Wno-error=lto-type-mismatch -Wno-error=strict-aliasing -fno-lto"
CFLAGS="${CFLAGS} ${DISABLE_LTO}"
CXXFLAGS="${CXXFLAGS} ${DISABLE_LTO}"
FCFLAGS="${FCFLAGS} ${DISABLE_LTO}"
FFLAGS="${FFLAGS} ${DISABLE_LTO}"
LDFLAGS="${LDFLAGS} ${DISABLE_LTO}"
```

建立 `/etc/portage/package.env/no-lto` 檔案（包含已知问题套件）：

```bash
# 已知与 LTO 有相容性问题的套件
# 仍使用 Clang 編譯，但禁用 LTO

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
<summary><b>配置 2：低記憶體編譯模式 (low-memory) - 点击展开</b></summary>

对于大型專案（如 Chromium, Rust），建議使用低記憶體配置以防止 OOM。

建立 `/etc/portage/env/low-memory.conf`：
```bash
# 减少并行任務数，例如改为 -j2 或 -j4
MAKEOPTS="-j4"
# 可選：移除一些耗記憶體的優化标志
COMMON_FLAGS="-O2 -pipe"
```

建立 `/etc/portage/package.env/low-memory`：
```bash
# 容易导致系統卡死的大型套件
# 使用低記憶體編譯设定

# 瀏覽器類別 (极大型專案)
www-client/chromium low-memory.conf
mail-client/thunderbird low-memory.conf

# 辦公套件
app-office/libreoffice low-memory.conf

# 虛擬化
app-emulation/qemu low-memory.conf

# Rust 大型專案
dev-lang/rust low-memory.conf
virtual/rust low-memory.conf
```
</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

如果遇到其他 LTO 相关的連結錯誤，请先嘗試禁用该套件的 LTO。也可以查看 [Gentoo Bugzilla](https://bugs.gentoo.org) 搜尋是否已有相关報告（搜尋"軟體套件名 lto"）。如果是新问题，欢迎提交 bug 報告幫助改进 Gentoo。

</div>

### 15.2 使用 Clang 編譯
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Clang](https://wiki.gentoo.org/wiki/Clang)

</div>

**前提条件**：安裝 Clang 和 LLD
```bash
emerge --ask llvm-core/clang llvm-core/lld
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**重要提示**

- 部分軟體套件（如 `sys-libs/glibc`, `app-emulation/wine`）无法使用 Clang 編譯，仍需 GCC。
- Gentoo 維護了 [bug #408963](https://bugs.gentoo.org/408963) 来跟踪 Clang 編譯失败的軟體套件。

</div>

**1. 针对特定軟體開啟 (推薦)**

建立環境配置檔案 `/etc/portage/env/clang.conf`：
```bash
CC="clang"
CXX="clang++"
CPP="clang-cpp"  # 某些軟體套件（如 xorg-server）需要
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```

應用到特定軟體（例如 `app-editors/neovim`），在 `/etc/portage/package.env` 中新增：
```text
app-editors/neovim clang.conf
```



**3. PGO 支援（配置檔案引導優化）**

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果需要 PGO 支援（如 `dev-lang/python[pgo]`），需要安裝以下套件：

</div>

```bash
emerge --ask llvm-core/clang-runtime
emerge --ask llvm-runtimes/compiler-rt-sanitizers
```

在 `/etc/portage/package.use` 中启用相关 USE 标志：
```text
llvm-core/clang-runtime sanitize
llvm-runtimes/compiler-rt-sanitizers profile orc
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

- 如果没有启用 `profile` 和 `orc` USE 标志，带有 `pgo` USE 标志的軟體套件（如 `dev-lang/python[pgo]`）会編譯失败。
- 編譯日誌可能会报错：`ld.lld: error: cannot open /usr/lib/llvm/18/bin/../../../../lib/clang/18/lib/linux/libclang_rt.profile-x86_64.a`

</div>

**4. 全局開啟 (不建議初学者)**

全局切换到 Clang 需要系統大部分軟體支援，且需要处理大量相容性问题，**仅建議高级使用者嘗試**。

如需全局启用，在 `/etc/portage/make.conf` 中新增：
```bash
CC="clang"
CXX="clang++"
CPP="clang-cpp"
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```

**GCC 回退環境**

对于无法使用 Clang 編譯的軟體套件，建立 `/etc/portage/env/gcc.conf`：
```bash
CC="gcc"
CXX="g++"
CPP="gcc -E"
AR="ar"
NM="nm"
RANLIB="ranlib"
```

在 `/etc/portage/package.env` 中为特定軟體指定使用 GCC：
```text
sys-libs/glibc gcc.conf
app-emulation/wine gcc.conf
```



---

## 16. 核心編譯进阶指南 (可選) {#section-16-kernel-advanced}

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1rem; border-radius: 0.5rem; border-left: 4px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Kernel](https://wiki.gentoo.org/wiki/Kernel)、[Kernel/Configuration](https://wiki.gentoo.org/wiki/Kernel/Configuration)、[Genkernel](https://wiki.gentoo.org/wiki/Genkernel)

</div>

本节面向希望深入掌控核心編譯的高级使用者，包括使用 LLVM/Clang 編譯、启用 LTO 優化、自動化配置等。

### 16.1 准备工作

安裝必要工具：
```bash
# 安裝核心原始碼和構建工具
emerge --ask sys-kernel/gentoo-sources

# （可選）安裝 Genkernel 用于自動化
emerge --ask sys-kernel/genkernel

# （可選）使用 LLVM/Clang 編譯需要
emerge --ask llvm-core/llvm \
    llvm-core/clang llvm-core/lld
```

### 16.2 查看系統資訊（硬體检测）

在配置核心前，了解你的硬體非常重要：

**查看 CPU 資訊**：
```bash
lscpu  # 查看 CPU 型号、核心数、架構等
cat /proc/cpuinfo | grep "model name" | head -1  # CPU 型号
```

**查看 PCI 裝置（顯示卡、網卡等）**：
```bash
lspci -k  # 列出所有 PCI 裝置及当前使用的驅動
lspci | grep -i vga  # 查看顯示卡
lspci | grep -i network  # 查看網卡
```

**查看 USB 裝置**：
```bash
lsusb  # 列出所有 USB 裝置
```

**查看已加载的核心模組**：
```bash
lsmod  # 列出当前加载的所有模組
lsmod | wc -l  # 模組数量
```

### 16.3 根据当前模組自動配置核心

如果你想保留当前系統（如 LiveCD）所有正常工作的硬體支援：

```bash
cd /usr/src/linux

# 方法 1：基于当前加载的模組建立最小化配置
make localmodconfig
# 这会只启用当前加载模組对应的核心选项（强烈推薦！）

# 方法 2：基于当前运行核心的配置建立
zcat /proc/config.gz > .config  # 如果当前核心支援
make olddefconfig  # 使用預設值更新配置
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

`localmodconfig` 是最安全的方法，它会确保你的硬體都能正常工作，同时移除不需要的驅動。

</div>

### 16.4 手動配置核心选项

**进入配置介面**：
```bash
cd /usr/src/linux
make menuconfig  # 文本介面（推薦）
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

| 英文选项 | 中文说明 | 關鍵配置 |
| :--- | :--- | :--- |
| **General setup** | 通用設定 | 本機主机名、Systemd/OpenRC 支援 |
| **Processor type and features** | 处理器類別型与特性 | CPU 型号选择、微码加载 |
| **Power management and ACPI options** | 電源管理与 ACPI | 筆記型電腦電源管理、挂起/休眠 |
| **Bus options (PCI etc.)** | 总线选项 | PCI 支援 (lspci) |
| **Virtualization** | 虛擬化 | KVM, VirtualBox 宿主/客户机支援 |
| **Enable loadable module support** | 可加载模組支援 | 允许使用核心模組 (*.ko) |
| **Networking support** | 網路支援 | TCP/IP 協議栈、防火墙 (Netfilter) |
| **Device Drivers** | 裝置驅動 | 顯示卡、網卡、音效卡、USB、NVMe 驅動 |
| **File systems** | 檔案系統 | ext4, btrfs, vfat, ntfs 支援 |
| **Security options** | 安全選项 | SELinux, AppArmor |
| **Gentoo Linux** | Gentoo 特有选项 | Portage 依賴项自動选择 (推薦) |

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**重要建議**

对于手動編譯，建議将**關鍵驅動**（如檔案系統、磁碟控制器、網卡）直接編譯进核心（选择 `[*]` 或 `<*>` 即 `=y`），而不是作为模組（`<M>` 即 `=m`）。这样可以避免 initramfs 缺失模組导致无法啟動的问题。

</div>

**必需启用的选项**（根据你的系統）：

1. **处理器支援**：
   - `General setup → Gentoo Linux support`
   - `Processor type and features → Processor family` (选择你的 CPU)

2. **檔案系統**：
   - `File systems → The Extended 4 (ext4) filesystem` (如果使用 ext4)
   - `File systems → Btrfs filesystem` (如果使用 Btrfs)

3. **裝置驅動**：
   - `Device Drivers → Network device support` (網卡驅動)
   - `Device Drivers → Graphics support` (顯示卡驅動)

4. **Systemd 使用者必需**：
   - `General setup → Control Group support`
   - `General setup → Namespaces support`

5. **Gentoo Linux 专有选项**（推薦全部启用）：
   
   进入 `Gentoo Linux --->` 選單：
   
   ```
   [*] Gentoo Linux support
       启用 Gentoo 特定的核心功能支援
   
   [*] Linux dynamic and persistent device naming (userspace devfs) support
       启用 udev 动态裝置管理支援（必需）
   
   [*] Select options required by Portage features
       自動启用 Portage 需要的核心选项（强烈推薦）
       这会自動配置必需的檔案系統和核心功能
   
   Support for init systems, system and service managers --->
       ├─ [*] OpenRC support  # 如果使用 OpenRC
       └─ [*] systemd support # 如果使用 systemd
   
   [*] Kernel Self Protection Project
       启用核心自我保护机制（提高安全性）
   
   [*] Print firmware information that the kernel attempts to load
       在啟動时顯示韌體加载資訊（便于除錯）
   ```

 <div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

启用 "Select options required by Portage features" 可以自動配置大部分必需选项，非常推薦！

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

在 menuconfig 中，按 `/` 可以搜尋选项，按 `?` 查看幫助。

</div>

### 16.5 自動启用推薦选项

Gentoo 提供了自動化腳本来启用常见硬體和功能：

```bash
cd /usr/src/linux

# 使用 Genkernel 的預設配置（包含大多数硬體支援）
genkernel --kernel-config=/usr/share/genkernel/arch/x86_64/kernel-config all

# 或者使用发行版預設配置作为基础
make defconfig  # 核心預設配置
# 然后再根据需要调整
make menuconfig
```

### 16.6 使用 LLVM/Clang 編譯核心

使用 LLVM/Clang 編譯核心可以获得更好的優化和更快的編譯速度（支援 ThinLTO）。

**方法 1：指定編譯器**（一次性）：
```bash
cd /usr/src/linux

# 使用 Clang 編譯
make LLVM=1 -j$(nproc)

# 使用 Clang + LTO（推薦）
make LLVM=1 LLVM_IAS=1 -j$(nproc)
```

**方法 2：設定環境變數**（永久）：
在 `/etc/portage/make.conf` 中新增（仅影响核心編譯）：
```bash
# 使用 LLVM/Clang 編譯核心
KERNEL_CC="clang"
KERNEL_LD="ld.lld"
```

**启用核心 LTO 支援**：
在 `make menuconfig` 中：
```
General setup
  → Compiler optimization level → Optimize for performance  # 选择 -O2（推薦）
  → Link Time Optimization (LTO) → Clang ThinLTO (NEW)      # 启用 ThinLTO（强烈推薦）
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要警告：核心編譯时强烈不建議使用 Full LTO！**

*   Full LTO 会导致編譯极其缓慢（可能需要数小时）
*   占用大量記憶體（可能需要 16GB+ RAM）
*   容易导致連結錯誤
*   **请务必使用 ThinLTO**，它更快、更穩定、記憶體占用更少

</div>

### 16.7 核心編譯选项優化

<details>
<summary><b>高级編譯優化（点击展开）</b></summary>

**在 `menuconfig` 中启用**：

```
General setup
  → Compiler optimization level
     → [*] Optimize for performance (-O2)  # 或 -O3，但可能不穩定

  → Link Time Optimization (LTO)
     → [*] Clang ThinLTO                   # 需要 LLVM=1

Kernel hacking
  → Compile-time checks and compiler options
     → [*] Optimize harder
```

**核心壓縮方式**（影响啟動速度和体积）：

```
General setup
  → Kernel compression mode
     → [*] ZSTD  # 推薦：壓縮率高且解壓快
     # 其他选项：LZ4（最快）、XZ（最小）、GZIP（相容性最好）
```

</details>

### 16.8 編譯和安裝核心

**手動編譯**：
```bash
cd /usr/src/linux

# 編譯核心和模組
make -j$(nproc)         # 使用所有 CPU 核心
make modules_install    # 安裝模組到 /lib/modules/
make install            # 安裝核心到 /boot/

# （可選）使用 LLVM/Clang + LTO
make LLVM=1 -j$(nproc)
make LLVM=1 modules_install
make LLVM=1 install
```

**使用 Genkernel 自動化**：
```bash
# 基本用法
genkernel --install all

# 使用 LLVM/Clang
genkernel --kernel-cc=clang --utils-cc=clang --install all

# 启用 LTO（需要手動配置 .config）
genkernel --kernel-make-opts="LLVM=1" --install all
```

### 16.9 核心統計与分析

編譯完成后，使用以下腳本查看核心統計資訊：

```bash
cd /usr/src/linux

echo "=== 核心統計 ==="
echo "Built-in: $(grep -c '=y$' .config)"
echo "模組: $(grep -c '=m$' .config)"
echo "总配置: $(wc -l < .config)"
echo "核心大小: $(ls -lh arch/x86/boot/bzImage 2>/dev/null | awk '{print $5}')"
echo "壓縮方式: $(grep '^CONFIG_KERNEL_' .config | grep '=y' | sed 's/CONFIG_KERNEL_//;s/=y//')"
```

**範例输出**：
```
=== 核心統計 ===
Built-in: 1723
模組: 201
总配置: 6687
核心大小: 11M
壓縮方式: ZSTD
```

**解读**：
- **Built-in (1723)**：編譯进核心本体的功能数量
- **模組 (201)**：作为可加载模組的驅動数量
- **核心大小 (11M)**：最终核心檔案大小（使用 ZSTD 壓縮后）

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**優化建議**

*   核心大小 < 15MB：优秀（精简配置）
*   核心大小 15-30MB：良好（標準配置）
*   核心大小 > 30MB：考虑禁用不需要的功能

</div>

### 16.10 常见问题排查

<details>
<summary><b>編譯錯誤与解决方案（点击展开）</b></summary>

**錯誤 1：缺少依賴**
```
*** No rule to make target 'debian/canonical-certs.pem'
```
解决：禁用签名证书
```bash
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
make olddefconfig
```

**錯誤 2：LTO 編譯失败**
```
ld.lld: error: undefined symbol
```
解决：某些模組不相容 LTO，禁用 LTO 或将问题模組设为 `=y`（而非 `=m`）

**錯誤 3：clang 版本过旧**
```
error: unknown argument: '-mretpoline-external-thunk'
```
解决：升級 LLVM/Clang 或使用 GCC 編譯

</details>

### 16.11 核心配置最佳实践

1. **儲存配置**：
   ```bash
   # 儲存当前配置到外部檔案
   cp .config ~/kernel-config-backup
   
   # 恢復配置
   cp ~/kernel-config-backup /usr/src/linux/.config
   make olddefconfig
   ```

2. **查看配置差异**：
   ```bash
   # 对比两个配置檔案
   scripts/diffconfig .config ../old-kernel/.config
   ```

3. **最小化配置**（仅包含必需功能）：
   ```bash
   make tinyconfig  # 建立极简配置
   make localmodconfig  # 然后新增当前硬體支援
   ```

---

## 17. 伺服器与 RAID 配置 (可選) {#section-17-server-raid}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Wiki: Mdadm](https://wiki.gentoo.org/wiki/Mdadm)

</div>

本节适用于需要配置软 RAID (mdadm) 的伺服器使用者。

### 17.1 核心配置 (手動編譯必选)

如果你手動編譯核心，必須启用以下选项（**注意：必須編譯进核心 `<*>` 即 `=y`，不能是模組 `<M>`**）：

```
Device Drivers  --->
    <*> Multiple devices driver support (RAID and LVM)
        <*> RAID support
            [*] Autodetect RAID arrays during kernel boot

            # 根据你的 RAID 级别选择（必須选 Y）：
            <*> Linear (append) mode                   # 线性模式
            <*> RAID-0 (striping) mode                 # RAID 0
            <*> RAID-1 (mirroring) mode                # RAID 1
            <*> RAID-10 (mirrored striping) mode       # RAID 10
            <*> RAID-4/RAID-5/RAID-6 mode              # RAID 5/6
```

### 17.2 配置 Dracut 加载 RAID 模組 (dist-kernel 必选)

如果你使用 `dist-kernel`（发行版核心）或者将 RAID 驅動編譯为了模組，**必須**透過 Dracut 强制加载 RAID 驅動，否则无法开机。

<details>
<summary><b>Dracut RAID 配置指南（点击展开）</b></summary>

**1. 启用 mdraid 支援**
建立 `/etc/dracut.conf.d/mdraid.conf`：
```bash
# Enable mdraid support for RAID arrays
add_dracutmodules+=" mdraid "
mdadmconf="yes"
```

**2. 强制加载 RAID 驅動**
建立 `/etc/dracut.conf.d/raid-modules.conf`：
```bash
# Ensure RAID modules are included and loaded
add_drivers+=" raid1 raid0 raid10 raid456 "
force_drivers+=" raid1 "
# Install modprobe configuration
install_items+=" /usr/lib/modules-load.d/ /etc/modules-load.d/ "
```

**3. 配置核心指令行參數 (UUID)**
你需要找到 RAID 阵列的 UUID 并新增到核心參數中。
建立 `/etc/dracut.conf.d/mdraid-cmdline.conf`：
```bash
# Kernel command line parameters for RAID arrays
# 请替換为你实际的 RAID UUID (透過 mdadm --detail --scan 查看)
kernel_cmdline="rd.md.uuid=68b53b0a:c6bd2ca0:caed4380:1cd75aeb rd.md.uuid=c8f92d69:59d61271:e8ffa815:063390ed"
```

**4. 重新生成 initramfs**
```bash
dracut --force
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

配置完成后，务必检查 `/boot/initramfs-*.img` 是否包含 RAID 模組：

</div>
> `lsinitrd /boot/initramfs-*.img | grep raid`

</details>

---

## 參考资料 {#reference}

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 官方文件

- **[Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)** 官方最新指南
- [Gentoo Wiki](https://wiki.gentoo.org/)
- [Portage Documentation](https://wiki.gentoo.org/wiki/Portage)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 社群支援

**Gentoo 中文社群**：
- Telegram 群组：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 频道：[@gentoocn](https://t.me/gentoocn)
- [GitHub](https://github.com/gentoo-zh)

**官方社群**：
- [Gentoo Forums](https://forums.gentoo.org/)
- IRC: `#gentoo` @ [Libera.Chat](https://libera.chat/)

</div>

</div>

## 結語

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; text-align: center;">

### 祝你在 Gentoo 上享受自由与灵活！

這份指南基于官方 [Handbook:AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64) 并簡化流程，標記了可選步驟，让更多人能輕鬆嘗試。

</div>
