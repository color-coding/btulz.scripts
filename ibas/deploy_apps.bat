@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo             deploy_apps.bat
echo                  by niuren.zhu
echo                          2017.06.18
echo  ˵����
echo     1. ����IBAS��WAR����Ӧ��Ŀ¼����Ҫ�Թ���ԱȨ��������
echo     2. ����1��IBAS����Ŀ¼��Ĭ��.\ibas��
echo     3. ����2��IBAS�İ�λ�ã�Ĭ��.\ibas_packages��
echo     4. ����3��IBAS����Ŀ¼��Ĭ��.\webapps��
echo     5. ����4��IBAS�����Ŀ¼��Ĭ��.\ibas_lib��
echo     6. �ű�ͨ�ļ����ӷ�ʽ�����������ļ�����־Ŀ¼��IBAS_HOME�¡�
echo     7. ��ǰ���ز�����7z��PATH�������򿽱���.\ibas_toolsĿ¼��
echo     8. �����conf\catalina.properties��shared.loader="${catalina.home}/ibas_lib/*.jar"��
echo **************************************************************************************
REM ��ȡ��ǰʱ�䣨���������ڣ�
SET DATE_NAME=
for /f "skip=1 delims=" %%a in ('wmic os get localdatetime /value') do (  
    for /f "tokens=2 delims==" %%b in ("%%a") do (  
        SET datetime=%%b  
        SET DATE_NAME=!datetime:~0,4!!datetime:~4,2!!datetime:~6,2!_!datetime:~8,2!!datetime:~10,2!!datetime:~12,2!
    )  
)
REM ���ò�������
SET WORK_FOLDER=%~dp0
REM ����ibasĿ¼
SET IBAS_HOME=%1
if "%IBAS_HOME%" equ "" SET IBAS_HOME=%WORK_FOLDER%ibas\
if not exist "%IBAS_HOME%" mkdir "%IBAS_HOME%"
REM ibas����Ŀ¼
SET IBAS_CONF=%IBAS_HOME%conf\
if not exist "%IBAS_CONF%" mkdir "%IBAS_CONF%"
REM ibas����Ŀ¼
SET IBAS_DATA=%IBAS_HOME%data\
if not exist "%IBAS_DATA%" mkdir "%IBAS_DATA%"
REM ibas��־Ŀ¼
SET IBAS_LOG=%IBAS_HOME%logs\
if not exist "%IBAS_LOG%" mkdir "%IBAS_LOG%"
REM ����IBAS_PACKAGEĿ¼
SET IBAS_PACKAGE=%2
if "%IBAS_PACKAGE%" equ "" SET IBAS_PACKAGE=%WORK_FOLDER%ibas_packages\
REM ����IBAS_DEPLOYĿ¼
SET IBAS_DEPLOY=%3
if "%IBAS_DEPLOY%" equ "" SET IBAS_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBAS_DEPLOY%" mkdir "%IBAS_DEPLOY%"
REM ����libĿ¼
SET IBAS_LIB=%4
if "%IBAS_LIB%" equ "" SET IBAS_LIB=%WORK_FOLDER%ibas_lib\
if not exist "%IBAS_LIB%" mkdir "%IBAS_LIB%"
REM ����7z
SET TOOL_7Z=%WORK_FOLDER%ibas_tools\7z.exe
if not exist "%TOOL_7Z%" SET TOOL_7Z=7z.exe
REM ���ñ���Ŀ¼
SET IBAS_PACKAGE_BACKUP=%IBAS_PACKAGE%backup\%DATE_NAME%\
if not exist "%IBAS_PACKAGE_BACKUP%" mkdir "%IBAS_PACKAGE_BACKUP%"

REM ��ʾ������Ϣ
echo ----------------------------------------------------
echo Ӧ�ð�Ŀ¼��%IBAS_PACKAGE%
echo ����Ŀ¼��%IBAS_DEPLOY%
echo ����Ŀ¼��%IBAS_LIB%
echo ����Ŀ¼��%IBAS_HOME%
echo ----------------------------------------------------


