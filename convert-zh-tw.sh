#!/bin/bash

SOURCE_FILE=$1
TARGET_FILE=$2

if [ -z "$SOURCE_FILE" ] || [ -z "$TARGET_FILE" ]; then
    echo "Usage: $0 <source_file> <target_file>"
    exit 1
fi

# Check if opencc is installed
if ! command -v opencc &> /dev/null; then
    echo "Error: opencc is not installed. Please run: brew install opencc"
    exit 1
fi

# Use OpenCC for simplified to traditional Chinese conversion
echo "Converting simplified Chinese to traditional Chinese using OpenCC..."
opencc -i "$SOURCE_FILE" -o "$TARGET_FILE" -c s2tw.json

# Perform Taiwan localization replacements using sed
echo "Applying Taiwan localization..."

# =============================================================================
# Taiwan-specific Computer Terms (must run before other replacements)
# =============================================================================

# File system related terms (文件系统 -> 檔案系統)
sed -i '' 's/文件系統/檔案系統/g' "$TARGET_FILE"
sed -i '' 's/文件系统/檔案系統/g' "$TARGET_FILE"

sed -i '' 's/偽文件系統/偽檔案系統/g' "$TARGET_FILE"

# Software/Package terms
sed -i '' 's/軟件包/軟體套件/g' "$TARGET_FILE"
sed -i '' 's/軟件/軟體/g' "$TARGET_FILE"
sed -i '' 's/包管理/套件管理/g' "$TARGET_FILE"
sed -i '' 's/二進制/二進位/g' "$TARGET_FILE"
sed -i '' 's/二進位包/二進位套件/g' "$TARGET_FILE"

# Hardware and firmware
sed -i '' 's/固件/韌體/g' "$TARGET_FILE"
sed -i '' 's/硬盤/硬碟/g' "$TARGET_FILE"
sed -i '' 's/U盤/隨身碟/g' "$TARGET_FILE"
sed -i '' 's/鼠标/滑鼠/g' "$TARGET_FILE"
sed -i '' 's/鼠標/滑鼠/g' "$TARGET_FILE"
sed -i '' 's/硬件/硬體/g' "$TARGET_FILE"
sed -i '' 's/屏幕/螢幕/g' "$TARGET_FILE"
sed -i '' 's/顯卡/顯示卡/g' "$TARGET_FILE"
sed -i '' 's/顯示卡驅動/顯示卡驅動程式/g' "$TARGET_FILE"

sed -i '' 's/獨顯/獨顯/g' "$TARGET_FILE"
sed -i '' 's/核顯/內顯/g' "$TARGET_FILE"

# Program/Script/Process/Kernel
sed -i '' 's/程序/程式/g' "$TARGET_FILE"
sed -i '' 's/脚本/腳本/g' "$TARGET_FILE"
sed -i '' 's/腳本/指令碼/g' "$TARGET_FILE"  # Taiwan commonly uses 指令碼 instead of 腳本
sed -i '' 's/引導程序/引導程式/g' "$TARGET_FILE"
sed -i '' 's/線程/執行緒/g' "$TARGET_FILE"
sed -i '' 's/進程/行程/g' "$TARGET_FILE"
sed -i '' 's/守護進程/守護行程/g' "$TARGET_FILE"
sed -i '' 's/內核/核心/g' "$TARGET_FILE"
sed -i '' 's/計算機/電腦/g' "$TARGET_FILE"
sed -i '' 's/代碼/程式碼/g' "$TARGET_FILE"
sed -i '' 's/链接/連結/g' "$TARGET_FILE"
sed -i '' 's/鏈接/連結/g' "$TARGET_FILE"
sed -i '' 's/軟鏈接/軟連結/g' "$TARGET_FILE"
sed -i '' 's/硬鏈接/硬連結/g' "$TARGET_FILE"
sed -i '' 's/符號鏈接/符號連結/g' "$TARGET_FILE"
sed -i '' 's/符號链接/符號連結/g' "$TARGET_FILE"

# Network terms
sed -i '' 's/網絡/網路/g' "$TARGET_FILE"
sed -i '' 's/互聯網/網際網路/g' "$TARGET_FILE"
sed -i '' 's/服務器/伺服器/g' "$TARGET_FILE"
sed -i '' 's/協議/協定/g' "$TARGET_FILE"

