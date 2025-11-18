---
title: "文件组织说明"
---

## 项目结构

本网站使用 [Hugo](https://gohugo.io/) 静态网站生成器和 [Blowfish](https://blowfish.page/) 主题构建。

### 内容组织

`content/` 目录下的各个子目录对应网站的不同栏目：

- `content/download/` - 下载页面
- `content/overlay/` - 中文 Overlay 说明
- `content/mirrorlist/` - 镜像列表
- `content/about/` - 关于页面
- `content/instruction/` - 本说明页面
- `content/posts/` - 新闻文章目录

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

### 发布新文章

在 `content/posts/` 目录下创建新的文章目录，包含：
- `index.zh-cn.md` - 简体中文版本
- `index.zh-tw.md` - 繁体中文版本

文章头部需包含 frontmatter 配置：
```yaml
---
title: "文章标题"
date: 2025-11-18
categories: ["分类"]
---
```

### 参与贡献

如想对本网站进行改进，请到此处发起 Pull Request：  
<https://github.com/Zakkaus/gentoo-zh.github.com>
