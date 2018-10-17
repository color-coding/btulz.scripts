@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo            compile_packages.bat
echo                     by niuren.zhu
echo                           2016.06.19
echo  ˵����
echo     1. ��װapache-maven�����ص�ַhttp://maven.apache.org/download.cgi��
echo     2. ��ѹapache-maven��������ϵͳ����MAVEN_HOMEΪ��ѹ�ĳ���Ŀ¼��
echo     3. ���PATH������%%MAVEN_HOME%%\bin�������JAVA_HOME�����Ƿ���ȷ��
echo     4. ������ʾ������mvn -v ��鰲װ�Ƿ�ɹ���
echo     5. �˽ű��������ǰĿ¼����Ŀ¼������pom.xml������jar����releaseĿ¼��
echo     6. ����compile_order.txt�ļ��е�������˳��
echo     7. ��Ҫ��װ7zip����ӵ�PATH��
echo ****************************************************************************
REM ���ò�������
SET WORK_FOLDER=%~dp0

echo --��ǰ������Ŀ¼��[%WORK_FOLDER%]

echo --�����Ŀ����
if exist %WORK_FOLDER%release\ rd /s /q %WORK_FOLDER%release\ >nul
if not exist %WORK_FOLDER%release md %WORK_FOLDER%release >nul

echo --ѹ���ļ�Ϊtar��
7z a -ttar btulz.scripts.tar ibas\*.sh ibas\*.bat
copy /y btulz.scripts.tar %WORK_FOLDER%release\ >nul
del /q btulz.scripts.tar

echo --�������
