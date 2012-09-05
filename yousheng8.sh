#!/bin/bash

if test $# -l 5; then
	echo "usage: $0 <html-suffix> <book-no> <digits> <first_chapter> <last_chapter> [prozilla-threads]"
	echo
	exit 1
fi
url_prefix="http://www1.yousheng8.com/"
html_suffix=$1
book=$2
digits=$3
first_chp=$4
last_chp=$5
if test $# -ge 6; then
	proz_threads=$6
else
	proz_threads=48
fi

for (( i=first_chp;i<=last_chp;i++ )); do
	curr_chp=`printf "%0${digits}d" $i`
	url=${url_prefix}down_${book}_${curr_chp}.${html_suffix}
	echo "URL = $url"
	wget -nv -O curr.htm.utf8 $url
#	iconv -f GBK -t UTF-8 -o curr.htm.utf8 curr.htm
	link=`grep "\.mp3" curr.htm.utf8 | cut -d\" -f2`
	echo "$link" #>>links
#	wget -nv -nc -c -O ${curr_chp}.mp3 $link
#prozilla is much faster than wget
	proz -k ${proz_threads} $link
done
rm curr*
