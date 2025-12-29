# Gentoo 中文社区

基于 Hugo 和 Blowfish 主题的 Gentoo 中文社区网站。

## 特性

- Hugo 静态网站生成器
- Blowfish 现代化主题
- 完整的繁简体中文双语支持
- 响应式设计
- 快速构建速度
- RSS 订阅

## 本地开发

### 安装依赖

```bash
# Gentoo
emerge www-apps/hugo
```

### 启动开发服务器

```bash
hugo server
```

访问 http://localhost:1313

### 构建网站

```bash
hugo
```

生成的文件在 `public/` 目录。

## 项目结构

```
.
├── config/
│   └── _default/          # 配置文件
│       ├── hugo.toml      # 主配置
│       ├── languages.*.toml # 语言配置
│       ├── menus.*.toml   # 菜单配置
│       ├── params.toml    # 主题参数
│       └── markup.toml    # Markdown 配置
├── content/
│   ├── zh-cn/            # 简体中文内容
│   └── zh-tw/            # 传统中文内容
├── themes/
│   └── blowfish/         # 主题 (submodule)
└── .gitignore            # Git 忽略文件
```

## GitHub Pages 部署

项目已配置为可直接在 GitHub Pages 上部署。推送到 GitHub 后，通过 GitHub Actions 自动构建。

## 链接

- [Hugo 文档](https://gohugo.io/documentation/)
- [Blowfish 主题](https://blowfish.page/)
- [Gentoo 官方](https://www.gentoo.org/)
