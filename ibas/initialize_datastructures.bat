@echo off
setlocal EnableDelayedExpansion
echo *****************************************************************
echo      initialize_datastructures.bat
echo                by niuren.zhu
echo                           2017.06.06
echo  说明：
echo     1. 分析jar包并创建数据结构，数据库信息取值app.xml。
echo     2. 参数1，待分析的目录，默认.\webapps。
echo     3. 参数2，共享库目录，默认.\ibas_lib。
echo     4. 提前下载btulz.transforms并放置.\ibas_tools\目录。
echo     5. 提前配置app.xml的数据库信息。
echo     6. 注意维护ibas.release的顺序说明。
echo *****************************************************************
REM 检查JAVA运行环境
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM 设置参数变量
SET WORK_FOLDER=%~dp0
REM 设置TOOLS目录
SET TOOLS_FOLDER=%WORK_FOLDER%ibas_tools\
SET TOOLS_TRANSFORM=%TOOLS_FOLDER%btulz.transforms.core-0.1.1.jar
if not exist "%TOOLS_TRANSFORM%" (
  echo not found btulz.transforms.core.
  goto :EOF
)
REM 设置DEPLOY目录
SET IBAS_DEPLOY=%1
if "%IBAS_DEPLOY%" equ "" SET IBAS_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBAS_DEPLOY%" (
  echo not found webapps.
  goto :EOF
)
REM 设置LIB目录
SET IBAS_LIB=%2
if "%IBAS_LIB%" equ "" SET IBAS_LIB=%WORK_FOLDER%ibas_lib\
if not exist "%IBAS_LIB%" mkdir "%IBAS_LIB%"
REM 数据库信息
SET Company=CC
SET MasterDbType=mssql
SET MasterDbServer=localhost
SET MasterDbPort=1433
SET MasterDbSchema=
SET MasterDbName=ibas_demo
SET MasterDbUserID=sa
SET MasterDbUserPassword=1q2w3e

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
echo ----读取配置文件[.\WEB-INF\app.xml]
   call :LOAD_CONF "%IBAS_DEPLOY%!module!\WEB-INF\app.xml"
)
if exist "%IBAS_DEPLOY%!module!\WEB-INF\lib\!jar!" (
echo ----开始处理[.\WEB-INF\lib\!jar!]
for %%f in (%IBAS_DEPLOY%!module!\WEB-INF\lib\!jar!) DO (
   call :CREATE_DS %%f
))
if exist "%IBAS_LIB%!jar!" (
echo ----开始处理[%IBAS_LIB%!jar!]
for %%f in (%IBAS_LIB%!jar!) DO (
   call :CREATE_DS %%f
))
echo --
)
echo 操作完成

goto :EOF
REM 函数，创建数据结构。参数1，分析的jar包
:CREATE_DS
  SET JarFile=%1
  echo %MasterDbServer%
  for /f "tokens=1,2 delims=: " %%a in ('echo %MasterDbServer%') do (
    if "%%a" neq "%MasterDbServer%" (
      SET MasterDbServer=%%a
      SET MasterDbPort=%%b
    )
  )
  SET COMMOND=java ^
    -jar "%TOOLS_TRANSFORM%" dsJar^
    -DsTemplate=ds_%MasterDbType%_ibas_classic.xml^
    -JarFile="%JarFile%"^
    -SqlFilter=sql_%MasterDbType%^
    -Company=%Company%^
    -DbServer=%MasterDbServer%^
    -DbPort=%MasterDbPort%^
    -DbSchema=%MasterDbSchema%^
    -DbName=%MasterDbName%^
    -DbUser=%MasterDbUserID%^
    -DbPassword=%MasterDbUserPassword%
  echo 运行：%COMMOND%
  call %COMMOND%
goto :EOF
REM 函数，读取配置文件。参数1，使用的配置文件
:LOAD_CONF
  SET ConfFile=%1
  if not exist %ConfFile% goto :EOF
  for /f "tokens=* delims== " %%i in ('type "%ConfFile%"') do (
    set str=%%i
    call :TRIM str
    if "!str:~0,5!"=="<add " (
      for /f tokens^=2^,4^ delims^=^" %%j in ("!str!") do (
        SET %%j=%%k
      )
    )
  )
REM 调整变量大小写
  call :TO_LOWERCASE MasterDbType
REM 数据库架构修正
  if "%MasterDbType%" equ "mssql" (
    SET MasterDbSchema=dbo
  ) else (
    SET MasterDbSchema=
  )
REM 数据库端口修正
  if "%MasterDbType%" equ "mssql" SET MasterDbPort=1433
  if "%MasterDbType%" equ "mysql" SET MasterDbPort=3306
  if "%MasterDbType%" equ "pgsql" SET MasterDbPort=5432
  if "%MasterDbType%" equ "hana" SET MasterDbPort=30015
goto :EOF
REM 函数，去除空格及制表符。参数1，处理的变量名
:TRIM
if "!%1:~0,1!"==" " (set %1=!%1:~1!&&goto TRIM)
if "!%1:~0,1!"=="	" (set %1=!%1:~1!&&goto TRIM)
if "!%1:~-1!"==" " (set %1=!%1:~0,-1!&&goto TRIM)
if "!%1:~-1!"=="	" (set %1=!%1:~0,-1!&&goto TRIM)
goto :EOF
REM 函数，大写字母转小写。参数1，处理的变量名
:TO_UPPERCASE
  SET "UP=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
  SET #=%1
  SET VALUE=!%#%!
  IF DEFINED # (
    FOR %%A IN (%UP%) DO SET VALUE=!VALUE:%%A=%%A!
  )
  SET %#%=%VALUE%
goto :EOF
REM 函数，小写字母转大写。参数1，处理的变量名
:TO_LOWERCASE
  SET "DOWN=a b c d e f g h i j k l m n o p q r s t u v w x y z"
  SET #=%1
  SET VALUE=!%#%!
  IF DEFINED # (
    FOR %%A IN (%DOWN%) DO SET VALUE=!VALUE:%%A=%%A!
  )
  SET %#%=%VALUE%
goto :EOF