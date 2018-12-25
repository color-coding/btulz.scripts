#!/bin/sh
echo '****************************************************************************'
echo '                 gits.sh                                                    '
echo '                      by niuren.zhu                                         '
echo '                           2017.09.15                                       '
echo '  说明：                                                                    '
echo '    1. 遍历工作目录，存在.git文件夹则执行传入指令。                         '
echo '    2. 参数1，指令。                                                        '
echo '    3. 参数1：clone时，需要提供地址，脚本会补全compile_order.txt内容。      '
echo '****************************************************************************'
# 设置参数变量
# 工作目录
WORK_FOLDER=`pwd`
# 命令
GIT_COMMAND=$@
if [ "${GIT_COMMAND}" = "" ]
then
    echo 命令无效
    exit 1
fi

echo --工作目录：${WORK_FOLDER}
echo --批量指令：git ${GIT_COMMAND}
if [ "$1" = "clone" ]
then
  while read folder
  do
    git ${GIT_COMMAND}${folder}
  done < ${WORK_FOLDER}/compile_order.txt | sed 's/\r//g'
  exit 0
fi
# 遍历当前目录
for folder in `ls -l "${WORK_FOLDER}" | awk '/^d/{print $NF}'`
do
  if [ -e "${WORK_FOLDER}/${folder}/.git" ]
  then
    cd ${WORK_FOLDER}/${folder}
    echo ----`pwd`
    git ${GIT_COMMAND}
  fi
done
cd ${WORK_FOLDER}
