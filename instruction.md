文件组织说明
============

项目根目录下01~04的几个md文件分别对应设置好的各个栏目，通过
文件头部的``---``标记中的字段调取相应的配置信息。

01download.md       下载
02overlay.md        中文Overlay
03mirrorlist.md     镜像列表
04about.md          关于

``_layout``目录有两种模板，``page``和``post``，``page``预留给不含时间的下载说明
等栏目使用，``post``给新闻这种包含时间的栏目使用。

``index.html``中的``site.posts``变量会循环遍历``_posts``目录中的所有文件生成
相应的文章条目，可以用来放新闻。

其他的结构化数据可以放在``_data``目录中，参照[这篇文章](http://jekyllrb.com/docs/datafiles/)上的使用说明。

目前需要逐步添加内容，以进一步确定模板的结构如何安排。
