#!/bin/sh
# Preserve POSIX shell semantics when invoked explicitly through zsh.
[ -z "${ZSH_VERSION:-}" ] || exec sh "$0" "$@"
echo '****************************************************************************'
echo '              compiles.sh                                                   '
echo '                      by niuren.zhu                                         '
echo '                           2017.06.01                                       '
echo '  说明：                                                                     '
echo '    1. 遍历工作目录，存在compile_packages.sh则调用。                            '
echo '    2. 参数，编译的模块名称，不提供时使用compile_order.txt文件。                  '
echo '****************************************************************************'
# 设置参数变量
# 工作目录
WORK_FOLDER=$(pwd)

# 开始时间
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
echo --开始时间：${START_TIME}
echo --工作目录：${WORK_FOLDER}

# 每个参数或每一行代表一个模块，保留空格并兼容 CRLF 清单。
runModule() {
  folder=$1
  [ -n "${folder}" ] || return 0
  [ -d "${WORK_FOLDER%/}/${folder}" ] || return 1
  if [ -e "${WORK_FOLDER%/}/${folder}/compile_packages.sh" ]; then
    if [ ! -x "${WORK_FOLDER%/}/${folder}/compile_packages.sh" ]; then
      chmod +x "${WORK_FOLDER%/}/${folder}/compile_packages.sh" || return 1
    fi
    (
      cd "${WORK_FOLDER%/}/${folder}" || exit 1
      echo ----开始编译：$(pwd)
      "${WORK_FOLDER%/}/${folder}/compile_packages.sh"
    ) || return 1
  fi
  echo '****************************************************************************'
}
if [ "$#" -gt 0 ]; then
  for folder do
    runModule "${folder}" || exit 1
  done
else
  if [ ! -e "${WORK_FOLDER%/}/compile_order.txt" ]; then
    # 文件不存在，先构建
    ls -1trd "${WORK_FOLDER%/}/"*/ 2>/dev/null | while IFS= read -r directory; do
      directory=${directory%/}
      printf '%s\n' "${directory##*/}"
    done >"${WORK_FOLDER%/}/compile_order.txt"
  fi
  LC_ALL=C sed 's/\r//g' "${WORK_FOLDER%/}/compile_order.txt" | while IFS= read -r folder || [ -n "$folder" ]; do
    runModule "${folder}" || exit 1
  done || exit 1
fi
cd "${WORK_FOLDER}"
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
