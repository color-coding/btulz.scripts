#!/bin/sh
echo '****************************************************************************'
echo '              clears.sh                                                     '
echo '                      by niuren.zhu                                         '
echo '                           2017.06.23                                       '
echo '  说明：                                                                    '
echo '    1. 遍历工作目录，删除日志文件。                                         '
echo '    2. 参数1，工作目录。                                                    '
echo '****************************************************************************'
# 设置参数变量
# 启动目录
STARTUP_FOLDER=`pwd`
# 工作目录默认第一个参数
WORK_FOLDER=$1
# 修正相对目录为启动目录
if [ "${WORK_FOLDER}" = "./" ]
then
  WORK_FOLDER=${STARTUP_FOLDER}
fi
# 未提供工作目录，则取启动目录
if [ "${WORK_FOLDER}" = "" ]
then
  WORK_FOLDER=${STARTUP_FOLDER}
fi

echo --工作的目录：${WORK_FOLDER}
# 获取编译顺序
if [ ! -e ${WORK_FOLDER}/compile_order.txt ]
then
  ls -l ${WORK_FOLDER} | awk '/^d/{print $NF}' > ${WORK_FOLDER}/compile_order.txt
fi
# 遍历当前目录
while read folder
do
  cd ${WORK_FOLDER}/${folder}
  echo --清理目录：`pwd`
  rm -f *log*.txt
# 清理符号链接
  for tmp in `find ${WORK_FOLDER}/${folder} -type l`
  do
    if [ -e ${tmp} ]
    then
      rm -f ${tmp} > /dev/null
    fi
  done
done < ${WORK_FOLDER}/compile_order.txt | sed 's/\r//g'
cd ${WORK_FOLDER}
