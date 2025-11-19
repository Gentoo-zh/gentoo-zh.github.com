---
title: "镜像列表"
---

Gentoo 的包管理体系由 Portage 树和 Distfiles 两部分组成：

- **Portage 树**：包数据库，包含所有软件包的 ebuild 文件和元数据
  - 传统通过 rsync 同步
  - 现代推荐使用 Git 同步（速度更快，支持增量更新）
- **Distfiles**：源代码下载文件，通过 HTTP/HTTPS 提供

Gentoo 在全球有大量镜像。本页面列出亚洲地区对中国用户有速度优势的主要镜像。

**官方完整镜像列表：**
- Distfiles 镜像：<https://www.gentoo.org/downloads/mirrors/#CN>
- rsync 镜像：<https://www.gentoo.org/support/rsync-mirrors/#CN>

**配置参考文档：**
- 仓库配置：<https://wiki.gentoo.org/wiki//etc/portage/repos.conf/zh-cn>
- Distfiles 镜像配置：<https://wiki.gentoo.org/wiki/GENTOO_MIRRORS/zh-cn>

## Portage 树同步方式

由于 rsync 是 CPU 与 IO 密集型操作，服务器负担较重且容易遭受 DoS 攻击，因此绝大多数镜像不再提供 rsync 服务。
**推荐使用 Git 方式同步 Portage 树**，具有以下优势：
- 增量更新，节省带宽
- 更好的网络稳定性
- 支持多种镜像源选择

如果你无法找到合适的 rsync 镜像，或防火墙禁止 rsync，可以使用以下替代方案：

1. **使用 emerge-webrsync**：Portage 会从 Distfiles 下载每日归档的 Portage 压缩包进行同步。
2. **使用 Git 同步**：在 `/etc/portage/repos.conf/gentoo.conf` 中配置：
   ```ini
   [DEFAULT]
   main-repo = gentoo

   [gentoo]
   location = /var/db/repos/gentoo
   sync-type = git
   sync-uri = https://mirrors.bfsu.edu.cn/git/gentoo-portage.git
   auto-sync = yes
   ```

   **可用的 Git 镜像源：**
   - 北京外国语大学：`https://mirrors.bfsu.edu.cn/git/gentoo-portage.git`
   - 清华大学：`https://mirrors.tuna.tsinghua.edu.cn/git/gentoo-portage.git`
   - GitHub（国外）：`https://github.com/gentoo-mirror/gentoo.git`

   配置后执行 `emerge --sync` 即可通过 Git 同步 Portage 树。

## Distfiles 镜像配置

配置 Distfiles 镜像可以加速软件包源代码的下载。有两种配置方式：

### 方法一：使用 make.conf 配置

在 `/etc/portage/make.conf` 文件中添加 `GENTOO_MIRRORS` 变量：

```bash
GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/ https://mirrors.tuna.tsinghua.edu.cn/gentoo/ https://mirrors.ustc.edu.cn/gentoo/"
```

建议配置多个镜像源，Portage 会按顺序尝试下载，提高成功率。

### 方法二：使用 mirrorselect 工具

```bash
# 安装 mirrorselect
emerge --ask app-portage/mirrorselect

# 自动选择最快的镜像（测试连接速度）
mirrorselect -i -o >> /etc/portage/make.conf

# 或手动从列表中选择
mirrorselect -i -o >> /etc/portage/make.conf
```

# 中国大陆镜像

* 清华大学开源镜像站
  - Portage: 不提供
  - Distfiles: https://mirrors.tuna.tsinghua.edu.cn/gentoo
* 中国科学技术大学（USTC）
  - Portage: rsync://rsync.mirrors.ustc.edu.cn/gentoo/
  - Distfiles: https://mirrors.ustc.edu.cn/gentoo/
* 浙江大学
  - Portage: rsync://mirrors.zju.edu.cn/gentoo/
  - Distfiles: https://mirrors.zju.edu.cn/gentoo/
* 南京大学 eScience Center
  - Portage: 不提供
  - Distfiles: https://mirrors.nju.edu.cn/gentoo/
* 兰州大学开源社区
  - Portage: 不提供
  - Distfiles: https://mirror.lzu.edu.cn/gentoo
* 网易
  - Portage: 不提供
  - Distfiles: https://mirrors.163.com/gentoo/
* 阿里云
  - Portage: 不提供
  - Distfiles: https://mirrors.aliyun.com/gentoo/

# 香港镜像

* CICKU
  - Portage: 不提供
  - Distfiles: https://hk.mirrors.cicku.me/gentoo/
* PlanetUnix Networks
  - Portage: rsync://hippocamp.cn.ext.planetunix.net/gentoo/
  - Distfiles: https://hippocamp.cn.ext.planetunix.net/pub/gentoo/

# 台湾镜像

* 国家高速网络与计算中心（NCHC）
  - Portage: 不提供
  - Distfiles: http://ftp.twaren.net/Linux/Gentoo/
* CICKU
  - Portage: 不提供
  - Distfiles: https://tw.mirrors.cicku.me/gentoo/

# 新加坡镜像

* Freedif
  - Portage: rsync://mirror.freedif.org/gentoo
  - Distfiles: https://mirror.freedif.org/gentoo
* CICKU
  - Portage: 不提供
  - Distfiles: https://sg.mirrors.cicku.me/gentoo/
* PlanetUnix Networks
  - Portage: rsync://enceladus.sg.ext.planetunix.net/gentoo/
  - Distfiles: https://enceladus.sg.ext.planetunix.net/pub/gentoo/

# 日本镜像

* 北陆尖端科学技术大学院大学（JAIST）
  - Portage: 不提供
  - Distfiles: https://ftp.iij.ad.jp/pub/linux/gentoo/
