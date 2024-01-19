@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo '                  deploy_docker.bat
echo '                     by niuren.zhu
echo '                        2021.08.28
echo '  说明：
echo '    1. 参数1，文件夹为网站目录。并构建运行容器。
echo '    2. 运行前，自主把应用war包，拷贝至网站目录下的ibas_packages下。
echo '    3. 应用配置及数据文件，在网站目录的ibas目录。
echo '    4. 脚本会自动在root\conf.d，创建网站的nginx配置。
echo '    5. 若开启Tomcat远程诊断，可以用jconsole连接，注意端口冲突。
echo '    6. 网站目录host文件会自动添加到容器（貌似windows不支持）。
echo **************************************************************************************
rem 设置参数变量
set WORK_FOLDER=%~dp0
if "%WORK_FOLDER:~-1%" equ "\" SET WORK_FOLDER=%WORK_FOLDER:~0,-1%

echo --工作目录：%WORK_FOLDER%
rem 获取网站名称
set WEBSITE=%~1
if "%WEBSITE%" equ "" (
    set /p WEBSITE=----请输入网站名称:
) else (
    echo --网站名称：%WEBSITE%
)
if "%WEBSITE%" equ "" (
    goto :eof
)
if not exist "%WORK_FOLDER%\%WEBSITE%" mkdir "%WORK_FOLDER%\%WEBSITE%"

rem 创建网站容器
call :DOWNCASE ibas-tomcat-%WEBSITE% RESULT
set CONTAINER_TOMCAT=%RESULT%
echo --网站容器：%CONTAINER_TOMCAT%
rem 检查数据目录
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas\conf\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas\conf\"
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas\data\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas\data\"
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas\logs\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas\logs\"
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas_packages\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas_packages\"
set /p RESET_TOMCAT=----重建网站容器？（n or [y]）:
if "%RESET_TOMCAT%" equ "" set RESET_TOMCAT=y

