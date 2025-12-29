---
title: "更新记录"
date: 2025-12-29
description: "Gentoo 中文社区网站更新记录"
slug: "changelog"
showDate: false
showAuthor: false
showReadingTime: false
showEdit: false
layoutBackgroundHeaderSpace: false
---

本页面记录网站内容的主要更新，便于读者追踪变更。

---

## 2025 年 12 月

### 2025-12-29

**网站语言与术语更新**
- 语言选择器显示名称从「繁体中文」改为「传统中文」，从「简体中文」改为「简化中文」
- 首页「新闻」标题改为「文章」
- 使用 opencc s2twp 转换传统中文版文章，确保字形正确

**关于页面更新**
- 更新群组规则，强调中华文化跨越地理边界
- 新增「语言哲学」章节，说明选择「传统中文」命名的理由

**Gentoo Linux 安装指南（基础篇）**
- 在 7.3 节「安装固件与微码」添加关于 `package.license` 的说明，解释为何在设置 `ACCEPT_LICENSE="*"` 后仍建议为 linux-firmware 单独创建 license 文件
- 优化 5.2 节「make.conf 范例」的懒人配置，为每个参数添加详细注释说明
- 新增 VIDEO_CARDS、INPUT_DEVICES、PORTAGE_ELOG_CLASSES 等配置范例

**贡献指南**
- 添加 `content/changelog/` 目录说明

**Jekyll 迁移至 Hugo 公告**
- 更新 Hugo 版本信息至 v0.148+
- 添加更新记录和贡献指南页面说明
- 补充贡献者自动更新功能说明

**网站基础设施**
- 修复贡献者自动更新后网站未重新部署的问题（移除提交信息中的 `[skip ci]` 标记）
- 更新 Blowfish 主题至最新版本
- 新增本更新记录页面
- 修正 sync_to_tw.sh 转换规则

---

## 更新说明

- 本页面记录网站**内容**的主要更新，不包括纯技术性修改
- 贡献者信息每周一自动更新，不在此处记录
- 如有问题或建议，请联系 [admin@zakk.au](mailto:admin@zakk.au) 或在 [Telegram 群组](https://t.me/gentoo_zh) 讨论
