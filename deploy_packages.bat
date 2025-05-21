@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo      deploy_packages.bat
echo                     by niuren.zhu
echo                           2017.09.06
echo  ˵����
echo     1. ����jar����maven�ֿ⡣
echo     2. ��setting.xml��^<servers^>�ڵ�����ӣ������û�����������Ҫ�����Ա���룩
echo           ^<server^>
echo             ^<id^>ibas-maven^<^/id^>
echo             ^<username^>�û���^<^/username^>
echo             ^<password^>����^<^/password^>
echo           ^<^/server^>
echo ****************************************************************************
rem ���ò�������
set WORK_FOLDER=%~dp0
rem �ֿ����ַ
set ROOT_URL=http://maven.colorcoding.org/repository/
rem �ֿ�����
set REPOSITORY=%1
rem ����Ĭ�ϲֿ�����
if "%REPOSITORY%"=="" set REPOSITORY=maven-releases
set REPOSITORY_URL=%ROOT_URL%%REPOSITORY%
set REPOSITORY_ID=ibas-maven

echo --���maven���л���
set MVN_BIN=mvn
if "%MAVEN_HOME%" neq "" (
  set MVN_BIN="%MAVEN_HOME%"\bin\mvn
)
call %MVN_BIN% -v >nul || goto :CHECK_MAVEN_FAILD

echo --������ַ��%REPOSITORY_URL%
rem �������߰�����
if exist %WORK_FOLDER%\release\btulz.scripts.tar (
  call %MVN_BIN% deploy:deploy-file ^
    -DgroupId=org.colorcoding.tools ^
    -DartifactId=btulz.scripts ^
    -Durl=%REPOSITORY_URL% ^
    -DrepositoryId=%REPOSITORY_ID% ^
    -Dfile=%WORK_FOLDER%\release\btulz.scripts.tar ^
    -Dpackaging=tar ^
    -Dversion=latest
)
echo --�������

goto :EOF
rem ********************************����Ϊ����************************************
:CHECK_MAVEN_FAILD
echo û�м�⵽MAVEN���밴�����²�����
echo 1. �Ƿ�װ�����ص�ַ��http://maven.apache.org/download.cgi
echo 2. �Ƿ����õ�PATH���������ú���Ҫ����
echo 3. ����mvn -v��������Ƿ�ɹ�
goto :EOF