@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo               builds.bat
echo                     by niuren.zhu
echo                           2017.06.01
echo  说明：
echo     1. 遍历工作目录，存在build_all.bat则调用。
echo     2. 参数1，工作目录。
echo ****************************************************************************
REM 设置参数变量
REM 启动目录
SET STARTUP_FOLDER=%~dp0
REM 传入的工作目录
SET WORK_FOLDER=%~1
REM 判断是否传工作目录，没有则是启动目录
if "%WORK_FOLDER%"=="" SET WORK_FOLDER=%STARTUP_FOLDER%
REM 若工作目录最后字符不是“\”则补齐
if "%WORK_FOLDER:~-1%" neq "\" SET WORK_FOLDER=%WORK_FOLDER%\

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

echo --工作的目录：%WORK_FOLDER%
for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  set FOLDER=%%l
  for /f %%m in ('dir /s /b "%WORK_FOLDER%!FOLDER!\*build_all.bat"') DO (
    SET FOLDER=%%~pm
    SET BUILDER=%%m
    cd /d !FOLDER!
    echo --开始调用：!BUILDER!
    call !BUILDER!
    echo ****************************************************************************
  )
)
cd /d %WORK_FOLDER%
cd %WORK_FOLDER%