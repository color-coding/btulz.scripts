@echo off
setlocal EnableDelayedExpansion
echo *************************************************************************************
echo '                  deploy_docker.bat
echo '                     by niuren.zhu
echo '                        2021.08.28
echo '  ˵����
echo '    1. ����1���ļ���Ϊ��վĿ¼������������������
echo '    2. ����ǰ��������Ӧ��war������������վĿ¼�µ�ibas_packages�¡�
echo '    3. Ӧ�����ü������ļ�������վĿ¼��ibasĿ¼��
echo '    4. �ű����Զ���root\conf.d��������վ��nginx���á�
echo '    5. ������TomcatԶ����ϣ�������jconsole���ӣ�ע��˿ڳ�ͻ��
echo **************************************************************************************
rem ���ò�������
set WORK_FOLDER=%~dp0
if "%WORK_FOLDER:~-1%" equ "\" SET WORK_FOLDER=%WORK_FOLDER:~0,-1%

echo --����Ŀ¼��%WORK_FOLDER%
rem ��ȡ��վ����
set WEBSITE=%~1
if "%WEBSITE%" equ "" (
    set /p WEBSITE=----��������վ����:
) else (
    echo --��վ���ƣ�%WEBSITE%
)
if "%WEBSITE%" equ "" (
    goto :eof
)
if not exist "%WORK_FOLDER%\%WEBSITE%" mkdir "%WORK_FOLDER%\%WEBSITE%"

rem ������վ����
call :DOWNCASE ibas-tomcat-%WEBSITE% RESULT
set CONTAINER_TOMCAT=%RESULT%
echo --��վ������%CONTAINER_TOMCAT%
rem �������Ŀ¼
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas\conf\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas\conf\"
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas\data\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas\data\"
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas\logs\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas\logs\"
if not exist "%WORK_FOLDER%\%WEBSITE%\ibas_packages\" mkdir "%WORK_FOLDER%\%WEBSITE%\ibas_packages\"
set /p RESET_TOMCAT=----�ؽ���վ��������n or [y]��:
if "%RESET_TOMCAT%" equ "" set RESET_TOMCAT=y

