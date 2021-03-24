@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo             deploy_apps.bat
echo                  by niuren.zhu
echo                          2017.06.18
echo  说明：
echo     1. 部署IBAS的WAR包到应用目录，需要以管理员权限启动。
echo     2. 参数1，IBAS数据目录，默认.\ibas。
echo     3. 参数2，IBAS的包位置，默认.\ibas_packages。
echo     4. 参数3，IBAS部署目录，默认.\webapps。
echo     5. 参数4，IBAS共享库目录，默认.\ibas_lib。
echo     6. 脚本通文件链接方式，集中配置文件和日志目录到IBAS_HOME下。
echo     7. 提前下载并配置7z到PATH变量，或拷贝到.\ibas_tools目录。
echo     8. 请调整conf\catalina.properties的shared.loader="${catalina.home}/ibas_lib/*.jar"。
echo **************************************************************************************
SET h=%time:~0,2%
SET hh=%h: =0%
SET DATE_NAME=%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%%time:~6,2%
REM 设置参数变量
SET WORK_FOLDER=%~dp0
REM 设置ibas目录
SET IBAS_HOME=%1
if "%IBAS_HOME%" equ "" SET IBAS_HOME=%WORK_FOLDER%ibas\
if not exist "%IBAS_HOME%" mkdir "%IBAS_HOME%"
REM ibas配置目录
SET IBAS_CONF=%IBAS_HOME%conf\
if not exist "%IBAS_CONF%" mkdir "%IBAS_CONF%"
REM ibas数据目录
SET IBAS_DATA=%IBAS_HOME%data\
if not exist "%IBAS_DATA%" mkdir "%IBAS_DATA%"
REM ibas日志目录
SET IBAS_LOG=%IBAS_HOME%logs\
if not exist "%IBAS_LOG%" mkdir "%IBAS_LOG%"
REM 设置IBAS_PACKAGE目录
SET IBAS_PACKAGE=%2
if "%IBAS_PACKAGE%" equ "" SET IBAS_PACKAGE=%WORK_FOLDER%ibas_packages\
REM 设置IBAS_DEPLOY目录
SET IBAS_DEPLOY=%3
if "%IBAS_DEPLOY%" equ "" SET IBAS_DEPLOY=%WORK_FOLDER%webapps\
if not exist "%IBAS_DEPLOY%" mkdir "%IBAS_DEPLOY%"
REM 设置lib目录
SET IBAS_LIB=%4
if "%IBAS_LIB%" equ "" SET IBAS_LIB=%WORK_FOLDER%ibas_lib\
if not exist "%IBAS_LIB%" mkdir "%IBAS_LIB%"
REM 设置7z
SET TOOL_7Z=%WORK_FOLDER%ibas_tools\7z.exe
if not exist "%TOOL_7Z%" SET TOOL_7Z=7z.exe
REM 设置备份目录
SET IBAS_PACKAGE_BACKUP=%IBAS_PACKAGE%backup\%DATE_NAME%\
if not exist "%IBAS_PACKAGE_BACKUP%" mkdir "%IBAS_PACKAGE_BACKUP%"

REM 显示参数信息
echo ----------------------------------------------------
echo 应用包目录：%IBAS_PACKAGE%
echo 部署目录：%IBAS_DEPLOY%
echo 共享目录：%IBAS_LIB%
echo 数据目录：%IBAS_HOME%
echo ----------------------------------------------------


