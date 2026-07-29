@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo                    startcat.bat
echo                          by niuren.zhu
echo                          2021.01.14
echo          说明：
echo              1. 列示并选择配置文件。
echo              2. 选择启动模式（后台/前台）。
echo              3. 启动Tomcat。
echo **************************************************************************************
rem 设置参数变量
set WORK_FOLDER=%~dp0

set CONFIG_FOLDER=%WORK_FOLDER%\ibas\conf
set TOMCAT=%WORK_FOLDER%\bin\startup.bat
set CATALINA=%WORK_FOLDER%\bin\catalina.bat

rem 检查环境
if not exist "%CONFIG_FOLDER%" (
    echo --没有配置文件夹
    goto :EOF
)
if not exist "%TOMCAT%" (
    echo --没有TOMCAT启动脚本
    goto :EOF
)

rem 启动前清理运行目录：日志保留最近3天，其余临时目录全部清空
echo --清理Tomcat运行目录
if exist "%WORK_FOLDER%catalina.out" type nul > "%WORK_FOLDER%catalina.out"
call :CLEAN_LOG_FOLDER "%WORK_FOLDER%logs"
call :CLEAN_LOG_FOLDER "%WORK_FOLDER%ibas\logs"
call :CLEAN_FOLDER "%WORK_FOLDER%temp"
call :CLEAN_FOLDER "%WORK_FOLDER%ibas_packages\backup"
call :CLEAN_FOLDER "%WORK_FOLDER%history"

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

rem 选择启动模式
echo --启动模式选择
echo   1) 后台启动（日志输出到文件）
echo   2) 前台启动（默认，当前终端输出日志）
set START_MODE=2
set /p START_MODE=--请输入启动模式[2]: 

if "%START_MODE%" equ "1" (
    echo --后台启动Tomcat
    call "%TOMCAT%"
) else (
    if exist "%CATALINA%" (
        echo --前台启动Tomcat，日志输出到当前终端，按Ctrl+C可停止
        call "%CATALINA%" run
    ) else (
        echo --未找到catalina脚本[%CATALINA%]，使用后台启动
        call "%TOMCAT%"
    )
)

goto :EOF

rem 清空指定目录内容，保留目录本身
:CLEAN_LOG_FOLDER
    if not exist "%~1\" goto :EOF
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%~1' -File -Recurse | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-3) } | Remove-Item -Force" >nul 2>&1
goto :EOF

:CLEAN_FOLDER
    if not exist "%~1\" goto :EOF
    del /f /q /a "%~1\*" >nul 2>&1
    for /d %%d in ("%~1\*") do rd /s /q "%%~fd" >nul 2>&1
goto :EOF

rem 函数：列示并选择文件
rem     参数1：文件目录
rem     参数2：文件类型
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
        echo "!INDEX!) %%~nxf"
        set FILE_NAMES[!INDEX!]=%%~ff
    )
    if exist "%FILE_FOLDER%\~last.%FILE_TYPE%" echo "0) ~last.%FILE_TYPE%"

    set /p CHOOSE=--请输入选择的文件序号:
    if "%CHOOSE%" equ "" goto :END_FUNC

    if "%CHOOSE%" equ "0" (
        copy /y "%FILE_FOLDER%\~last.%FILE_TYPE%" "%FILE_FOLDER%\%FILE_TYPE%" >>nul
        goto :END_FUNC
    )
    echo --使用文件：!FILE_NAMES[%CHOOSE%]!
    copy /y "%FILE_FOLDER%\%FILE_TYPE%" "%FILE_FOLDER%\~last.%FILE_TYPE%" >>nul
    copy /y "!FILE_NAMES[%CHOOSE%]!" "%FILE_FOLDER%\%FILE_TYPE%" >>nul

:END_FUNC
    for /L %%i in (1, 1, %INDEX%) DO (
        set FILE_NAMES[%%i]=
    )

goto :EOF
