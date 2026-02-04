#!/bin/sh
echo '****************************************************************************'
echo '                 download_apps.bat                                         '
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
PACKAGES_FOLDER=${STARTUP_FOLDER}/ibas_packages
if [ ! -e ${PACKAGES_FOLDER} ]; then
  mkdir ${PACKAGES_FOLDER}
fi
PACKAGES_LIST=${WORK_FOLDER}/packages.txt
APP_VERSION=$1
if [ "${APP_VERSION}" = "" ]; then
  read -p "--请输入版本号: " APP_VERSION
fi
if [ "${APP_VERSION}" = "" ]; then
  APP_VERSION=$(date '+%Y%m%d%H%M')
fi

echo --工作目录：${WORK_FOLDER}
echo --应用目录：${PACKAGES_FOLDER}
echo --应用列表：${PACKAGES_LIST}
echo --应用版本：${APP_VERSION}

if [ ! -e ${PACKAGES_LIST} ]; then
  echo 不存在程序列表文件[packages.txt]
  exit 0
fi
# 下载列表文件
cd "${PACKAGES_FOLDER}"
while read package_url; do
  if [ ${package_url:0:4} = "http" ]; then
    package_url=$(eval "echo ${package_url}")
    echo ---正在下载：${package_url}
    curl --retry 3 -L -O "${package_url}" && echo ${package_url} | awk -F "/" '{print $NF}' >>ibas.deploy.order.txt; \
  fi
done <"${PACKAGES_LIST}" | sed 's/\r//g'
cd "${WORK_FOLDER}"
if [ -e "${PACKAGES_FOLDER}/ibas.deploy.order.txt" ]; then
  echo --应用清单：
  cat "${PACKAGES_FOLDER}/ibas.deploy.order.txt"
fi
echo 操作完成
