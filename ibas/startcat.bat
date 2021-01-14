@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo                    startcat.bat
echo                          by niuren.zhu
echo                          2021.01.14
echo          说明：
echo              1. 列示并选择配置文件。
echo              2. 启动Tomcat。
echo **************************************************************************************
rem 设置参数变量
set WORK_FOLDER=%~dp0

set CONFIG_FOLDER=%WORK_FOLDER%\ibas\conf
set TOMCAT=%WORK_FOLDER%\bin\startup.bat

rem 检查环境
if not exist "%CONFIG_FOLDER%" (
    echo --没有配置文件夹
    goto :EOF
)
if not exist "%TOMCAT%" (
    echo --没有TOMCAT启动脚本
    goto :EOF
)

rem 选择文件
echo --后端配置文件选择
call :CHOOSE_FILE %CONFIG_FOLDER% app.xml
echo.

echo --服务路由文件选择
call :CHOOSE_FILE %CONFIG_FOLDER% service_routing.xml
echo.

echo --前端配置文件选择
call :CHOOSE_FILE %CONFIG_FOLDER% config.json
echo.

echo --启动Tomcat
call "%TOMCAT%"

goto :EOF

rem 函数：列示并选择文件。
rem     参数1，文件目录
rem     参数2，文件类型
:CHOOSE_FILE
    set FILE_FOLDER=%1
    set FILE_TYPE=%2

    if not exist "%FILE_FOLDER%" goto :END_FUNC
    if "%FILE_TYPE%" equ "" goto :END_FUNC

    for /f "tokens=1,2 delims=. " %%a in ('echo %FILE_TYPE%') do (
        set FILE_TYPE_1=%%a
        set FILE_TYPE_2=%%b
    )
    set FILE_FILTER=%FILE_TYPE_1%.*.%FILE_TYPE_2%
    set FILE_NAMES=
    set INDEX=0
    for %%f in ("%FILE_FOLDER%\%FILE_FILTER%") DO (
        set /a INDEX=!INDEX! + 1
        echo "!INDEX!) %%~ff"
        set FILE_NAMES[!INDEX!]=%%~ff
    )
    if exist "%FILE_FOLDER%~last.%FILE_TYPE%" echo "0) %FILE_FOLDER%~last.%FILE_TYPE%"

    set /p CHOOSE=--请输入选择的文件序号:
    if "%CHOOSE%" equ "" goto :END_FUNC

    if "%CHOOSE%" equ "0" (
        copy /y "%FILE_FOLDER%\~last.%FILE_TYPE%" "%FILE_FOLDER%\%FILE_TYPE%" >>nil
        goto :END_FUNC
    )
    echo --使用文件：!FILE_NAMES[%CHOOSE%]!
    copy /y "%FILE_FOLDER%\%FILE_TYPE%" "%FILE_FOLDER%\~last.%FILE_TYPE%" >>nil
    copy /y "!FILE_NAMES[%CHOOSE%]!" "%FILE_FOLDER%\%FILE_TYPE%" >>nil

:END_FUNC
    for /L %%i in (1, 1, %INDEX%) DO (
        set FILE_NAMES[%%i]=
    )

goto :EOF