echo ��ʼ��ѹ[%IBAS_PACKAGE%]��war��
REM ��ʼ������ǰ�汾
if not exist "%IBAS_PACKAGE%ibas.deploy.order.txt" dir /b /od "%IBAS_PACKAGE%ibas.*.war" >"%IBAS_PACKAGE%ibas.deploy.order.txt"
for /f %%m in (%IBAS_PACKAGE%ibas.deploy.order.txt) DO (
    echo --��ʼ����[%%m]
    SET module=%%m
REM ��ȡ�ļ����ֵڶ���.��λ�ã�ibas.NAME.service-.....war
	call :PosChar !module! 6 . pos
	set /a pos=pos-5
	call :GetChar !module! 5 !pos! name
    if !pos! GTR 0 (
        if exist "%IBAS_PACKAGE%%%m" (
            echo !name!>>"%IBAS_DEPLOY%ibas.release.txt"
            %TOOL_7Z% x "%IBAS_PACKAGE%%%m" -r -y -o"%IBAS_DEPLOY%!name!"
REM ����WEB��ȫĿ¼
            if exist "%IBAS_DEPLOY%!name!\WEB-INF\" (
REM ɾ�������ļ�����ͳһ��IBAS_CONFĿ¼
                if exist "%IBAS_DEPLOY%!name!\WEB-INF\app.xml" (
                    if not exist "%IBAS_CONF%app.xml" copy /y "%IBAS_DEPLOY%!name!\WEB-INF\app.xml" "%IBAS_CONF%app.xml"
                    del /q "%IBAS_DEPLOY%!name!\WEB-INF\app.xml"
                    mklink "%IBAS_DEPLOY%!name!\WEB-INF\app.xml" "%IBAS_CONF%app.xml"
                )
REM ɾ��·���ļ�����ͳһ��IBAS_CONFĿ¼
                if exist "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml" (
                    if not exist "%IBAS_CONF%service_routing.xml" copy /y "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBAS_CONF%service_routing.xml"
                    del /q "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml"
                    mklink "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBAS_CONF%service_routing.xml"
                )
REM ͳһ��־Ŀ¼��IBAS_LOGĿ¼
                if exist "%IBAS_DEPLOY%!name!\WEB-INF\logs" rd /s /q "%IBAS_DEPLOY%!name!\WEB-INF\logs"
                mklink /d "%IBAS_DEPLOY%!name!\WEB-INF\logs" "%IBAS_LOG%"
REM ͳһ����Ŀ¼��IBAS_DATAĿ¼
                if exist "%IBAS_DEPLOY%!name!\WEB-INF\data" rd /s /q "%IBAS_DEPLOY%!name!\WEB-INF\data"
                mklink /d "%IBAS_DEPLOY%!name!\WEB-INF\data" "%IBAS_DATA%"
REM ͳһlibĿ¼������Ŀ¼
                if exist "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar" (
                    dir "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar" >"%IBAS_DEPLOY%!name!\WEB-INF\lib\file_list.txt"
                    copy /y "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar" "%IBAS_LIB%"
                    del /q "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar"
                )
            )
REM ɾ��ǰ�����ã���ͳһ��IBAS_CONFĿ¼
            if exist "%IBAS_DEPLOY%!name!\config.json" (
                if not exist "%IBAS_CONF%config.json" copy /y "%IBAS_DEPLOY%!name!\config.json" "%IBAS_CONF%config.json"
                del /q "%IBAS_DEPLOY%!name!\config.json"
                mklink "%IBAS_DEPLOY%!name!\config.json" "%IBAS_CONF%config.json"
            )
REM ���ݳ����
            move "%IBAS_PACKAGE%%%m" "%IBAS_PACKAGE_BACKUP%%%m"
        )
    )
)
REM ����˳���ļ�
move "%IBAS_PACKAGE%ibas.deploy.order.txt" "%IBAS_PACKAGE_BACKUP%ibas.deploy.order.txt" > nul
REM ����ROOTĿ¼
if exist "%IBAS_DEPLOY%root" rename "%IBAS_DEPLOY%root" ROOT > nul

REM ����jar���ɰ�����
if exist "%IBAS_LIB%" (
  echo ����[ibas_lib]�ɰ��ļ�
  if exist "%IBAS_LIB%\~file_types.txt" (del /s /q "%IBAS_LIB%\~file_types.txt" > nul)
  echo.>"%IBAS_LIB%\~file_types.txt"
  for /f %%m in ('dir /b /o-n "%IBAS_LIB%\*.jar"') do (
    set file=%%m
    call :PosLastChar !file! - length
    call :GetChar !file! 0 !length! file_type
	find "#!file_type!#" "%IBAS_LIB%\~file_types.txt" > nul && (
      echo --����[!file!]
	  del /s /q "%IBAS_LIB%\!file!"
      echo !file! >>"%IBAS_LIB%\~deleted_files.txt"
	) || (
      echo #!file_type!# >>"%IBAS_LIB%\~file_types.txt"
	)
  )
)
echo �������
goto :eof

rem :get char to pos
rem :%1 char; %2 start index; %3 length; %4 return value
:GetChar
set SubStr=%1
set SubStr=!SubStr:~%2,%3!
set %4=!SubStr!
goto :eof

rem :poschar str tag Res
rem :%1 char; %2 start index; %3 search char; %4 return value
:PosChar
set SubStr=
set TmpVar=%1
set F=%2
set %4=-1
:pos_begin
set SubStr=!TmpVar:~%F%,1!
if not defined substr goto :post_end 
if "%SubStr%"=="%3" (
set %4=%f%
goto :post_end
) else (
set /a f=%f%+1
goto :pos_begin
)
:post_end
goto :eof

rem :PosLastChar str tag Res
:PosLastChar
set SubStr=
set F=0 
set TmpVar=%1
set %3=-1
:PosLastCharBegin
set SubStr=!TmpVar:~%F%,1!
if not defined substr goto :PosLastCharEnd 
if "%SubStr%"=="%2" (
set %3=%f%
set /a f=%f%+1
goto :PosLastCharBegin
) else (
set /a f=%f%+1
goto :PosLastCharBegin
)
:PosLastCharEnd
goto :eof