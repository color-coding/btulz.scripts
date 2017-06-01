#!/bin/bash
echo '****************************************************************************'
echo '              gits_push.sh                                                  '
echo '                      by niuren.zhu                                         '
echo '                           2017.06.01                                       '
echo '  说明：                                                                    '
echo '    1. 遍历工作目录，存在.git文件夹则获取最新版。                              '
echo '    2. 参数1，工作目录。                                                     '
echo '****************************************************************************'
# 设置参数变量
# 启动目录
STARTUP_FOLDER=`pwd`
# 工作目录默认第一个参数
WORK_FOLDER=$1
# 修正相对目录为启动目录
if [ "${WORK_FOLDER}" == "./" ]
then
  WORK_FOLDER=${STARTUP_FOLDER}
fi
# 未提供工作目录，则取启动目录
if [ "${WORK_FOLDER}" == "" ]
then
  WORK_FOLDER=${STARTUP_FOLDER}
fi

echo --工作的目录：${WORK_FOLDER}
# 遍历当前目录存
for folder in `ls -l "${WORK_FOLDER}" | awk '/^d/{print $NF}'`
do
  if [ -e "${WORK_FOLDER}/${folder}/.git" ]
  then
    cd ${WORK_FOLDER}/${folder}
    echo ----开始提交：`pwd`
    git push
  fi
done
cd ${WORK_FOLDER}