# Localization/System terms
sed -i '' 's/本地化/本機化/g' "$TARGET_FILE"
sed -i '' 's/本地/本機/g' "$TARGET_FILE"
sed -i '' 's/默認/預設/g' "$TARGET_FILE"
sed -i '' 's/支持/支援/g' "$TARGET_FILE"
sed -i '' 's/配置/設定/g' "$TARGET_FILE"
sed -i '' 's/設置/設定/g' "$TARGET_FILE"
sed -i '' 's/帳戶/帳號/g' "$TARGET_FILE"
sed -i '' 's/賬戶/帳號/g' "$TARGET_FILE"
sed -i '' 's/權限/權限/g' "$TARGET_FILE"
sed -i '' 's/登錄/登入/g' "$TARGET_FILE"
sed -i '' 's/註銷/登出/g' "$TARGET_FILE"
sed -i '' 's/重啟/重新啟動/g' "$TARGET_FILE"
sed -i '' 's/内存/記憶體/g' "$TARGET_FILE"
sed -i '' 's/內存/記憶體/g' "$TARGET_FILE"
sed -i '' 's/存储/儲存/g' "$TARGET_FILE"
sed -i '' 's/存儲/儲存/g' "$TARGET_FILE"
sed -i '' 's/数据库/資料庫/g' "$TARGET_FILE"
sed -i '' 's/數據庫/資料庫/g' "$TARGET_FILE"
sed -i '' 's/数据/資料/g' "$TARGET_FILE"
sed -i '' 's/數據/資料/g' "$TARGET_FILE"

# Interface/Display
sed -i '' 's/界面/介面/g' "$TARGET_FILE"
sed -i '' 's/分辨率/解析度/g' "$TARGET_FILE"
sed -i '' 's/菜單/選單/g' "$TARGET_FILE"
sed -i '' 's/窗口/視窗/g' "$TARGET_FILE"
sed -i '' 's/高清/高畫質/g' "$TARGET_FILE"
sed -i '' 's/光标/游標/g' "$TARGET_FILE"
sed -i '' 's/光標/游標/g' "$TARGET_FILE"

# Documentation/Files/Misc
sed -i '' 's/文檔/文件/g' "$TARGET_FILE"
sed -i '' 's/信息/資訊/g' "$TARGET_FILE"
sed -i '' 's/查找/尋找/g' "$TARGET_FILE"
sed -i '' 's/命令/指令/g' "$TARGET_FILE"
sed -i '' 's/終端/終端機/g' "$TARGET_FILE"
sed -i '' 's/密鑰/金鑰/g' "$TARGET_FILE"

# Mirror/Image terminology (order matters!)
# First: Handle specific compound terms that should keep "鏡像"
sed -i '' 's/鏡像站/鏡像站/g' "$TARGET_FILE"           # Keep as is
sed -i '' 's/鏡像源/鏡像站/g' "$TARGET_FILE"           # 鏡像源 -> 鏡像站
sed -i '' 's/鏡像列表/鏡像列表/g' "$TARGET_FILE"       # Keep as is
sed -i '' 's/镜像列表/鏡像列表/g' "$TARGET_FILE"       # 镜像列表 -> 鏡像列表
sed -i '' 's/鏡像加速/鏡像加速/g' "$TARGET_FILE"       # Keep as is

# Then: Handle ISO images (should become 映像檔)
sed -i '' 's/ISO 鏡像/ISO 映像檔/g' "$TARGET_FILE"

# Finally: Convert remaining standalone "鏡像" in specific contexts
# Note: We keep most "鏡像" (mirror) as is, only convert in specific contexts
# Do NOT use a blanket 's/鏡像/映像檔/g' as it breaks mirror terminology

sed -i '' 's/並行/平行/g' "$TARGET_FILE"
sed -i '' 's/交互/互動/g' "$TARGET_FILE"
sed -i '' 's/音頻/音訊/g' "$TARGET_FILE"
sed -i '' 's/視頻/影片/g' "$TARGET_FILE"
sed -i '' 's/在线/線上/g' "$TARGET_FILE"
sed -i '' 's/在線/線上/g' "$TARGET_FILE"
sed -i '' 's/离线/離線/g' "$TARGET_FILE"
sed -i '' 's/脱机/離線/g' "$TARGET_FILE"
sed -i '' 's/脫機/離線/g' "$TARGET_FILE"

