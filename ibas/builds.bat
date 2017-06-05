@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo               builds.bat
echo                     by niuren.zhu
echo                           2017.06.01
echo  ˵����
echo     1. ��������Ŀ¼������build_all.bat����á�
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

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

echo --������Ŀ¼��%WORK_FOLDER%
for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  for /f %%m in ('dir /s /b "%WORK_FOLDER%%%l\*build_all.bat"') DO (
    SET BUILDER=%%m
    echo ----��ʼ������!BUILDER!
    call !BUILDER!
  )
)
cd %WORK_FOLDER%