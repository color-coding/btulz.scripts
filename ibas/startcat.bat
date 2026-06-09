@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo                    startcat.bat
echo                          by niuren.zhu
echo                          2021.01.14
echo          ˵����
echo              1. ��ʾ��ѡ�������ļ���
echo              2. ����Tomcat��
echo **************************************************************************************
rem ���ò�������
set WORK_FOLDER=%~dp0

set CONFIG_FOLDER=%WORK_FOLDER%\ibas\conf
set TOMCAT=%WORK_FOLDER%\bin\startup.bat

rem ��黷��
if not exist "%CONFIG_FOLDER%" (
    echo --û�������ļ���
    goto :EOF
)
if not exist "%TOMCAT%" (
    echo --û��TOMCAT�����ű�
    goto :EOF
)

rem ѡ���ļ�
echo --��������ļ�ѡ��
call :CHOOSE_FILE %CONFIG_FOLDER% app.xml
echo.

echo --����·���ļ�ѡ��
call :CHOOSE_FILE %CONFIG_FOLDER% service_routing.xml
echo.

echo --ǰ�������ļ�ѡ��
call :CHOOSE_FILE %CONFIG_FOLDER% config.json
echo.

echo --����Tomcat
call "%TOMCAT%"

goto :EOF

rem ��������ʾ��ѡ���ļ���
rem     ����1���ļ�Ŀ¼
rem     ����2���ļ�����
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

    set /p CHOOSE=--������ѡ����ļ����:
    if "%CHOOSE%" equ "" goto :END_FUNC

    if "%CHOOSE%" equ "0" (
        copy /y "%FILE_FOLDER%\~last.%FILE_TYPE%" "%FILE_FOLDER%\%FILE_TYPE%" >>nul
        goto :END_FUNC
    )
    echo --ʹ���ļ���!FILE_NAMES[%CHOOSE%]!
    copy /y "%FILE_FOLDER%\%FILE_TYPE%" "%FILE_FOLDER%\~last.%FILE_TYPE%" >>nul
    copy /y "!FILE_NAMES[%CHOOSE%]!" "%FILE_FOLDER%\%FILE_TYPE%" >>nul

:END_FUNC
    for /L %%i in (1, 1, %INDEX%) DO (
        set FILE_NAMES[%%i]=
    )

goto :EOF