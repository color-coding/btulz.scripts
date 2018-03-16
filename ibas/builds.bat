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

echo --������Ŀ¼��%WORK_FOLDER%
echo --��鹤��
SET COMPRESS=false
call uglifyjs -V
if "%ERRORLEVEL%"=="0" (
  SET COMPRESS=true
) else (
  echo ���Ȱ�װѹ������[npm install uglify-es -g]
)

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  set FOLDER=%%l
  for /f %%m in ('dir /s /b "%WORK_FOLDER%!FOLDER!\*build_all.bat"') DO (
    SET BUILDER=%%m
    cd /d %%~pm
    echo --��ʼ���ã�!BUILDER!
    call !BUILDER!
    cd /d !WORK_FOLDER!
  )
REM ����ѹ��js�ļ�
  if "%COMPRESS%"=="true" (
REM ������ǰĿ¼
    for /f %%n in ('dir /s /b %WORK_FOLDER%!FOLDER!\*.js') DO (
      set FILE=%%n
      set DONE=true
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:target=!"=="!TMP_VALUE!" (set DONE=true) else set DONE=false
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:3rdparty=!"=="!TMP_VALUE!" (set DONE=true) else set DONE=false
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:openui5\resources=!"=="!TMP_VALUE!" (set DONE=true) else set DONE=false
      set TMP_VALUE=!FILE!
      if "!DONE!"=="true" if "!TMP_VALUE:~-7!" neq ".min.js" (set DONE=true) else set DONE=false
      if "!DONE!"=="true" (
        set COMPRESSED=!FILE:~0,-3!.min.js
        echo --��ʼѹ����!FILE!
        call uglifyjs --compress --keep-classnames --keep-fnames --mangle --output !COMPRESSED! !FILE!
      )
    )
  )
  echo ****************************************************************************
)