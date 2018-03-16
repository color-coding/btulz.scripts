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

echo --工作的目录：%WORK_FOLDER%
echo --检查工具
SET COMPRESS=false
call uglifyjs -V
if "%ERRORLEVEL%"=="0" (
  SET COMPRESS=true
) else (
  echo 请先安装压缩工具[npm install uglify-es -g]
)

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  set FOLDER=%%l
  for /f %%m in ('dir /s /b "%WORK_FOLDER%!FOLDER!\*build_all.bat"') DO (
    SET BUILDER=%%m
    cd /d %%~pm
    echo --开始调用：!BUILDER!
    call !BUILDER!
    cd /d !WORK_FOLDER!
  )
REM 尝试压缩js文件
  if "%COMPRESS%"=="true" (
REM 遍历当前目录
    for /f %%n in ('dir /s /b %WORK_FOLDER%!FOLDER!\*.js') DO (
      set FILE=%%n
      set DONE=true
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:target=!"=="!TMP_VALUE!" (set DONE=true) else set DONE=false
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:3rdparty=!"=="!TMP_VALUE!" (set DONE=true) else set DONE=false
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:openui5\resources=!"=="!TMP_VALUE!" (set DONE=true) else set DONE=false
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:~-7!" neq ".min.js" (set DONE=true) else set DONE=false
      if "!DONE!"=="true" (
        set COMPRESSED=!FILE:~0,-3!.min.js
        echo --开始压缩：!FILE!
        call uglifyjs --compress --keep-classnames --keep-fnames --mangle --output !COMPRESSED! !FILE!
      )
    )
  )
  echo ****************************************************************************
)