#!/bin/sh
echo '****************************************************************************'
echo '                  compress.sh                                               '
echo '                       by niuren.zhu                                        '
echo '                           2018.03.15                                       '
echo '  说明：                                                                    '
echo '    1. 遍历工作目录，压缩*.js文件为*.min.js文件。                      '
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

# 检查工具
uglifyjs -V
if [ "$?" != "0" ]
then
  echo 请先安装压缩工具
  echo npm install uglify-es -g
  exit 0
fi

echo --工作的目录：${WORK_FOLDER}
# 获取编译顺序
if [ ! -e ${WORK_FOLDER}/compile_order.txt ]
then
  ls -l ${WORK_FOLDER} | awk '/^d/{print $NF}' > ${WORK_FOLDER}/compile_order.txt
fi
# 遍历当前目录
while read module
do
  for file in `find ${WORK_FOLDER}/${module} -type f -name *.js ! -name *.min.js ! -path "*3rdparty*"`
  do
    compressed=${file%%.js*}.min.js
    echo --压缩：${file}
    uglifyjs --compress --keep-classnames --keep-fnames --mangle --output ${compressed} ${file}
  done
done < ${WORK_FOLDER}/compile_order.txt | sed 's/\r//g'
cd ${WORK_FOLDER}
