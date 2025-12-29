---
title: "Gentoo Linux 安裝指南 (進階最佳化篇)"
date: 2025-11-25
summary: "Gentoo Linux 進階最佳化教學，涵蓋 make.conf 最佳化、LTO、Tmpfs、系統維護等。"
description: "2025 年最新 Gentoo Linux 安裝指南 (進階最佳化篇)，涵蓋 make.conf 最佳化、LTO、Tmpfs、系統維護等。"
keywords:
  - Gentoo Linux
  - make.conf
  - LTO
  - Tmpfs
  - 系統維護
  - 編譯最佳化
tags:
  - Gentoo
  - Linux
  - 教學
  - 系統最佳化
categories:
  - tutorial
authors:
  - zakkaus
---

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">

### 文章特別說明

本文是 **Gentoo Linux 安裝指南** 系列的第三部分：**進階最佳化**。

**系列導航**：
1. [基礎安裝](/posts/2025-11-25-gentoo-install-base/)：從零開始安裝 Gentoo 基礎系統
2. [桌面配置](/posts/2025-11-25-gentoo-install-desktop/)：顯示卡驅動、桌面環境、輸入法等
3. **進階最佳化（本文）**：make.conf 最佳化、LTO、系統維護

**上一步**：[桌面配置](/posts/2025-11-25-gentoo-install-desktop/)

</div>

