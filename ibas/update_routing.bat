@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo                       update_routing.bat
echo                               by niuren.zhu     
echo                               2022.10.27     
echo  说明：     
echo    1. 分析数据库更新[service_routing.xml]。       
echo    2. 参数1，配置文件地址，默认：./ibas/conf/app.xml。       
echo    3. 参数2，输出文件地址，默认：./ibas/conf/service_routing.xml。    
echo    4. 参数3，数据服务地址模板，默认：${ModuleName}/services/rest/data/。
echo    5. 参数4，视图服务地址模板，默认：.../${ModuleName}/。     
echo    6. 参数5，共享库目录，默认./ibas_lib。  
echo    7. 提前下载btulz.transforms并放置./ibas_tools/目录。     
echo    8. 提前配置app.xml的数据库信息。       
echo *****************************************************************
rem 设置参数变量
set "WORK_FOLDER=%CD%"
rem 设置ibas_tools目录
set TOOLS_FOLDER=%WORK_FOLDER%\ibas_tools\
set TOOLS_TRANSFORM=
for /f "delims=" %%i in ('dir /b "%TOOLS_FOLDER%btulz.transforms.bobas-*.jar"') do (
  set TOOLS_TRANSFORM=%TOOLS_FOLDER%%%i
)
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms, in [%TOOLS_FOLDER%].
  exit /b 1
)

rem 设置java路径
if exist "%WORK_FOLDER%\jdk\bin" (
  set "JAVA_HOME=%WORK_FOLDER%\jdk"
  set "PATH=%JAVA_HOME%\bin;%PATH%"
)

rem 设置配置文件
set "CONF_APP=%~1"
if "%CONF_APP%"=="" set "CONF_APP=%WORK_FOLDER%\ibas\conf\app.xml"
if not exist "%CONF_APP%" (
  echo not found app.xml.
  exit /b 1
)

rem 设置输出文件
set "CONF_ROUTING=%~2"
if "%CONF_ROUTING%"=="" set "CONF_ROUTING=%WORK_FOLDER%\ibas\conf\service_routing.xml"

rem 设置数据服务地址
set "URL_DATA=%~3"
if "%URL_DATA%"=="" set "URL_DATA=.../${ModuleName}/services/rest/data/"

rem 设置视图服务地址
set "URL_VIEW=%~4"
if "%URL_VIEW%"=="" set "URL_VIEW=.../${ModuleName}/"

rem 设置LIB目录
set "IBAS_LIB=%~5"
if "%IBAS_LIB%"=="" set "IBAS_LIB=%WORK_FOLDER%\ibas_lib"


rem 显示参数信息
echo ----------------------------------------------------
echo 工具地址：%TOOLS_TRANSFORM%
echo 配置文件：%CONF_APP%
echo 输出文件：%CONF_ROUTING%
echo 数据服务地址：%URL_DATA%
echo 视图服务地址：%URL_VIEW%
echo 共享LIB目录：%IBAS_LIB%
echo ----------------------------------------------------

rem 链接数据库类（在Windows中创建硬链接而非符号链接）
for %%F in ("%IBAS_LIB%\bobas*.db*.jar") do (
  if not exist "%TOOLS_FOLDER%\%%~nxF" (
    mklink /H "%TOOLS_FOLDER%\%%~nxF" "%%F" >nul 2>&1
    if errorlevel 1 (
      echo Failed to create hard link for %%~nxF, copying instead.
      copy "%%F" "%TOOLS_FOLDER%\%%~nxF" >nul
    )
  )
)

rem 运行Java转换工具
java -jar "%TOOLS_TRANSFORM%" routing "-config=%CONF_APP%" "-out=%CONF_ROUTING%" "-dataUrl=%URL_DATA%" "-viewUrl=%URL_VIEW%"

echo --
echo 操作完成