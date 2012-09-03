::usage: %0 [book] [1st chapter] [last chapter] [html suffix]

@echo off

set url_prefix=http://www1.yousheng8.com/
set book=%1
set first_chp=%2
set last_chp=%3
set html_suffix=%4

for /L %%i in (%first_chp%, 1, %last_chp%) do (
	printf "%%02d" %%i >curr.txt 2>nul
	call ::aa %%i
)
del curr.*
goto :eof
:aa
for /F %%c in (curr.txt) do (
	set curr_chp=%%c
	echo %curr_chp%
	set url_suffix=down_%book%_%curr_chp%.%html_suffix%
	echo %url_suffix%
	wget -O curr.htm %url_prefix%%url_suffix%
	grep "\.mp3" curr.htm >curr.link
	sed -i -e s/\"/\!/g curr.link
	call ::bb %%c
)
goto :eof
:bb
for /F "tokens=2 delims=!" %%j in (curr.link) do (
	echo %%j
)
goto :eof