if "%RESET_TOMCAT%" equ "y" (
    set /p JMX_TOMCAT=----开启Tomcat远程诊断？（[n] or y）: 
    if "!JMX_TOMCAT!" equ "y" (
        set /p JMX_PORT=----远程诊断端口？（8900）: 
        if "!JMX_PORT!" equ "" (
            set JMX_PORT=8900
        )
        REM 检查环境变量文件
        if exist "%WORK_FOLDER%\%WEBSITE%\tomcat_setenv.bat" (
            del /f "%WORK_FOLDER%\%WEBSITE%\tomcat_setenv.bat"
        )
        set OUT_PUT="%WORK_FOLDER%\%WEBSITE%\tomcat_setenv.bat"
        echo REM script created >!OUT_PUT!
        echo SET JAVA_OPTS="%%JAVA_OPTS%% -Dcom.sun.management.jmxremote" >>!OUT_PUT!
        echo SET JAVA_OPTS="%%JAVA_OPTS%% -Dcom.sun.management.jmxremote.authenticate=false" >>!OUT_PUT!
        echo SET JAVA_OPTS="%%JAVA_OPTS%% -Dcom.sun.management.jmxremote.ssl=false" >>!OUT_PUT!
        echo SET JAVA_OPTS="%%JAVA_OPTS%% -Dcom.sun.management.jmxremote.port=!JMX_PORT!" >>!OUT_PUT!
        echo SET JAVA_OPTS="%%JAVA_OPTS%% -Dcom.sun.management.jmxremote.rmi.port=!JMX_PORT!" >>!OUT_PUT!
        echo SET JAVA_OPTS="%%JAVA_OPTS%% -Djava.rmi.server.hostname=%ComputerName%" >>!OUT_PUT!

        set DOCKER_JMX=-v "%WORK_FOLDER%\%WEBSITE%\tomcat_setenv.bat:C:\apache-tomcat\bin\setenv.bat"
        set DOCKER_JMX=!DOCKER_JMX! -p !JMX_PORT!:!JMX_PORT!
    )
    set /p MEM_TOMCAT=----网站容器内存？（1024m）:
    if "%MEM_TOMCAT%" equ "" (
        set MEM_TOMCAT=1024
    )
    set /a MEM_JAVA=!MEM_TOMCAT! - 128
    if exist "%WORK_FOLDER%\%WEBSITE%\hosts" (
REM 貌似windows版不支持
        set /p USE_HOSTS=----检测到host文件是否使用？（[n] or y）:
        if "!USE_HOSTS!" equ "y" (
            for /f "delims=" %%m in (%WORK_FOLDER%\%WEBSITE%\hosts) DO (
                set HOST=%%m
                if "!HOST:~0,1!" neq "#" (
                    set DONE=YES
                    for /f "tokens=1,2,*" %%a in ("!HOST!") do (
                        set HOST_IP=%%a
                        set HOST_NAME=%%b
                    )
                    if "!HOST_IP!" equ "" (
                        set DONE=NO
                    )
                    if "!HOST_IP!" equ "::1" (
                        set DONE=NO
                    )
                    if "!HOST_IP!" equ "127.0.0.1" (
                        set DONE=NO
                    )
                    if "!HOST_IP!" equ "255.255.255.255" (
                        set DONE=NO
                    )
                    if "!HOST_NAME!" equ "" (
                        set DONE=NO
                    )
                    if "!HOST_NAME!" equ "localhost" (
                        set DONE=NO
                    )
                    if "!DONE!" equ "YES" (
                        set HOST_TOMCAT=!HOST_TOMCAT! --add-host=!HOST_NAME!:!HOST_IP!
                    )
                )
            )
        )
    )
    if exist "%WORK_FOLDER%\%WEBSITE%\CONTAINER_IMAGE" (
        set /P DEF_IMAGE_TOMCAT=<"%WORK_FOLDER%\%WEBSITE%\CONTAINER_IMAGE"
    )
    if "!DEF_IMAGE_TOMCAT!" equ "" (
        set DEF_IMAGE_TOMCAT=colorcoding/tomcat:ibas-alpine
    )
    set /p IMAGE_TOMCAT=----网站容器镜像？（!DEF_IMAGE_TOMCAT!）:
    if "!IMAGE_TOMCAT!" equ "" (
        set IMAGE_TOMCAT=!DEF_IMAGE_TOMCAT!
    )
    set /p STARTUP_PARS=----其他启动参数 :
    docker rm -vf %CONTAINER_TOMCAT%
    docker run -d ^
        --name %CONTAINER_TOMCAT% ^
        -m !MEM_TOMCAT!m ^
        -v "%WORK_FOLDER%\%WEBSITE%\ibas:C:\apache-tomcat\ibas" ^
        -v "%WORK_FOLDER%\%WEBSITE%\ibas_packages:C:\apache-tomcat\ibas_packages" ^
        !STARTUP_PARS! ^
        !HOST_TOMCAT! ^
        !IMAGE_TOMCAT!
    echo !IMAGE_TOMCAT!>"%WORK_FOLDER%\%WEBSITE%\CONTAINER_IMAGE"
) else (
    rem 启动更新，需要做好目录映射
    docker start %CONTAINER_TOMCAT%
)

rem 释放程序包
docker exec -it %CONTAINER_TOMCAT% "C:\apache-tomcat\deploy_apps.bat"
rem 升级数据库
set /p UPDATE_DATABASE=----刷新数据库？（[n] or y）:
if "%UPDATE_DATABASE%" equ "y" (
    docker exec -it %CONTAINER_TOMCAT% "C:\apache-tomcat\initialize_apps.bat"
)
rem 重新启动容器
docker restart %CONTAINER_TOMCAT%

rem 更新根网站
set CONTAINER_NGINX=ibas-nginx-root
set NGINX_CONFD=%WORK_FOLDER%\root\conf.d
set NGINX_CERT=%WORK_FOLDER%\root\cert
set NGINX_NAME=%ComputerName%
set NGINX_PORT_HTTP=

