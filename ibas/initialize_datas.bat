@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datas.bat
echo                by niuren.zhu
echo                       2017.06.06
echo  说明：
echo     1. 分析jar包并初始化数据，数据库信息取值app.xml。
echo     2. 参数1，待分析的目录，默认.\webapps。
echo     3. 参数2，共享库目录，默认.\ibas_lib。
echo     4. 提前下载btulz.transforms并放置.\ibas_tools\目录。
echo     5. 提前配置app.xml的数据库信息。
echo *****************************************************************
REM 检查JAVA运行环境
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM 设置参数变量
SET WORK_FOLDER=.\
REM 设置TOOLS目录
SET TOOLS_FOLDER=%WORK_FOLDER%ibas_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.bobas-0.1.0.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.bobas.
  goto :EOF
)
REM 设置DEPLOY目录
SET ibas_DEPLOY=%1
if "%IBAS_DEPLOY%" equ "" SET IBAS_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBAS_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
REM 设置LIB目录
SET IBAS_LIB=%2
if "%IBAS_LIB%" equ "" SET IBAS_LIB=%WORK_FOLDER%ibas_lib\
if not exist "%IBAS_LIB%" mkdir "%IBAS_LIB%"

REM 显示参数信息
echo ----------------------------------------------------
echo 工具地址：%TOOLS_TRANSFORM%
echo 部署目录：%IBAS_DEPLOY%
echo 共享目录：%IBAS_LIB%
echo ----------------------------------------------------

echo 开始分析[%IBAS_DEPLOY%]目录
REM 开始发布当前版本
if not exist "%IBAS_DEPLOY%ibas.release.txt" dir /D /B /A:D "%IBAS_DEPLOY%" >"%IBAS_DEPLOY%ibas.release.txt"
for /f %%m in (%IBAS_DEPLOY%ibas.release.txt) DO (
echo --开始处理[%%m]
SET module=%%m
SET jar=ibas.!module!-*.jar
if exist "%IBAS_DEPLOY%!module!\WEB-INF\app.xml" (
  SET FILE_APP=%IBAS_DEPLOY%!module!\WEB-INF\app.xml
  if exist "%IBAS_DEPLOY%!module!\WEB-INF\lib\!jar!" (
    echo ----开始处理[.\WEB-INF\lib\!jar!]
    SET FILE_CLASSES=
    for %%f in (%IBAS_DEPLOY%!module!\WEB-INF\lib\*.jar) DO (
       SET "FILE_CLASSES=!FILE_CLASSES!%%f;"
    )
    for %%f in (%IBAS_DEPLOY%!module!\WEB-INF\lib\!jar!) DO (
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
  ))
  if exist "%IBAS_LIB%!jar!" (
    echo ----开始处理[%IBAS_LIB%!jar!]
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
echo 操作完成

goto :EOF
REM 函数，初始化数据。参数1，分析的jar包 参数2，配置文件 参数3，加载的类库
REM 注意：命令字符太长，系统不能执行
:INIT_DATA
  SET JarFile=%1
  SET Config=%2
  SET Classes=%3
  SET COMMOND=java -jar %TOOLS_TRANSFORM% init -data=%JarFile% -config=%Config% -classes=%Classes%
  echo 运行：%COMMOND%
  call %COMMOND%
goto :EOF