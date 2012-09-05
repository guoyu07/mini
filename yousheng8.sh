#!/bin/bash

url_prefix="http://www1.yousheng8.com/"
html_suffix=$1
book=$2
first_chp=$3
last_chp=$4
digits=$5

for (( i=first_chp;i<=last_chp;i++ )); do
	curr_chp=`printf "%0${digits}d" $i`
	url=${url_prefix}down_${book}_${curr_chp}.${html_suffix}
	wget -nv -O curr.htm $url
	iconv -f GBK -t UTF-8 -o curr.htm.utf8 curr.htm
	link=`grep "\.mp3" curr.htm.utf8 | cut -d\" -f2`
	wget -nc -c -O ${curr_chp}.mp3 $link
	#prozilla is much faster than wget
#	proz $link
done
rm curr*
