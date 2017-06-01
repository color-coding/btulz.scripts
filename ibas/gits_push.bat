@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo              gits_push.bat
echo                     by niuren.zhu
echo                           2017.05.27
echo  说明：
echo     1. 遍历工作目录，存在.git文件夹则上传远程仓库。
echo     2. 运行前请自行检查是否提交。
echo     3. 参数1，工作目录。
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
for /f %%l in ('dir /b "%WORK_FOLDER%"') DO (
  SET FOLDER=%WORK_FOLDER%%%l
  if exist !FOLDER!\.git (  
    echo ----开始提交：!FOLDER!
    cd !FOLDER!
    git push
  )
)
cd %WORK_FOLDER%
