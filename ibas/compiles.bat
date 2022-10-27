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
REM ���ò�������
REM ����Ŀ¼
SET STARTUP_FOLDER=%~dp0
REM ����Ĺ���Ŀ¼
SET WORK_FOLDER=%~1
REM �ж��Ƿ񴫹���Ŀ¼��û����������Ŀ¼
if "%WORK_FOLDER%"=="" SET WORK_FOLDER=%STARTUP_FOLDER%
REM ������Ŀ¼����ַ����ǡ�\������
if "%WORK_FOLDER:~-1%" neq "\" SET WORK_FOLDER=%WORK_FOLDER%\

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b /od "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

echo --������Ŀ¼��%WORK_FOLDER%
for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  SET FOLDER=%WORK_FOLDER%%%l
  if exist !FOLDER!\compile_packages.bat (  
    echo ----��ʼ���룺!FOLDER!
    cd !FOLDER!
    call !FOLDER!\compile_packages.bat
  )
)
cd %WORK_FOLDER%