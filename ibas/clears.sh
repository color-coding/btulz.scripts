#!/bin/sh
# Preserve POSIX shell semantics when invoked explicitly through zsh.
[ -z "${ZSH_VERSION:-}" ] || exec sh "$0" "$@"
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
STARTUP_FOLDER=$(pwd)
# 工作目录默认第一个参数
WORK_FOLDER=$1
# 修正相对目录为启动目录
if [ "${WORK_FOLDER}" = "./" ]; then
  WORK_FOLDER=${STARTUP_FOLDER}
fi
# 未提供工作目录，则取启动目录
if [ "${WORK_FOLDER}" = "" ]; then
  WORK_FOLDER=${STARTUP_FOLDER}
fi
# Resolve before any cd so relative input stays anchored to the startup directory.
WORK_FOLDER=$(CDPATH= cd -- "${WORK_FOLDER}" && pwd) || exit 1

echo --工作的目录：${WORK_FOLDER}
# 获取编译顺序
if [ ! -e "${WORK_FOLDER%/}/compile_order.txt" ]; then
  ls -1td "${WORK_FOLDER%/}/"*/ 2>/dev/null | while IFS= read -r directory; do
      directory=${directory%/}
      printf '%s\n' "${directory##*/}"
    done >"${WORK_FOLDER%/}/compile_order.txt"
fi
# 遍历当前目录
LC_ALL=C sed 's/\r//g' "${WORK_FOLDER%/}/compile_order.txt" | while IFS= read -r folder || [ -n "$folder" ]; do
  [ -z "${folder}" ] && continue
  cd "${WORK_FOLDER%/}/${folder}" || continue
  echo --清理目录：$(pwd)
  rm -f *log*.txt
  rm -rf release
  # 清理失效的符号链接
  find "${WORK_FOLDER%/}/${folder}" -type l | while IFS= read -r tmp; do
    if [ ! -e "${tmp}" ]; then
      rm -f "${tmp}" >/dev/null
    fi
  done
done
cd "${WORK_FOLDER}"
