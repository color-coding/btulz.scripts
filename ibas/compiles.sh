#!/bin/sh
echo '****************************************************************************'
echo '              compiles.sh                                                   '
echo '                      by niuren.zhu                                         '
echo '                           2017.06.01                                       '
echo '  说明：                                                                     '
echo '    1. 遍历工作目录，存在compile_packages.bat则调用。                            '
echo '    2. 参数1，编译的模块名称，不提供时使用compile_order.txt文件。                  '
echo '****************************************************************************'
# 设置参数变量
# 工作目录
WORK_FOLDER=$(pwd)

# 开始时间
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
echo --开始时间：${START_TIME}
echo --工作目录：${WORK_FOLDER}

# 获取编译内容
COMPILE_ORDER=$@
if [ "${COMPILE_ORDER}" = "" ]; then
  # 没提供编译内容，则使用文件
  if [ ! -e ${WORK_FOLDER}/compile_order.txt ]; then
    # 文件不存在，先构建
    ls -ltr ${WORK_FOLDER} | awk '/^d/{print $NF}' >${WORK_FOLDER}/compile_order.txt
  fi
  COMPILE_ORDER=$(cat ${WORK_FOLDER}/compile_order.txt)
fi
# 遍历当前目录
for folder in ${COMPILE_ORDER}; do
  if [ -e ${WORK_FOLDER}/${folder}/compile_packages.sh ]; then
    if [ ! -x ${WORK_FOLDER}/${folder}/compile_packages.sh ]; then
      chmod 775 ${WORK_FOLDER}/${folder}/compile_packages.sh
    fi
    cd ${WORK_FOLDER}/${folder}
    echo ----开始编译：$(pwd)
    ${WORK_FOLDER}/${folder}/compile_packages.sh
  fi
  echo '****************************************************************************'
done
cd ${WORK_FOLDER}
# 计算执行时间
END_TIME=$(date +'%Y-%m-%d %H:%M:%S')
if [ "$(uname)" = "Darwin" ]; then
  # macOS
  START_SECONDS=$(date -j -f "%Y-%m-%d %H:%M:%S" "$START_TIME" +%s)
  END_SECONDS=$(date -j -f "%Y-%m-%d %H:%M:%S" "$END_TIME" +%s)
else
  START_SECONDS=$(date --date="$START_TIME" +%s)
  END_SECONDS=$(date --date="$END_TIME" +%s)
fi
echo --结束时间：${END_TIME}，共$((END_SECONDS - START_SECONDS))秒
