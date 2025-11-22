---
title: "贡献指南"
description: "如何为 Gentoo 中文社区网站做出贡献"
---

欢迎参与 Gentoo 中文社区网站的建设！本指南介绍网站的项目结构和参与贡献的方法。

## 项目概况

本网站使用 [Hugo](https://gohugo.io/) 静态网站生成器和 [Blowfish](https://blowfish.page/) 主题构建，托管在 GitHub Pages 上。

**项目仓库**：<https://github.com/gentoo-zh/gentoo-zh.github.com>

## 项目结构

### 内容组织

`content/` 目录下的各个子目录对应网站的不同栏目：

- `content/download/` - 下载页面（包含镜像源和安装介质）
- `content/overlay/` - gentoo-zh Overlay 说明
- `content/mirrorlist/` - 镜像列表（Portage 树和 Distfiles 配置）
- `content/about/` - 关于页面（项目历史和定位）
- `content/authors/` - 作者页面（贡献者信息）
- `content/posts/` - 新闻文章和教程目录
- `content/categories/` - 文章分类定义

每个栏目包含简体中文（`_index.zh-cn.md`）和繁体中文（`_index.zh-tw.md`）版本。

### 配置文件

主要配置文件位于 `config/_default/` 目录：

- `hugo.toml` - Hugo 主配置（网站基本信息、分类法定义）
- `languages.zh-cn.toml` / `languages.zh-tw.toml` - 语言配置
- `menus.zh-cn.toml` / `menus.zh-tw.toml` - 导航菜单配置
- `params.toml` - 主题参数配置（外观、功能开关）
- `markup.toml` - Markdown 渲染配置

### 数据文件

`data/` 目录存储结构化数据：

- `data/authors/` - 作者信息（JSON 格式）
  - 支持 GitHub / Telegram / 微博等社交链接
  - 自动从 GitHub 获取头像

### 多语言支持

网站支持简体中文和繁体中文双语：
- 简体中文翻译：`i18n/zh-CN.yaml`
- 繁体中文翻译：`i18n/zh-TW.yaml`

### 主题和资源

- `themes/blowfish/` - Blowfish 主题（通过 git submodule 管理）
- `static/` - 静态资源（图片、CNAME 等）
- `assets/` - 需要处理的资源文件
- `layouts/` - 自定义布局模板（如作者页面）

## 如何贡献

### 1. 提交新文章

在 `content/posts/` 目录下创建新的文章目录：

```bash
mkdir content/posts/YYYY-MM-DD-article-name
cd content/posts/YYYY-MM-DD-article-name
```

创建简体和繁体中文版本：

**index.zh-cn.md** (简体中文)：
```yaml
---
title: "文章标题"
date: 2025-11-22
categories: ["tutorial"]
authors: ["yourname"]
---

文章内容...
```

**index.zh-tw.md** (繁体中文)：
```yaml
---
title: "文章標題"
date: 2025-11-22
categories: ["tutorial"]
authors: ["yourname"]
---

文章內容...
```

**可用的文章分类**：
- `announcement` - 公告
- `tutorial` - 教程
- `news` - 新闻
- `community` - 社区动态

### 2. 添加作者信息

在 `data/authors/` 目录创建 JSON 文件：

```json
{
  "name": "你的名字",
  "bio": "简介",
  "social": [
    { "github": "https://github.com/yourname" },
    { "telegram": "https://t.me/yourname" }
  ]
}
```

头像会自动从 GitHub 获取。

### 3. 改进现有内容

欢迎改进：
- 修正错别字或不准确的表述
- 更新过时的技术信息
- 添加新的使用技巧
- 完善文档说明
- 补充缺失的繁体中文翻译

### 4. 技术改进

如对网站技术架构有改进建议：
- 功能增强
- 性能提升
- 新功能开发
- 主题定制

## 贡献流程

### Fork 和 Clone

```bash
# Fork 项目到你的 GitHub 账号
# 然后 clone 到本地
git clone https://github.com/你的用户名/gentoo-zh.github.com.git
cd gentoo-zh.github.com

# 初始化主题子模块
git submodule update --init --recursive
```

### 本地预览

```bash
# 安装 Hugo (Gentoo)
emerge --ask www-apps/hugo

# 启动本地服务器
hugo server -D

# 访问 http://localhost:1313 预览
```

### 提交 Pull Request

```bash
# 创建新分支
git checkout -b your-feature-branch

# 提交更改
git add .
git commit -m "描述你的更改"
git push origin your-feature-branch

# 在 GitHub 上创建 Pull Request
```

## 写作规范

### Markdown 格式

- 使用标准 Markdown 语法
- 代码块指定语言：\`\`\`bash
- 图片使用相对路径
- 链接使用 Markdown 格式

### 中文排版

- 中英文之间添加空格
- 使用全角标点符号
- 数字使用半角
- 专有名词保持原文（如 Gentoo、Hugo）

### 示例

```markdown
Gentoo Linux 是一个基于源代码的 Linux 发行版，使用 Portage 包管理系统。

## 安装步骤

1. 下载 Stage3 压缩包
2. 解压到目标目录：
   ```bash
   tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
   ```
```

## 常见问题

### 如何更新主题？

```bash
cd themes/blowfish
git pull origin main
cd ../..
git add themes/blowfish
git commit -m "更新 Blowfish 主题"
```

### 如何添加新的页面？

在 `content/` 下创建新目录，添加 `_index.zh-cn.md` 和 `_index.zh-tw.md`。

### 繁体中文如何转换？

可以使用 `opencc` 工具：

```bash
opencc -c s2twp -i index.zh-cn.md -o index.zh-tw.md
```

然后手动调整地域词汇差异。

## 社区交流

遇到问题或有建议？

- **Telegram 群组**：[@gentoo_zh](https://t.me/gentoo_zh)
- **Telegram 频道**：[@gentoocn](https://t.me/gentoocn)
- **GitHub Issues**：<https://github.com/gentoo-zh/gentoo-zh.github.com/issues>

## 许可协议

本站内容采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 许可协议，除非另有说明。

代码贡献遵循项目的 MIT 许可。

---

感谢你的贡献，让我们一起建设更好的 Gentoo 中文社区！
