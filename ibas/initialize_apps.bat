@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo               initialize_apps.bat
echo                    by niuren.zhu
echo                    2018.01.27
echo  说明：
echo     1. 分析jar包创建数据结构和初始化数据，需要在Tomcat目录。
echo     2. 参数1，配置文件（app.xml）路径，默认WEB-INF\app.xml。
echo     3. 提前下载btulz.transforms并放置.\ibas_tools\目录。
echo     4. 注意维护ibas.release的顺序说明。
echo *****************************************************************
rem 设置参数变量
if "%1" neq "" (
  if not exist "%1" (
    echo not found config file, %1.
    goto :EOF
  )
set IBAS_APP=%1
)
rem 设置参数变量
set WORK_FOLDER=%CD%
rem 设置TOOLS目录
set TOOLS_FOLDER=%WORK_FOLDER%\ibas_tools\
set TOOLS_TRANSFORM=
for /f "delims=" %%i in ('dir /b "%TOOLS_FOLDER%btulz.transforms.bobas-*.jar"') do (
  set TOOLS_TRANSFORM=%TOOLS_FOLDER%%%i
)
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.bobas.
  goto :EOF
)
rem 设置DEPLOY目录
set IBAS_DEPLOY=%WORK_FOLDER%\webapps\
if not exist "%IBAS_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
rem 设置LIB目录
set IBAS_LIB=%WORK_FOLDER%\ibas_lib\
if not exist "%IBAS_LIB%" mkdir "%IBAS_LIB%"

rem 显示参数信息
echo ----------------------------------------------------
echo 工具地址：%TOOLS_TRANSFORM%
echo 部署目录：%IBAS_DEPLOY%
echo 共享目录：%IBAS_LIB%
if "%IBAS_APP%" neq "" echo 配置文件：%IBAS_APP%
echo ----------------------------------------------------

echo 开始分析[%IBAS_DEPLOY%]目录
set DB_JAR=bobas.businessobjectscommon.db.*.jar
rem 开始发布当前版本
if not exist "%IBAS_DEPLOY%ibas.release.txt" dir /D /B /OD /A:D "%IBAS_DEPLOY%" >"%IBAS_DEPLOY%ibas.release.txt"
for /f %%m in (%IBAS_DEPLOY%ibas.release.txt) DO (
echo --开始处理[%%m]
set MODULE=%%m
set MODULE_JAR=ibas.!MODULE!*.jar
if not exist "%IBAS_APP%" (
  set FILE_APP=%IBAS_DEPLOY%!MODULE!\WEB-INF\app.xml
) else (
  set FILE_APP=%IBAS_APP%
)
if exist "!FILE_APP!" (
  if exist "%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!DB_JAR!" (
    echo ----开始处理[.\WEB-INF\lib\!DB_JAR!]
    for %%f in (%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!DB_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
    )
  )
  if exist "%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!MODULE_JAR!" (
    echo ----开始处理[.\WEB-INF\lib\!MODULE_JAR!]
    set FILE_CLASSES=%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\
    for %%f in (%IBAS_DEPLOY%!MODULE!\WEB-INF\lib\!MODULE_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
    )
  )
rem 共享目录处理
  if exist "%IBAS_LIB%!DB_JAR!" (
    echo ----开始处理[%IBAS_LIB%!DB_JAR!]
    for %%f in (%IBAS_LIB%!DB_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
    )
    set DB_JAR=__DONE__
  )
  if exist "%IBAS_LIB%!MODULE_JAR!" (
    echo ----开始处理[%IBAS_LIB%!MODULE_JAR!]
    set FILE_CLASSES=%IBAS_LIB%
    for %%f in (%IBAS_LIB%!MODULE_JAR!) DO (
       call :INIT_DS "%%f" "!FILE_APP!"
       call :INIT_DATA "%%f" "!FILE_APP!" "!FILE_CLASSES!"
    )
  )
)
echo --
)
echo 操作完成

goto :EOF
rem 函数，初始化数据。参数1，分析的jar包 参数2，配置文件 参数3，加载的类库
rem 注意：命令字符太长，系统不能执行
:INIT_DATA
  set JarFile=%1
  set Config=%2
  set Classes=%3
  set COMMOND=java -jar %TOOLS_TRANSFORM% init -data=%JarFile% -config=%Config% -classes=%Classes%
  echo 运行：%COMMOND%
  call %COMMOND%
goto :EOF
rem 函数，初始化数据。参数1，分析的jar包 参数2，配置文件
rem 注意：命令字符太长，系统不能执行
:INIT_DS
  set JarFile=%1
  set Config=%2
  set COMMOND=java -jar %TOOLS_TRANSFORM% ds -data=%JarFile% -config=%Config%
  echo 运行：%COMMOND%
  call %COMMOND%
goto :EOF