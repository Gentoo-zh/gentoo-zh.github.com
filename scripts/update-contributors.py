#!/usr/bin/env python3
"""
更新貢獻者信息腳本
- 從 GitHub API 抓取貢獻者列表和詳細信息
- 下載並轉換頭像為 WebP 格式
- 更新每個貢獻者的提交次數、博客、Twitter 等信息
- 自動計算權重用於排序

使用方法:
    python3 scripts/update-contributors.py [選項]

選項:
    --min-commits N    只處理提交次數 >= N 的貢獻者 (默認: 10)
    --skip-avatars     跳過頭像下載
    --skip-info        跳過個人信息更新
    --dry-run          只顯示會做什麼,不實際修改文件
"""

import subprocess
import json
import os
import re
import sys
import argparse
from pathlib import Path

# 配置
REPO = "microcai/gentoo-zh"
CONTENT_DIR = "content/contributors"
AVATAR_SIZES = {
    "card": 200,      # 列表頁卡片頭像
    "single": 240     # 個人頁頭像
}
MIN_COMMITS_DEFAULT = 10


def run_command(cmd, check=True):
    """執行命令並返回結果"""
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=check
    )
    return result


def fetch_contributors():
    """從 GitHub 獲取貢獻者列表"""
    print("正在獲取貢獻者列表...")
    
    contributors = []
    page = 1
    
    while True:
        result = run_command([
            'gh', 'api',
            f'/repos/{REPO}/contributors?per_page=100&page={page}'
        ])
        
        data = json.loads(result.stdout)
        if not data:
            break
            
        contributors.extend(data)
        print(f"  已獲取第 {page} 頁: {len(data)} 位貢獻者")
        page += 1
    
    print(f"總共找到 {len(contributors)} 位貢獻者\n")
    return contributors


def fetch_user_info(login):
    """獲取用戶詳細信息"""
    result = run_command([
        'gh', 'api', f'/users/{login}'
    ])
    return json.loads(result.stdout)


def download_and_convert_avatar(login, avatar_url, dry_run=False):
    """下載並轉換頭像為 WebP"""
    contrib_dir = Path(CONTENT_DIR) / login
    
    if dry_run:
        print(f"  [DRY-RUN] 會下載頭像: {avatar_url}")
        return
    
    # 創建目錄
    contrib_dir.mkdir(parents=True, exist_ok=True)
    
    # 下載原始頭像
    temp_avatar = contrib_dir / "avatar_temp.png"
    run_command(['curl', '-sL', avatar_url, '-o', str(temp_avatar)])
    
    # 轉換為不同尺寸的 WebP
    for size_name, size in AVATAR_SIZES.items():
        output_file = contrib_dir / f"avatar_{size_name}.webp"
        run_command([
            'cwebp',
            '-q', '90',
            '-resize', str(size), str(size),
            str(temp_avatar),
            '-o', str(output_file)
        ], check=False)
    
    # 清理臨時文件
    temp_avatar.unlink()


def update_commits_only(login, commits, dry_run=False):
    """只更新提交次數和權重"""
    contrib_dir = Path(CONTENT_DIR) / login
    weight = 10000 - commits
    
    updated = False
    for lang in ['zh-cn', 'zh-tw']:
        file_path = contrib_dir / f"index.{lang}.md"
        if not file_path.exists():
            continue
        
        content = file_path.read_text(encoding='utf-8')
        
        # 更新 weight
        new_content = re.sub(
            r'^weight: \d+',
            f'weight: {weight}',
            content,
            flags=re.MULTILINE
        )
        
        # 更新提交次數
        new_content = re.sub(
            r'\d+ 次提交',
            f'{commits} 次提交',
            new_content
        )
        
        if new_content != content:
            if not dry_run:
                file_path.write_text(new_content, encoding='utf-8')
            updated = True
    
    return updated


