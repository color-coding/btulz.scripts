#!/bin/sh
echo '****************************************************************************'
echo '                 startcat.sh                                                '
echo '                      by niuren.zhu                                         '
echo '                           2020.02.27                                       '
echo '  说明：                                                                     '
echo '    1. 启动Tomcat。                                                          '
echo '    2. 参数1，配置文件分组。（app.[demo].xml，app.[dev].xml）                   '
echo '    3. 参数2，数据库配置。(app.demo.[mysql].xml，app.dev.[mysql].xml)          '
echo '****************************************************************************'
# 设置参数变量
# 启动目录
WORK_FOLDER=$(pwd)
CONFIG_FOLDER=${WORK_FOLDER}/ibas/conf
if [ ! -e ${CONFIG_FOLDER} ]; then
  echo --没有配置文件夹
  exit 0
fi
TOMCAT=${WORK_FOLDER}/bin/startup.sh
if [ ! -e ${TOMCAT} ]; then
  echo --没有TOMCAT启动脚本
  exit 0
fi
# 参数赋值
CONFIG_GROUP=$1
CONFIG_DB=$2
if [ "${CONFIG_GROUP}" = "" ]; then
  echo --启动Tomcat
  "${TOMCAT}"
  exit 0
fi
# 配置文件名
FILE_APP_XML=app
FILE_CONFIG_JSON=config
FILE_SERVICE_ROUTING_XML=service_routing
# 补全文件名
if [ ! "${CONFIG_GROUP}" = "" ]; then
  FILE_APP_XML=${FILE_APP_XML}.${CONFIG_GROUP}
  FILE_CONFIG_JSON=${FILE_CONFIG_JSON}.${CONFIG_GROUP}
  FILE_SERVICE_ROUTING_XML=${FILE_SERVICE_ROUTING_XML}.${CONFIG_GROUP}
fi
if [ ! "${CONFIG_DB}" = "" ]; then
  FILE_APP_XML=${FILE_APP_XML}.${CONFIG_DB}
fi
FILE_APP_XML=${FILE_APP_XML}.xml
FILE_CONFIG_JSON=${FILE_CONFIG_JSON}.json
FILE_SERVICE_ROUTING_XML=${FILE_SERVICE_ROUTING_XML}.xml
# 应用配置文件
echo --前端配置：${FILE_CONFIG_JSON}
echo --后端配置：${FILE_APP_XML}
echo --路由配置：${FILE_SERVICE_ROUTING_XML}
APP_XML=app.xml
CONFIG_JSON=config.json
SERVICE_ROUTING_XML=service_routing.xml
# 备份上次配置
LAST_SIGN=~last
if [ -e "${CONFIG_FOLDER}/${APP_XML}" ]; then
  rm -f "${CONFIG_FOLDER}/${LAST_SIGN}.${APP_XML}"
  cp "${CONFIG_FOLDER}/${APP_XML}" "${CONFIG_FOLDER}/${LAST_SIGN}.${APP_XML}"
fi
if [ -e "${CONFIG_FOLDER}/${CONFIG_JSON}" ]; then
  rm -f "${CONFIG_FOLDER}/${LAST_SIGN}.${CONFIG_JSON}"
  cp "${CONFIG_FOLDER}/${CONFIG_JSON}" "${CONFIG_FOLDER}/${LAST_SIGN}.${CONFIG_JSON}"
fi
if [ -e "${CONFIG_FOLDER}/${SERVICE_ROUTING_XML}" ]; then
  rm -f "${CONFIG_FOLDER}/${LAST_SIGN}.${SERVICE_ROUTING_XML}"
  cp "${CONFIG_FOLDER}/${SERVICE_ROUTING_XML}" "${CONFIG_FOLDER}/${LAST_SIGN}.${SERVICE_ROUTING_XML}"
fi
# 覆盖当前配置
if [ -e "${CONFIG_FOLDER}/${FILE_APP_XML}" ]; then
  rm -f "${CONFIG_FOLDER}/${APP_XML}"
  cp "${CONFIG_FOLDER}/${FILE_APP_XML}" "${CONFIG_FOLDER}/${APP_XML}"
fi
if [ -e "${CONFIG_FOLDER}/${FILE_CONFIG_JSON}" ]; then
  rm -f "${CONFIG_FOLDER}/${CONFIG_JSON}"
  cp "${CONFIG_FOLDER}/${FILE_CONFIG_JSON}" "${CONFIG_FOLDER}/${CONFIG_JSON}"
fi
if [ -e "${CONFIG_FOLDER}/${FILE_SERVICE_ROUTING_XML}" ]; then
  rm -f "${CONFIG_FOLDER}/${SERVICE_ROUTING_XML}"
  cp "${CONFIG_FOLDER}/${FILE_SERVICE_ROUTING_XML}" "${CONFIG_FOLDER}/${SERVICE_ROUTING_XML}"
fi
echo --启动Tomcat
"${TOMCAT}"
