@echo off
setlocal EnableDelayedExpansion
echo ***************************************************************************
echo                gits.bat
echo                     by niuren.zhu
echo                           2017.09.15
echo  说明：
echo     1. 遍历工作目录，存在.git文件夹则执行传入指令。
echo     2. 参数1，指令。
echo ****************************************************************************
REM 设置参数变量
REM 启动目录
SET WORK_FOLDER=%~dp0
REM 命令
SET GIT_COMMAND=
REM 拼接命令
:LOOP
IF "%1"=="" (
    GOTO :COMMAND_DONE
) ELSE (
    SET GIT_COMMAND=!GIT_COMMAND! %1
    SHIFT /1
    GOTO :LOOP
)
:COMMAND_DONE
IF "!GIT_COMMAND!"=="" (
    echo 命令无效
    GOTO :EOF
)

echo --工作目录：%WORK_FOLDER%
echo --批量指令：git !GIT_COMMAND!
for /f %%l in ('dir /b "%WORK_FOLDER%"') DO (
  SET FOLDER=%WORK_FOLDER%%%l
  if exist !FOLDER!\.git (
    echo ----!FOLDER!
    cd !FOLDER!
    git %GIT_COMMAND%
  )
)
cd %WORK_FOLDER%
