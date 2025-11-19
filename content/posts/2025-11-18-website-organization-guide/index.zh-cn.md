---
title: "网站文件组织与贡献指南"
date: 2025-11-18
categories: ["website"]
authors: ["zakkaus"]
---

本指南介绍 Gentoo 中文社区网站的项目结构和参与贡献的方法。

## 项目结构

本网站使用 [Hugo](https://gohugo.io/) 静态网站生成器和 [Blowfish](https://blowfish.page/) 主题构建。

### 内容组织

`content/` 目录下的各个子目录对应网站的不同栏目：

- `content/download/` - 下载页面
- `content/overlay/` - 中文 Overlay 说明
- `content/mirrorlist/` - 镜像列表
- `content/about/` - 关于页面
- `content/posts/` - 新闻文章目录
- `content/categories/` - 文章分类定义

每个栏目包含简体中文（`_index.zh-cn.md`）和繁体中文（`_index.zh-tw.md`）版本。

### 配置文件

主要配置文件位于 `config/_default/` 目录：

- `hugo.toml` - Hugo 主配置
- `languages.zh-cn.toml` / `languages.zh-tw.toml` - 语言配置
- `menus.zh-cn.toml` / `menus.zh-tw.toml` - 导航菜单配置
- `params.toml` - 主题参数配置

### 多语言支持

网站支持简体中文和繁体中文双语：
- 简体中文翻译：`i18n/zh-CN.yaml`
- 繁体中文翻译：`i18n/zh-TW.yaml`

### 主题和资源

- `themes/blowfish/` - Blowfish 主题（通过 git submodule 管理）
- `static/` - 静态资源（图片、CNAME 等）
- `assets/` - 需要处理的资源文件

## 发布新文章

在 `content/posts/` 目录下创建新的文章目录，包含：
- `index.zh-cn.md` - 简体中文版本
- `index.zh-tw.md` - 繁体中文版本

文章头部需包含 frontmatter 配置：

```yaml
---
title: "文章标题"
date: 2025-11-19
categories: ["分类"]
authors: ["作者ID"]
---
```

### 可用的文章分类

- `announcement` - 公告
- `community` - 社区动态
- `tutorial` - 教程
- `website` - 网站相关

## 参与贡献

### 提交文章

1. Fork 项目仓库
2. 在 `content/posts/` 创建新文章目录
3. 编写简体中文和繁体中文版本
4. 提交 Pull Request

### 改进现有内容

欢迎改进：
- 修正错别字或不准确的表述
- 更新过时的技术信息
- 添加新的使用技巧
- 完善文档说明

### 技术改进

如对网站技术架构有改进建议：
- 功能增强
- 性能提升
- 新功能开发

请到 GitHub 提交 Issue 或 Pull Request：  
<https://github.com/Zakkaus/gentoo-zh.github.com>

## 社区交流

- Telegram 群组：[@gentoo_zh](https://t.me/gentoo_zh)
- Telegram 频道：[@gentoocn](https://t.me/gentoocn)
- GitHub：<https://github.com/gentoo-zh>

欢迎加入我们，一起建设更好的 Gentoo 中文社区！
