---
title: "Overlay"
---

Gentoo 的 Overlay 机制可以让用户使用官方 Portage 树以外的软件包，作为一个软件来源的扩充和叠加。
故名为 Overlay（意为叠加）。

gentoo-zh Overlay 是 Gentoo 社区历史悠久的老牌 Overlay 之一，其前身是 2003 年创立的 gentoo-tw
和随后创立的 gentoo-china。后来，台湾和大陆社区的共同努力下，合并为了 gentoo-zh overlay。本
overlay 旨在为用户提供：

* 和中国用户相关的软件和补丁，例如
  - 某些软件的 CJK 补丁
  - 本地 Linux 应用
* 额外的软件
  * 特色软件包（不一定和中文或 CJK 相关）
    - 如 gentoo-zh 特色 e-sources 内核包，整合了多种补丁
  * 从其它 Overlay 搬运过来的软件包
* 更新的软件版本
  - Portage 是一个庞大的系统，有些包未免会暂时被人忽视而忘记更新
    * 如长期提供最新版本的 Boost
* 错误修复
  - gentoo-zh 开发者遇到一个错误时，会在解决后第一时间将相关补丁推入源中。

## 仓库地址

gentoo-zh overlay 的源代码托管在 GitHub 上：

<https://github.com/microcai/gentoo-zh>

## 如何使用

> **重要提示**（更新时间：2025-10-07）
>
> 根据 [Gentoo 官方公告](https://www.gentoo.org/support/news-items/2025-10-07-cache-enabled-mirrors-removal.html)，Gentoo 已停止为第三方仓库提供缓存镜像支持。从 2025-10-30 起，所有第三方仓库（包括 gentoo-zh）的镜像配置将从官方仓库列表中移除。
>
> **这意味着什么？**
> - `eselect repository` 和 `layman` 等工具仍可正常使用
> - 官方将不再提供快取镜像，改为直接从上游源（GitHub）同步
> - 官方仓库（::gentoo、::guru、::kde、::science）不受影响，仍可使用镜像
>
> **如果您之前已添加 gentoo-zh overlay，请更新同步 URI：**
>
> ```bash
> # 查看已安装的仓库
> eselect repository list -i
>
> # 移除旧配置
> eselect repository remove gentoo-zh
>
> # 重新启用（将自动使用正确的上游源）
> eselect repository enable gentoo-zh
> ```

### 手动配置

在 `/etc/portage/repos.conf/` 目录下创建 `gentoo-zh.conf` 文件，内容如下：

```ini
[gentoo-zh]
location = /var/db/repos/gentoo-zh
sync-type = git
sync-uri = https://github.com/microcai/gentoo-zh.git
auto-sync = yes
```

然后同步：

```bash
emerge --sync gentoo-zh
```

## 使用 overlay 中的软件包

配置完成后，就可以像使用官方源一样安装 overlay 中的软件包了：

```bash
emerge --ask <package-name>
```

如果想查看 overlay 提供了哪些软件包，可以使用：

```bash
eix -RO gentoo-zh
```

## 参与贡献

欢迎向 gentoo-zh overlay 贡献代码！请访问 GitHub 仓库提交 Pull Request 或报告问题。
