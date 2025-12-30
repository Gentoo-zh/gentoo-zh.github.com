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

# Taiwan-specific computer terms that OpenCC doesn't handle well
sed -i '' 's/软件包/軟體套件/g' "$TARGET_FILE"
sed -i '' 's/软件/軟體/g' "$TARGET_FILE"
sed -i '' 's/包管理/套件管理/g' "$TARGET_FILE"
sed -i '' 's/固件/韌體/g' "$TARGET_FILE"
sed -i '' 's/程序/程式/g' "$TARGET_FILE"
sed -i '' 's/脚本/腳本/g' "$TARGET_FILE"
sed -i '' 's/鼠标/滑鼠/g' "$TARGET_FILE"
sed -i '' 's/硬盘/硬碟/g' "$TARGET_FILE"
sed -i '' 's/U盘/隨身碟/g' "$TARGET_FILE"
sed -i '' 's/网络/網路/g' "$TARGET_FILE"
sed -i '' 's/互联网/網際網路/g' "$TARGET_FILE"
sed -i '' 's/服务器/伺服器/g' "$TARGET_FILE"
sed -i '' 's/本地/本機/g' "$TARGET_FILE"
sed -i '' 's/笔记本/筆記型電腦/g' "$TARGET_FILE"
sed -i '' 's/文档/文件/g' "$TARGET_FILE"

# =============================================================================
# Mirror Source Corrections for Taiwan
# Replace mainland China mirrors with Taiwan mirrors
# =============================================================================

echo "Replacing mirror sources for Taiwan..."

# Fix ISO download links
sed -i '' 's|https://mirrors\.bfsu\.edu\.cn/gentoo/releases/amd64/autobuilds/|http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/|g' "$TARGET_FILE"

# Fix Stage3 download links (in links command)
sed -i '' 's|links https://mirrors\.bfsu\.edu\.cn/gentoo/releases/amd64/autobuilds/|links http://ftp.twaren.net/Linux/Gentoo/releases/amd64/autobuilds/|g' "$TARGET_FILE"

# Fix GENTOO_MIRRORS configuration
sed -i '' 's|GENTOO_MIRRORS="https://mirrors\.bfsu\.edu\.cn/gentoo/"|GENTOO_MIRRORS="http://ftp.twaren.net/Linux/Gentoo/"|g' "$TARGET_FILE"
sed -i '' 's|https://mirrors\.tuna\.tsinghua\.edu\.cn/gentoo|http://ftp.twaren.net/Linux/Gentoo|g' "$TARGET_FILE"
sed -i '' 's|https://mirrors\.ustc\.edu\.cn/gentoo|http://ftp.twaren.net/Linux/Gentoo|g' "$TARGET_FILE"
sed -i '' 's|https://mirrors\.bfsu\.edu\.cn/gentoo|http://ftp.twaren.net/Linux/Gentoo|g' "$TARGET_FILE"
sed -i '' 's|https://mirrors\.sjtug\.sjtu\.edu\.cn/gentoo|http://ftp.twaren.net/Linux/Gentoo|g' "$TARGET_FILE"

# Fix echo command for GENTOO_MIRRORS
sed -i '' "s|echo 'GENTOO_MIRRORS=\"https://mirrors\\.bfsu\\.edu\\.cn/gentoo/\"'|echo 'GENTOO_MIRRORS=\"http://ftp.twaren.net/Linux/Gentoo/\"'|g" "$TARGET_FILE"

# Fix comments mentioning specific Chinese mirrors
sed -i '' 's|BFSU (北京外國語大學)|TWAREN (台灣學術網路)|g' "$TARGET_FILE"
sed -i '' 's|TUNA (清華大學)|NCHC (國家高速網路中心)|g' "$TARGET_FILE"
sed -i '' 's|USTC (中國科學技術大學)||g' "$TARGET_FILE"
sed -i '' 's|SJTU (上海交通大學)||g' "$TARGET_FILE"
sed -i '' 's|以 BFSU 鏡像站|以 TWAREN 鏡像站|g' "$TARGET_FILE"
sed -i '' 's|以 BFSU 鏡像站為例|以 TWAREN 鏡像站為例|g' "$TARGET_FILE"
sed -i '' 's|# 鏡像源 (BFSU)|# 鏡像源 (TWAREN)|g' "$TARGET_FILE"

# Remove empty mirror comment lines (from deleted USTC/SJTU)
sed -i '' '/^#   $/d' "$TARGET_FILE"

# Fix mirror list sections
sed -i '' 's|中國大陸常用鏡像（任選其一）：|台灣常用鏡像（任選其一）：|g' "$TARGET_FILE"
sed -i '' 's|中國大陸常用映象（任選其一）：|台灣常用映象（任選其一）：|g' "$TARGET_FILE"
sed -i '' 's|中国大陆常用镜像|台灣常用鏡像|g' "$TARGET_FILE"

# Fix comment about mirror selection
sed -i '' 's|國內鏡像|合適的鏡像|g' "$TARGET_FILE"
sed -i '' 's|国内鏡像|合適的鏡像|g' "$TARGET_FILE"
sed -i '' 's|国内镜像|合適的鏡像|g' "$TARGET_FILE"
sed -i '' 's|建議選擇國內鏡像加速|建議選擇合適的鏡像加速|g' "$TARGET_FILE"
sed -i '' 's|建議选择国内鏡像加速|建議選擇合適的鏡像加速|g' "$TARGET_FILE"
sed -i '' 's|选择国内镜像|選擇合適的鏡像|g' "$TARGET_FILE"

echo "Taiwan localization completed successfully!"
