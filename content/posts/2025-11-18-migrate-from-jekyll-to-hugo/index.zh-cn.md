---
title: "网站从 Jekyll 迁移至 Hugo"
date: 2025-11-18
categories: ["announcement"]
authors: ["zakkaus"]
---

经过多年使用 Jekyll 作为静态站点生成器，Gentoo 中文社区网站现已成功迁移至 Hugo。本文介绍此次迁移的背景、原因和主要改进。

## 项目背景

Gentoo 中文社区网站创建于 2014 年，由 [@zhcj](https://github.com/zhcj)（清风博主）与 [@biergaizi](https://github.com/biergaizi)（比尔盖子）共同发起。项目使用 Jekyll 作为静态站点生成器已有多年，但随着社区发展和技术演进，Jekyll 的一些限制逐渐显现。

经创始人 @biergaizi 授权，[@Zakkaus](https://github.com/zakkaus) 于 2025 年接手本项目的日常维护工作，并启动了从 Jekyll 到 Hugo 的迁移工作。

## 为什么选择 Hugo？

### 性能优势

- **构建速度快**：Hugo 使用 Go 编写，构建速度比 Jekyll 快数十倍
- **无需 Ruby 环境**：Hugo 是单一二进制文件，部署更简单
- **内存占用低**：大型站点构建时资源消耗更少

### 功能特性

- **内置多语言支持**：原生支持简体中文和繁体中文
- **强大的主题系统**：采用 Blowfish 主题，界面现代美观
- **更好的资源管理**：支持图片优化、CSS/JS 打包等
- **灵活的内容组织**：Page Bundles 让资源管理更直观

## 主要改进

### 1. 现代化界面

采用 [Blowfish](https://blowfish.page/) 主题，提供：
- 响应式设计，完美支持移动设备
- 深色/浅色模式切换
- 优雅的文章排版
- 更好的可读性

### 2. 多语言支持

- 简体中文（zh-CN）
- 繁体中文（zh-TW）
- 未来可轻松添加更多语言

### 3. 内容优化

新增和完善的页面：
- **下载页面**：列出官方和中国内陆镜像源，特别标注 Apple Silicon Mac 用户注意事项
- **镜像列表**：详细的 Portage 树和 Distfiles 配置说明
- **Overlay 文档**：gentoo-zh overlay 使用指南
- **关于页面**：项目历史和团队介绍
- **贡献者页面**：展示社区贡献者信息

### 4. 性能提升

- WebP 图片格式，减少文件大小
- 静态资源优化
- 更快的页面加载速度
- 改进的 SEO 优化

### 5. 用户体验改进

- 折叠式导航菜单，页面更简洁
- GitHub 链接使用图标显示
- 改进的移动端体验
- 更好的中文字体渲染

## 技术栈

- **静态站点生成器**：Hugo v0.1xx+
- **主题**：Blowfish
- **部署**：Cloudflare Pages / GitHub Pages
- **版本控制**：Git
- **CI/CD**：GitHub Actions

## 迁移过程

### 内容迁移

1. 将 Jekyll 的 `_posts` 目录迁移到 Hugo 的 `content/posts`
2. 转换 front matter 格式（YAML → TOML）
3. 调整图片路径和资源引用
4. 使用 Page Bundles 组织文章资源

### 配置调整

1. 将 `_config.yml` 转换为 Hugo 配置文件结构
2. 设置多语言支持（简体/繁体中文）
3. 配置主题参数和自定义选项
4. 设置菜单和导航结构

### 样式定制

1. 自定义背景图片和配色方案
2. 配置社交媒体链接
3. 添加自定义 CSS 优化中文显示
4. 优化移动端布局

## 数据迁移

所有作者信息已迁移到 `data/authors/` 目录：
- [@biergaizi](https://github.com/biergaizi) - 创始人
- [@zhcj](https://github.com/zhcj) - 创始人
- [@zakkaus](https://github.com/zakkaus) - 现任维护者

作者系统支持：
- GitHub / Telegram / 微博等社交链接
- 个人简介
- 文章关联

## 未来计划

- 持续完善中文文档
- 添加更多 Gentoo 相关教程
- 改进搜索功能
- 添加评论系统（可选）
- 优化构建流程

## 反馈与贡献

如果您在使用新网站时遇到问题或有建议，欢迎：
- 加入 Telegram 群组：[@gentoo_zh](https://t.me/gentoo_zh)
- 关注 Telegram 频道：[@gentoocn](https://t.me/gentoocn)
- 在 [GitHub](https://github.com/gentoo-zh/gentoo-zh.github.com) 提交 Issue 或 Pull Request

## 致谢

感谢 [@biergaizi](https://github.com/biergaizi) 和 [@zhcj](https://github.com/zhcj) 创立并长期维护 Gentoo 中文社区。感谢 Blowfish 主题的开发者提供了优秀的主题框架。感谢所有为 Gentoo 中文社区做出贡献的成员！

---

*网站迁移完成于 2025 年 11 月*