## 13. make.conf 進階配置指南

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[make.conf](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

</div>

`/etc/portage/make.conf` 是 Gentoo 的全域性配置檔案，控制編譯器、最佳化引數、USE 標誌等。

#### 1. 編譯器配置

**基本配置 (推薦)**
```bash
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"   # Fortran
FFLAGS="${COMMON_FLAGS}"    # Fortran 77
```

**引數說明**：
- `-march=native`：針對當前 CPU 最佳化（推薦）
- `-O2`：最佳化級別 2（平衡效能與穩定性）
- `-pipe`：使用管道加速編譯

#### 2. 並行編譯配置

```bash
MAKEOPTS="-j<核心數> -l<負載限制>"
EMERGE_DEFAULT_OPTS="--jobs=<並行套件數> --load-average=<負載>"
```

**推薦值**：
- **4核/8執行緒**：`MAKEOPTS="-j8 -l8"`, `EMERGE_DEFAULT_OPTS="--jobs=2"`
- **8核/16執行緒**：`MAKEOPTS="-j16 -l16"`, `EMERGE_DEFAULT_OPTS="--jobs=4"`
- **16核/32執行緒**：`MAKEOPTS="-j32 -l32"`, `EMERGE_DEFAULT_OPTS="--jobs=6"`

#### 3. USE 標誌配置

```bash
# 基礎 USE 範例
USE="systemd dbus policykit"
USE="${USE} wayland X gtk qt6"
USE="${USE} pulseaudio alsa"
USE="${USE} -doc -test"
```

**常用 USE 標誌**：
| 類別別 | USE 標誌 | 說明 |
| ---- | -------- | ---- |
| **系統** | `systemd` / `openrc` | init 系統 |
| **桌面** | `wayland`, `X`, `gtk`, `qt6` | 桌面協議和工具套件 |
| **音訊** | `pipewire`, `pulseaudio`, `alsa` | 音訊系統 |
| **影片** | `ffmpeg`, `x264`, `vpx` | 影片編解碼 |
| **國際化** | `cjk`, `nls`, `icu` | 中文支援 |
| **停用** | `-doc`, `-test`, `-examples` | 停用不必要的功能 |


#### 4. 語言配置

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

# 輸入裝置
INPUT_DEVICES="libinput"

# CPU 特性 (自動檢測，執行: emerge --ask app-portage/cpuid2cpuflags)
CPU_FLAGS_X86="<cpuid2cpuflags 輸出>"
```

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**詳見**：[5.3 CPU 指令集最佳化 (CPU_FLAGS_X86)](/posts/2025-11-25-gentoo-install-base/#step-5-portage)

</div>

#### 6. Portage 功能

```bash
FEATURES="parallel-fetch parallel-install candy ccache"
```

**常用 FEATURES**：
- `parallel-fetch`：並行下載
- `parallel-install`：並行安裝
- `candy`：美化輸出
- `ccache`：編譯快取（需安裝 `dev-build/ccache`）

#### 7. 完整配置範例

**新手推薦配置**：
```bash
# /etc/portage/make.conf
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"

MAKEOPTS="-j4 -l4"  # 根據 CPU 調整

USE="systemd wayland pipewire -doc -test"


L10N="en zh zh-CN"
VIDEO_CARDS="intel"  # 或 nvidia/amdgpu

FEATURES="parallel-fetch candy"
ACCEPT_LICENSE="*"
```

### 13.1 日常維護：如何成為合格的系統管理員

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Upgrading Gentoo](https://wiki.gentoo.org/wiki/Upgrading_Gentoo/zh-tw) · [Gentoo Cheat Sheet](https://wiki.gentoo.org/wiki/Gentoo_Cheat_Sheet)

</div>

Gentoo 是滾動發行版，維護系統是使用體驗的重要組成部分。

**1. 保持系統更新**
建議每一到兩週更新一次系統，避免積壓過多更新導致依賴衝突。
```bash
emerge --sync              # 同步軟體倉庫
emerge -avuDN @world       # 更新所有軟體
```

**2. 關注官方新聞 (重要)**
在更新前或遇到問題時，務必檢查是否有官方新聞推送。
```bash
eselect news list          # 列出新聞
eselect news read          # 閱讀新聞
```

**3. 處理配置檔案更新**
軟體更新後，配置檔案可能也會更新。**不要忽略** `etc-update` 或 `dispatch-conf` 的提示。
```bash
dispatch-conf              # 互動式合併配置檔案 (推薦)
# 或
etc-update
```

**4. 清理無用依賴**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Remove orphaned packages](https://wiki.gentoo.org/wiki/Knowledge_Base:Remove_orphaned_packages)

</div>

```bash
emerge --ask --depclean    # 移除不再需要的孤立依賴
```

**5. 定期清理原始碼套件**
```bash
emerge --ask app-portage/gentoolkit # 安裝工具套件
eclean-dist                         # 清理已下載的舊原始碼套件
```

**6. 自動處理 USE 變更**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Autounmask-write](https://wiki.gentoo.org/wiki/Knowledge_Base:Autounmask-write) · [Dispatch-conf](https://wiki.gentoo.org/wiki/Dispatch-conf)

</div>

當安裝或更新軟體提示 "The following USE changes are necessary" 時：
1.  **讓 Portage 自動寫入配置**：`emerge --ask --autounmask-write <套件名>`
2.  **確認並更新配置**：`dispatch-conf` (按 u 確認，q 退出)
3.  **再次嘗試操作**：`emerge --ask <套件名>`

**7. 處理軟體衝突 (Blocked Packages)**
如果遇到 "Error: The above package list contains packages which cannot be installed at the same time..."：
- **解決方法**：根據提示，手動解除安裝衝突軟體 (`emerge --deselect <套件名>` 後 `emerge --depclean`)。

**8. 安全檢查 (GLSA)**
Gentoo 發布安全公告 (GLSA) 來通知使用者潛在的安全漏洞。
```bash
glsa-check -l      # 列出所有未修復的安全公告
glsa-check -t all  # 測試所有受影響的軟體套件
```

**9. 系統日誌與服務狀態**
定期檢查系統日誌和服務狀態，確保系統健康執行。
- **OpenRC**:
    ```bash
    rc-status      # 檢視服務狀態
    tail -f /var/log/messages # 檢視系統日誌 (需安裝 syslog-ng 等)
    ```
- **Systemd (Journalctl 常用指令)**:
    | 指令 | 作用 |
    | ---- | ---- |
    | `systemctl --failed` | 檢視啟動失敗的服務 |
    | `journalctl -b` | 檢視本次啟動的日誌 |
    | `journalctl -b -1` | 檢視上一次啟動的日誌 |
    | `journalctl -f` | 即時跟隨最新日誌 (類別似 tail -f) |
    | `journalctl -p err` | 僅顯示錯誤 (Error) 級別的日誌 |
    | `journalctl -u <服務名>` | 檢視特定服務的日誌 |
    | `journalctl --since "1 hour ago"` | 檢視最近 1 小時的日誌 |
    | `journalctl --disk-usage` | 檢視日誌佔用的磁碟空間 |
    | `journalctl --vacuum-time=2weeks` | 清理 2 周前的日誌 |

### 13.2 Portage 技巧與目錄結構

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Portage](https://wiki.gentoo.org/wiki/Portage/zh-tw) · [/etc/portage](https://wiki.gentoo.org/wiki//etc/portage)

</div>

**1. 核心目錄結構 (`/etc/portage/`)**
Gentoo 的配置非常靈活，建議使用**目錄**而不是單個檔案來管理配置：

| 檔案/目錄 | 用途 |
| --------- | ---- |
| `make.conf` | 全域性編譯引數 (CFLAGS, MAKEOPTS, USE, GENTOO_MIRRORS) |
| `package.use/` | 針對特定軟體的 USE 標誌配置 |
| `package.accept_keywords/` | 允許安裝測試版 (keyword) 軟體 |
| `package.mask/` | 遮蔽特定版本的軟體 |
| `package.unmask/` | 解除遮蔽特定版本的軟體 |
| `package.license/` | 接受特定軟體的許可證 |
| `package.env/` | 針對特定軟體的環境變數 (如使用不同的編譯器引數) |

**2. 常用 Emerge 指令速查**
> 完整手冊請執行 `man emerge`

| 引數 (縮寫) | 作用 | 範例 |
| ----------- | ---- | ---- |
| `--ask` (`-a`) | 執行前詢問確認 | `emerge -a vim` |
| `--verbose` (`-v`) | 顯示詳細資訊 (USE 標誌等) | `emerge -av vim` |
| `--oneshot` (`-1`) | 安裝但不加入 World 檔案 (不作為系統依賴) | `emerge -1 rust` |
| `--update` (`-u`) | 更新軟體套件 | `emerge -u vim` |
| `--deep` (`-D`) | 深度計算依賴 (更新依賴的依賴) | `emerge -uD @world` |
| `--newuse` (`-N`) | USE 標誌改變時重新編譯 | `emerge -uDN @world` |
| `--depclean` (`-c`) | 清理不再需要的孤立依賴 | `emerge -c` |
| `--deselect` | 從 World 檔案中移除 (不解除安裝) | `emerge --deselect vim` |
| `--search` (`-s`) | 搜尋軟體套件 (推薦用 eix) | `emerge -s vim` |
| `--info` | 顯示 Portage 環境資訊 (除錯用) | `emerge --info` |

**3. 快速搜尋軟體套件 (Eix)**
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Eix](https://wiki.gentoo.org/wiki/Eix)

</div>
> `emerge --search` 速度較慢，推薦使用 `eix` 進行毫秒級搜尋。

1.  **安裝與更新索引**：
    ```bash
    emerge --ask app-portage/eix
    eix-update # 安裝後或同步後執行
    ```
2.  **搜尋軟體**：
    ```bash
    eix <關鍵詞>        # 搜尋所有軟體
    eix -I <關鍵詞>     # 僅搜尋已安裝軟體
    eix -R <關鍵詞>     # 搜尋遠端 Overlay (需配置 eix-remote)
    ```

---

## 14. 進階編譯最佳化 [可選]

為了提升後續的編譯速度，建議配置 tmpfs 和 ccache。

### 14.1 配置 tmpfs (記憶體編譯)

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Tmpfs](https://wiki.gentoo.org/wiki/Tmpfs)

</div>

將編譯臨時目錄掛載到記憶體，減少 SSD 磨損並加速編譯。

<details>
<summary><b>Tmpfs 配置指南（點選展開）</b></summary>

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

`size` 大小不要超過你的物理記憶體大小（建議設為記憶體的一半），否則可能導致系統不穩定。

</div>

編輯 `/etc/fstab`，新增以下行（size 建議設定為記憶體的一半，例如 16G）：
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

快取編譯中間產物，加快重新編譯速度。
```bash
emerge --ask dev-build/ccache
ccache -M 20G  # 設定快取大小為 20GB
```

### 14.3 處理大型軟體編譯 (避免 tmpfs 爆滿)

Firefox、LibreOffice 等大型軟體編譯時可能會耗盡 tmpfs 空間。我們可以配置 Portage 讓這些特定軟體使用硬碟進行編譯。

<details>
<summary><b>Notmpfs 配置指南（點選展開）</b></summary>

1. 建立配置目錄：
   ```bash
   mkdir -p /etc/portage/env
   mkdir -p /var/tmp/notmpfs
   ```

2. 建立 `notmpfs.conf`：
   ```bash
   echo 'PORTAGE_TMPDIR="/var/tmp/notmpfs"' > /etc/portage/env/notmpfs.conf
   ```

3. 針對特定軟體應用配置：
   編輯 `/etc/portage/package.env` (如果是目錄則建立檔案)：
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

### 14.4 LTO 與 Clang 最佳化

詳細配置請參考 **Section 15 進階編譯最佳化**。

---

## 15. LTO 與 Clang 編譯最佳化 (可選)

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**風險提示**

LTO 會顯著增加編譯時間和記憶體消耗，且可能導致部分軟體編譯失敗。**強烈不建議全域性開啟**，僅推薦針對特定軟體（如瀏覽器）開啟。

</div>

### 15.1 連結時最佳化 (LTO)
<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[LTO](https://wiki.gentoo.org/wiki/LTO)

</div>

LTO (Link Time Optimization) 將最佳化推遲到連結階段，可帶來效能提升和體積減小。

<details style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1rem; border-radius: 0.75rem; margin: 1rem 0; border: 1px solid rgba(59, 130, 246, 0.2);">
<summary style="cursor: pointer; font-weight: bold; color: #1d4ed8;">LTO 優缺點詳細分析（點選展開）</summary>

<div style="margin-top: 1rem;">

**優勢**：
*   效能提升（通常兩位數）
*   二進位制體積減小
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

如果你的系統是 4 核 CPU 配 4GB 記憶體，那麼花在編譯上的時間可能遠超最佳化帶來的效能提升。請根據硬體配置權衡利弊。

</div>

**1. 使用 USE 標誌開啟 (最推薦)**

對於 Firefox 和 Chromium 等大型軟體，官方 ebuild 通常提供了經過測試的 `lto` 和 `pgo` USE 標誌：

在 `/etc/portage/package.use/browser` 中啟用：
```text
www-client/firefox lto pgo
www-client/chromium lto pgo  # 注意：PGO 在 Wayland 環境下可能無法使用
```

**USE="lto" 標誌說明**：部分軟體套件需要特殊修復才能支援 LTO，可以全域性或針對特定軟體套件啟用 `lto` USE 標誌：
```bash
# 在 /etc/portage/make.conf 中全域性啟用
USE="lto"
```

**2. 針對特定軟體套件啟用 LTO (推薦)**

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

**3. 全域性啟用 LTO (GCC 系統)**

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

全域性 LTO 會導致大量軟體套件編譯失敗，需要頻繁維護排除列表，**不建議新手嘗試**。

</div>

編輯 `/etc/portage/make.conf`：
```bash
# 這些警告指示 LTO 可能導致的執行時問題，將其提升為錯誤
# -Werror=odr: One Definition Rule 違規（多次定義同一符號）
# -Werror=lto-type-mismatch: LTO 類別型不匹配
# -Werror=strict-aliasing: 嚴格別名違規
WARNING_FLAGS="-Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing"

# -O2: 最佳化級別 2（推薦）
# -pipe: 使用管道加速編譯
# -march=native: 針對當前 CPU 最佳化
# -flto: 啟用連結時最佳化（Full LTO）
# 注意：GCC 的 -flto 預設使用 Full LTO，適合 GCC 系統
COMMON_FLAGS="-O2 -pipe -march=native -flto ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 編譯器標誌
CXXFLAGS="${COMMON_FLAGS}"        # C++ 編譯器標誌
FCFLAGS="${COMMON_FLAGS}"         # Fortran 編譯器標誌
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 編譯器標誌
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 連結器標誌

USE="lto"  # 啟用 LTO 支援的 USE 標誌
```

**4. 全域性啟用 LTO (LLVM/Clang 系統 - 推薦使用 ThinLTO)**

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**預設推薦**

如果使用 Clang，強烈推薦使用 ThinLTO (`-flto=thin`) 而非 Full LTO (`-flto`)。ThinLTO 速度更快，記憶體佔用更少，支援並行化。

</div>

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

如果 `clang-common` 未啟用 `default-lld` USE 標誌，必須在 `LDFLAGS` 中新增 `-fuse-ld=lld`。

</div>

編輯 `/etc/portage/make.conf`：
```bash
# Clang 目前尚未完全實現這些診斷，但保留這些標誌以備將來使用
# -Werror=odr: One Definition Rule 違規檢測（Clang 部分支援）
# -Werror=strict-aliasing: 嚴格別名違規檢測（Clang 正在開發）
WARNING_FLAGS="-Werror=odr -Werror=strict-aliasing"

# -O2: 最佳化級別 2（平衡效能與穩定性）
# -pipe: 使用管道加速編譯
# -march=native: 針對當前 CPU 最佳化
# -flto=thin: 啟用 ThinLTO（推薦，速度快且並行化）
COMMON_FLAGS="-O2 -pipe -march=native -flto=thin ${WARNING_FLAGS}"
CFLAGS="${COMMON_FLAGS}"          # C 編譯器標誌
CXXFLAGS="${COMMON_FLAGS}"        # C++ 編譯器標誌
FCFLAGS="${COMMON_FLAGS}"         # Fortran 編譯器標誌
FFLAGS="${COMMON_FLAGS}"          # Fortran 77 編譯器標誌
LDFLAGS="${COMMON_FLAGS} ${LDFLAGS}"  # 連結器標誌

USE="lto"  # 啟用 LTO 支援的 USE 標誌
```

**ThinLTO vs Full LTO（推薦新手閱讀）**：

| 類別型 | 標誌 | 優勢 | 劣勢 | 推薦場景 |
|------|------|------|------|----------|
| **ThinLTO** | `-flto=thin` | • 速度快<br>• 記憶體佔用少<br>• 支援並行化<br>• 編譯速度提升 2-3 倍 | • 僅 Clang/LLVM 支援 | **預設推薦**（Clang 使用者） |
| Full LTO | `-flto` | • 更深度的最佳化<br>• GCC 和 Clang 均支援 | • 速度慢<br>• 記憶體佔用高<br>• 序列處理 | GCC 使用者或需要極致最佳化時 |

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

如果你使用 Clang，請務必使用 `-flto=thin`。這是目前的最佳實踐，能在保證效能的同時大幅減少編譯時間。

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

在 `/etc/portage/package.env` 中為 Rust 軟體套件指定：
```text
dev-lang/rust llvm-lto.conf
```

### 15.3 進階軟體套件環境配置 (package.env)

針對特定軟體套件的特殊配置（如停用 LTO 或低記憶體模式），可以使用 `package.env` 進行精細控制。

<details>
<summary><b>配置 1：停用 LTO 的軟體套件列表 (no-lto) - 點選展開</b></summary>

某些軟體套件已知與 LTO 不相容。建議建立 `/etc/portage/env/nolto.conf`：

```bash
# 停用 LTO 及相關警告
DISABLE_LTO="-Wno-error=odr -Wno-error=lto-type-mismatch -Wno-error=strict-aliasing -fno-lto"
CFLAGS="${CFLAGS} ${DISABLE_LTO}"
CXXFLAGS="${CXXFLAGS} ${DISABLE_LTO}"
FCFLAGS="${FCFLAGS} ${DISABLE_LTO}"
FFLAGS="${FFLAGS} ${DISABLE_LTO}"
LDFLAGS="${LDFLAGS} ${DISABLE_LTO}"
```

建立 `/etc/portage/package.env/no-lto` 檔案（包含已知問題套件）：

```bash
# 已知與 LTO 有相容性問題的套件
# 仍使用 Clang 編譯，但停用 LTO

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
<summary><b>配置 2：低記憶體編譯模式 (low-memory) - 點選展開</b></summary>

對於大型專案（如 Chromium, Rust），建議使用低記憶體配置以防止 OOM。

建立 `/etc/portage/env/low-memory.conf`：
```bash
# 減少並行任務數，例如改為 -j2 或 -j4
MAKEOPTS="-j4"
# 可選：移除一些耗記憶體的最佳化標誌
COMMON_FLAGS="-O2 -pipe"
```

建立 `/etc/portage/package.env/low-memory`：
```bash
# 容易導致系統卡死的大型套件
# 使用低記憶體編譯設定

# 瀏覽器類別 (極大型專案)
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

如果遇到其他 LTO 相關的連結錯誤，請先嘗試停用該套件的 LTO。也可以檢視 [Gentoo Bugzilla](https://bugs.gentoo.org) 搜尋是否已有相關報告（搜尋"軟體套件名 lto"）。如果是新問題，歡迎提交 bug 報告幫助改進 Gentoo。

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

**1. 針對特定軟體開啟 (推薦)**

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



**3. PGO 支援（配置檔案引導最佳化）**

<div style="background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(217, 119, 6, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(245, 158, 11); margin: 1.5rem 0;">

**注意**

如果需要 PGO 支援（如 `dev-lang/python[pgo]`），需要安裝以下套件：

</div>

```bash
emerge --ask llvm-core/clang-runtime
emerge --ask llvm-runtimes/compiler-rt-sanitizers
```

在 `/etc/portage/package.use` 中啟用相關 USE 標誌：
```text
llvm-core/clang-runtime sanitize
llvm-runtimes/compiler-rt-sanitizers profile orc
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**警告**

- 如果沒有啟用 `profile` 和 `orc` USE 標誌，帶有 `pgo` USE 標誌的軟體套件（如 `dev-lang/python[pgo]`）會編譯失敗。
- 編譯日誌可能會報錯：`ld.lld: error: cannot open /usr/lib/llvm/18/bin/../../../../lib/clang/18/lib/linux/libclang_rt.profile-x86_64.a`

</div>

**4. 全域性開啟 (不建議初學者)**

全域性切換到 Clang 需要系統大部分軟體支援，且需要處理大量相容性問題，**僅建議高階使用者嘗試**。

如需全域性啟用，在 `/etc/portage/make.conf` 中新增：
```bash
CC="clang"
CXX="clang++"
CPP="clang-cpp"
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```

**GCC 回退環境**

對於無法使用 Clang 編譯的軟體套件，建立 `/etc/portage/env/gcc.conf`：
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

本節面向希望深入掌控核心編譯的高階使用者，包括使用 LLVM/Clang 編譯、啟用 LTO 最佳化、自動化配置等。

### 16.1 準備工作

安裝必要工具：
```bash
# 安裝核心原始碼和構建工具
emerge --ask sys-kernel/gentoo-sources

# （可選）安裝 Genkernel 用於自動化
emerge --ask sys-kernel/genkernel

# （可選）使用 LLVM/Clang 編譯需要
emerge --ask llvm-core/llvm \
    llvm-core/clang llvm-core/lld
```

### 16.2 檢視系統資訊（硬體檢測）

在配置核心前，瞭解你的硬體非常重要：

**檢視 CPU 資訊**：
```bash
lscpu  # 檢視 CPU 型號、核心數、架構等
cat /proc/cpuinfo | grep "model name" | head -1  # CPU 型號
```

**檢視 PCI 裝置（顯示卡、網絡卡等）**：
```bash
lspci -k  # 列出所有 PCI 裝置及當前使用的驅動
lspci | grep -i vga  # 檢視顯示卡
lspci | grep -i network  # 檢視網絡卡
```

**檢視 USB 裝置**：
```bash
lsusb  # 列出所有 USB 裝置
```

**檢視已載入的核心模組**：
```bash
lsmod  # 列出當前載入的所有模組
lsmod | wc -l  # 模組數量
```

### 16.3 根據當前模組自動配置核心

如果你想保留當前系統（如 LiveCD）所有正常工作的硬體支援：

```bash
cd /usr/src/linux

# 方法 1：基於當前載入的模組建立最小化配置
make localmodconfig
# 這會只啟用當前載入模組對應的核心選項（強烈推薦！）

# 方法 2：基於當前執行核心的配置建立
zcat /proc/config.gz > .config  # 如果當前核心支援
make olddefconfig  # 使用預設值更新配置
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

`localmodconfig` 是最安全的方法，它會確保你的硬體都能正常工作，同時移除不需要的驅動。

</div>

### 16.4 手動配置核心選項

**進入配置介面**：
```bash
cd /usr/src/linux
make menuconfig  # 文字介面（推薦）
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

**常用選項對照表**：

| 英文選項 | 中文說明 | 關鍵配置 |
| :--- | :--- | :--- |
| **General setup** | 通用設定 | 本機主機名、Systemd/OpenRC 支援 |
| **Processor type and features** | 處理器類別型與特性 | CPU 型號選擇、微碼載入 |
| **Power management and ACPI options** | 電源管理與 ACPI | 筆記型電腦電源管理、掛起/休眠 |
| **Bus options (PCI etc.)** | 匯流排選項 | PCI 支援 (lspci) |
| **Virtualization** | 虛擬化 | KVM, VirtualBox 宿主/客戶機支援 |
| **Enable loadable module support** | 可載入模組支援 | 允許使用核心模組 (*.ko) |
| **Networking support** | 網路支援 | TCP/IP 協議棧、防火牆 (Netfilter) |
| **Device Drivers** | 裝置驅動 | 顯示卡、網絡卡、音效卡、USB、NVMe 驅動 |
| **File systems** | 檔案系統 | ext4, btrfs, vfat, ntfs 支援 |
| **Security options** | 安全選項 | SELinux, AppArmor |
| **Gentoo Linux** | Gentoo 特有選項 | Portage 依賴項自動選擇 (推薦) |

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**重要建議**

對於手動編譯，建議將**關鍵驅動**（如檔案系統、磁碟控制器、網絡卡）直接編譯進核心（選擇 `[*]` 或 `<*>` 即 `=y`），而不是作為模組（`<M>` 即 `=m`）。這樣可以避免 initramfs 缺失模組導致無法啟動的問題。

</div>

**必需啟用的選項**（根據你的系統）：

1. **處理器支援**：
   - `General setup → Gentoo Linux support`
   - `Processor type and features → Processor family` (選擇你的 CPU)

2. **檔案系統**：
   - `File systems → The Extended 4 (ext4) filesystem` (如果使用 ext4)
   - `File systems → Btrfs filesystem` (如果使用 Btrfs)

3. **裝置驅動**：
   - `Device Drivers → Network device support` (網絡卡驅動)
   - `Device Drivers → Graphics support` (顯示卡驅動)

4. **Systemd 使用者必需**：
   - `General setup → Control Group support`
   - `General setup → Namespaces support`

5. **Gentoo Linux 專有選項**（推薦全部啟用）：
   
   進入 `Gentoo Linux --->` 選單：
   
   ```
   [*] Gentoo Linux support
       啟用 Gentoo 特定的核心功能支援
   
   [*] Linux dynamic and persistent device naming (userspace devfs) support
       啟用 udev 動態裝置管理支援（必需）
   
   [*] Select options required by Portage features
       自動啟用 Portage 需要的核心選項（強烈推薦）
       這會自動配置必需的檔案系統和核心功能
   
   Support for init systems, system and service managers --->
       ├─ [*] OpenRC support  # 如果使用 OpenRC
       └─ [*] systemd support # 如果使用 systemd
   
   [*] Kernel Self Protection Project
       啟用核心自我保護機制（提高安全性）
   
   [*] Print firmware information that the kernel attempts to load
       在啟動時顯示韌體載入資訊（便於除錯）
   ```

 <div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**新手提示**

啟用 "Select options required by Portage features" 可以自動配置大部分必需選項，非常推薦！

</div>

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

在 menuconfig 中，按 `/` 可以搜尋選項，按 `?` 檢視幫助。

</div>

### 16.5 自動啟用推薦選項

Gentoo 提供了自動化指令碼來啟用常見硬體和功能：

```bash
cd /usr/src/linux

# 使用 Genkernel 的預設配置（包含大多數硬體支援）
genkernel --kernel-config=/usr/share/genkernel/arch/x86_64/kernel-config all

# 或者使用發行版預設配置作為基礎
make defconfig  # 核心預設配置
# 然後再根據需要調整
make menuconfig
```

### 16.6 使用 LLVM/Clang 編譯核心

使用 LLVM/Clang 編譯核心可以獲得更好的最佳化和更快的編譯速度（支援 ThinLTO）。

**方法 1：指定編譯器**（一次性）：
```bash
cd /usr/src/linux

# 使用 Clang 編譯
make LLVM=1 -j$(nproc)

# 使用 Clang + LTO（推薦）
make LLVM=1 LLVM_IAS=1 -j$(nproc)
```

**方法 2：設定環境變數**（永久）：
在 `/etc/portage/make.conf` 中新增（僅影響核心編譯）：
```bash
# 使用 LLVM/Clang 編譯核心
KERNEL_CC="clang"
KERNEL_LD="ld.lld"
```

**啟用核心 LTO 支援**：
在 `make menuconfig` 中：
```
General setup
  → Compiler optimization level → Optimize for performance  # 選擇 -O2（推薦）
  → Link Time Optimization (LTO) → Clang ThinLTO (NEW)      # 啟用 ThinLTO（強烈推薦）
```

<div style="background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(239, 68, 68); margin: 1.5rem 0;">

**重要警告：核心編譯時強烈不建議使用 Full LTO！**

*   Full LTO 會導致編譯極其緩慢（可能需要數小時）
*   佔用大量記憶體（可能需要 16GB+ RAM）
*   容易導致連結錯誤
*   **請務必使用 ThinLTO**，它更快、更穩定、記憶體佔用更少

</div>

### 16.7 核心編譯選項最佳化

<details>
<summary><b>高階編譯最佳化（點選展開）</b></summary>

**在 `menuconfig` 中啟用**：

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
     # 其他選項：LZ4（最快）、XZ（最小）、GZIP（相容性最好）
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

# 啟用 LTO（需要手動配置 .config）
genkernel --kernel-make-opts="LLVM=1" --install all
```

### 16.9 核心統計與分析

編譯完成後，使用以下指令碼檢視核心統計資訊：

```bash
cd /usr/src/linux

echo "=== 核心統計 ==="
echo "Built-in: $(grep -c '=y$' .config)"
echo "模組: $(grep -c '=m$' .config)"
echo "總配置: $(wc -l < .config)"
echo "核心大小: $(ls -lh arch/x86/boot/bzImage 2>/dev/null | awk '{print $5}')"
echo "壓縮方式: $(grep '^CONFIG_KERNEL_' .config | grep '=y' | sed 's/CONFIG_KERNEL_//;s/=y//')"
```

**範例輸出**：
```
=== 核心統計 ===
Built-in: 1723
模組: 201
總配置: 6687
核心大小: 11M
壓縮方式: ZSTD
```

**解讀**：
- **Built-in (1723)**：編譯進核心本體的功能數量
- **模組 (201)**：作為可載入模組的驅動數量
- **核心大小 (11M)**：最終核心檔案大小（使用 ZSTD 壓縮後）

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 1.5rem; border-radius: 0.75rem; border-left: 4px solid rgb(34, 197, 94); margin: 1.5rem 0;">

**最佳化建議**

*   核心大小 < 15MB：優秀（精簡配置）
*   核心大小 15-30MB：良好（標準配置）
*   核心大小 > 30MB：考慮停用不需要的功能

</div>

### 16.10 常見問題排查

<details>
<summary><b>編譯錯誤與解決方案（點選展開）</b></summary>

**錯誤 1：缺少依賴**
```
*** No rule to make target 'debian/canonical-certs.pem'
```
解決：停用簽名證書
```bash
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
make olddefconfig
```

**錯誤 2：LTO 編譯失敗**
```
ld.lld: error: undefined symbol
```
解決：某些模組不相容 LTO，停用 LTO 或將問題模組設為 `=y`（而非 `=m`）

**錯誤 3：clang 版本過舊**
```
error: unknown argument: '-mretpoline-external-thunk'
```
解決：升級 LLVM/Clang 或使用 GCC 編譯

</details>

### 16.11 核心配置最佳實踐

1. **儲存配置**：
   ```bash
   # 儲存當前配置到外部檔案
   cp .config ~/kernel-config-backup
   
   # 恢復配置
   cp ~/kernel-config-backup /usr/src/linux/.config
   make olddefconfig
   ```

2. **檢視配置差異**：
   ```bash
   # 對比兩個配置檔案
   scripts/diffconfig .config ../old-kernel/.config
   ```

3. **最小化配置**（僅包含必需功能）：
   ```bash
   make tinyconfig  # 建立極簡配置
   make localmodconfig  # 然後新增當前硬體支援
   ```

---

## 17. 伺服器與 RAID 配置 (可選) {#section-17-server-raid}

<div style="background: rgba(59, 130, 246, 0.08); padding: 0.75rem 1rem; border-radius: 0.5rem; border-left: 3px solid rgb(59, 130, 246); margin: 1rem 0;">

**可參考**：[Gentoo Wiki: Mdadm](https://wiki.gentoo.org/wiki/Mdadm)

</div>

本節適用於需要配置軟 RAID (mdadm) 的伺服器使用者。

### 17.1 核心配置 (手動編譯必選)

如果你手動編譯核心，必須啟用以下選項（**注意：必須編譯進核心 `<*>` 即 `=y`，不能是模組 `<M>`**）：

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

### 17.2 配置 Dracut 載入 RAID 模組 (dist-kernel 必選)

如果你使用 `dist-kernel`（發行版核心）或者將 RAID 驅動編譯為了模組，**必須**透過 Dracut 強制載入 RAID 驅動，否則無法開機。

<details>
<summary><b>Dracut RAID 配置指南（點選展開）</b></summary>

**1. 啟用 mdraid 支援**
建立 `/etc/dracut.conf.d/mdraid.conf`：
```bash
# Enable mdraid support for RAID arrays
add_dracutmodules+=" mdraid "
mdadmconf="yes"
```

**2. 強制載入 RAID 驅動**
建立 `/etc/dracut.conf.d/raid-modules.conf`：
```bash
# Ensure RAID modules are included and loaded
add_drivers+=" raid1 raid0 raid10 raid456 "
force_drivers+=" raid1 "
# Install modprobe configuration
install_items+=" /usr/lib/modules-load.d/ /etc/modules-load.d/ "
```

**3. 配置核心指令行引數 (UUID)**
你需要找到 RAID 陣列的 UUID 並新增到核心引數中。
建立 `/etc/dracut.conf.d/mdraid-cmdline.conf`：
```bash
# Kernel command line parameters for RAID arrays
# 請替換為你實際的 RAID UUID (透過 mdadm --detail --scan 檢視)
kernel_cmdline="rd.md.uuid=68b53b0a:c6bd2ca0:caed4380:1cd75aeb rd.md.uuid=c8f92d69:59d61271:e8ffa815:063390ed"
```

**4. 重新生成 initramfs**
```bash
dracut --force
```

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem; margin: 1.5rem 0;">

**提示**

配置完成後，務必檢查 `/boot/initramfs-*.img` 是否包含 RAID 模組：

</div>
> `lsinitrd /boot/initramfs-*.img | grep raid`

</details>

---

## 參考資料 {#reference}

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin: 1.5rem 0;">

<div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(37, 99, 235, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 官方檔案

- **[Gentoo Handbook: AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64)** 官方最新指南
- [Gentoo Wiki](https://wiki.gentoo.org/)
- [Portage Documentation](https://wiki.gentoo.org/wiki/Portage)

</div>

<div style="background: linear-gradient(135deg, rgba(139, 92, 246, 0.1), rgba(124, 58, 237, 0.05)); padding: 1.5rem; border-radius: 0.75rem;">

### 社群支援

**Gentoo 中文社群**：
- Telegram 群組：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 頻道：[@gentoocn](https://t.me/gentoocn)
- [GitHub](https://github.com/gentoo-zh)

**官方社群**：
- [Gentoo Forums](https://forums.gentoo.org/)
- IRC: `#gentoo` @ [Libera.Chat](https://libera.chat/)

</div>

</div>

## 結語

<div style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(22, 163, 74, 0.05)); padding: 2rem; border-radius: 1rem; margin: 1.5rem 0; text-align: center;">

### 祝你在 Gentoo 上享受自由與靈活！

這份指南基於官方 [Handbook:AMD64](https://wiki.gentoo.org/wiki/Handbook:AMD64) 並簡化流程，標記了可選步驟，讓更多人能輕鬆嘗試。

</div>
