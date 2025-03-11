@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo                 download_apps.bat
echo                       by niuren.zhu
echo                          2025.03.11
echo  说明：
echo     1. 应用列表[packages.txt]，其中版本号可为变量。
echo     2. 根据列表，下载应用到./ibas_packages。
echo     3. 参数1，应用版本。
echo **************************************************************************************
REM 设置参数变量
SET STARTUP_FOLDER=%~dp0
SET PACKAGES_FOLDER=%STARTUP_FOLDER%ibas_packages\
SET WORK_FOLDER=%STARTUP_FOLDER%
SET PACKAGES_LIST=%WORK_FOLDER%packages.txt
SET APP_VERSION=%1
if "%APP_VERSION%" equ "" (
  set /p APP_VERSION=--请输入版本号:
)
REM 设置默认版本号
if "%APP_VERSION%" equ "" (
  SET APP_VERSION=
  for /f "skip=1 delims=" %%a in ('wmic os get localdatetime /value') do (
    for /f "tokens=2 delims==" %%b in ("%%a") do (
      SET datetime=%%b
      SET APP_VERSION=!datetime:~0,4!!datetime:~4,2!!datetime:~6,2!!datetime:~8,2!!datetime:~10,2!
    )
  )
)

if "%WORK_FOLDER:~-1%" neq "\" SET WORK_FOLDER=%WORK_FOLDER%\
if not exist "%PACKAGES_FOLDER%" mkdir "%PACKAGES_FOLDER%"

REM 设置工具
SET TOOL_CURL=%WORK_FOLDER%ibas_tools\curl.exe
if not exist "%TOOL_CURL%" SET TOOL_CURL=curl.exe

REM 显示参数信息
echo ----------------------------------------------------
echo --工作的目录：%WORK_FOLDER%
echo --程序的目录：%PACKAGES_FOLDER%
echo --应用的列表：%PACKAGES_LIST%
echo --应用的版本：%APP_VERSION%
echo ----------------------------------------------------

if not exist "%PACKAGES_LIST%" (
  echo 不存在程序列表文件[packages.txt]
  goto :EOF
)

REM 下载列表文件
for /f %%l in (%PACKAGES_LIST%) do (
  set PACKAGE_URL=%%l
  if "!PACKAGE_URL:~0,4!" equ "http" (
    echo ---正在下载：!PACKAGE_URL!
    cd "!PACKAGES_FOLDER!" && "!TOOL_CURL!"  --retry 3 -L -O "!PACKAGE_URL!"
  )
)
cd "%WORK_FOLDER%"
echo --程序清单：
dir "%PACKAGES_FOLDER%"\*.war
echo 操作完成
