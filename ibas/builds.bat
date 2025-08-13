@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo               builds.bat
echo                     by niuren.zhu
echo                           2017.06.01
echo  说明：
echo     1. 遍历工作目录，存在build_all.bat则调用。
echo     2. 使用uglifyjs压缩*.js文件为*.min.js。
echo     3. 参数1，工作目录。
echo     4. 环境变量[TS_COMPRESS_DISABLED=true]，则不开启文件压缩。
echo     5. 环境变量[TS_COMPRESS_NO_ORIGINAL=true]，则不保留原始文件。
echo ****************************************************************************
rem 设置参数变量
rem 启动目录
set STARTUP_FOLDER=%~dp0
rem 传入的工作目录
set WORK_FOLDER=%~1
rem 判断是否传工作目录，没有则是启动目录
if "%WORK_FOLDER%"=="" set WORK_FOLDER=%STARTUP_FOLDER%
rem 若工作目录最后字符不是“\”则补齐
if "%WORK_FOLDER:~-1%" neq "\" set WORK_FOLDER=%WORK_FOLDER%\

echo --工作的目录：%WORK_FOLDER%
echo --检查工具
set COMPRESS=false
if not "%TS_COMPRESS_DISABLED%"=="true" (
  call uglifyjs -V
  if "%ERRORLEVEL%"=="0" (
    set COMPRESS=true
  ) else (
    echo 请先安装压缩工具[npm install uglify-es -g]
  )
)

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b /od "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  set FOLDER=%%l
  for /f "delims=" %%m in ('dir /s /b "%WORK_FOLDER%!FOLDER!\*build_all.bat" ^| findstr /v /i "\\test\\apps\\"') DO (
    set BUILDER=%%m
    cd /d %%~pm
    echo --开始调用：!BUILDER!
    call !BUILDER!
    cd /d !WORK_FOLDER!
  )
rem 尝试压缩js文件
  if "%COMPRESS%"=="true" (
rem 遍历当前目录
    for /f %%n in ('dir /s /b %WORK_FOLDER%!FOLDER!\*.js ^| findstr /v /i "\\openui5\\" ^| findstr /v /i "\\3rdparty\\" ^| findstr /v /i "\\test\\apps\\"') DO (
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
        call uglifyjs --compress --safari10 --keep-classnames --keep-fnames --mangle --output !COMPRESSED! !FILE!
        if "!TS_COMPRESS_NO_ORIGINA!"=="true" (
          copy /y !COMPRESSED! !FILE!
        )
      )
    )
  )
  echo ****************************************************************************
)