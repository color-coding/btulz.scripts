@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo                 download_apps.bat
echo                       by niuren.zhu
echo                          2025.03.11
echo  ˵����
echo     1. Ӧ���б�[packages.txt]�����а汾�ſ�Ϊ������
echo     2. �����б�����Ӧ�õ�./ibas_packages��
echo     3. ����1��Ӧ�ð汾��
echo **************************************************************************************
REM ���ò�������
SET STARTUP_FOLDER=%~dp0
SET PACKAGES_FOLDER=%STARTUP_FOLDER%ibas_packages\
SET WORK_FOLDER=%STARTUP_FOLDER%
SET PACKAGES_LIST=%WORK_FOLDER%packages.txt
SET APP_VERSION=%1
if "%APP_VERSION%" equ "" (
  set /p APP_VERSION=--������汾��:
)
REM ����Ĭ�ϰ汾��
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

REM ���ù���
SET TOOL_CURL=%WORK_FOLDER%ibas_tools\curl.exe
if not exist "%TOOL_CURL%" SET TOOL_CURL=curl.exe

REM ��ʾ������Ϣ
echo ----------------------------------------------------
echo --������Ŀ¼��%WORK_FOLDER%
echo --�����Ŀ¼��%PACKAGES_FOLDER%
echo --Ӧ�õ��б�%PACKAGES_LIST%
echo --Ӧ�õİ汾��%APP_VERSION%
echo ----------------------------------------------------

if not exist "%PACKAGES_LIST%" (
  echo �����ڳ����б��ļ�[packages.txt]
  goto :EOF
)

REM �����б��ļ�
for /f %%l in (%PACKAGES_LIST%) do (
  set PACKAGE_URL=%%l
  if "!PACKAGE_URL:~0,4!" equ "http" (
    echo ---�������أ�!PACKAGE_URL!
    cd "!PACKAGES_FOLDER!" && "!TOOL_CURL!"  --retry 3 -L -O "!PACKAGE_URL!"
  )
)
cd "%WORK_FOLDER%"
echo --�����嵥��
dir "%PACKAGES_FOLDER%"\*.war
echo �������
