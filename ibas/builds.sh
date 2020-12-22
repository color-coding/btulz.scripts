#!/bin/sh
echo '****************************************************************************'
echo '              builds.sh                                                     '
echo '                      by niuren.zhu                                         '
echo '                           2017.06.01                                       '
echo '  说明：                                                                     '
echo '    1. 遍历工作目录，存在build_all.bat则调用。                                  '
echo '    2. 使用uglifyjs压缩*.js文件为*.min.js。                                   '
echo '    3. 参数1，编译的模块名称，不提供时使用compile_order.txt文件。                 '
echo '****************************************************************************'
# 设置参数变量
# 工作目录
WORK_FOLDER=$(pwd)
# 开始时间
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
echo --开始时间：${START_TIME}
echo --工作目录：${WORK_FOLDER}

echo --检查工具
COMPRESS=false
uglifyjs -V
if [ "$?" = "0" ]; then
  COMPRESS=true
else
  echo 请先安装压缩工具[npm install uglify-es -g]
  exit 1
fi

# 获取编译内容
COMPILE_ORDER=$@
if [ "${COMPILE_ORDER}" = "" ]; then
  # 没提供编译内容，则使用文件
  if [ ! -e ${WORK_FOLDER}/compile_order.txt ]; then
    # 文件不存在，先构建
    ls -l ${WORK_FOLDER} | awk '/^d/{print $NF}' >${WORK_FOLDER}/compile_order.txt
  fi
  COMPILE_ORDER=$(cat ${WORK_FOLDER}/compile_order.txt)
fi
# 开始遍历目录
for folder in ${COMPILE_ORDER}; do
  for builder in $(find ${WORK_FOLDER}/${folder} -type f -name build_all.sh); do
    # 运行编译命令
    if [ ! -x "${builder}" ]; then
      chmod 775 ${builder}
    fi
    echo --开始调用：${builder}
    "${builder}"
  done
  # 尝试压缩js文件
  if [ "${COMPRESS}" = "true" ]; then
    # 遍历当前目录
    for file in $(find ${WORK_FOLDER}/${folder} -type f -name *.js ! -name *.min.js ! -path "*3rdparty*" ! -path "*openui5/resources*" ! -path "*target*" ! -path "*test/integration*"); do
      compressed=${file%.js*}.min.js
      echo --开始压缩：${file}
      uglifyjs --compress --safari10 --keep-classnames --keep-fnames --mangle --output ${compressed} ${file}
    done
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
