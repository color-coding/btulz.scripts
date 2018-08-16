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
REM ���ò�������
SET WORK_FOLDER=%~dp0
REM �ֿ����ַ
SET ROOT_URL=http://maven.colorcoding.org/repository/
REM �ֿ�����
SET REPOSITORY=%1
REM ����Ĭ�ϲֿ�����
if "%REPOSITORY%"=="" SET REPOSITORY=maven-releases
set REPOSITORY_URL=%ROOT_URL%%REPOSITORY%
set REPOSITORY_ID=ibas-maven

echo --���maven���л���
call mvn -v >nul || goto :CHECK_MAVEN_FAILD

echo --������ַ��%REPOSITORY_URL%
REM �������߰�����
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
echo --�������

goto :EOF
REM ********************************����Ϊ����************************************
:CHECK_MAVEN_FAILD
echo û�м�⵽MAVEN���밴�����²�����
echo 1. �Ƿ�װ�����ص�ַ��http://maven.apache.org/download.cgi
echo 2. �Ƿ����õ�PATH���������ú���Ҫ����
echo 3. ����mvn -v��������Ƿ�ɹ�
goto :EOF