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

### 2025-12-30

**Gentoo Linux 安装指南（基础篇）**

<details>
<summary><b>5.2 节 make.conf 范例优化（点击展开）</b></summary>

- 简化为「快速配置 + 引用进阶篇」模式，降低新手入门复杂度
- 新增详细配置说明提示框，引导用户查阅 [进阶篇 13.11 节](/posts/2025-11-25-gentoo-install-advanced/#1311-详细配置范例完整注释版)
- 优化所有配置项的注释说明，包括编译优化参数、并行编译、镜像源、USE 标志、FEATURES、编译日志等
- 新增内存不足时的调整建议、高级用户可选配置提示
- 新增 ACCEPT_LICENSE 许可证管理说明，引导查阅 [进阶篇 13.12 节](/posts/2025-11-25-gentoo-install-advanced/#1312-accept_license-软件许可证详解)
- 移除 VIDEO_CARDS / INPUT_DEVICES 配置（已移至桌面配置篇）

</details>

<details>
<summary><b>5.3 节：CPU 指令集优化 (CPU_FLAGS_X86) 内容优化（点击展开）</b></summary>

**参考文档**：[CPU_FLAGS_*](https://wiki.gentoo.org/wiki/CPU_FLAGS_*/zh-cn)

- 调整该节的定位与表述，使其更符合「基础篇快速上手」风格
- 引导查阅 [进阶篇 13.13 节](/posts/2025-11-25-gentoo-install-advanced/#1313-cpu-指令集优化-cpu_flags_x86) 获取更深入的说明

</details>

<details>
<summary><b>5.4 节新增：Binary Package Host（二进制包主机）（点击展开）</b></summary>

**参考文档**：[Gentoo Handbook: Binary Package Host](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Optional:_Adding_a_binary_package_host) · [Binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)

- 新增完整章节，介绍如何使用官方二进制包主机大幅缩短安装时间
- 包含配置示例：`/etc/portage/binrepos.conf/gentoobinhost.conf`
- 说明 FEATURES 配置：`getbinpkg` / `binpkg-request-signature`
- 提供验证与测试方法
- 在文章导览中同步更新相关提示

</details>

<details>
<summary><b>6.4 节 fstab 配置大幅完善（点击展开）</b></summary>

- 补充「为什么需要这一步？」说明（自动挂载、UUID 不变性等）
- 新增 genfstab 自动生成完整指南：
  - 安装方法（Gig-OS / Gentoo Minimal ISO）
  - 三种执行场景：chroot 内 / LiveGUI 新终端 / TTY 切换
  - 兼容性说明：Btrfs 子卷 / LUKS 加密分区 / 普通分区
- 新增手动编辑 fstab 详细说明（字段含义、基础配置示例）
- 新增 Btrfs 子卷配置折叠说明：自动生成 + 手动配置 + 常用挂载选项表格
- 新增 LUKS 加密分区配置折叠说明：UUID 区别 / 自动生成 / 手动配置 / 常见问题
- 将所有 fstab 相关内容以 `<details>` 折叠重排，降低章节长度压力

</details>

<details>
<summary><b>7.3 节 package.license 说明补充（点击展开）</b></summary>

- 新增 `package.license` 配置说明，解释为何在设置 `ACCEPT_LICENSE="*"` 后仍建议为 linux-firmware 单独创建 license 文件
- 说明最佳实践：即使全局接受所有许可证，为特定软件包创建 license 文件是 Gentoo 社区推荐做法，便于将来调整许可证策略时不阻止关键软件安装

</details>

- 8.1 节「系统服务工具」将 OpenRC / systemd 用户分别折叠，提升可读性
- `systemd-boot` 说明改为更保守的表述：强调仅适用于 UEFI，并提示部分 ARM/RISC-V 设备固件可能不支持完整 UEFI

---

**Gentoo Linux 安装指南（桌面篇）**

<details>
<summary><b>12.1 节 VIDEO_CARDS 配置重构（点击展开）</b></summary>

**参考文档**：[Gentoo Handbook: VIDEO_CARDS](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#VIDEO_CARDS)

- 从 make.conf 全局配置改为推荐使用 `/etc/portage/package.use/video-cards` 方式（符合官方最佳实践）
- 新增详细硬件对照表：Intel / NVIDIA / AMD / Raspberry Pi / QEMU/KVM / WSL 等 9 种平台
- 补充官方参考链接与推荐做法说明

</details>

---

**Gentoo Linux 安装指南（进阶篇）**

<details>
<summary><b>13.5 节 ACCEPT_LICENSE 引用修正（点击展开）</b></summary>

- 修正错误引用：从「基础篇 5.2 节：ACCEPT_LICENSE 详细说明」改为页内锚点「[13.12 节：ACCEPT_LICENSE 软件许可证详解](#1312-accept_license-软件许可证详解)」
- 原因：基础篇 5.2 节仅包含简单配置，详细说明位于进阶篇 13.12 节

</details>

<details>
<summary><b>CPU_FLAGS_X86：基础篇/进阶篇定位去重（点击展开）</b></summary>

- 调整进阶篇 13.13 的内容定位：不再重复基础篇 5.3 的操作步骤，改为“进阶概念 + 常见注意事项 + 延伸说明”
- 在进阶篇 13.13 直接导向基础篇 [5.3 配置 CPU 指令集优化](/posts/2025-11-25-gentoo-install-base/#53-配置-cpu-指令集优化)，避免读者在两篇文章看到几乎相同的命令段

</details>

<details>
<summary><b>13 章 make.conf 进阶配置完全重构（点击展开）</b></summary>

**参考文档**：[make.conf - Gentoo Wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf)

从扁平的 9 个小节重构为结构化的 13 个子章节（13.1-13.13），大幅提升逻辑性与可读性：

- **13.1 编译器优化参数**：表格化呈现 `-march=native` / `-O2` / `-O3` / `-pipe` 等参数，新增 `-flto` / `-fomit-frame-pointer` 等进阶参数说明，提供高性能/兼容性/调试配置范例
- **13.2 并行编译配置**：新增硬件配置推荐表（4核到32核），涵盖 RAM 不足与服务器环境配置建议
- **13.3 USE 标志管理**：按系统/桌面/音频/网络/国际化分类折叠，提供完整 USE 标志配置范例
- **13.4 语言与本地化**：补充 L10N / LINGUAS / LC_MESSAGES 配置建议
- **13.5 许可证管理 (ACCEPT_LICENSE)**：新增许可证组说明表（@FREE、@BINARY-REDISTRIBUTABLE 等），详细说明针对特定软件包配置方式，引用 13.12 节详细说明
- **13.6 Portage 功能增强 (FEATURES)**：使用表格呈现选项（parallel-fetch、ccache、distcc 等），加入 ccache 配置示例
- **13.7 镜像源配置**：提供中国大陆与全球镜像源列表
- **13.8 编译日志配置**：说明 PORTAGE_ELOG_CLASSES 与邮件配置
- **13.9 显卡与输入设备配置**：加入警告框，强调已移至桌面配置篇，推荐使用 package.use 方式配置
- **13.10 完整配置示例**：分为新手推荐与高性能工作站两种配置，分别折叠
- **13.11 延伸阅读**：整合所有相关 Gentoo Wiki 链接
- **13.12 ACCEPT_LICENSE 软件许可证详解**（新增折叠章节）：详细说明 GLEP 23、许可证组概念、常用许可证组表格、配置方式、单包配置示例等
- **13.13 CPU 指令集优化 (CPU_FLAGS_X86)**（新增折叠章节）：详细说明 CPU_FLAGS_X86 配置方法、cpuid2cpuflags 工具使用、示例配置等

</details>

<details>
<summary><b>18 章新增：Secure Boot 配置（点击展开）</b></summary>

**参考文档**：[Gentoo Handbook: Secure Boot](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Alternative:_Secure_Boot) · [Signed kernel module support](https://wiki.gentoo.org/wiki/Signed_kernel_module_support)

- **18.1 使用 sbctl 自动化管理（推荐）**：完整 sbctl 工作流程（安装、生成密钥、注册密钥、签名、验证）
- **18.2 手动配置 Secure Boot（使用 OpenSSL）**（折叠）：适合深入学习的用户，包含密钥生成、内核模块签名、UKI 配置、MOK 注册等
- 补充 Setup Mode 疑难排解：说明如何在 BIOS/UEFI 中清除密钥以进入 Setup Mode
- 新增常见问题 FAQ

</details>

---

**网站基础设施**
- GitHub Actions 部署工作流调整 Hugo 版本为 `0.153.2`（与 Blowfish 主题声明的兼容范围对齐）
- 删除格式错误的 `sync_to_tw.sh`
- 新增 `convert-zh-tw.sh`（用于简转繁与台湾本地化处理，包含 OpenCC + 镜像源替换等规则）

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