# Device terms
sed -i '' 's/筆記本/筆記型電腦/g' "$TARGET_FILE"

# Advanced/High-end terminology
sed -i '' 's/高端/進階/g' "$TARGET_FILE"

# File Type Corrections (must run after other replacements)
sed -i '' 's/二進位文件/二進位檔案/g' "$TARGET_FILE"
sed -i '' 's/二進制文件/二進位檔案/g' "$TARGET_FILE"
sed -i '' 's/設定文件/設定檔/g' "$TARGET_FILE"
sed -i '' 's/簽名文件/簽名檔/g' "$TARGET_FILE"
sed -i '' 's/可執行文件/可執行檔/g' "$TARGET_FILE"
sed -i '' 's/外部文件/外部檔案/g' "$TARGET_FILE"
sed -i '' 's/驗證文件/驗證檔案/g' "$TARGET_FILE"

# =============================================================================
# Mirror Source Corrections for Taiwan
# Since we now include all regions in both versions, we keep all mirror URLs
# Only change: download links and default values (not the echo examples)
# =============================================================================

echo "Replacing mirror sources for Taiwan..."

# Fix ISO download links
sed -i '' 's|https://mirrors\.ustc\.edu\.cn/gentoo/releases/amd64/autobuilds/|http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/|g' "$TARGET_FILE"

# Fix Stage3 download links (in links command)
sed -i '' 's|links https://mirrors\.ustc\.edu\.cn/gentoo/releases/amd64/autobuilds/|links http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/|g' "$TARGET_FILE"

# Fix default GENTOO_MIRRORS value in examples (single line assignment, not in echo commands)
# This will be handled later with more specific patterns

# Fix default echo commands in section 5.1 (comment out mainland China default, uncomment Taiwan default)
# Comment out the USTC echo command
sed -i '' 's|^echo '\''GENTOO_MIRRORS="https://mirrors\.ustc\.edu\.cn/gentoo/"'\'' >> /etc/portage/make\.conf           # 中國科學技術大學|# echo '\''GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/"'\'' >> /etc/portage/make.conf           # 中國科學技術大學|g' "$TARGET_FILE"

# Uncomment the TWAREN echo command
sed -i '' 's|^# echo '\''GENTOO_MIRRORS="http://ftp\.twaren\.net/Linux/Gentoo/"'\'' >> /etc/portage/make\.conf          # NCHC|echo '\''GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"'\'' >> /etc/portage/make.conf          # NCHC|g' "$TARGET_FILE"

# Fix inline comments in make.conf examples
# Comment out China USTC mirror and uncomment Taiwan NCHC mirror
sed -i '' 's|^GENTOO_MIRRORS="https://mirrors\.ustc\.edu\.cn/gentoo/"  # 中國科學技術大學（推薦）|# GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/"  # 中國科學技術大學|g' "$TARGET_FILE"
sed -i '' 's|^# GENTOO_MIRRORS="http://ftp\.twaren\.net/Linux/Gentoo/"  # 台灣 NCHC|GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"  # NCHC（推薦）|g' "$TARGET_FILE"
sed -i '' 's|^# GENTOO_MIRRORS="http://ftp\.twaren\.net/Linux/Gentoo/"  # 臺灣 NCHC|GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"  # NCHC（推薦）|g' "$TARGET_FILE"

# Fix GENTOO_MIRRORS in make.conf section headers (without inline comment, single line)
sed -i '' 's|^GENTOO_MIRRORS="https://mirrors\.ustc\.edu\.cn/gentoo/"$|GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"|g' "$TARGET_FILE"

# Fix inline comments for legacy formats
sed -i '' 's|GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"                    # 中國科學技術大學（推薦）|GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"                    # NCHC（推薦）|g' "$TARGET_FILE"
sed -i '' 's|GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"                            |GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"                            # NCHC|g' "$TARGET_FILE"

# Fix comments mentioning examples
sed -i '' 's|以 USTC 映像檔站為例|以 TWAREN 映像檔站為例|g' "$TARGET_FILE"
sed -i '' 's|#以 USTC 映像檔站為例|#以 TWAREN 映像檔站為例|g' "$TARGET_FILE"
sed -i '' 's|下載 Minimal ISO（以 USTC 映像檔站為例）：|下載 Minimal ISO（以 TWAREN 映像檔站為例）：|g' "$TARGET_FILE"
sed -i '' 's|以中國科學技術大學鏡像為例|以 NCHC 鏡像為例|g' "$TARGET_FILE"
sed -i '' 's|（以中國科學技術大學鏡像為例）|（以 NCHC 鏡像為例）|g' "$TARGET_FILE"

