@ECHO off
SETLOCAL EnableDelayedExpansion
ECHO ***************************************************************************
ECHO                gits.bat
ECHO                     by niuren.zhu
ECHO                           2017.09.15
ECHO  ˵����
ECHO     1. ��������Ŀ¼������.git�ļ�����ִ�д���ָ�
ECHO     2. ����1��ָ�
ECHO     3. ����1��cloneʱ����Ҫ�ṩ��ַ���ű��Ჹȫcompile_order.txt���ݡ�
ECHO ****************************************************************************
REM ���ò�������
REM ����Ŀ¼
SET WORK_FOLDER=%~dp0
REM ����
SET GIT_COMMAND=git
REM ƴ������
:LOOP
IF "%1"=="" (
    GOTO :COMMAND_DONE
) ELSE (
    SET GIT_COMMAND=!GIT_COMMAND! %1
    SHIFT /1
    GOTO :LOOP
)
:COMMAND_DONE
IF "!GIT_COMMAND!"=="git" (
    ECHO ������Ч
    GOTO :EOF
)
ECHO --����Ŀ¼��%WORK_FOLDER%
ECHO --����ָ�!GIT_COMMAND!
IF "!GIT_COMMAND:~0,9!"=="git clone" (
  IF EXIST "%WORK_FOLDER%compile_order.txt" (
    FOR /f %%l IN (%WORK_FOLDER%compile_order.txt) DO (
      SET FOLDER=%%l
      !GIT_COMMAND!/!FOLDER!
    )
  )
) ELSE (
  FOR /f %%l IN ('DIR /b "%WORK_FOLDER%"') DO (
    SET FOLDER=%WORK_FOLDER%%%l
    IF EXIST !FOLDER!\.git (
      ECHO ----!FOLDER!
      CD !FOLDER!
      %GIT_COMMAND%
    )
  )
)
CD %WORK_FOLDER%
