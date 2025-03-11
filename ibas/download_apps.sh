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

echo --工作的目录：${WORK_FOLDER}
echo --程序的目录：${PACKAGES_FOLDER}
echo --应用的列表：${PACKAGES_LIST}
echo --应用的版本：${APP_VERSION}

if [ ! -e ${PACKAGES_LIST} ]; then
  echo 不存在程序列表文件[packages.txt]
  exit 0
fi
# 下载列表文件
while read package_url; do
  if [[ ${package_url} = "http"* ]]; then
    package_url=$(eval "echo ${package_url}")
    echo ---正在下载：${package_url}
    cd "${PACKAGES_FOLDER}" && curl --retry 3 -L -O "${package_url}"
  fi
done <"${PACKAGES_LIST}" | sed 's/\r//g'
cd "${WORK_FOLDER}"
echo --程序清单：
ls "${PACKAGES_FOLDER}"/*.war
echo 操作完成
