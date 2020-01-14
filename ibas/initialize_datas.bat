@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datas.bat
echo                by niuren.zhu
echo                       2017.06.06
echo  ˵����
echo     1. ����jar������ʼ�����ݣ����ݿ���Ϣȡֵapp.xml��
echo     2. ����1����������Ŀ¼��Ĭ��.\webapps��
echo     3. ����2�������Ŀ¼��Ĭ��.\ibas_lib��
echo     4. ��ǰ����btulz.transforms������.\ibas_tools\Ŀ¼��
echo     5. ��ǰ����app.xml�����ݿ���Ϣ��
echo     6. ע��ά��ibas.release��˳��˵����
echo *****************************************************************
REM ���JAVA���л���
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM ���ò�������
SET WORK_FOLDER=.\
REM ����TOOLSĿ¼
SET TOOLS_FOLDER=%WORK_FOLDER%ibas_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.bobas-0.1.0.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.bobas.
  goto :EOF
)
REM ����DEPLOYĿ¼
SET ibas_DEPLOY=%1
if "%IBAS_DEPLOY%" equ "" SET IBAS_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBAS_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
REM ����LIBĿ¼
SET IBAS_LIB=%2
if "%IBAS_LIB%" equ "" SET IBAS_LIB=%WORK_FOLDER%ibas_lib\
if not exist "%IBAS_LIB%" mkdir "%IBAS_LIB%"

REM ��ʾ������Ϣ
echo ----------------------------------------------------
echo ���ߵ�ַ��%TOOLS_TRANSFORM%
echo ����Ŀ¼��%IBAS_DEPLOY%
echo ����Ŀ¼��%IBAS_LIB%
echo ----------------------------------------------------

echo ��ʼ����[%IBAS_DEPLOY%]Ŀ¼
REM ��ʼ������ǰ�汾
if not exist "%IBAS_DEPLOY%ibas.release.txt" dir /D /B /A:D "%IBAS_DEPLOY%" >"%IBAS_DEPLOY%ibas.release.txt"
for /f %%m in (%IBAS_DEPLOY%ibas.release.txt) DO (
echo --��ʼ����[%%m]
SET module=%%m
SET jar=ibas.!module!*.jar
if exist "%IBAS_DEPLOY%!module!\WEB-INF\app.xml" (
  SET FILE_APP=%IBAS_DEPLOY%!module!\WEB-INF\app.xml
  if exist "%IBAS_DEPLOY%!module!\WEB-INF\lib\!jar!" (
    echo ----��ʼ����[.\WEB-INF\lib\!jar!]
    SET FILE_CLASSES=
    for %%f in (%IBAS_DEPLOY%!module!\WEB-INF\lib\*.jar) DO (
       SET "FILE_CLASSES=!FILE_CLASSES!%%f;"
    )
    for %%f in (%IBAS_DEPLOY%!module!\WEB-INF\lib\!jar!) DO (
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
  ))
  if exist "%IBAS_LIB%!jar!" (
    echo ----��ʼ����[%IBAS_LIB%!jar!]
    SET FILE_CLASSES=
    for %%f in (%IBAS_LIB%*.jar) DO (
       SET "FILE_CLASSES=!FILE_CLASSES!%%f;"
    )
    for %%f in (%IBAS_LIB%\!jar!) DO (
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
  ))
)
echo --
)
echo �������

goto :EOF
REM ��������ʼ�����ݡ�����1��������jar�� ����2�������ļ� ����3�����ص����
REM ע�⣺�����ַ�̫����ϵͳ����ִ��
:INIT_DATA
  SET JarFile=%1
  SET Config=%2
  SET Classes=%3
  SET COMMOND=java -jar %TOOLS_TRANSFORM% init -data=%JarFile% -config=%Config% -classes=%Classes%
  echo ���У�%COMMOND%
  call %COMMOND%
goto :EOF