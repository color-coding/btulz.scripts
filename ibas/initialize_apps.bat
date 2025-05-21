@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo               initialize_apps.bat
echo                    by niuren.zhu
echo                    2018.01.27
echo  ˵����
echo     1. ����jar���������ݽṹ�ͳ�ʼ�����ݣ���Ҫ��TomcatĿ¼��
echo     2. ����1�������ļ���app.xml��·����Ĭ��WEB-INF\app.xml��
echo     3. ��ǰ����btulz.transforms������.\ibas_tools\Ŀ¼��
echo     4. ע��ά��ibas.release��˳��˵����
echo *****************************************************************
rem ���ò�������
if "%1" neq "" (
  if not exist "%1" (
    echo not found config file, %1.
    goto :EOF
  )
set IBAS_APP=%1
)
rem ���ò�������
set WORK_FOLDER=%CD%
rem ����TOOLSĿ¼
set TOOLS_FOLDER=%WORK_FOLDER%\ibas_tools\
set TOOLS_TRANSFORM=
for /f "delims=" %%i in ('dir /b "%TOOLS_FOLDER%btulz.transforms.bobas-*.jar"') do (
  set TOOLS_TRANSFORM=%TOOLS_FOLDER%%%i
)
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.bobas.
  goto :EOF
)
rem ����DEPLOYĿ¼
set IBAS_DEPLOY=%WORK_FOLDER%\webapps\
if not exist "%IBAS_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
rem ����LIBĿ¼
set IBAS_LIB=%WORK_FOLDER%\ibas_lib\
if not exist "%IBAS_LIB%" mkdir "%IBAS_LIB%"

rem ��ʾ������Ϣ
echo ----------------------------------------------------
echo ���ߵ�ַ��%TOOLS_TRANSFORM%
echo ����Ŀ¼��%IBAS_DEPLOY%
echo ����Ŀ¼��%IBAS_LIB%
if "%IBAS_APP%" neq "" echo �����ļ���%IBAS_APP%
echo ----------------------------------------------------

echo ��ʼ����[%IBAS_DEPLOY%]Ŀ¼
set DB_JAR=bobas.businessobjectscommon.db.*.jar
rem ��ʼ������ǰ�汾
if not exist "%IBAS_DEPLOY%ibas.release.txt" dir /D /B /OD /A:D "%IBAS_DEPLOY%" >"%IBAS_DEPLOY%ibas.release.txt"
for /f %%m in (%IBAS_DEPLOY%ibas.release.txt) DO (
echo --��ʼ����[%%m]
set MODULE=%%m
set MODULE_JAR=ibas.!MODULE!*.jar
if not exist "%IBAS_APP%" (
  set FILE_APP=%IBAS_DEPLOY%!MODULE!\WEB-INF\app.xml
) else (
  set FILE_APP=%IBAS_APP%
)
if exist "!FILE_APP!" (
  if exist "%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!DB_JAR!" (
    echo ----��ʼ����[.\WEB-INF\lib\!DB_JAR!]
    for %%f in (%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!DB_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
    )
  )
  if exist "%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!MODULE_JAR!" (
    echo ----��ʼ����[.\WEB-INF\lib\!MODULE_JAR!]
    set FILE_CLASSES=%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\
    for %%f in (%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!MODULE_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
    )
  )
rem ����Ŀ¼����
  if exist "%IBAS_LIB%!DB_JAR!" (
    echo ----��ʼ����[%IBAS_LIB%!DB_JAR!]
    for %%f in (%IBAS_LIB%!DB_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
    )
    set DB_JAR=__DONE__
  )
  if exist "%IBAS_LIB%!MODULE_JAR!" (
    echo ----��ʼ����[%IBAS_LIB%!MODULE_JAR!]
    set FILE_CLASSES=%IBAS_LIB%
    for %%f in (%IBAS_LIB%!MODULE_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
    )
  )
)
echo --
)
echo �������

goto :EOF
rem ��������ʼ�����ݡ�����1��������jar�� ����2�������ļ� ����3�����ص����
rem ע�⣺�����ַ�̫����ϵͳ����ִ��
:INIT_DATA
  set JarFile=%1
  set Config=%2
  set Classes=%3
  set COMMOND=java -jar %TOOLS_TRANSFORM% init -data=%JarFile% -config=%Config% -classes=%Classes%
  echo ���У�%COMMOND%
  call %COMMOND%
goto :EOF
rem ��������ʼ�����ݡ�����1��������jar�� ����2�������ļ�
rem ע�⣺�����ַ�̫����ϵͳ����ִ��
:INIT_DS
  set JarFile=%1
  set Config=%2
  set COMMOND=java -jar %TOOLS_TRANSFORM% ds -data=%JarFile% -config=%Config%
  echo ���У�%COMMOND%
  call %COMMOND%
goto :EOF