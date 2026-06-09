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
rem 设置参数变量
set STARTUP_FOLDER=%~dp0
set PACKAGES_FOLDER=%STARTUP_FOLDER%ibas_packages\
set WORK_FOLDER=%STARTUP_FOLDER%
set PACKAGES_LIST=%WORK_FOLDER%packages.txt
set APP_VERSION=%1
if "%APP_VERSION%" equ "" (
  set /p APP_VERSION=--请输入版本号:
)
rem 设置默认版本号
if "%APP_VERSION%" equ "" (
  set APP_VERSION=
  for /f "skip=1 delims=" %%a in ('wmic os get localdatetime /value') do (
    for /f "tokens=2 delims==" %%b in ("%%a") do (
      set datetime=%%b
      set APP_VERSION=!datetime:~0,4!!datetime:~4,2!!datetime:~6,2!!datetime:~8,2!!datetime:~10,2!
    )
  )
)

if "%WORK_FOLDER:~-1%" neq "\" set WORK_FOLDER=%WORK_FOLDER%\
if not exist "%PACKAGES_FOLDER%" mkdir "%PACKAGES_FOLDER%"

rem 设置工具
set TOOL_CURL=%WORK_FOLDER%ibas_tools\curl.exe
if not exist "%TOOL_CURL%" set TOOL_CURL=curl.exe

rem 显示参数信息
echo ----------------------------------------------------
echo --工作目录：%WORK_FOLDER%
echo --应用目录：%PACKAGES_FOLDER%
echo --应用列表：%PACKAGES_LIST%
echo --应用版本：%APP_VERSION%
echo ----------------------------------------------------

if not exist "%PACKAGES_LIST%" (
  echo 不存在程序列表文件[packages.txt]
  goto :EOF
)

rem 下载列表文件
cd "%PACKAGES_FOLDER%"
for /f "usebackq delims=" %%l in ("%PACKAGES_LIST%") do (
  set PACKAGE_URL=%%l
  if "!PACKAGE_URL:~0,4!" equ "http" (
    echo ---正在下载：!PACKAGE_URL!
    for %%a in (echo "!PACKAGE_URL:/=" "!") do (
      set FILE_NAME=%%~a
    )
    "!TOOL_CURL!" --retry 3 -Lf -O "!PACKAGE_URL!" && echo !FILE_NAME!>>ibas.deploy.order.txt
  )
)
cd "%WORK_FOLDER%"
if exist "%PACKAGES_FOLDER%\ibas.deploy.order.txt" (
  echo --应用清单：
  type "%PACKAGES_FOLDER%\ibas.deploy.order.txt"
)
echo 操作完成
