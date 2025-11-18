---
title: "文件組織說明"
---

項目根目錄下01~04的幾個md文件分別對應設置好的各個欄目，通過文件頭部的`---`標記中的字段調取相應的配置信息。

- `01download.md` - 下載
- `02overlay.md` - 中文Overlay
- `03mirrorlist.md` - 鏡像列表
- `04about.md` - 關於

`_layout`目錄有兩種模板，`page`和`post`，`page`預留給不含時間的下載說明等欄目使用，`post`給新聞這種包含時間的欄目使用。

`index.html`中的`site.posts`變量會循環遍歷`_posts`目錄中的所有文件生成相應的文章條目，可以用來放新聞。

其他的結構化數據可以放在`_data`目錄中，參照[這篇文章](http://jekyllrb.com/docs/datafiles/)上的使用說明。

目前需要逐步添加內容，以進一步確定模板的結構如何安排。

如想對本網站進行增減，請到此處發起 PR <https://github.com/Gentoo-zh/gentoo-zh.github.com>
