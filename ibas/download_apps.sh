#!/bin/sh
# Preserve POSIX shell semantics when invoked explicitly through zsh.
[ -z "${ZSH_VERSION:-}" ] || exec sh "$0" "$@"
echo '****************************************************************************'
echo '                 download_apps.sh                                          '
echo '                       by niuren.zhu                                       '
echo '                          2025.03.11                                       '
echo '  说明：                                                                     '
echo '    1. 应用列表[packages.txt]，其中版本号可为变量。                              '
echo '    2. 根据列表，下载应用到./ibas_packages。                                    '
echo '    3. 参数1，应用版本。                                                       '
echo '****************************************************************************'
# 设置参数变量
STARTUP_FOLDER=$(pwd)
WORK_FOLDER=${STARTUP_FOLDER}
PACKAGES_FOLDER=${STARTUP_FOLDER%/}/ibas_packages
if [ ! -e "${PACKAGES_FOLDER}" ]; then
  mkdir "${PACKAGES_FOLDER}"
fi
PACKAGES_LIST=${WORK_FOLDER%/}/packages.txt
APP_VERSION=$1
if [ "${APP_VERSION}" = "" ]; then
  printf '%s' "--请输入版本号: "
  IFS= read -r APP_VERSION
fi
if [ "${APP_VERSION}" = "" ]; then
  APP_VERSION=$(date '+%Y%m%d%H%M')
fi

echo --工作目录：${WORK_FOLDER}
echo --应用目录：${PACKAGES_FOLDER}
echo --应用列表：${PACKAGES_LIST}
echo --应用版本：${APP_VERSION}

if [ ! -e "${PACKAGES_LIST}" ]; then
  echo 不存在程序列表文件[packages.txt]
  exit 0
fi
# 下载列表文件
cd "${PACKAGES_FOLDER}"
LC_ALL=C sed 's/\r//g' "${PACKAGES_LIST}" | while IFS= read -r package_url || [ -n "$package_url" ]; do
  [ -z "${package_url}" ] && continue
  echo "${package_url}" | grep -q "^http"
  if [ $? -eq 0 ]; then
    # 安全替换版本变量，避免eval命令注入；用|作为分隔符并转义特殊字符，避免APP_VERSION中含/、&、\时sed报错
    APP_VERSION_ESC=$(printf '%s' "${APP_VERSION}" | sed -e 's/[\\|&]/\\&/g')
    package_url=$(echo "${package_url}" | sed "s|\${APP_VERSION}|${APP_VERSION_ESC}|g")
    echo ---正在下载：${package_url}
    curl --retry 3 -Lf -O "${package_url}" && echo "${package_url}" | awk -F "/" '{print $NF}' >>ibas.deploy.order.txt; \
  fi
done
cd "${WORK_FOLDER}"
if [ -e "${PACKAGES_FOLDER%/}/ibas.deploy.order.txt" ]; then
  echo --应用清单：
  cat "${PACKAGES_FOLDER%/}/ibas.deploy.order.txt"
fi
echo 操作完成
