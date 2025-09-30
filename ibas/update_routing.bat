@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo                       update_routing.bat
echo                               by niuren.zhu     
echo                               2022.10.27     
echo  ˵����     
echo    1. �������ݿ����[service_routing.xml]��       
echo    2. ����1�������ļ���ַ��Ĭ�ϣ�./ibas/conf/app.xml��       
echo    3. ����2������ļ���ַ��Ĭ�ϣ�./ibas/conf/service_routing.xml��    
echo    4. ����3�����ݷ����ַģ�壬Ĭ�ϣ�${ModuleName}/services/rest/data/��
echo    5. ����4����ͼ�����ַģ�壬Ĭ�ϣ�.../${ModuleName}/��     
echo    6. ����5�������Ŀ¼��Ĭ��./ibas_lib��  
echo    7. ��ǰ����btulz.transforms������./ibas_tools/Ŀ¼��     
echo    8. ��ǰ����app.xml�����ݿ���Ϣ��       
echo *****************************************************************
rem ���ò�������
set "WORK_FOLDER=%CD%"
rem ����ibas_toolsĿ¼
set "TOOLS_FOLDER=%WORK_FOLDER%\ibas_tools"
set "TOOLS_TRANSFORM=%TOOLS_FOLDER%\btulz.transforms.bobas-0.1.0.jar"
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms, in [%TOOLS_FOLDER%].
  exit /b 1
)

rem ����java·��
if exist "%WORK_FOLDER%\jdk\bin" (
  set "JAVA_HOME=%WORK_FOLDER%\jdk"
  set "PATH=%JAVA_HOME%\bin;%PATH%"
)

rem ���������ļ�
set "CONF_APP=%~1"
if "%CONF_APP%"=="" set "CONF_APP=%WORK_FOLDER%\ibas\conf\app.xml"
if not exist "%CONF_APP%" (
  echo not found app.xml.
  exit /b 1
)

rem ��������ļ�
set "CONF_ROUTING=%~2"
if "%CONF_ROUTING%"=="" set "CONF_ROUTING=%WORK_FOLDER%\ibas\conf\service_routing.xml"

rem �������ݷ����ַ
set "URL_DATA=%~3"
if "%URL_DATA%"=="" set "URL_DATA=.../${ModuleName}/services/rest/data/"

rem ������ͼ�����ַ
set "URL_VIEW=%~4"
if "%URL_VIEW%"=="" set "URL_VIEW=.../${ModuleName}/"

rem ����LIBĿ¼
set "IBAS_LIB=%~5"
if "%IBAS_LIB%"=="" set "IBAS_LIB=%WORK_FOLDER%\ibas_lib"


rem ��ʾ������Ϣ
echo ----------------------------------------------------
echo ���ߵ�ַ��%TOOLS_TRANSFORM%
echo �����ļ���%CONF_APP%
echo ����ļ���%CONF_ROUTING%
echo ���ݷ����ַ��%URL_DATA%
echo ��ͼ�����ַ��%URL_VIEW%
echo ����LIBĿ¼��%IBAS_LIB%
echo ----------------------------------------------------

rem �������ݿ��ࣨ��Windows�д���Ӳ���Ӷ��Ƿ������ӣ�
for %%F in ("%IBAS_LIB%\bobas*.db*.jar") do (
  if not exist "%TOOLS_FOLDER%\%%~nxF" (
    mklink /H "%TOOLS_FOLDER%\%%~nxF" "%%F" >nul 2>&1
    if errorlevel 1 (
      echo Failed to create hard link for %%~nxF, copying instead.
      copy "%%F" "%TOOLS_FOLDER%\%%~nxF" >nul
    )
  )
)

rem ����Javaת������
java -jar "%TOOLS_TRANSFORM%" routing "-config=%CONF_APP%" "-out=%CONF_ROUTING%" "-dataUrl=%URL_DATA%" "-viewUrl=%URL_VIEW%"

echo --
echo �������