echo --网站根节点：%CONTAINER_NGINX%
set /p UPDATE_ROOT=----更新根节点？（n or [y]）:
if "%UPDATE_ROOT%" equ "" (
    set UPDATE_ROOT=y
)
if "%UPDATE_ROOT%" equ "n" (
    goto :eof
)
rem 获取端口号
set /p NGINX_PORT_HTTP=----根节点http端口（80）:
if "%NGINX_PORT_HTTP%" equ "" (
    set NGINX_PORT_HTTP=80
)
rem 检查数据目录
if not exist "%NGINX_CERT%" mkdir "%NGINX_CERT%"
if not exist "%NGINX_CONFD%" mkdir "%NGINX_CONFD%"
if not exist "%NGINX_CONFD%\default.conf" (
    set OUT_PUT="%NGINX_CONFD%\default.conf"
    echo    # script created >!OUT_PUT!
    echo    server { >>!OUT_PUT!
    echo        listen       %NGINX_PORT_HTTP%; >>!OUT_PUT!
    echo        server_name  localhost %NGINX_NAME%; >>!OUT_PUT!

    echo        location \ { >>!OUT_PUT!
    echo            root   C:/nginx/html; >>!OUT_PUT!
    echo            index  index.html index.htm; >>!OUT_PUT!
    echo        } >>!OUT_PUT!

    echo        error_page   500 502 503 504  \50x.html; >>!OUT_PUT!
    echo        location = \50x.html { >>!OUT_PUT!
    echo            root   C:/nginx/html; >>!OUT_PUT!
    echo        } >>!OUT_PUT!

    echo        proxy_connect_timeout 1800; >>!OUT_PUT!
    echo        proxy_send_timeout 1800; >>!OUT_PUT!
    echo        proxy_read_timeout 1800; >>!OUT_PUT!

    echo        # others >>!OUT_PUT!
    echo        include C:/nginx/conf.d/*.location; >>!OUT_PUT!
    echo    } >>!OUT_PUT!
)
if not exist "%NGINX_CONFD%\%WEBSITE%.location" (
    set OUT_PUT="%NGINX_CONFD%\%WEBSITE%.location"
    echo    # script created >!OUT_PUT!
    echo    location /%WEBSITE%/ { >>!OUT_PUT!
    echo        proxy_pass http://%CONTAINER_TOMCAT%:8080/; >>!OUT_PUT!
    echo        proxy_redirect off; >>!OUT_PUT!
    echo        proxy_set_header Host $host; >>!OUT_PUT!
    echo        proxy_set_header X-Real-IP $remote_addr; >>!OUT_PUT!
    echo        proxy_set_header REMOTE-HOST $remote_addr; >>!OUT_PUT!
    echo        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >>!OUT_PUT!
    echo    } >>!OUT_PUT!
)
rem 重新创建根网站容器
set LINK_CONTAINER=
for /f "delims=" %%I in ('docker ps --format "table {{.Names}}"') do (
    set NAME=%%I
    if "!NAME:~0,12!" equ "ibas-tomcat-" (
        set LINK_CONTAINER=!LINK_CONTAINER! --link !NAME!
    )
)
docker rm -vf %CONTAINER_NGINX%
docker run -d ^
    --name %CONTAINER_NGINX% ^
    -p %NGINX_PORT_HTTP%:80 ^
    -m 64m ^
    -v "%NGINX_CONFD%:C:\nginx\conf.d" ^
    -v "%NGINX_CERT%:C:\nginx\cert" ^
    %LINK_CONTAINER% ^
    colorcoding/nginx:ibas-wincore
echo --网站地址：http:\\%NGINX_NAME%:%NGINX_PORT_HTTP%\%WEBSITE%\
echo --网站地址：https:\\%NGINX_NAME%:%NGINX_PORT_HTTPS%\%WEBSITE%\

goto :eof

:DOWNCASE
SET "DOWN=a b c d e f g h i j k l m n o p q r s t u v w x y z"
SETLOCAL ENABLEDELAYEDEXPANSION
SET $=&SET "#=%~1"
IF DEFINED # (
  FOR %%A IN (%DOWN%) DO SET #=!#:%%A=%%A!
)
ENDLOCAL & SET "%~2=%#%" & goto :eof