echo 开始解压[%IBAS_PACKAGE%]的war包
REM 开始发布当前版本
if not exist "%IBAS_PACKAGE%ibas.deploy.order.txt" dir /b "%IBAS_PACKAGE%ibas.*.war" >"%IBAS_PACKAGE%ibas.deploy.order.txt"
for /f %%m in (%IBAS_PACKAGE%ibas.deploy.order.txt) DO (
    echo --开始处理[%%m]
    SET module=%%m
    SET name=!module:~5,-18!
REM echo !name! REM 此处有个坑，文件名后几位不是.service-X.X.X.war格式就挂了。
    if exist "%IBAS_PACKAGE%%%m" (
        echo !name!>>"%IBAS_DEPLOY%ibas.release.txt"
        %TOOL_7Z% x "%IBAS_PACKAGE%%%m" -r -y -o"%IBAS_DEPLOY%!name!"
REM 删除配置文件，并统一到IBAS_CONF目录
        if exist "%IBAS_DEPLOY%!name!\WEB-INF\app.xml" (
            if not exist "%IBAS_CONF%app.xml" copy /y "%IBAS_DEPLOY%!name!\WEB-INF\app.xml" "%IBAS_CONF%app.xml"
            del /q "%IBAS_DEPLOY%!name!\WEB-INF\app.xml"
            mklink "%IBAS_DEPLOY%!name!\WEB-INF\app.xml" "%IBAS_CONF%app.xml"
        )
REM 删除路由文件，并统一到IBAS_CONF目录
        if exist "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml" (
            if not exist "%IBAS_CONF%service_routing.xml" copy /y "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBAS_CONF%service_routing.xml"
            del /q "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml"
            mklink "%IBAS_DEPLOY%!name!\WEB-INF\service_routing.xml" "%IBAS_CONF%service_routing.xml"
        )
REM 删除前端配置，并统一到IBAS_CONF目录
        if exist "%IBAS_DEPLOY%!name!\config.json" (
            if not exist "%IBAS_CONF%config.json" copy /y "%IBAS_DEPLOY%!name!\config.json" "%IBAS_CONF%config.json"
            del /q "%IBAS_DEPLOY%!name!\config.json"
            mklink "%IBAS_DEPLOY%!name!\config.json" "%IBAS_CONF%config.json"
        )
REM 统一日志目录到IBAS_LOG目录
        if exist "%IBAS_DEPLOY%!name!\WEB-INF\logs" rd /s /q "%IBAS_DEPLOY%!name!\WEB-INF\logs"
        mklink /d "%IBAS_DEPLOY%!name!\WEB-INF\logs" "%IBAS_LOG%"
REM 统一数据目录到IBAS_DATA目录
        if exist "%IBAS_DEPLOY%!name!\WEB-INF\data" rd /s /q "%IBAS_DEPLOY%!name!\WEB-INF\data"
        mklink /d "%IBAS_DEPLOY%!name!\WEB-INF\data" "%IBAS_DATA%"
REM 统一lib目录到运行目录
        if exist "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar" (
            dir "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar" >file_list.txt
            copy /y "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar" "%IBAS_LIB%"
            del /q "%IBAS_DEPLOY%!name!\WEB-INF\lib\*.jar"
        )
REM 备份程序包
        move "%IBAS_PACKAGE%%%m" "%IBAS_PACKAGE_BACKUP%%%m"
    )
)
REM 备份顺序文件
move "%IBAS_PACKAGE%ibas.deploy.order.txt" "%IBAS_PACKAGE_BACKUP%ibas.deploy.order.txt" > nul
REM 修正ROOT目录
if exist "%IBAS_DEPLOY%root" rename "%IBAS_DEPLOY%root" ROOT > nul

REM 共享jar包旧版清理
if exist "%IBAS_LIB%" (
  echo 清理[ibas_lib]旧版文件
  if exist "%IBAS_LIB%\~file_types.txt" (del /s /q "%IBAS_LIB%\~file_types.txt" > nul && echo.>"%IBAS_LIB%\~file_types.txt")
  for /f %%m in ('dir /b /o-n "%IBAS_LIB%\*.jar"') do (
    set file=%%m
    call :PosLastChar !file! - length
    call :GetChar !file! !length! file_type
	find "#!file_type!#" "%IBAS_LIB%\~file_types.txt" > nul && (
      echo --清理[!file!]
	  del /s /q "%IBAS_LIB%\!file!"
      echo !file! >>"%IBAS_LIB%\~deleted_files.txt"
	) || (
      echo #!file_type!# >>"%IBAS_LIB%\~file_types.txt"
	)
  )
)
echo 操作完成
goto :eof
rem :get char to pos
:GetChar
set SubStr=%1
set SubStr=!SubStr:~0,%2!
set %3=!SubStr!
goto :eof

rem :poschar str tag Res
:PosChar
set SubStr=
set F=0 
set TmpVar=%1
set %3=-1
:pos_begin
set SubStr=!TmpVar:~%F%,1!
if not defined substr goto :post_end 
if "%SubStr%"=="%2" (
set %3=%f%
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