@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo             copy_wars.bat
echo                  by niuren.zhu
echo                          2017.08.30
echo  说明：
echo     1. 遍历工作目录，寻找war包到./ibas_packages。
echo     2. 参数1，工作目录。
echo **************************************************************************************
rem 设置参数变量
set STARTUP_FOLDER=%~dp0
set PACKAGES_FOLDER=%STARTUP_FOLDER%ibas_packages\
set WORK_FOLDER=%1

if "%WORK_FOLDER:~-1%" neq "\" set WORK_FOLDER=%WORK_FOLDER%\
if not exist "%PACKAGES_FOLDER%" mkdir "%PACKAGES_FOLDER%"

rem 显示参数信息
echo ----------------------------------------------------
echo --工作的目录：%WORK_FOLDER%
echo --程序的目录：%PACKAGES_FOLDER%
echo ----------------------------------------------------

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b /od "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

if exist "%PACKAGES_FOLDER%ibas.deploy.order.txt" del /q /f "%PACKAGES_FOLDER%ibas.deploy.order.txt"

for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  set FOLDER=%WORK_FOLDER%%%l\release\
  if exist "!FOLDER!*.service-*.war" (
    copy /y "!FOLDER!*.service-*.war" "%PACKAGES_FOLDER%"
    dir /b !FOLDER!*.service-*.war >>"%PACKAGES_FOLDER%ibas.deploy.order.txt"
  )
)
echo --程序清单：
dir "%PACKAGES_FOLDER%"\*.war
echo 操作完成