@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo              compiles.bat
echo                     by niuren.zhu
echo                           2017.05.27
echo  ˵����
echo     1. ��������Ŀ¼������compile_packages.bat����á�
echo     2. ����1������Ŀ¼��
echo ****************************************************************************
rem ���ò�������
rem ����Ŀ¼
set STARTUP_FOLDER=%~dp0
rem ����Ĺ���Ŀ¼
set WORK_FOLDER=%~1
rem �ж��Ƿ񴫹���Ŀ¼��û����������Ŀ¼
if "%WORK_FOLDER%"=="" set WORK_FOLDER=%STARTUP_FOLDER%
rem ������Ŀ¼����ַ����ǡ�\������
if "%WORK_FOLDER:~-1%" neq "\" set WORK_FOLDER=%WORK_FOLDER%\

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b /od "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

echo --������Ŀ¼��%WORK_FOLDER%
for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  set FOLDER=%WORK_FOLDER%%%l
  if exist !FOLDER!\compile_packages.bat (  
    echo ----��ʼ���룺!FOLDER!
    cd !FOLDER!
    call !FOLDER!\compile_packages.bat
  )
)
cd %WORK_FOLDER%