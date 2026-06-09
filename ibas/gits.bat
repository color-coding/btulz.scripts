@ECHO off
SETLOCAL EnableDelayedExpansion
ECHO ***************************************************************************
ECHO                gits.bat
ECHO                     by niuren.zhu
ECHO                           2017.09.15
ECHO  说明：
ECHO     1. 遍历工作目录，存在.git文件夹则执行传入指令。
ECHO     2. 参数1，指令。
ECHO     3. 参数1：clone时，需要提供地址，脚本会补全compile_order.txt内容。
ECHO ****************************************************************************
rem 设置参数变量
rem 启动目录
set WORK_FOLDER=%~dp0
rem 命令
set GIT_COMMAND=git
rem 拼接命令
:LOOP
IF "%1"=="" (
    GOTO :COMMAND_DONE
) ELSE (
    set GIT_COMMAND=!GIT_COMMAND! %1
    SHIFT /1
    GOTO :LOOP
)
:COMMAND_DONE
IF "!GIT_COMMAND!"=="git" (
    ECHO 命令无效
    GOTO :EOF
)
ECHO --工作目录：%WORK_FOLDER%
ECHO --批量指令：!GIT_COMMAND!
IF "!GIT_COMMAND:~0,9!"=="git clone" (
  IF EXIST "%WORK_FOLDER%compile_order.txt" (
    FOR /f %%l IN (%WORK_FOLDER%compile_order.txt) DO (
      set FOLDER=%%l
      !GIT_COMMAND!/!FOLDER!
    )
  )
) ELSE (
  FOR /f %%l IN ('DIR /b "%WORK_FOLDER%"') DO (
    set FOLDER=%WORK_FOLDER%%%l
    IF EXIST !FOLDER!\.git (
      ECHO ----!FOLDER!
      CD "!FOLDER!"
      %GIT_COMMAND%
    )
  )
)
CD %WORK_FOLDER%
