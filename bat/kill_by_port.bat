rem rem 执行bat 输入指定的端口号进行杀
@echo off
setlocal enabledelayedexpansion
for /f "delims=  tokens=1" %%i in ('netstat -aon ^| findstr %1') do (
set a=%%i
goto js
)
:js
taskkill /pid "!a:~71,5!"
pause>nul