@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo               builds.bat
echo                     by niuren.zhu
echo                           2017.06.01
echo  ˵����
echo     1. ��������Ŀ¼������build_all.bat����á�
echo     2. ʹ��uglifyjsѹ��*.js�ļ�Ϊ*.min.js��
echo     3. ����1������Ŀ¼��
echo     4. ��������[TS_COMPRESS_DISABLED=true]���򲻿����ļ�ѹ����
echo     5. ��������[TS_COMPRESS_NO_ORIGINAL=true]���򲻱���ԭʼ�ļ���
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

echo --������Ŀ¼��%WORK_FOLDER%
echo --��鹤��
set COMPRESS=false
if not "%TS_COMPRESS_DISABLED%"=="true" (
  call uglifyjs -V
  if "%ERRORLEVEL%"=="0" (
    set COMPRESS=true
  ) else (
    echo ���Ȱ�װѹ������[npm install uglify-es -g]
  )
)

if not exist "%WORK_FOLDER%compile_order.txt" dir /a:d /b /od "%WORK_FOLDER%" >"%WORK_FOLDER%compile_order.txt"

for /f %%l in (%WORK_FOLDER%compile_order.txt) do (
  set FOLDER=%%l
  for /f "delims=" %%m in ('dir /s /b "%WORK_FOLDER%!FOLDER!\*build_all.bat" ^| findstr /v /i "\\test\\apps\\"') DO (
    set BUILDER=%%m
    cd /d %%~pm
    echo --��ʼ���ã�!BUILDER!
    call !BUILDER!
    cd /d !WORK_FOLDER!
  )
rem ����ѹ��js�ļ�
  if "%COMPRESS%"=="true" (
rem ������ǰĿ¼
    for /f %%n in ('dir /s /b %WORK_FOLDER%!FOLDER!\*.js ^| findstr /v /i "\\openui5\\" ^| findstr /v /i "\\3rdparty\\" ^| findstr /v /i "\\test\\apps\\"') DO (
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
        call uglifyjs --compress --safari10 --keep-classnames --keep-fnames --mangle --output !COMPRESSED! !FILE!
        if "!TS_COMPRESS_NO_ORIGINA!"=="true" (
          copy /y !COMPRESSED! !FILE!
        )
      )
    )
  )
  echo ****************************************************************************
)