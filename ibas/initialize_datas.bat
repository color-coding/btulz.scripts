@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datas.bat
echo                by niuren.zhu
echo                       2017.03.22
echo  ˵����
echo     1. ����jar������ʼ�����ݣ����ݿ���Ϣȡֵapp.xml��
echo     2. ����1����������Ŀ¼��Ĭ��.\webapps��
echo     3. ����2�������Ŀ¼��Ĭ��.\ibas_lib��
echo     4. ��ǰ����btulz.transforms������.\ibas_tools\Ŀ¼��
echo     5. ��ǰ����app.xml�����ݿ���Ϣ��
echo *****************************************************************
REM ���JAVA���л���
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM ���ò�������
SET WORK_FOLDER=%~dp0
REM ����TOOLSĿ¼
SET TOOLS_FOLDER=%WORK_FOLDER%ibas_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.bobas-0.1.0.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.bobas.
  goto :EOF
)
REM ����DEPLOYĿ¼
SET ibas_DEPLOY=%1
if "%ibas_DEPLOY%" equ "" SET ibas_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%ibas_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
REM ����LIBĿ¼
SET ibas_LIB=%2
if "%ibas_LIB%" equ "" SET ibas_LIB=%WORK_FOLDER%ibas_lib\
if not exist "%ibas_LIB%" mkdir "%ibas_LIB%"

REM ��ʾ������Ϣ
echo ----------------------------------------------------
echo ���ߵ�ַ��%TOOLS_TRANSFORM%
echo ����Ŀ¼��%ibas_DEPLOY%
echo ����Ŀ¼��%ibas_LIB%
echo ----------------------------------------------------

echo ��ʼ����[%ibas_DEPLOY%]Ŀ¼
REM ��ʼ������ǰ�汾
if not exist "%ibas_DEPLOY%ibas.release.txt" dir /D /B /A:D "%ibas_DEPLOY%" >"%ibas_DEPLOY%ibas.release.txt"
for /f %%m in (%ibas_DEPLOY%ibas.release.txt) DO (
echo --��ʼ����[%%m]
SET module=%%m
SET jar=ibas.!module!-*.jar
if exist "%ibas_DEPLOY%!module!\WEB-INF\app.xml" (
  SET FILE_APP=%ibas_DEPLOY%!module!\WEB-INF\app.xml
  if exist "%ibas_DEPLOY%!module!\WEB-INF\lib\!jar!" (
    echo ----��ʼ����[.\WEB-INF\lib\!jar!]
    SET FILE_CLASSES=
    for %%f in (%ibas_DEPLOY%!module!\WEB-INF\lib\*.jar) DO (
       SET "FILE_CLASSES=!FILE_CLASSES!%%f;"
    )
    for %%f in (%ibas_DEPLOY%!module!\WEB-INF\lib\!jar!) DO (
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
  ))
  if exist "%ibas_LIB%!jar!" (
    echo ----��ʼ����[%ibas_LIB%!jar!]
    SET FILE_CLASSES=
    for %%f in (%ibas_LIB%*.jar) DO (
       SET "FILE_CLASSES=!FILE_CLASSES!%%f;"
    )
    for %%f in (%ibas_LIB%!jar!) DO (
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
  ))
)
echo --
)
echo �������

goto :EOF
REM ��������ʼ�����ݡ�����1��������jar�� ����2�������ļ� ����3�����ص����
:INIT_DATA
  SET JarFile=%1
  SET Config=%2
  SET Classes=%3
  SET COMMOND=java ^
    -jar "%TOOLS_TRANSFORM%" init^
    -data=%JarFile%^
    -config=%Config%^
    -classes=%Classes%
  echo ���У�%COMMOND%
  call %COMMOND%
goto :EOF