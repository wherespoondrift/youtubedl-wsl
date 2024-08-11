# youtubedl-wsl
Use linux shell in windows 10  by wsl run yt-dlp

运行环境 启用wsl的 windows10

wsl -l

适用于 Linux 的 Windows 子系统分发版:
Ubuntu (默认)

安装工具 jq

sudo apt install jq

本身直接用-f b/bv+ba yt-dlp基本自动弄好

参考https://github.com/yt-dlp/yt-dlp

弄个sh自用，wsl跨平台有脑痛的cp936 与 UTF-8 互相兼容的问题

cmd 输入 chcp 查看代码页

某些视频名称的特殊符号令人投降干脆用shell ls再获取名称，避免有意想不到的符号可能保存时自动替换了运行出错。
还得用IFS_OLD把空格定义为非分隔符，纯属折腾整活

分析列表playlist.txt

bash

./binaries/yt-dlp.exe -j https://www.youtube.com/playlist?list=目标 2>/dev/null | jq -r '.id,.title,.duration,.duration_string,.original_url,"☢"' | tr "\n" "\t" | sed $'s/\\t☢\\t/\\n/g' | tee playlist.txt

如果视频名称居然有☢字符，那就换一个做分割标记 或者就让它去吧，别太留恋

有的播单夹带所以存playlist.txt手动编辑剃掉不要的再批量下

交叉系统用也有好处，有好用的程序没跨平台
