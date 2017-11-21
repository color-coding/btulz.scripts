#!/bin/sh
echo '****************************************************************************'
echo '                 gits.sh                                                    '
echo '                      by niuren.zhu                                         '
echo '                           2017.09.15                                       '
echo '  说明：                                                                    '
echo '    1. 遍历工作目录，存在.git文件夹则执行传入指令。                         '
echo '    2. 参数1，指令。                                                        '
echo '****************************************************************************'
# 设置参数变量
# 工作目录
WORK_FOLDER=`pwd`
# 命令
GIT_COMMAND=$@
if [ "${GIT_COMMAND}" == "" ]
then
    echo 命令无效
    exit 1
fi

echo --工作目录：${WORK_FOLDER}
echo --批量指令：git ${GIT_COMMAND}
# 遍历当前目录存
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