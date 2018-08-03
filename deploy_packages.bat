@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo      deploy_packages.bat
echo                     by niuren.zhu
echo                           2017.09.06
echo  说明：
echo     1. 发布jar包到maven仓库。
echo     2. 在setting.xml的^<servers^>节点下添加（其中用户名与密码需要向管理员申请）
echo           ^<server^>
echo             ^<id^>ibas-maven^<^/id^>
echo             ^<username^>用户名^<^/username^>
echo             ^<password^>密码^<^/password^>
echo           ^<^/server^>
echo ****************************************************************************
REM 设置参数变量
SET WORK_FOLDER=%~dp0
REM 仓库根地址
SET ROOT_URL=http://maven.colorcoding.org/repository/
REM 仓库名称
SET REPOSITORY=%1
REM 设置默认仓库名称
if "%REPOSITORY%"=="" SET REPOSITORY=maven-releases
set REPOSITORY_URL=%ROOT_URL%%REPOSITORY%
set REPOSITORY_ID=ibas-maven

echo --检查maven运行环境
call mvn -v >nul || goto :CHECK_MAVEN_FAILD

echo --发布地址：%REPOSITORY_URL%
REM 发布工具包集合
if exist %WORK_FOLDER%\release\btulz.scripts.tar (
  call mvn deploy:deploy-file ^
    -DgroupId=org.colorcoding.tools ^
    -DartifactId=btulz.scripts ^
    -Durl=%REPOSITORY_URL% ^
    -DrepositoryId=%REPOSITORY_ID% ^
    -Dfile=%WORK_FOLDER%\release\btulz.scripts.tar ^
    -Dpackaging=tar ^
    -Dversion=latest
)
echo --操作完成

goto :EOF
REM ********************************以下为函数************************************
:CHECK_MAVEN_FAILD
echo 没有检测到MAVEN，请按照以下步骤检查
echo 1. 是否安装，下载地址：http://maven.apache.org/download.cgi
echo 2. 是否配置到PATH变量，配置后需要重启
echo 3. 运行mvn -v检查配置是否成功
goto :EOF