if "%RESET_TOMCAT%" equ "y" (
    set /p JMX_TOMCAT=----����TomcatԶ����ϣ���[n] or y��: 
    if "!JMX_TOMCAT!" equ "y" (
        set /p JMX_PORT=----Զ����϶˿ڣ���8900��: 
        if "!JMX_PORT!" equ "" (
            set JMX_PORT=8900
        )
        REM ��黷�������ļ�
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
    set /p MEM_TOMCAT=----��վ�����ڴ棿��1024m��:
    if "%MEM_TOMCAT%" equ "" (
        set MEM_TOMCAT=1024
    )
    set /a MEM_JAVA=!MEM_TOMCAT! - 128    
    if exist "%WORK_FOLDER%\%WEBSITE%\CONTAINER_IMAGE" (
        set /P DEF_IMAGE_TOMCAT=<"%WORK_FOLDER%\%WEBSITE%\CONTAINER_IMAGE"
    )
    if "!DEF_IMAGE_TOMCAT!" equ "" (
        set DEF_IMAGE_TOMCAT=colorcoding/tomcat:ibas-alpine
    )
    set /p IMAGE_TOMCAT=----��վ�������񣿣�!DEF_IMAGE_TOMCAT!��:
    if "!IMAGE_TOMCAT!" equ "" (
        set IMAGE_TOMCAT=!DEF_IMAGE_TOMCAT!
    )
    docker rm -vf %CONTAINER_TOMCAT%
    docker run -d ^
        --name %CONTAINER_TOMCAT% ^
        -m !MEM_TOMCAT!m ^
        -v "%WORK_FOLDER%\%WEBSITE%\ibas:C:\apache-tomcat\ibas" ^
        -v "%WORK_FOLDER%\%WEBSITE%\ibas_packages:C:\apache-tomcat\ibas_packages" ^
        !IMAGE_TOMCAT!
    echo !IMAGE_TOMCAT!>"%WORK_FOLDER%\%WEBSITE%\CONTAINER_IMAGE"
) else (
    rem �������£���Ҫ����Ŀ¼ӳ��
    docker start %CONTAINER_TOMCAT%
)

rem �ͷų����
docker exec -it %CONTAINER_TOMCAT% "C:\apache-tomcat\deploy_apps.bat"
rem �������ݿ�
set /p UPDATE_DATABASE=----ˢ�����ݿ⣿��[n] or y��:
if "%UPDATE_DATABASE%" equ "y" (
    docker exec -it %CONTAINER_TOMCAT% "C:\apache-tomcat\initialize_apps.bat"
)
rem ������������
docker restart %CONTAINER_TOMCAT%

rem ���¸���վ
set CONTAINER_NGINX=ibas-nginx-root
set NGINX_CONFD=%WORK_FOLDER%\root\conf.d
set NGINX_CERT=%WORK_FOLDER%\root\cert
set NGINX_NAME=%ComputerName%
set NGINX_PORT_HTTP=
set NGINX_PORT_HTTPS=

echo --��վ���ڵ㣺%CONTAINER_NGINX%
set /p UPDATE_ROOT=----���¸��ڵ㣿��n or [y]��:
if "%UPDATE_ROOT%" equ "" (
    set UPDATE_ROOT=y
)
if "%UPDATE_ROOT%" equ "n" (
    goto :eof
)
rem ��ȡ�˿ں�
set /p NGINX_PORT_HTTP=----���ڵ�http�˿ڣ�80��:
if "%NGINX_PORT_HTTP%" equ "" (
    set NGINX_PORT_HTTP=80
)
set /p NGINX_PORT_HTTPS=----���ڵ�https�˿ڣ�443��:
if "%NGINX_PORT_HTTPS%" equ "" (
    set NGINX_PORT_HTTPS=443
)
rem �������Ŀ¼
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

    echo        # others >>!OUT_PUT!
    echo        include C:/nginx/conf.d/*.location; >>!OUT_PUT!
    echo    } >>!OUT_PUT!

    echo    server { >>!OUT_PUT!
    echo        listen %NGINX_PORT_HTTPS%; >>!OUT_PUT!
    echo        server_name %NGINX_NAME%; >>!OUT_PUT!
    echo        ssl on; >>!OUT_PUT!
    echo        ssl_certificate   C:/nginx/cert/1_%NGINX_NAME%_bundle.crt; >>!OUT_PUT!
    echo        ssl_certificate_key  C:/nginx/cert/2_%NGINX_NAME%.key; >>!OUT_PUT!
    echo        ssl_session_timeout 5m; >>!OUT_PUT!
    echo        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4; >>!OUT_PUT!
    echo        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; >>!OUT_PUT!
    echo        ssl_prefer_server_ciphers on; >>!OUT_PUT!

    echo        location \ { >>!OUT_PUT!
    echo            root   C:/nginx/html; >>!OUT_PUT!
    echo            index  index.html index.htm; >>!OUT_PUT!
    echo        } >>!OUT_PUT!

    echo        error_page   500 502 503 504  \50x.html; >>!OUT_PUT!
    echo        location = \50x.html { >>!OUT_PUT!
    echo            root   C:/nginx/html; >>!OUT_PUT!
    echo        } >>!OUT_PUT!

    echo        # others >>!OUT_PUT!
    echo        include C:/nginx/conf.d/*.location; >>!OUT_PUT!
    echo    } >>!OUT_PUT!
)
if not exist "%NGINX_CONFD%\%WEBSITE%.location" (
    set OUT_PUT="%NGINX_CONFD%\%WEBSITE%.location"
    echo    # script created >!OUT_PUT!
    echo    location /%WEBSITE%/ { >>!OUT_PUT!
    echo        proxy_connect_timeout 1800; >>!OUT_PUT!
    echo        proxy_send_timeout 1800; >>!OUT_PUT!
    echo        proxy_read_timeout 1800; >>!OUT_PUT!

    echo        proxy_pass http://%CONTAINER_TOMCAT%:8080/; >>!OUT_PUT!
    echo        proxy_redirect off; >>!OUT_PUT!
    echo        proxy_set_header Host $host; >>!OUT_PUT!
    echo        proxy_set_header X-Real-IP $remote_addr; >>!OUT_PUT!
    echo        proxy_set_header REMOTE-HOST $remote_addr; >>!OUT_PUT!
    echo        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; >>!OUT_PUT!
    echo    } >>!OUT_PUT!
)
rem ���´�������վ����
set LINK_TOMCATS=
for /f "delims=" %%I in ('docker ps --format "table {{.Names}}"') do (
    set NAME=%%I
    if "!NAME:~0,12!" equ "ibas-tomcat-" (
        set LINK_TOMCATS=!LINK_TOMCATS! --link !NAME!
    )
)
docker rm -vf %CONTAINER_NGINX%
docker run -d ^
    --name %CONTAINER_NGINX% ^
    -p %NGINX_PORT_HTTP%:80 ^
    -p %NGINX_PORT_HTTPS%:443 ^
    -m 64m ^
    -v "%NGINX_CONFD%:C:\nginx\conf.d" ^
    -v "%NGINX_CERT%:C:\nginx\cert" ^
    %LINK_TOMCATS% ^
    colorcoding/nginx:ibas-wincore
echo --��վ��ַ��http:\\%NGINX_NAME%:%NGINX_PORT_HTTP%\%WEBSITE%\
echo --��վ��ַ��https:\\%NGINX_NAME%:%NGINX_PORT_HTTPS%\%WEBSITE%\

goto :eof

:DOWNCASE
SET "DOWN=a b c d e f g h i j k l m n o p q r s t u v w x y z"
SETLOCAL ENABLEDELAYEDEXPANSION
SET $=&SET "#=%~1"
IF DEFINED # (
  FOR %%A IN (%DOWN%) DO SET #=!#:%%A=%%A!
)
ENDLOCAL & SET "%~2=%#%" & goto :eof