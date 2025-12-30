---
title: "Gentoo Linux 安裝指南 (進階優化篇)"
date: 2025-11-25
summary: "Gentoo Linux 進階優化教程，涵蓋 make.conf 優化、LTO、Tmpfs、系統維護等。"
description: "2025 年最新 Gentoo Linux 安裝指南 (進階優化篇)，涵蓋 make.conf 優化、LTO、Tmpfs、系統維護等。"
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
  - 教程
  - 系統優化
categories:
  - tutorial
authors:
  - zakkaus
---

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 文章特別說明

本文是 **Gentoo Linux 安裝指南** 系列的第三部分：**進階優化**。

**系列導航**：
1. [基礎安裝](/posts/2025-11-25-gentoo-install-base/)：從零開始安裝 Gentoo 基礎系統
2. [桌面設定](/posts/2025-11-25-gentoo-install-desktop/)：顯示卡驅動程式、桌面環境、輸入法等
3. **進階優化（本文）**：make.conf 優化、LTO、系統維護

**上一步**：[桌面設定](/posts/2025-11-25-gentoo-install-desktop/)

</div>

## 13. make.conf 進階設定指南

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**官方文件**：[make.conf - Gentoo Wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf) · [基礎篇 5.2 節：make.conf 範例](/posts/2025-11-25-gentoo-install-base/#52-makeconf-範例)

</div>

`/etc/portage/make.conf` 是 Gentoo 的核心設定檔，控制著軟體套件的編譯方式、系統功能和優化參數。本章將深入講解各個設定項的含義與最佳實踐。

---

### 13.1 編譯器優化參數

這些參數決定了軟體套件的編譯方式，直接影響系統性能。

#### COMMON_FLAGS：編譯器通用標誌

```bash
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
```

**參數詳解**：

| 參數 | 說明 | 注意事項 |
|------|------|----------|
| `-march=native` | 針對當前 CPU 架構優化 | 編譯的程式可能無法在其他 CPU 上運行 |
| `-O2` | 優化級別 2（推薦） | 平衡性能、穩定性與編譯時間 |
| `-O3` | 激進優化（不推薦） | 可能導致部分軟體編譯失敗或運行異常 |
| `-pipe` | 使用管道傳遞資料 | 加速編譯，略微增加記憶體佔用 |

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**推薦設定**

對於大多數用戶，使用 `-march=native -O2 -pipe` 已經足夠。除非你明確知道自己在做什麼，否則不要使用 `-O3` 或其他激進優化參數。

</div>

#### CPU 指令集優化 (CPU_FLAGS_X86)

CPU 指令集標誌建議使用 `app-portage/cpuid2cpuflags` 自動檢測並寫入 `CPU_FLAGS_X86`。

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**快速上手**：請參考 [基礎篇 5.3 節：CPU 指令集優化](/posts/2025-11-25-gentoo-install-base/#53-設定-cpu-指令集優化)

**完整說明（推薦）**：請參考 [13.13 節：CPU 指令集優化 (CPU_FLAGS_X86)](#1313-cpu-指令集優化-cpu_flags_x86)

</div>

---

### 13.2 平行編譯設定

控制編譯過程的平行化程度，合理設定可大幅加速軟體套件安裝。

#### MAKEOPTS：單個包的平行編譯

```bash
MAKEOPTS="-j<執行緒數> -l<負載限制>"
```

**推薦設定**（根據 CPU 執行緒數和記憶體容量）：

| 硬體設定 | MAKEOPTS | 說明 |
|---------|----------|------|
| 4核8執行緒 + 16GB 記憶體 | `-j8 -l8` | 標準設定 |
| 8核16執行緒 + 32GB 記憶體 | `-j16 -l16` | 主流設定 |
| 16核32執行緒 + 64GB 記憶體 | `-j32 -l32` | 進階設定 |
| 記憶體不足（< 8GB） | `-j<執行緒數/2>` | 減半避免記憶體耗盡 |

**參數說明**：
- `-j<N>`：同時運行的編譯任務數（建議 = CPU 執行緒數）
- `-l<N>`：系統負載上限，超過此值暫停新任務

#### EMERGE_DEFAULT_OPTS：多包平行編譯

```bash
EMERGE_DEFAULT_OPTS="--ask --verbose --jobs=<平行包數> --load-average=<負載>"
```

**推薦設定**：

| CPU 執行緒數 | --jobs 值 | 說明 |
|-----------|----------|------|
| 4-8 執行緒 | 2 | 同時編譯 2 個包 |
| 12-16 執行緒 | 3-4 | 同時編譯 3-4 個包 |
| 24+ 執行緒 | 4-6 | 同時編譯 4-6 個包 |

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意事項**

- `--jobs` 會顯著增加記憶體佔用，記憶體不足時請謹慎使用
- 推薦先使用預設單包編譯，穩定後再激活多包平行
- Chrome、LLVM 等大型軟體套件單獨編譯時已佔用大量記憶體

</div>

---

### 13.3 USE 標誌管理

USE 標誌控制軟體功能的開關，是 Gentoo 定製化的核心。

#### 全局 USE 標誌

```bash
USE="systemd dbus policykit networkmanager bluetooth"
USE="${USE} wayland X gtk qt6"
USE="${USE} pipewire pulseaudio alsa"
USE="${USE} -doc -test -examples"
```

**分類說明**：

<details>
<summary><b>系統與初始化（點擊展開）</b></summary>

| USE 標誌 | 說明 | 推薦 |
|---------|------|------|
| `systemd` | 使用 systemd init 系統 | 新手推薦 |
| `openrc` | 使用 OpenRC init 系統 | 傳統用戶 |
| `udev` | 現代設備管理 | 必需 |
| `dbus` | 行程間通信（桌面必需） | 桌面必需 |
| `policykit` | 權限管理（桌面必需） | 桌面必需 |

</details>

<details>
<summary><b>桌面環境與顯示（點擊展開）</b></summary>

| USE 標誌 | 說明 | 推薦 |
|---------|------|------|
| `wayland` | Wayland 顯示協定 | 現代桌面推薦 |
| `X` | X11 顯示協定 | 兼容性好 |
| `gtk` | GTK+ 工具包（GNOME/Xfce） | GNOME 用戶 |
| `qt6` / `qt5` | Qt 工具包（KDE Plasma） | KDE 用戶 |
| `kde` | KDE 集成 | KDE 用戶 |
| `gnome` | GNOME 集成 | GNOME 用戶 |

</details>

<details>
<summary><b>多媒體與音訊（點擊展開）</b></summary>

| USE 標誌 | 說明 | 推薦 |
|---------|------|------|
| `pipewire` | 現代音訊/影片伺服器 | 現代桌面推薦 |
| `pulseaudio` | PulseAudio 音訊伺服器 | 傳統桌面 |
| `alsa` | ALSA 音訊支援 | 底層必需 |
| `ffmpeg` | FFmpeg 編解碼支援 | 推薦 |
| `x264` / `x265` | H.264/H.265 影片編碼 | 影片處理 |
| `vaapi` / `vdpau` | 硬體影片加速 | 有顯示卡推薦 |

</details>

<details>
<summary><b>網路與連接（點擊展開）</b></summary>

| USE 標誌 | 說明 | 推薦 |
|---------|------|------|
| `networkmanager` | 圖形化網路管理 | 桌面用戶推薦 |
| `bluetooth` | 藍牙支援 | 需要時激活 |
| `wifi` | 無線網路支援 | 筆記型電腦必需 |

</details>

<details>
<summary><b>國際化與文件（點擊展開）</b></summary>

| USE 標誌 | 說明 | 推薦 |
|---------|------|------|
| `cjk` | 中日韓字體與輸入法支援 | 中文用戶必需 |
| `nls` | 本機化支援（軟體翻譯） | 推薦 |
| `icu` | Unicode 支援 | 推薦 |
| `-doc` | 禁用文件安裝 | 節省空間 |
| `-test` | 禁用測試套件 | 加速編譯 |
| `-examples` | 禁用示例文件 | 節省空間 |

</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**USE 標誌策略建議**

1. **最小化原則**：只激活你需要的功能，禁用不需要的（使用 `-` 前綴）
2. **分類管理**：用 `USE="${USE} ......"` 分類添加，便於維護
3. **單包覆蓋**：特定軟體套件的 USE 標誌放在 `/etc/portage/package.use/` 中

</div>

---

### 13.4 語言與本機化

```bash
# 軟體翻譯與文件支援
L10N="en en-US zh zh-CN zh-TW"

# 舊式本機化變量（部分軟體仍需要）
LINGUAS="en en_US zh zh_CN zh_TW"

# 保持編譯輸出為英文（便於搜索錯誤資訊）
LC_MESSAGES=C
```

---

### 13.5 許可證管理 (ACCEPT_LICENSE)

控制系統可以安裝哪些許可證的軟體。

#### 常見設定方式

```bash
# 方式 1：接受所有許可證（新手推薦）
ACCEPT_LICENSE="*"

# 方式 2：僅自由軟體
ACCEPT_LICENSE="@FREE"

# 方式 3：自由軟體 + 可再分發的二進位
ACCEPT_LICENSE="@FREE @BINARY-REDISTRIBUTABLE"

# 方式 4：嚴格控制（拒絕所有，再顯式允許）
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"
```

#### 許可證組說明

| 許可證組 | 說明 |
|---------|------|
| `@FREE` | 所有自由軟體（OSI/FSF 認證） |
| `@BINARY-REDISTRIBUTABLE` | 允許再分發的二進位軟體 |
| `@GPL-COMPATIBLE` | GPL 兼容許可證 |

#### 單包許可證設定（推薦方式）

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

### 13.6 Portage 功能增強 (FEATURES)

```bash
FEATURES="parallel-fetch candy"
```

**常用 FEATURES**：

| 功能 | 說明 | 推薦 |
|-----|------|------|
| `parallel-fetch` | 平行下載源碼包 | 推薦 |
| `candy` | 美化 emerge 輸出（彩色進度條） | 推薦 |
| `ccache` | 編譯緩存（需安裝 `dev-build/ccache`） | 頻繁重編譯時推薦 |
| `parallel-install` | 平行安裝（實驗性） | 不推薦 |
| `splitdebug` | 分離調試資訊 | 調試時使用 |

---

### 13.7 鏡像站設定 (GENTOO_MIRRORS)

```bash
# 更多鏡像請參考：https://www.gentoo.org.cn/mirrorlist/
# 建議根據地理位置選擇（任選其一或多個，空格分隔）

# 臺灣鏡像（推薦）
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# 或使用其他鏡像：
# 中國大陸：
#   GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/"            # 中國科學技術大學
#   GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo/"   # 清華大學
#   GENTOO_MIRRORS="https://mirrors.zju.edu.cn/gentoo/"             # 浙江大學
# 香港：
#   GENTOO_MIRRORS="https://hk.mirrors.cicku.me/gentoo/"            # CICKU
# 臺灣：
#   GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"            # NCHC
#   GENTOO_MIRRORS="https://tw.mirrors.cicku.me/gentoo/"            # CICKU
# 新加坡：
#   GENTOO_MIRRORS="https://mirror.freedif.org/gentoo/"             # Freedif
#   GENTOO_MIRRORS="https://sg.mirrors.cicku.me/gentoo/"            # CICKU
```

---

### 13.8 編譯日誌設定

```bash
# 記錄哪些級別的日誌
PORTAGE_ELOG_CLASSES="warn error log qa"

# 日誌保存方式
PORTAGE_ELOG_SYSTEM="save"  # 保存到 /var/log/portage/elog/
```

**日誌級別說明**：
- `warn`：警告資訊（設定問題）
- `error`：錯誤資訊（編譯失敗）
- `log`：普通日誌
- `qa`：質量保證警告（安全問題）

---

### 13.9 顯示卡與輸入設備

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**重要提示**

`VIDEO_CARDS` 和 `INPUT_DEVICES` **不建議**在 make.conf 中全局設定。

推薦使用 `/etc/portage/package.use/` 方式針對特定軟體套件設定，詳見 [桌面設定篇 12.1 節](/posts/2025-11-25-gentoo-install-desktop/#121-全局設定)。

</div>

---

### 13.10 完整設定示例

<details>
<summary><b>新手推薦設定（點擊展開）</b></summary>

```bash
# /etc/portage/make.conf
# vim: set filetype=bash

# ========== 編譯器優化 ==========
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# ========== 平行編譯 ==========
MAKEOPTS="-j8"  # 根據 CPU 執行緒數調整

# ========== USE 標誌 ==========
USE="systemd dbus policykit networkmanager bluetooth"
USE="${USE} wayland pipewire"
USE="${USE} -doc -test"

# ========== 語言與本機化 ==========
L10N="en zh zh-CN"
LINGUAS="en zh_CN"
LC_MESSAGES=C

# ========== 鏡像站 ==========
# 建議根據地理位置選擇（擇一或多個，空格分隔）：
# GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/"  # 中國科學技術大學
# GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo/"  # 清華大學
# GENTOO_MIRRORS="https://hk.mirrors.cicku.me/gentoo/"  # 香港 CICKU
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"  # NCHC（推薦）
# GENTOO_MIRRORS="https://tw.mirrors.cicku.me/gentoo/"  # 臺灣 CICKU
# GENTOO_MIRRORS="https://mirror.freedif.org/gentoo/"  # 新加坡 Freedif
# GENTOO_MIRRORS="https://sg.mirrors.cicku.me/gentoo/"  # 新加坡 CICKU
# 更多鏡像請參考：https://www.gentoo.org/downloads/mirrors/

# ========== Portage 設定 ==========
FEATURES="parallel-fetch candy"
EMERGE_DEFAULT_OPTS="--ask --verbose"

# ========== 許可證 ==========
ACCEPT_LICENSE="*"

# ========== 編譯日誌 ==========
PORTAGE_ELOG_CLASSES="warn error log"
PORTAGE_ELOG_SYSTEM="save"
```

</details>

<details>
<summary><b>高性能設定（點擊展開）</b></summary>

```bash
# /etc/portage/make.conf
# vim: set filetype=bash

# ========== 編譯器優化 ==========
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# ========== 平行編譯（進階硬體） ==========
MAKEOPTS="-j32 -l32"
EMERGE_DEFAULT_OPTS="--ask --verbose --jobs=4 --load-average=32"

# ========== USE 標誌（完整桌面） ==========
USE="systemd udev dbus policykit"
USE="${USE} networkmanager bluetooth wifi"
USE="${USE} wayland X gtk qt6 kde"
USE="${USE} pipewire pulseaudio alsa"
USE="${USE} ffmpeg x264 x265 vaapi vulkan"
USE="${USE} cjk nls icu"
USE="${USE} -doc -test -examples"

# ========== 語言與本機化 ==========
L10N="en en-US zh zh-CN zh-TW"
LINGUAS="en en_US zh zh_CN zh_TW"
LC_MESSAGES=C

# ========== 鏡像站 ==========
# 建議根據地理位置選擇（擇一或多個，空格分隔）：
# GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/"  # 中國科學技術大學
# GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo/"  # 清華大學
# GENTOO_MIRRORS="https://hk.mirrors.cicku.me/gentoo/"  # 香港 CICKU
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"  # NCHC（推薦）
# GENTOO_MIRRORS="https://tw.mirrors.cicku.me/gentoo/"  # 臺灣 CICKU
# GENTOO_MIRRORS="https://mirror.freedif.org/gentoo/"  # 新加坡 Freedif
# GENTOO_MIRRORS="https://sg.mirrors.cicku.me/gentoo/"  # 新加坡 CICKU
# 更多鏡像請參考：https://www.gentoo.org/downloads/mirrors/

# ========== Portage 設定 ==========
FEATURES="parallel-fetch candy ccache"
CCACHE_DIR="/var/cache/ccache"

# ========== 許可證 ==========
ACCEPT_LICENSE="*"

# ========== 編譯日誌 ==========
PORTAGE_ELOG_CLASSES="warn error log qa"
PORTAGE_ELOG_SYSTEM="save"
```

</details>

---

### 13.11 詳細設定範例（完整註釋版）

<details>
<summary><b>詳細設定範例（建議閱讀並調整）（點擊展開）</b></summary>

```conf
# vim: set filetype=bash  # 告訴 Vim 使用 bash 語法高亮

# ========== 系統架構（勿手動修改） ==========
# 由 Stage3 缺省，表示目標系統架構（通常無需修改）
CHOST="x86_64-pc-linux-gnu"

# ========== 編譯優化參數 ==========
# -march=native    針對當前 CPU 架構優化，性能最佳
#                  注意：編譯出的程式可能無法在其他 CPU 上運行
# -O2              推薦的優化級別（平衡性能、穩定性、編譯時間）
#                  注意：避免使用 -O3，可能導致軟體編譯失敗或運行異常
# -pipe            使用管道代替臨時文件，加速編譯過程
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"      # C 語言編譯器選項
CXXFLAGS="${COMMON_FLAGS}"    # C++ 語言編譯器選項
FCFLAGS="${COMMON_FLAGS}"     # Fortran 編譯器選項
FFLAGS="${COMMON_FLAGS}"      # Fortran 77 編譯器選項

# CPU 指令集優化（自動生成，見下文 13.13 節）
# 運行: emerge --ask app-portage/cpuid2cpuflags && cpuid2cpuflags >> /etc/portage/make.conf
# CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"

# ========== 平行編譯設定 ==========
# MAKEOPTS: 控制 make 的平行任務數
#   -j<N>   同時運行的編譯任務數，推薦值 = CPU 執行緒數（運行 nproc 查看）
#   -l<N>   系統負載限制，防止系統重載（可選，一般與 -j 值相同）
MAKEOPTS="-j8"  # 示例：8 執行緒 CPU

# 記憶體不足時的調整建議：
#    16GB 記憶體 + 8 核 CPU → MAKEOPTS="-j4 -l8"  (減半平行數)
#    32GB 記憶體 + 16 核 CPU → MAKEOPTS="-j16 -l16"

# ========== 語言與本機化設定 ==========
# LC_MESSAGES: 保持編譯輸出為英文，便於搜索錯誤資訊和社區求助
LC_MESSAGES=C

# L10N: 本機化語言支援（影響軟體翻譯、幫助文件、拼寫檢查等）
L10N="en en-US zh zh-CN zh-TW"

# LINGUAS: 舊式本機化變量（部分軟體仍依賴此變量）
LINGUAS="en en_US zh zh_CN zh_TW"

# ========== 鏡像站設定 ==========
# 更多鏡像請參考：https://www.gentoo.org.cn/mirrorlist/
# 台灣常用鏡像（任選其一）：
#   USTC (中國科學技術大學): https://mirrors.ustc.edu.cn/gentoo/
#   TUNA (清華大學): https://mirrors.tuna.tsinghua.edu.cn/gentoo/
#   ZJU (浙江大學): https://mirrors.zju.edu.cn/gentoo/
# 香港/臺灣/新加坡鏡像：
#   CICKU (香港): https://hk.mirrors.cicku.me/gentoo/
#   NCHC (臺灣): http://ftp.twaren.net/Linux/Gentoo/
#   Freedif (新加坡): https://mirror.freedif.org/gentoo/
GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"

# ========== Emerge 預設選項 ==========
# --ask              運行前詢問確認（推薦保留，防止誤操作）
# --verbose          顯示詳細資訊（USE 標誌變化、依賴關係等）
# --with-bdeps=y     更新時也檢查構建時依賴（避免依賴過時）
# --complete-graph=y 完整的依賴圖分析（解決複雜依賴衝突）
EMERGE_DEFAULT_OPTS="--ask --verbose --with-bdeps=y --complete-graph=y"

# 高級用戶可選設定（需要充足記憶體）：
#    --jobs=N           平行編譯多個軟體套件（記憶體充足時建議 2-4）
#    --load-average=N   系統負載上限（建議與 CPU 核心數相同）
# EMERGE_DEFAULT_OPTS="--ask --verbose --jobs=2 --load-average=8"

# ========== USE 標誌（全局功能開關） ==========
# 控制所有軟體套件的編譯選項，影響功能可用性和依賴關係
#
# 系統基礎：
#   systemd        使用 systemd init 系統（若用 OpenRC 改為 -systemd）
#   udev           現代設備管理（推薦保留）
#   dbus           行程間通信（桌面環境必需）
#   policykit      權限管理（桌面環境必需）
#
# 網路與硬體：
#   networkmanager 圖形化網路管理（桌面用戶推薦）
#   bluetooth      藍牙支援
#
# 開發工具：
#   git            Git 版本控制（開發者必備）
#
# 核心選擇：
#   dist-kernel    使用發行版預設定核心（新手強烈推薦）
#                  不使用此標誌則需手動設定核心（見第 7 章）
#
USE="systemd udev dbus policykit networkmanager bluetooth git dist-kernel"

# 常用的可選 USE 標誌：
#   音訊：pulseaudio / pipewire（音訊伺服器，二選一）
#   顯示：wayland / X（顯示協定，桌面環境需要）
#   圖形：vulkan, opengl（現代圖形 API）
#   影片：vaapi, vdpau（硬體影片加速）
#   打印：cups（打印系統）
#   容器：flatpak, appimage（第三方應用支援）
#   禁用：-doc, -test, -examples（節省編譯時間和磁盤空間）

# ========== 許可證設定 ==========
# ACCEPT_LICENSE: 控制可安裝軟體的許可證類型
#
# 常見設定：
#   "*"                接受所有許可證（新手推薦，避免許可證問題阻止安裝）
#   "@FREE"            僅接受自由軟體（嚴格的開源政策）
#   "@BINARY-REDISTRIBUTABLE"  允許自由再分發的二進位軟體
#   "-* @FREE"         拒絕所有後顯式允許（最嚴格控制）
#
# 推薦策略：
#   - 新手/桌面用戶：使用 "*" 避免許可證問題
#   - 開源軟體堅持者：使用 "@FREE"，需要閉源軟體時單獨設定
#   - 詳細說明見下方「13.12 ACCEPT_LICENSE 詳解」
ACCEPT_LICENSE="*"

# 針對特定軟體套件的許可證設定（推薦方式）：
#    創建 /etc/portage/package.license/ 目錄並添加設定檔
#    示例見下方「13.12 ACCEPT_LICENSE 詳解」

# ========== Portage 功能設定（可選） ==========
# FEATURES: 激活 Portage 的高級功能
#   parallel-fetch    平行下載源碼包（加速更新）
#   parallel-install  平行安裝多個包（實驗性，可能不穩定）
#   candy             美化 emerge 輸出（彩色進度條）
#   ccache            編譯緩存（需安裝 dev-build/ccache，加速重複編譯）
#   splitdebug        分離調試資訊到獨立文件（節省空間，便於調試）
# FEATURES="parallel-fetch candy"

# ========== 編譯日誌設定（推薦激活） ==========
# PORTAGE_ELOG_CLASSES: 要記錄的日誌級別
#   info     一般資訊（安裝成功消息等）
#   warn     警告資訊（設定問題、不推薦的操作）
#   error    錯誤資訊（編譯失敗、依賴問題）
#   log      普通日誌（所有輸出）
#   qa       質量保證警告（ebuild 問題、安全警告）
PORTAGE_ELOG_CLASSES="warn error log qa"

# PORTAGE_ELOG_SYSTEM: 日誌輸出方式
#   save          保存到 /var/log/portage/elog/（推薦，便於事後查看）
#   echo          編譯後直接顯示在終端機
#   mail          通過郵件發送（需設定郵件系統）
#   syslog        發送到系統日誌
#   custom        自定義處理腳本
PORTAGE_ELOG_SYSTEM="save"

# 注意：文件末尾必須保留空行（POSIX 標準要求）
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**設定說明**

這是一個帶有詳細註釋的完整 `make.conf` 範例。實際使用時：
1. **必須調整**：`MAKEOPTS`（根據你的 CPU 執行緒數）、`GENTOO_MIRRORS`（選擇就近鏡像）
2. **建議調整**：`USE` 標誌（根據需要的桌面環境和功能）
3. **可選設定**：`FEATURES`、日誌設定等（按需激活）
4. **VIDEO_CARDS / INPUT_DEVICES** 已移至 [桌面設定篇](/posts/2025-11-25-gentoo-install-desktop/)

</div>

</details>

---

### 13.12 ACCEPT_LICENSE 軟體許可證詳解

<details>
<summary><b>ACCEPT_LICENSE 軟體許可證管理（點擊展開）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**參考文件**：[Gentoo Handbook: ACCEPT_LICENSE](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Configure_the_ACCEPT_LICENSE_variable) · [GLEP 23](https://www.gentoo.org/glep/glep-0023.html) · [License Groups](https://gitweb.gentoo.org/proj/portage.git/tree/cnf/license_groups)

</div>

#### 什麼是 ACCEPT_LICENSE？

根據 [GLEP 23](https://www.gentoo.org/glep/glep-0023.html)（Gentoo Linux Enhancement Proposal 23），Gentoo 提供了一個機制，允許系統管理員"控制他們安裝的軟體的許可證類型"。`ACCEPT_LICENSE` 變量決定了 Portage 可以安裝哪些許可證的軟體。

**為什麼需要這個？**
- Gentoo 軟體倉庫包含數千個軟體套件，涉及數百種不同的軟體許可證
- 你可能只想使用自由軟體（OSI 認證）或需要接受某些閉源許可證
- 無需逐一審批每個許可證 —— GLEP 23 引入了**許可證組 (License Groups)** 概念

#### 常用許可證組

許可證組使用 `@` 符號前綴，便於與單個許可證區分：

| 許可證組 | 說明 |
|---------|------|
| `@GPL-COMPATIBLE` | FSF 認可的 GPL 兼容許可證 [[1]](https://www.gnu.org/licenses/license-list.html) |
| `@FSF-APPROVED` | FSF 認可的自由軟體許可證（包含 `@GPL-COMPATIBLE`）|
| `@OSI-APPROVED` | OSI（Open Source Initiative）認可的開源許可證 [[2]](https://www.opensource.org/licenses) |
| `@MISC-FREE` | 其他可能符合自由軟體定義的許可證（未經 FSF/OSI 認證）[[3]](https://www.gnu.org/philosophy/free-sw.html) |
| `@FREE-SOFTWARE` | 合併 `@FSF-APPROVED` + `@OSI-APPROVED` + `@MISC-FREE` |
| `@FSF-APPROVED-OTHER` | FSF 認可的"自由文件"和"實用作品"許可證（包括字體）|
| `@MISC-FREE-DOCS` | 其他自由文件許可證（未列入 `@FSF-APPROVED-OTHER`）[[4]](https://freedomdefined.org/) |
| `@FREE-DOCUMENTS` | 合併 `@FSF-APPROVED-OTHER` + `@MISC-FREE-DOCS` |
| `@FREE` | **所有自由軟體和文件**（合併 `@FREE-SOFTWARE` + `@FREE-DOCUMENTS`）|
| `@BINARY-REDISTRIBUTABLE` | 至少允許自由再分發二進位檔案的許可證（包含 `@FREE`）|
| `@EULA` | 試圖剝奪用戶權利的許可協定（比"保留所有權利"更嚴格）|

#### 查看當前系統設定

```bash
portageq envvar ACCEPT_LICENSE
```

輸出示例（預設值）：
```
@FREE
```

這表示系統預設只允許安裝 `@FREE` 組的軟體（自由軟體）。

#### 設定 ACCEPT_LICENSE

可以在以下位置設定：

**1. 系統全局設定（`/etc/portage/make.conf`）**
覆蓋 profile 的預設值：

```conf
# 接受所有許可證（包括閉源軟體）
ACCEPT_LICENSE="*"

# 或：僅接受自由軟體 + 可自由再分發的二進位檔案
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"

# 或：僅自由軟體（預設值）
ACCEPT_LICENSE="@FREE"
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**推薦做法**

- **新手/桌面用戶**：使用 `ACCEPT_LICENSE="*"` 避免許可證問題導致軟體安裝失敗
- **純自由軟體用戶**：使用 `ACCEPT_LICENSE="@FREE"`，需要閉源軟體時單獨為包設定
- 前綴 `-*` 表示先拒絕所有，再顯式允許指定組（更嚴格的控制）

</div>

**2. 針對單個包設定（`/etc/portage/package.license`）**

某些軟體套件可能需要特定許可證（例如韌體、顯示卡驅動程式）：

```bash
# 創建目錄（如果不存在）
mkdir -p /etc/portage/package.license
```

編輯 `/etc/portage/package.license/kernel`：
```conf
# unrar 壓縮工具
app-arch/unrar unRAR

# Linux 韌體（包含非自由韌體）
sys-kernel/linux-firmware linux-fw-redistributable

# Intel 微碼
sys-firmware/intel-microcode intel-ucode
```

#### LICENSE 變量的免責聲明

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要提示**

ebuild 中的 `LICENSE` 變量僅是開發者和用戶的**參考指南**，不是法律聲明，也不保證 100% 準確。請勿僅依賴 ebuild 的許可證標識，建議深入檢查軟體套件本身及其安裝的所有文件。

參考：[Gentoo Handbook: ACCEPT_LICENSE](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Configure_the_ACCEPT_LICENSE_variable)

</div>

#### 實際應用建議

在本指南的 `make.conf` 範例中，我們使用了 `ACCEPT_LICENSE="*"`（接受所有許可證）。如果你希望嚴格控制：

1. 先將 `make.conf` 中的設定改為 `ACCEPT_LICENSE="@FREE"`
2. 安裝軟體時，如果遇到許可證阻止，Portage 會提示需要哪個許可證
3. 根據需要，在 `/etc/portage/package.license/` 中為特定軟體套件添加例外

示例（安裝閉源 NVIDIA 驅動時的提示）：
```
The following license changes are necessary to proceed:
 x11-drivers/nvidia-drivers NVIDIA-r2
```

解決方式：
```bash
echo "x11-drivers/nvidia-drivers NVIDIA-r2" >> /etc/portage/package.license/nvidia
```

</details>

---

### 13.13 CPU 指令集優化 (CPU_FLAGS_X86)

<details>
<summary><b>CPU 指令集優化 (CPU_FLAGS_X86)（點擊展開）</b></summary>

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn)

</div>

`CPU_FLAGS_X86` 是 Gentoo 用來描述“你的 CPU 實際支援哪些 x86 指令集”的變量。部分軟體套件會依據它來開啟（或關閉）對應的優化，例如 AES、AVX、SSE4.2 等。

這裡刻意不再重複“如何生成並寫入 `CPU_FLAGS_X86`”的操作步驟（基礎篇已經給了最短可用流程）：

- **快速設定步驟**：請直接按照基礎篇 [5.3 設定 CPU 指令集優化](/posts/2025-11-25-gentoo-install-base/#53-設定-cpu-指令集優化) 完成。

完成後，你通常會在 `/etc/portage/make.conf` 看到像這樣的一行：
```conf
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"
```

#### 注意事項

1. **避免重複追加**：`cpuid2cpuflags >> /etc/portage/make.conf` 會“追加”到文件末尾。如果你重複執行多次，可能出現多行 `CPU_FLAGS_X86=...`。建議保留最後一行（或你想用的那一行），把其餘重複行刪掉，避免日後自己看不懂。
2. **跨機器可攜性**：如果你會把同一份設定同步到不同主機（或機器會更換 CPU），`CPU_FLAGS_X86` 最好不要“直接複製”。建議在每臺機器上各自跑一次檢測工具，讓結果匹配該主機。
3. **不是所有架構都用它**：`CPU_FLAGS_X86` 顧名思義只適用於 x86（amd64/x86）。
   - 如果你裝的是 **ARM64（arm64）/ ARM（arm）/ RISC-V** 等架構：通常**不要設定** `CPU_FLAGS_X86`。
   - 請改為查閱 Gentoo Wiki 的 [CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn) 頁面，按你的架構使用對應的 `CPU_FLAGS_…` 變量與檢測方式（不同架構用的變量名與工具可能不同，用 x86 的 `cpuid2cpuflags` 不一定適用）。

#### 說明：我改了之後，哪些軟體套件會受影響？

一般來說，這類變更會影響到需要基於 CPU 指令集做條件編譯的軟體套件；要讓改動生效，通常需要重新編譯受影響的軟體套件（或跑一次 world 更新讓 Portage 自行判斷）。具體策略與細節會依你當前的 USE/FEATURES 與軟體套件版本而異。

</details>

---

### 13.14 延伸閱讀

- [Gentoo Wiki: make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)
- [Gentoo Wiki: ACCEPT_LICENSE](https://wiki.gentoo.org/wiki/ACCEPT_LICENSE)
- [Gentoo Wiki: USE flag](https://wiki.gentoo.org/wiki/USE_flag)
- [桌面設定篇 12.1 節：VIDEO_CARDS 設定](/posts/2025-11-25-gentoo-install-desktop/#121-全局設定)
- [GLEP 23: License Groups](https://www.gentoo.org/glep/glep-0023.html)

---

## 14. 進階編譯優化 [可選]

為了提升後續的編譯速度，建議設定 tmpfs 和 ccache。

### 14.1 設定 tmpfs (記憶體編譯)

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Tmpfs](https://wiki.gentoo.org/wiki/Tmpfs)

</div>

將編譯臨時目錄掛載到記憶體，減少 SSD 磨損並加速編譯。

<details>
<summary><b>Tmpfs 設定指南（點擊展開）</b></summary>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

`size` 大小不要超過你的物理記憶體大小（建議設為記憶體的一半），否則可能導致系統不穩定。

</div>

編輯 `/etc/fstab`，添加以下行（size 建議設定為記憶體的一半，例如 16G）：
```fstab
tmpfs   /var/tmp/portage   tmpfs   size=16G,uid=portage,gid=portage,mode=775,noatime   0 0
```
掛載目錄：
```bash
mount /var/tmp/portage
```
</details>

### 14.2 設定 ccache (編譯緩存)

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Ccache](https://wiki.gentoo.org/wiki/Ccache)

</div>

緩存編譯中間產物，加快重新編譯速度。
```bash
emerge --ask dev-build/ccache
ccache -M 20G  # 設定緩存大小為 20GB
```

### 14.3 處理大型軟體編譯 (避免 tmpfs 爆滿)

Firefox、LibreOffice 等大型軟體編譯時可能會耗盡 tmpfs 空間。我們可以設定 Portage 讓這些特定軟體使用硬碟進行編譯。

<details>
<summary><b>Notmpfs 設定指南（點擊展開）</b></summary>

1. 創建設定目錄：
   ```bash
   mkdir -p /etc/portage/env
   mkdir -p /var/tmp/notmpfs
   ```

2. 創建 `notmpfs.conf`：
   ```bash
   echo 'PORTAGE_TMPDIR="/var/tmp/notmpfs"' > /etc/portage/env/notmpfs.conf
   ```

3. 針對特定軟體應用設定：
   編輯 `/etc/portage/package.env` (如果是目錄則創建文件)：
   ```bash
   vim /etc/portage/package.env
   ```
   寫入：
   ```conf
   www-client/chromium notmpfs.conf
   app-office/libreoffice notmpfs.conf
   dev-qt/qtwebengine notmpfs.conf
   ```

</details>

### 14.4 LTO 與 Clang 優化

詳細設定請參考 **Section 15 進階編譯優化**。

---

## 15. LTO 與 Clang 編譯優化 (可選)

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**風險提示**

LTO 會顯著增加編譯時間和記憶體消耗，且可能導致部分軟體編譯失敗。**強烈不建議全局打開**，僅推薦針對特定軟體（如瀏覽器）打開。

</div>

### 15.1 連結時優化 (LTO)
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[LTO](https://wiki.gentoo.org/wiki/LTO)

</div>

LTO (Link Time Optimization) 將優化推遲到連結階段，可帶來性能提升和體積減小。

<details style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1rem; border-radius: 0.75rem; margin: 1rem 0; border: 1px solid rgba(59, 130, 246, 0.2);">
<summary style="cursor: pointer; font-weight: bold; color: #1d4ed8;">LTO 優缺點詳細分析（點擊展開）</summary>

<div style="margin-top: 1rem;">

**優勢**：
*   性能提升（通常兩位數）
*   二進位體積減小
*   啟動時間改善

**劣勢**：
*   編譯時間增加 2-3 倍
*   記憶體消耗巨大
*   穩定性風險
*   故障排查困難

</div>

</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

如果你的系統是 4 核 CPU 配 4GB 記憶體，那麼花在編譯上的時間可能遠超優化帶來的性能提升。請根據硬體設定權衡利弊。

</div>

**1. 使用 USE 標誌打開 (最推薦)**

對於 Firefox 和 Chromium 等大型軟體，官方 ebuild 通常提供了經過測試的 `lto` 和 `pgo` USE 標誌：

在 `/etc/portage/package.use/browser` 中激活：
```text
www-client/firefox lto pgo
www-client/chromium lto pgo  # 注意：PGO 在 Wayland 環境下可能無法使用
```

**USE="lto" 標誌說明**：部分軟體套件需要特殊修復才能支援 LTO，可以全局或針對特定軟體套件激活 `lto` USE 標誌：
```bash
# 在 /etc/portage/make.conf 中全局激活
USE="lto"
```

**2. 針對特定軟體套件激活 LTO (推薦)**

創建 `/etc/portage/env/lto.conf`：
```bash
CFLAGS="${CFLAGS} -flto"
CXXFLAGS="${CXXFLAGS} -flto"
```

在 `/etc/portage/package.env` 中應用：
```text
www-client/firefox lto.conf
app-editors/vim lto.conf
```

**3. 全局激活 LTO (GCC 系統)**

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

全局 LTO 會導致大量軟體套件編譯失敗，需要頻繁維護排除列表，**不建議新手嘗試**。

</div>

編輯 `/etc/portage/make.conf`：
```bash
# 這些警告指示 LTO 可能導致的運行時問題，將其提升為錯誤
# -Werror=odr: One Definition Rule 違規（多次定義同一符號）
# -Werror=lto-type-mismatch: LTO 類型不匹配
# -Werror=strict-aliasing: 嚴格別名違規
WARNING_FLAGS="-Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing"

# -O2: 優化級別 2（推薦）
# -pipe: 使用管道加速編譯
# -march=native: 針對當前 CPU 優化
# -flto: 激活連結時優化（Full LTO）
# 注意：GCC 的 -flto 預設使用 Full LTO，適合 GCC 系統
COMMON_FLAGS="-O2 -pipe -march=native -flto ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 編譯器標誌
CXXFLAGS="${COMMON_FLAGS}"        # C++ 編譯器標誌
FCFLAGS="${COMMON_FLAGS}"         # Fortran 編譯器標誌
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 編譯器標誌
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 連結器標誌

USE="lto"  # 激活 LTO 支援的 USE 標誌
```

**4. 全局激活 LTO (LLVM/Clang 系統 - 推薦使用 ThinLTO)**

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**預設推薦**

如果使用 Clang，強烈推薦使用 ThinLTO (`-flto=thin`) 而非 Full LTO (`-flto`)。ThinLTO 速度更快，記憶體佔用更少，支援平行化。

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

如果 `clang-common` 未激活 `default-lld` USE 標誌，必須在 `LDFLAGS` 中添加 `-fuse-ld=lld`。

</div>

編輯 `/etc/portage/make.conf`：
```bash
# Clang 目前尚未完全實現這些診斷，但保留這些標誌以備將來使用
# -Werror=odr: One Definition Rule 違規檢測（Clang 部分支援）
# -Werror=strict-aliasing: 嚴格別名違規檢測（Clang 正在開發）
WARNING_FLAGS="-Werror=odr -Werror=strict-aliasing"

# -O2: 優化級別 2（平衡性能與穩定性）
# -pipe: 使用管道加速編譯
# -march=native: 針對當前 CPU 優化
# -flto=thin: 激活 ThinLTO（推薦，速度快且平行化）
COMMON_FLAGS="-O2 -pipe -march=native -flto=thin ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 編譯器標誌
CXXFLAGS="${COMMON_FLAGS}"        # C++ 編譯器標誌
FCFLAGS="${COMMON_FLAGS}"         # Fortran 編譯器標誌
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 編譯器標誌
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 連結器標誌

USE="lto"  # 激活 LTO 支援的 USE 標誌
```

**ThinLTO vs Full LTO（推薦新手閱讀）**：

| 類型 | 標誌 | 優勢 | 劣勢 | 推薦場景 |
|------|------|------|------|----------|
| **ThinLTO** | `-flto=thin` | • 速度快<br>• 記憶體佔用少<br>• 支援平行化<br>• 編譯速度提升 2-3 倍 | • 僅 Clang/LLVM 支援 | **預設推薦**（Clang 用戶） |
| Full LTO | `-flto` | • 更深度的優化<br>• GCC 和 Clang 均支援 | • 速度慢<br>• 記憶體佔用高<br>• 串行處理 | GCC 用戶或需要極致優化時 |

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

如果你使用 Clang，請務必使用 `-flto=thin`。這是目前的最佳實踐，能在保證性能的同時大幅減少編譯時間。

</div>

**5. Rust LTO 設定**

**在 LLVM 系統上**：
```bash
# 在 /etc/portage/make.conf 中添加
RUSTFLAGS="${RUSTFLAGS} -Clinker-plugin-lto"
```

**在 GCC 系統上**（需要使用 Clang 編譯 Rust 程式碼）：
創建 `/etc/portage/env/llvm-lto.conf`：
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

在 `/etc/portage/package.env` 中為 Rust 軟體套件指定：
```text
dev-lang/rust llvm-lto.conf
```

### 15.3 進階軟體套件環境設定 (package.env)

針對特定軟體套件的特殊設定（如禁用 LTO 或低記憶體模式），可以使用 `package.env` 進行精細控制。

<details>
<summary><b>設定 1：禁用 LTO 的軟體套件列表 (no-lto) - 點擊展開</b></summary>

某些軟體套件已知與 LTO 不兼容。建議創建 `/etc/portage/env/nolto.conf`：

```bash
# 禁用 LTO 及相關警告
DISABLE_LTO="-Wno-error=odr -Wno-error=lto-type-mismatch -Wno-error=strict-aliasing -fno-lto"
CFLAGS="${CFLAGS} ${DISABLE_LTO}"
CXXFLAGS="${CXXFLAGS} ${DISABLE_LTO}"
FCFLAGS="${FCFLAGS} ${DISABLE_LTO}"
FFLAGS="${FFLAGS} ${DISABLE_LTO}"
LDFLAGS="${LDFLAGS} ${DISABLE_LTO}"
```

創建 `/etc/portage/package.env/no-lto` 文件（包含已知問題包）：

```bash
# 已知與 LTO 有兼容性問題的套件
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
<summary><b>設定 2：低記憶體編譯模式 (low-memory) - 點擊展開</b></summary>

對於大型項目（如 Chromium, Rust），建議使用低記憶體設定以防止 OOM。

創建 `/etc/portage/env/low-memory.conf`：
```bash
# 減少平行任務數，例如改為 -j2 或 -j4
MAKEOPTS="-j4"
# 可選：移除一些耗記憶體的優化標誌
COMMON_FLAGS="-O2 -pipe"
```

創建 `/etc/portage/package.env/low-memory`：
```bash
# 容易導致系統卡死的大型套件
# 使用低記憶體編譯設定

# 瀏覽器類 (極大型項目)
www-client/chromium low-memory.conf
mail-client/thunderbird low-memory.conf

# 辦公套件
app-office/libreoffice low-memory.conf

# 虛擬化
app-emulation/qemu low-memory.conf

# Rust 大型項目
dev-lang/rust low-memory.conf
virtual/rust low-memory.conf
```
</details>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

如果遇到其他 LTO 相關的連結錯誤，請先嚐試禁用該包的 LTO。也可以查看 [Gentoo Bugzilla](https://bugs.gentoo.org) 搜索是否已有相關報告（搜索"軟體套件名 lto"）。如果是新問題，歡迎提交 bug 報告幫助改進 Gentoo。

</div>

### 15.2 使用 Clang 編譯
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Clang](https://wiki.gentoo.org/wiki/Clang)

</div>

**前提條件**：安裝 Clang 和 LLD
```bash
emerge --ask llvm-core/clang llvm-core/lld
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**重要提示**

- 部分軟體套件（如 `sys-libs/glibc`, `app-emulation/wine`）無法使用 Clang 編譯，仍需 GCC。
- Gentoo 維護了 [bug #408963](https://bugs.gentoo.org/408963) 來跟蹤 Clang 編譯失敗的軟體套件。

</div>

**1. 針對特定軟體打開 (推薦)**

創建環境設定檔 `/etc/portage/env/clang.conf`：
```bash
CC="clang"
CXX="clang++"
CPP="clang-cpp"  # 某些軟體套件（如 xorg-server）需要
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```

應用到特定軟體（例如 `app-editors/neovim`），在 `/etc/portage/package.env` 中添加：
```text
app-editors/neovim clang.conf
```


**3. PGO 支援（設定檔引導優化）**

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果需要 PGO 支援（如 `dev-lang/python[pgo]`），需要安裝以下包：

</div>

```bash
emerge --ask llvm-core/clang-runtime
emerge --ask llvm-runtimes/compiler-rt-sanitizers
```

在 `/etc/portage/package.use` 中激活相關 USE 標誌：
```text
llvm-core/clang-runtime sanitize
llvm-runtimes/compiler-rt-sanitizers profile orc
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

- 如果沒有激活 `profile` 和 `orc` USE 標誌，帶有 `pgo` USE 標誌的軟體套件（如 `dev-lang/python[pgo]`）會編譯失敗。
- 編譯日誌可能會報錯：`ld.lld: error: cannot open /usr/lib/llvm/18/bin/../../../../lib/clang/18/lib/linux/libclang_rt.profile-x86_64.a`

</div>

**4. 全局打開 (不建議初學者)**

全局切換到 Clang 需要系統大部分軟體支援，且需要處理大量兼容性問題，**僅建議高級用戶嘗試**。

如需全局激活，在 `/etc/portage/make.conf` 中添加：
```bash
CC="clang"
CXX="clang++"
CPP="clang-cpp"
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```

**GCC 回退環境**

對於無法使用 Clang 編譯的軟體套件，創建 `/etc/portage/env/gcc.conf`：
```bash
CC="gcc"
CXX="g++"
CPP="gcc -E"
AR="ar"
NM="nm"
RANLIB="ranlib"
```

在 `/etc/portage/package.env` 中為特定軟體指定使用 GCC：
```text
sys-libs/glibc gcc.conf
app-emulation/wine gcc.conf
```


---

## 16. 核心編譯進階指南 (可選) {#section-16-kernel-advanced}

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1rem; border-radius: 0.5rem; border-left: 4px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Kernel](https://wiki.gentoo.org/wiki/Kernel)、[Kernel/Configuration](https://wiki.gentoo.org/wiki/Kernel/Configuration)、[Genkernel](https://wiki.gentoo.org/wiki/Genkernel)

</div>

本節面向希望深入掌控核心編譯的高級用戶，包括使用 LLVM/Clang 編譯、激活 LTO 優化、自動化設定等。

### 16.1 準備工作

安裝必要工具：
```bash
# 安裝核心源碼和構建工具
emerge --ask sys-kernel/gentoo-sources

# （可選）安裝 Genkernel 用於自動化
emerge --ask sys-kernel/genkernel

# （可選）使用 LLVM/Clang 編譯需要
emerge --ask llvm-core/llvm \
    llvm-core/clang llvm-core/lld
```

### 16.2 查看系統資訊（硬體檢測）

在設定核心前，瞭解你的硬體非常重要：

**查看 CPU 資訊**：
```bash
lscpu  # 查看 CPU 型號、核心數、架構等
cat /proc/cpuinfo | grep "model name" | head -1  # CPU 型號
```

**查看 PCI 設備（顯示卡、網卡等）**：
```bash
lspci -k  # 列出所有 PCI 設備及當前使用的驅動
lspci | grep -i vga  # 查看顯示卡
lspci | grep -i network  # 查看網卡
```

**查看 USB 設備**：
```bash
lsusb  # 列出所有 USB 設備
```

**查看已加載的核心模塊**：
```bash
lsmod  # 列出當前加載的所有模塊
lsmod | wc -l  # 模塊數量
```

### 16.3 根據當前模塊自動設定核心

如果你想保留當前系統（如 LiveCD）所有正常工作的硬體支援：

```bash
cd /usr/src/linux

# 方法 1：基於當前加載的模塊創建最小化設定
make localmodconfig
# 這會只激活當前加載模塊對應的核心選項（強烈推薦！）

# 方法 2：基於當前運行核心的設定創建
zcat /proc/config.gz > .config  # 如果當前核心支援
make olddefconfig  # 使用預設值更新設定
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

`localmodconfig` 是最安全的方法，它會確保你的硬體都能正常工作，同時移除不需要的驅動。

</div>

### 16.4 手動設定核心選項

**進入設定介面**：
```bash
cd /usr/src/linux
make menuconfig  # 文本介面（推薦）
```

```text
  ┌────────────── Linux/x86 6.17.9-gentoo Kernel Configuration ──────────────┐
  │  Arrow keys navigate the menu.  <Enter> selects submenus ---> (or empty  │   │  submenus ----).  Highlighted letters are hotkeys.  Pressing <Y>         │   │  includes, <N> excludes, <M> modularizes features.  Press <Esc><Esc> to  │   │  exit, <?> for Help, </> for Search.  Legend: [*] built-in  [ ] excluded │   │ ┌──────────────────────────────────────────────────────────────────────┐ │   │ │        General setup  --->                                           │ │   │ │    [*] 64-bit kernel                                                 │ │   │ │        Processor type and features  --->                             │ │   │ │    [ ] Mitigations for CPU vulnerabilities  ----                     │ │   │ │        Power management and ACPI options  --->                       │ │   │ │        Bus options (PCI etc.)  --->                                  │ │   │ │        Binary Emulations  --->                                       │ │   │ │    [*] Virtualization  --->                                          │ │   │ │        General architecture-dependent options  --->                  │ │   │ │    [*] Enable loadable module support  --->                          │ │   │ │    -*- Enable the block layer  --->                                  │ │   │ │        Executable file formats  --->                                 │ │   │ │        Memory Management options  --->                               │ │   │ │    -*- Networking support  --->                                      │ │   │ │        Device Drivers  --->                                          │ │   │ │        File systems  --->                                            │ │   │ │        Security options  --->                                        │ │   │ │    -*- Cryptographic API  --->                                       │ │   │ │        Library routines  --->                                        │ │   │ │        Kernel hacking  --->                                          │ │   │ │        Gentoo Linux  --->                                            │ │   │ │                                                                      │ │   │ │                                                                      │ │   │ └──────────────────────────────────────────────────────────────────────┘ │   ├──────────────────────────────────────────────────────────────────────────┤   │         <Select>    < Exit >    < Help >    < Save >    < Load >         │   └──────────────────────────────────────────────────────────────────────────┘ ```

**常用選項對照表**：

| 英文選項 | 中文說明 | 關鍵設定 |
| :--- | :--- | :--- |
| **General setup** | 通用設定 | 本機主機名、Systemd/OpenRC 支援 |
| **Processor type and features** | 處理器類型與特性 | CPU 型號選擇、微碼加載 |
| **Power management and ACPI options** | 電源管理與 ACPI | 筆記型電腦電源管理、掛起/休眠 |
| **Bus options (PCI etc.)** | 總線選項 | PCI 支援 (lspci) |
| **Virtualization** | 虛擬化 | KVM, VirtualBox 宿主/客戶機支援 |
| **Enable loadable module support** | 可加載模塊支援 | 允許使用核心模塊 (*.ko) |
| **Networking support** | 網路支援 | TCP/IP 協定棧、防火牆 (Netfilter) |
| **Device Drivers** | 設備驅動 | 顯示卡、網卡、聲卡、USB、NVMe 驅動 |
| **File systems** | 檔案系統 | ext4, btrfs, vfat, ntfs 支援 |
| **Security options** | 安全選項 | SELinux, AppArmor |
| **Gentoo Linux** | Gentoo 特有選項 | Portage 依賴項自動選擇 (推薦) |

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**重要建議**

對於手動編譯，建議將**關鍵驅動**（如檔案系統、磁盤控制器、網卡）直接編譯進核心（選擇 `[*]` 或 `<*>` 即 `=y`），而不是作為模塊（`<M>` 即 `=m`）。這樣可以避免 initramfs 缺失模塊導致無法啟動的問題。

</div>

**必需激活的選項**（根據你的系統）：

1. **處理器支援**：
   - `General setup → Gentoo Linux support`
   - `Processor type and features → Processor family` (選擇你的 CPU)

2. **檔案系統**：
   - `File systems → The Extended 4 (ext4) filesystem` (如果使用 ext4)
   - `File systems → Btrfs filesystem` (如果使用 Btrfs)

3. **設備驅動**：
   - `Device Drivers → Network device support` (網卡驅動)
   - `Device Drivers → Graphics support` (顯示卡驅動程式)

4. **Systemd 用戶必需**：
   - `General setup → Control Group support`
   - `General setup → Namespaces support`

5. **Gentoo Linux 專有選項**（推薦全部激活）：
     進入 `Gentoo Linux --->` 選單：
     ```
   [*] Gentoo Linux support
       激活 Gentoo 特定的核心功能支援
     [*] Linux dynamic and persistent device naming (userspace devfs) support
       激活 udev 動態設備管理支援（必需）
     [*] Select options required by Portage features
       自動激活 Portage 需要的核心選項（強烈推薦）
       這會自動設定必需的檔案系統和核心功能
     Support for init systems, system and service managers --->
       ├─ [*] OpenRC support  # 如果使用 OpenRC
       └─ [*] systemd support # 如果使用 systemd
     [*] Kernel Self Protection Project
       激活核心自我保護機制（提高安全性）
     [*] Print firmware information that the kernel attempts to load
       在啟動時顯示韌體加載資訊（便於調試）
   ```

 <div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

激活 "Select options required by Portage features" 可以自動設定大部分必需選項，非常推薦！

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

在 menuconfig 中，按 `/` 可以搜索選項，按 `?` 查看幫助。

</div>

### 16.5 自動激活推薦選項

Gentoo 提供了自動化腳本來激活常見硬體和功能：

```bash
cd /usr/src/linux

# 使用 Genkernel 的預設設定（包含大多數硬體支援）
genkernel --kernel-config=/usr/share/genkernel/arch/x86_64/kernel-config all

# 或者使用發行版預設設定作為基礎
make defconfig  # 核心預設設定
# 然後再根據需要調整
make menuconfig
```

### 16.6 使用 LLVM/Clang 編譯核心

使用 LLVM/Clang 編譯核心可以獲得更好的優化和更快的編譯速度（支援 ThinLTO）。

**方法 1：指定編譯器**（一次性）：
```bash
cd /usr/src/linux

# 使用 Clang 編譯
make LLVM=1 -j$(nproc)

# 使用 Clang + LTO（推薦）
make LLVM=1 LLVM_IAS=1 -j$(nproc)
```

**方法 2：設定環境變量**（永久）：
在 `/etc/portage/make.conf` 中添加（僅影響核心編譯）：
```bash
# 使用 LLVM/Clang 編譯核心
KERNEL_CC="clang"
KERNEL_LD="ld.lld"
```

**激活核心 LTO 支援**：
在 `make menuconfig` 中：
```
General setup
  → Compiler optimization level → Optimize for performance  # 選擇 -O2（推薦）
  → Link Time Optimization (LTO) → Clang ThinLTO (NEW)      # 激活 ThinLTO（強烈推薦）
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要警告：核心編譯時強烈不建議使用 Full LTO！**

*   Full LTO 會導致編譯極其緩慢（可能需要數小時）
*   佔用大量記憶體（可能需要 16GB+ RAM）
*   容易導致連結錯誤
*   **請務必使用 ThinLTO**，它更快、更穩定、記憶體佔用更少

</div>

### 16.7 核心編譯選項優化

<details>
<summary><b>高級編譯優化（點擊展開）</b></summary>

**在 `menuconfig` 中激活**：

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

**核心壓縮方式**（影響啟動速度和體積）：

```
General setup
  → Kernel compression mode
     → [*] ZSTD  # 推薦：壓縮率高且解壓快
     # 其他選項：LZ4（最快）、XZ（最小）、GZIP（兼容性最好）
```

</details>

### 16.8 編譯和安裝核心

**手動編譯**：
```bash
cd /usr/src/linux

# 編譯核心和模塊
make -j$(nproc)         # 使用所有 CPU 核心
make modules_install    # 安裝模塊到 /lib/modules/
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

# 激活 LTO（需要手動設定 .config）
genkernel --kernel-make-opts="LLVM=1" --install all
```

### 16.9 核心統計與分析

編譯完成後，使用以下腳本查看核心統計資訊：

```bash
cd /usr/src/linux

echo "=== 核心統計 ==="
echo "Built-in: $(grep -c '=y$' .config)"
echo "模塊: $(grep -c '=m$' .config)"
echo "總設定: $(wc -l < .config)"
echo "核心大小: $(ls -lh arch/x86/boot/bzImage 2>/dev/null | awk '{print $5}')"
echo "壓縮方式: $(grep '^CONFIG_KERNEL_' .config | grep '=y' | sed 's/CONFIG_KERNEL_//;s/=y//')"
```

**示例輸出**：
```
=== 核心統計 ===
Built-in: 1723
模塊: 201
總設定: 6687
核心大小: 11M
壓縮方式: ZSTD
```

**解讀**：
- **Built-in (1723)**：編譯進核心本體的功能數量
- **模塊 (201)**：作為可加載模塊的驅動數量
- **核心大小 (11M)**：最終核心文件大小（使用 ZSTD 壓縮後）

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**優化建議**

*   核心大小 < 15MB：優秀（精簡設定）
*   核心大小 15-30MB：良好（標準設定）
*   核心大小 > 30MB：考慮禁用不需要的功能

</div>

### 16.10 常見問題排查

<details>
<summary><b>編譯錯誤與解決方案（點擊展開）</b></summary>

**錯誤 1：缺少依賴**
```
*** No rule to make target 'debian/canonical-certs.pem'
```
解決：禁用簽名證書
```bash
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
make olddefconfig
```

**錯誤 2：LTO 編譯失敗**
```
ld.lld: error: undefined symbol
```
解決：某些模塊不兼容 LTO，禁用 LTO 或將問題模塊設為 `=y`（而非 `=m`）

**錯誤 3：clang 版本過舊**
```
error: unknown argument: '-mretpoline-external-thunk'
```
解決：升級 LLVM/Clang 或使用 GCC 編譯

</details>

### 16.11 核心設定最佳實踐

1. **保存設定**：
   ```bash
   # 保存當前設定到外部檔案
   cp .config ~/kernel-config-backup
     # 恢復設定
   cp ~/kernel-config-backup /usr/src/linux/.config
   make olddefconfig
   ```

2. **查看設定差異**：
   ```bash
   # 對比兩個設定檔
   scripts/diffconfig .config ../old-kernel/.config
   ```

3. **最小化設定**（僅包含必需功能）：
   ```bash
   make tinyconfig  # 創建極簡設定
   make localmodconfig  # 然後添加當前硬體支援
   ```

---

## 17. 伺服器與 RAID 設定 (可選) {#section-17-server-raid}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Wiki: Mdadm](https://wiki.gentoo.org/wiki/Mdadm)

</div>

本節適用於需要設定軟 RAID (mdadm) 的伺服器用戶。

### 17.1 核心設定 (手動編譯必選)

如果你手動編譯核心，必須激活以下選項（**注意：必須編譯進核心 `<*>` 即 `=y`，不能是模塊 `<M>`**）：

```
Device Drivers  --->
    <*> Multiple devices driver support (RAID and LVM)
        <*> RAID support
            [*] Autodetect RAID arrays during kernel boot

            # 根據你的 RAID 級別選擇（必須選 Y）：
            <*> Linear (append) mode                   # 線性模式
            <*> RAID-0 (striping) mode                 # RAID 0
            <*> RAID-1 (mirroring) mode                # RAID 1
            <*> RAID-10 (mirrored striping) mode       # RAID 10
            <*> RAID-4/RAID-5/RAID-6 mode              # RAID 5/6
```

### 17.2 設定 Dracut 加載 RAID 模塊 (dist-kernel 必選)

如果你使用 `dist-kernel`（發行版核心）或者將 RAID 驅動編譯為了模塊，**必須**通過 Dracut 強制加載 RAID 驅動，否則無法開機。

<details>
<summary><b>Dracut RAID 設定指南（點擊展開）</b></summary>

**1. 激活 mdraid 支援**
創建 `/etc/dracut.conf.d/mdraid.conf`：
```bash
# Enable mdraid support for RAID arrays
add_dracutmodules+=" mdraid "
mdadmconf="yes"
```

**2. 強制加載 RAID 驅動**
創建 `/etc/dracut.conf.d/raid-modules.conf`：
```bash
# Ensure RAID modules are included and loaded
add_drivers+=" raid1 raid0 raid10 raid456 "
force_drivers+=" raid1 "
# Install modprobe configuration
install_items+=" /usr/lib/modules-load.d/ /etc/modules-load.d/ "
```

**3. 設定核心指令行參數 (UUID)**
你需要找到 RAID 數組的 UUID 並添加到核心參數中。
創建 `/etc/dracut.conf.d/mdraid-cmdline.conf`：
```bash
# Kernel command line parameters for RAID arrays
# 請替換為你實際的 RAID UUID (通過 mdadm --detail --scan 查看)
kernel_cmdline="rd.md.uuid=68b53b0a:c6bd2ca0:caed4380:1cd75aeb rd.md.uuid=c8f92d69:59d61271:e8ffa815:063390ed"
```

**4. 重新生成 initramfs**
```bash
dracut --force
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

設定完成後，務必檢查 `/boot/initramfs-*.img` 是否包含 RAID 模塊：

</div>
> `lsinitrd /boot/initramfs-*.img | grep raid`

</details>

---

## 18. Secure Boot 設定 (可選) {#section-18-secure-boot}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Handbook: Secure Boot](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Alternative:_Secure_Boot) · [Signed kernel module support](https://wiki.gentoo.org/wiki/Signed_kernel_module_support)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

**什麼是 Secure Boot？**

Secure Boot（安全啟動）是 UEFI 韌體的一項安全功能，通過驗證啟動加載器和核心的數字簽名，防止未經授權的程式碼在啟動階段運行。激活 Secure Boot 後，系統僅會加載經過信任的簽名檔。

**為何需要設定？**

Gentoo 預設安裝**不支援 Secure Boot**，若你的主板激活了 Secure Boot，系統將無法啟動。本節介紹如何設定 Secure Boot。

</div>

### 18.1 使用 sbctl 自動化管理（推薦） {#sbctl}

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**sbctl** 是一個 Secure Boot 管理工具,能自動化處理金鑰生成、簽名和註冊流程,相比手動使用 OpenSSL 設定更為簡便。

</div>

**步驟 1：安裝 sbctl**

```bash
emerge --ask app-crypt/sbctl
```

**步驟 2：檢查當前狀態**

```bash
sbctl status
```

預期輸出（安裝前）：
```
Installed:	✘ Sbctl is not installed
Setup Mode:	✘ Enabled
Secure Boot:	✘ Disabled
```

<details>
<summary><b>如果 Setup Mode 顯示為 Disabled（關閉）怎麼辦？</b></summary>

**Setup Mode** 是 UEFI 韌體的一個特殊模式，允許修改 Secure Boot 金鑰。如果顯示為 `Disabled`，你需要：

**方法 1：清除現有的 Secure Boot 金鑰（推薦）**

在 BIOS/UEFI 設定中找到以下選項（不同主板命名可能略有不同）：
- **Clear Secure Boot Keys** / **清除安全啟動金鑰**
- **Reset to Setup Mode** / **重置為設定模式**
- **Delete All Keys** / **刪除所有金鑰**

清除後，Setup Mode 會自動切換為 `Enabled`。

> **注意**：必須清除金鑰才能進入 Setup Mode！單純關閉 Secure Boot（設為 Disabled）**不會**啟用 Setup Mode，因為金鑰仍然存在，韌體不允許寫入新金鑰。

**驗證 Setup Mode**

重新啟動後再次檢查：
```bash
sbctl status
```

確認 `Setup Mode: ✘ Enabled` 後，再繼續下一步。

</details>

**步驟 3：生成金鑰（自動完成）**

```bash
sbctl create-keys
```

輸出：
```
Created Owner UUID a9fbbdb7-a05f-48d5-b63a-08c5df45ee70
Creating secure boot keys...✔
Secure boot keys created!
```

金鑰自動生成到 `/var/lib/sbctl/keys/`，無需手動操作！

**步驟 4：註冊金鑰到 UEFI 韌體**

```bash
sbctl enroll-keys -m
```

- `-m` 參數表示**保留 Microsoft 供應商金鑰**（推薦），這樣可以啟動 Windows 和其他已簽名的 EFI 程式

輸出：
```
Enrolling keys to EFI variables...
With vendor keys from microsoft...✔
Enrolled keys to the EFI variables!
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1rem 0;">

**警告**

如果你的系統沒有集成顯示卡（iGPU），**不要使用 `-m` 參數**，否則可能導致系統無法啟動。這種情況下使用：
```bash
sbctl enroll-keys  # 不加 -m
```

</div>

**步驟 5：設定 Portage 自動簽名**

編輯 `/etc/portage/make.conf`，添加 sbctl 的金鑰路徑：

```bash
# Secure Boot: 使用 sbctl 的金鑰自動簽名
USE="${USE} secureboot modules-sign"

MODULES_SIGN_KEY="/var/lib/sbctl/keys/db/db.key"
MODULES_SIGN_CERT="/var/lib/sbctl/keys/db/db.pem"
SECUREBOOT_SIGN_KEY="/var/lib/sbctl/keys/db/db.key"
SECUREBOOT_SIGN_CERT="/var/lib/sbctl/keys/db/db.pem"
```

**步驟 6：重新編譯核心**

```bash
emerge --ask sys-kernel/gentoo-kernel-bin  # 或你使用的核心包
```

Portage 會自動使用 sbctl 的金鑰簽名核心和模塊！

**步驟 7：簽名啟動加載器**

根據你使用的啟動加載器，運行對應指令：

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
<summary><b>使用 EFI Stub（直接啟動）</b></summary>

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

**步驟 8：驗證簽名狀態**

```bash
sbctl verify
```

預期輸出（所有文件都應顯示 ✔）：
```
Verifying file database and EFI images in /efi...
✔ /efi/EFI/gentoo/grubx64.efi is signed
✔ /boot/vmlinuz is signed
✔ /efi/EFI/Linux/gentoo-6.x.x.efi is signed
```

**步驟 9：激活 Secure Boot**

1. 重新啟動進入 BIOS/UEFI 設定
2. 找到 **Secure Boot** 選項
3. 將其設定為 **Enabled**
4. 保存並重新啟動

**步驟 10：確認 Secure Boot 已激活**

啟動後檢查狀態：
```bash
sbctl status
```

成功輸出：
```
Installed:	✓ sbctl is installed
Owner GUID:	a9fbbdb7-a05f-48d5-b63a-08c5df45ee70
Setup Mode:	✓ Disabled
Secure Boot:	✓ Enabled
Vendor Keys:	microsoft
```

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**sbctl 的優勢**

1. **自動化**：一條指令生成所有金鑰
2. **簡單**：無需手動管理 PEM/DER 格式轉換
3. **智能**：自動跟蹤需要簽名的文件（`/var/lib/sbctl/files.json`）
4. **安全**：金鑰預設權限為 600，自動保護
5. **可驗證**：隨時用 `sbctl verify` 檢查簽名狀態

如果你希望用更少的步驟完成設定，通常可以優先考慮使用 sbctl；如需完全掌控證書與簽名流程，則使用本節的手動 OpenSSL 方式。

</div>

---

### 18.2 進階：手動 OpenSSL 方式（可選）

<details>
<summary><b>展開查看手動設定方法（適合進階用戶/企業環境）</b></summary>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**適用場景**

- 需要自定義證書參數（如有效期、金鑰長度）
- 企業環境需要使用現有 PKI 基礎設施
- 對金鑰管理有特殊安全要求
- 學習 Secure Boot 底層原理

**如果你已使用 sbctl 完成設定，可以跳過本節。**

</div>

#### 18.2.1 生成自簽名證書

**步驟 1：安裝必要工具**

```bash
emerge --ask app-crypt/sbsigntools sys-apps/kmod[openssl]
```

**步驟 2：生成證書**

創建金鑰目錄：
```bash
mkdir -p /etc/kernel/certs
cd /etc/kernel/certs
```

生成 RSA 私鑰和證書：
```bash
# 生成私鑰 (2048 位 RSA)
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt \
  -days 36500 -nodes -subj "/CN=My Kernel Signing Key/"

# 轉換為 DER 格式 (核心需要)
openssl x509 -in MOK.crt -outform DER -out MOK.der

# 設定安全權限
chmod 600 MOK.key
```

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1rem 0;">

**重要提示**

- **金鑰安全**：`MOK.key` 是私鑰，必須妥善保管（建議備份到離線儲存）
- **證書有效期**：此處設定為 36500 天（約 100 年），可根據需要調整
- **CN 名稱**：可自定義為任意描述性名稱

</div>

#### 18.2.2 設定核心模塊簽名


**步驟 1：激活核心模塊簽名支援**

編輯 `/etc/portage/package.use/kernel`，為 `dist-kernel` 添加 `modules-sign` USE 標誌：
```bash
# /etc/portage/package.use/kernel
virtual/dist-kernel modules-sign
sys-kernel/installkernel dracut
```

**步驟 2：設定簽名參數**

編輯 `/etc/portage/make.conf`，添加以下內容：
```bash
# Secure Boot: 核心模塊簽名設定
MODULES_SIGN_KEY="/etc/kernel/certs/MOK.key"
MODULES_SIGN_CERT="/etc/kernel/certs/MOK.der"
MODULES_SIGN_HASH="sha512"
```

**步驟 3：重新編譯核心**

重新安裝核心，使簽名生效：
```bash
emerge --ask @module-rebuild
emerge --ask sys-kernel/gentoo-kernel-bin  # 或你使用的核心包
```

編譯完成後，驗證模塊簽名：
```bash
modinfo /lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amdgpu/amdgpu.ko | grep sig
```

預期輸出應包含：
```
sig_id:         PKCS#7
signer:         My Kernel Signing Key
sig_key:        XX:XX:XX:XX:...
sig_hashalgo:   sha512
```

#### 18.2.3 設定核心映像簽名（Unified Kernel Image）

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**Unified Kernel Image (UKI)**

將核心、initramfs、指令行參數打包為單一 EFI 可執行檔，並進行整體簽名。這是 Secure Boot 的推薦方式。

</div>

**步驟 1：激活 secureboot USE 標誌**

編輯 `/etc/portage/package.use/kernel`：
```bash
# /etc/portage/package.use/kernel
virtual/dist-kernel modules-sign secureboot
sys-kernel/installkernel dracut uki
```

**步驟 2：設定簽名參數**

編輯 `/etc/portage/make.conf`，添加核心映像簽名設定：
```bash
# Secure Boot: 核心映像簽名設定
SECUREBOOT_SIGN_KEY="/etc/kernel/certs/MOK.key"
SECUREBOOT_SIGN_CERT="/etc/kernel/certs/MOK.crt"
```

**步驟 3：設定 installkernel**

創建 `/etc/kernel/install.conf`：
```bash
# /etc/kernel/install.conf
layout=uki
uki_generator=dracut
initrd_generator=dracut
```

**步驟 4：重新生成核心**

```bash
emerge --ask sys-kernel/gentoo-kernel-bin  # 或你使用的核心包
```

生成的 UKI 文件位於：
```
/efi/EFI/Linux/gentoo-6.x.x.efi
```

#### 18.2.4 註冊 MOK (Machine Owner Key)

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**MOK 管理**

由於 Gentoo 使用自簽名證書，你需要將證書註冊到 UEFI 韌體的 MOK（Machine Owner Key）列表中，以便 Secure Boot 信任你的簽名。

</div>

**步驟 1：安裝 Shim**

```bash
emerge --ask sys-boot/shim
```

**步驟 2：拷貝 Shim 到 EFI 分區**

```bash
cp /usr/share/shim/shimx64.efi /efi/EFI/gentoo/
cp /usr/share/shim/mmx64.efi /efi/EFI/gentoo/
```

**步驟 3：導入 MOK 證書**

使用 `mokutil` 導入證書（需要在啟動後的 MOK Manager 中確認）：
```bash
mokutil --import /etc/kernel/certs/MOK.der
```

設定一個臨時密碼（重新啟動後在 MOK Manager 中輸入）：
```
input password:
input password again:
```

**步驟 4：設定啟動項**

使用 `efibootmgr` 創建啟動項（指向 Shim）：
```bash
efibootmgr --create --disk /dev/nvme0n1 --part 1 \
  --label "Gentoo Secure Boot" \
  --loader '\EFI\gentoo\shimx64.efi'
```

**步驟 5：重新啟動並註冊 MOK**

1. 重新啟動系統
2. 進入 **MOK Manager**（藍色介面）
3. 選擇 **Enroll MOK** → **Continue** → **Yes**
4. 輸入之前設定的臨時密碼
5. 選擇 **Reboot**

#### 18.2.5 驗證 Secure Boot 狀態

重新啟動後，檢查 Secure Boot 是否正常工作：
```bash
# 檢查 Secure Boot 狀態
bootctl status | grep "Secure Boot"

# 預期輸出：
# Secure Boot: enabled (user)
```

查看已加載的金鑰：
```bash
mokutil --list-enrolled
```

#### 18.2.6 常見問題排查

<details>
<summary><b>問題 1：系統無法啟動，顯示 "Verification failed: (0x1A) Security Violation"</b></summary>

**原因**：核心或啟動加載器未正確簽名。

**解決方法**：
1. 在 BIOS 中**臨時關閉 Secure Boot**
2. 進入系統後，重新運行簽名步驟（18.2.2 和 18.2.3）
3. 確認 `/efi/EFI/Linux/*.efi` 文件存在
4. 重新啟動並重新註冊 MOK（步驟 18.2.4）

</details>

<details>
<summary><b>問題 2：模塊加載失敗，dmesg 顯示 "module verification failed: signature and/or required key missing"</b></summary>

**原因**：核心模塊未簽名或簽名不匹配。

**解決方法**：
```bash
# 重新編譯並簽名所有模塊
emerge --ask @module-rebuild
emerge --ask sys-kernel/gentoo-kernel-bin
```

</details>

<details>
<summary><b>問題 3：如何臨時禁用 Secure Boot？</b></summary>

**方法 1（推薦）**：在 BIOS/UEFI 設定中關閉 Secure Boot

**方法 2**：刪除已註冊的 MOK 證書
```bash
mokutil --reset
# 重新啟動後在 MOK Manager 中確認刪除
```

</details>

</details>

---

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**Secure Boot 設定總結**

推薦方式：
- **新手用戶**：使用 **sbctl**（18.1 節）—— 簡單快速，幾條指令完成
- **進階用戶**：使用**手動 OpenSSL 方式**（18.2 節）—— 完全自定義控制

完成後，系統將擁有與商業發行版同等的安全啟動保護。

</div>

---

## 參考資料 {#reference}

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 官方文件

- **[Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)** 官方最新指南
- [Gentoo Wiki](https://wiki.gentoo.org/)
- [Portage Documentation](https://wiki.gentoo.org/wiki/Portage)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 社區支援

**Gentoo 中文社區**：
- Telegram 群組：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 頻道：[@gentoocn](https://t.me/gentoocn)
- [GitHub](https://github.com/gentoo-zh)

**官方社區**：
- [Gentoo Forums](https://forums.gentoo.org/)
- IRC: `#gentoo` @ [Libera.Chat](https://libera.chat/)

</div>

</div>

## 結語

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; text-align: center;">

### 祝你在 Gentoo 上享受自由與靈活！

這份指南基於官方 [Handbook:AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64) 並簡化流程，標記了可選步驟，讓更多人能輕鬆嘗試。

</div>