def create_contributor_page(login, user_data, commits, dry_run=False):
    """創建或更新貢獻者頁面"""
    contrib_dir = Path(CONTENT_DIR) / login
    
    name = user_data.get('name') or login
    blog = (user_data.get('blog') or '').strip()
    twitter = (user_data.get('twitter_username') or '').strip()
    
    # 收集連結
    links = []
    if blog:
        if not blog.startswith('http'):
            blog = 'https://' + blog
        links.append({'name': 'blog', 'url': blog})
    
    if twitter:
        links.append({'name': 'twitter', 'url': f'https://twitter.com/{twitter}'})
    
    # 計算權重 (用於排序)
    weight = 10000 - commits
    
    # 確定標籤 (默認為 Overlay 貢獻者,管理員需手動設置)
    tag_cn = "Overlay 貢獻者"
    tag_tw = "Overlay 貢獻者"
    
    # 生成 frontmatter
    def generate_content(lang, tag):
        frontmatter = f"""---
title: "{name}"
tags: ['{tag}']
externalUrl: "https://github.com/{login}\""""
        
        if links:
            frontmatter += "\nlinks:"
            for link in links:
                frontmatter += f'\n  - name: "{link["name"]}"'
                frontmatter += f'\n    url: "{link["url"]}"'
        
        frontmatter += f"""
weight: {weight}
showDate: false
showAuthor: false
showReadingTime: false
showEdit: false
showLikes: false
showViews: false
layoutBackgroundHeaderSpace: false
---

{commits} 次提交
"""
        return frontmatter
    
    if dry_run:
        print(f"  [DRY-RUN] 會創建/更新: {login} ({name})")
        print(f"    提交: {commits}, 權重: {weight}, 標籤: {tag_cn}")
        if links:
            print(f"    連結: {', '.join(l['name'] for l in links)}")
        return
    
    # 創建目錄
    contrib_dir.mkdir(parents=True, exist_ok=True)
    
    # 寫入文件
    for lang, tag in [('zh-cn', tag_cn), ('zh-tw', tag_tw)]:
        file_path = contrib_dir / f"index.{lang}.md"
        content = generate_content(lang, tag)
        file_path.write_text(content, encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(
        description='更新 Gentoo 中文社區貢獻者信息',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument(
        '--min-commits',
        type=int,
        default=MIN_COMMITS_DEFAULT,
        help=f'只處理提交次數 >= N 的貢獻者 (默認: {MIN_COMMITS_DEFAULT})'
    )
    parser.add_argument(
        '--skip-avatars',
        action='store_true',
        help='跳過頭像下載'
    )
    parser.add_argument(
        '--skip-info',
        action='store_true',
        help='跳過個人信息更新'
    )
    parser.add_argument(
        '--commits-only',
        action='store_true',
        help='只更新提交次數和權重,不修改其他信息(標籤、連結等)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='只顯示會做什麼,不實際修改文件'
    )
    
    args = parser.parse_args()
    
    if args.dry_run:
        print("=== DRY RUN 模式 ===\n")
    
    # 獲取貢獻者列表
    contributors = fetch_contributors()
    
    # 過濾貢獻者
    filtered = [c for c in contributors if c['contributions'] >= args.min_commits]
    print(f"過濾後剩餘 {len(filtered)} 位貢獻者 (>= {args.min_commits} 次提交)\n")
    
    # 處理每位貢獻者
    updated_count = 0
    skipped_count = 0
    
    for contrib in filtered:
        login = contrib['login']
        commits = contrib['contributions']
        avatar_url = contrib['avatar_url']
        
        print(f"處理 {login} ({commits} 次提交)...")
        
        try:
            # 只更新提交次數模式
            if args.commits_only:
                contrib_dir = Path(CONTENT_DIR) / login
                # 如果貢獻者目錄不存在,需要創建新貢獻者
                if not contrib_dir.exists():
                    print(f"  [新貢獻者] 創建頁面...")
                    user_data = fetch_user_info(login)
                    download_and_convert_avatar(login, avatar_url, args.dry_run)
                    create_contributor_page(login, user_data, commits, args.dry_run)
                    updated_count += 1
                elif update_commits_only(login, commits, args.dry_run):
                    updated_count += 1
                    weight = 10000 - commits
                    print(f"  更新: 提交 {commits}, 權重 {weight}")
                else:
                    skipped_count += 1
                continue
            
            # 獲取用戶詳細信息
            if not args.skip_info:
                user_data = fetch_user_info(login)
            else:
                user_data = {'login': login}
            
            # 下載頭像
            if not args.skip_avatars:
                download_and_convert_avatar(login, avatar_url, args.dry_run)
            
            # 創建/更新頁面
            if not args.skip_info:
                create_contributor_page(login, user_data, commits, args.dry_run)
            
            updated_count += 1
            
        except Exception as e:
            print(f"  錯誤: {e}")
            skipped_count += 1
            continue
    
    print(f"\n{'=' * 50}")
    print(f"完成!")
    print(f"  已更新: {updated_count} 位")
    if skipped_count > 0:
        print(f"  無變化: {skipped_count} 位")
    
    if args.dry_run:
        print("\n(這是 DRY RUN,沒有實際修改任何文件)")


if __name__ == '__main__':
    main()
