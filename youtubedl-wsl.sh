#!/bin/bash

waiturl()
{
echo -e "\033[36m请输入完整网址: \n比如https://www.youtube.com/watch?v=3MLIZRww_Q0\t\033[0m"
read dl_url
if [[ $dl_url =~ "http" ]];then
echo -e "\033[33m网址 ok! \033[0m"
download
else
echo -e "\033[31输入网址错误! \033[0m"
exit 1
fi
}
download()
{
tmpdir=$(mktemp -d)
one=${tmpdir}/one
two=${tmpdir}/two

#dl_url="https://www.youtube.com/watch?v=w4xw9LLVvRA"
# ./binaries/yt-dlp.exe -v --list-formats https://www.youtube.com/watch?v=3MLIZRww_Q0
# ./binaries/yt-dlp.exe -j https://www.youtube.com/playlist?list=PLZDwfIerdFF2SmqIHBUVx-EpoqGeoFhuN 2>/dev/null | jq -r '.id,.title,.duration,.duration_string,.original_url,"☢"' | tr "\n" "\t" | sed $'s/\\t☢\\t/\\n/g' | tee playlist.txt

IFS_OLD=$IFS;IFS=$'\n'

/mnt/c/WINDOWS/system32/cmd.exe /C binaries\\yt-dlp.exe -v --no-check-certificate -j $dl_url | jq -r '.id,.title,.duration,.duration_string,.original_url,"☢"' | tr "\n" "\t" | sed $'s/\\t☢\\t/\\n/g' | tee $two
filename=`cat $two | awk -F "\t" '{ print $2 }'`
duration=`cat $two | awk -F "\t" '{ print $3 }'`
duration_string=`cat $two | awk -F "\t" '{ print $4 }'`

/mnt/c/WINDOWS/system32/cmd.exe /C binaries\\yt-dlp.exe --no-check-certificate --list-formats $dl_url | tee $one
bestvideo=`cat $one | grep "video only" | tr -d "\~" | awk -F "[ ]+" '{ print $7,$1 }' | grep -i "K" | sort -n | tail -n 1| awk -F "[ ]+" '{ print $2 }'`
bestaudeo=`cat $one | grep "audio only" | tr -d "\~" | awk -F "[ ]+" '{ print $7,$1 }' | grep -i "m" | sort -n | tail -n 1| awk -F "[ ]+" '{ print $2 }'`
echo -e "\033[33m\n`cat $one | grep $bestvideo`\033[0m"
echo -e "\033[33m`cat $one | grep $bestaudeo`\n\033[0m"
/mnt/c/WINDOWS/system32/cmd.exe /C binaries\\yt-dlp.exe -k -v --no-check-certificate -f $bestvideo --fixup never $dl_url -o youtubedl/%\(title\)s.mp4
/mnt/c/WINDOWS/system32/cmd.exe /C binaries\\yt-dlp.exe -k -v --no-check-certificate -f $bestaudeo --fixup never $dl_url -o youtubedl/%\(title\)s.%\(ext\)s

echo -e "\033[33m\n`cat $two` \033[0m"
mp4file=`ls ./youtubedl/*mp4`;mkvfile=`echo -ne $mp4file | sed 's/\.mp4/.mkv/g'`;webmfile=`echo -ne $mp4file | sed 's/\.mp4/.webm/g'`;m4afile=`echo -ne $mp4file | sed 's/\.mp4/.m4a/g'`
#mp4file="./youtubedl/$filename.mp4";mkvfile="./youtubedl/$filename.mkv";webmfile="./youtubedl/$filename.webm";m4afile="./youtubedl/$filename.m4a"

if [ -e "$webmfile" ];then
echo -e "\033[33mwebm ok! \033[0m"
/mnt/c/WINDOWS/system32/cmd.exe /C binaries\\mkvmerge.exe --ui-language zh_CN --no-date --priority normal --output "$mkvfile" --language 0:zh \( "$mp4file" \) --language "0:zh" --track-name "0:中文" \( "$webmfile" \) --track-order "0:0,1:0"
fi
if [ -e "$m4afile" ];then
echo -e "\033[33mm4a ok! \033[0m"
/mnt/c/WINDOWS/system32/cmd.exe /C binaries\\mkvmerge.exe --ui-language zh_CN --no-date --priority normal --output "$mkvfile" --language 0:zh \( "$mp4file" \) --language "0:zh" --track-name "0:中文" \( "$m4afile" \) --track-order "0:0,1:0"
fi


if [ -e "$mkvfile" ];then
echo -e "\033[33m$filename 下载完成! \033[0m"

find ./youtubedl -maxdepth 1 -type f ! -name '*.mkv' -print0 | xargs -0 rm -vf
IFS=$IFS_OLD
	if [ -s $list ] 2>/dev/null;then
		sed -i '1d' $list
	fi
prepare
return
else
echo -e "\033[31m$filename 下载错误! \033[0m"
exit 1
fi
}

prepare()
{
list='playlist.txt'
if [ -s $list ] 2>/dev/null;then
IFS_OLD=$IFS;IFS=$'\n'
dl_url=`sed 'q' $list | tr -d "\r\n" | awk -F "\t" '{ print $5 }'`
IFS=$IFS_OLD
	if [[ $dl_url =~ "http" ]];then
		echo -e "\033[33m 下载 `sed 'q' $list | tr -d "\r\n" | awk -F "\t" '{ print $2 }'`\033[0m"
		download
	else
		sed -i '1d' $list
		prepare
	fi
else
	if [ -e $list ];then
		echo -e "\033[33m playlist.txt下载完成 \033[0m"
		rm -vf $list
	fi
	waiturl
fi
}
prepare