# Fix recommendation comments (only for the active/default lines, not all region labels)
# Pattern: "# 中国大陆镜像（推荐）：" at start of line -> "# 台湾镜像（推荐）："
sed -i '' 's|^# 中國大陸鏡像（推薦）：|# 臺灣鏡像（推薦）：|g' "$TARGET_FILE"
sed -i '' 's|^# 中國大陸鏡像（推薦）$|# 臺灣鏡像（推薦）|g' "$TARGET_FILE"
sed -i '' 's|中國大陸映像檔（推薦）|台灣映像檔（推薦）|g' "$TARGET_FILE"
sed -i '' 's|中國大陸常用映像檔（任選其一）：|台灣常用映像檔（任選其一）：|g' "$TARGET_FILE"
sed -i '' 's|中國大陸常用鏡像（任選其一）：|台灣常用鏡像（任選其一）：|g' "$TARGET_FILE"

# Do NOT replace labels in commented-out sections like "# 香港："  - keep all regions intact

# Fix "国内推荐" comments (keeping region options intact)
sed -i '' 's|國內推薦：USTC、TUNA、ZJU 等|推薦根據地理位置選擇（台灣/香港/新加坡優先）|g' "$TARGET_FILE"
# Fix mirror section headers to be more neutral
sed -i '' 's|建議根據地理位置選擇（擇一或多個，空格分隔）|建議根據地理位置選擇（擇一或多個，空格分隔）|g' "$TARGET_FILE"
sed -i '' 's|更多映像檔請參考：https://www.gentoo.org.cn/mirrorlist/|更多映像檔請參考：https://www.gentoo.org.cn/mirrorlist/|g' "$TARGET_FILE"

# =============================================================================
# Git Repository Mirror Source Corrections
# For Taiwan version: Remove "需翻墙" hints, adjust default to GitHub
# =============================================================================

echo "Replacing Git repository sources..."

# Remove "需翻墙" / "可能需要国际网络" hints (not needed outside China)
sed -i '' 's|（需翻牆）||g' "$TARGET_FILE"
sed -i '' 's|（可能需要國際網路）||g' "$TARGET_FILE"
sed -i '' 's|可能需要國際網路||g' "$TARGET_FILE"

# Change default sync-uri to GitHub for Portage
sed -i '' 's|sync-uri = https://mirrors\.ustc\.edu\.cn/git/gentoo-portage\.git|sync-uri = https://github.com/gentoo-mirror/gentoo.git|g' "$TARGET_FILE"
sed -i '' 's|sync-uri = https://mirrors\.bfsu\.edu\.cn/git/gentoo-portage\.git|sync-uri = https://github.com/gentoo-mirror/gentoo.git|g' "$TARGET_FILE"

# Fix "可用的 Git 镜像源" section title
sed -i '' 's|可用的 Git 映像檔源：|可用的 Git 儲存庫：|g' "$TARGET_FILE"
sed -i '' 's|可用的 Gentoo Portage Git 鏡像站：|可用的 Gentoo Portage Git 鏡像站：|g' "$TARGET_FILE"

# Update section headers to be region-neutral
sed -i '' 's|- \*\*中國大陸\*\*：|- \*\*可用的 Portage Git 儲存庫（擇一）\*\*：|g' "$TARGET_FILE"
sed -i '' 's|- \*\*官方源（可能需要國際網路）\*\*：|- \*\*官方源\*\*：|g' "$TARGET_FILE"

# Remove "(推薦)" from China mirror descriptions in Taiwan version
sed -i '' 's|中國科學技術大學（推薦）|中國科學技術大學|g' "$TARGET_FILE"

# Update gentoo-zh overlay default to use GitHub
# Keep all mirror options but adjust documentation
sed -i '' 's|原始源（GitHub，可能需要國際網路）|官方源（GitHub）|g' "$TARGET_FILE"
sed -i '' 's|原始源（GitHub，）|官方源（GitHub）|g' "$TARGET_FILE"

# Don't delete China university mirrors - just keep them as options
# Users in Taiwan/HK/SG can still choose to use them if they want

echo "Taiwan localization completed successfully!"
