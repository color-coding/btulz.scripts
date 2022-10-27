#!/bin/sh
echo '****************************************************************************'
echo '     update_routing.sh                                                      '
echo '            by niuren.zhu                                                   '
echo '               2022.10.27                                                   '
echo '  说明：                                                                     '
echo '    1. 分析数据库更新[service_routing.xml]。                                   '
echo '    2. 参数1，配置文件地址，默认：./ibas/conf/app.xml。                          '
echo '    3. 参数2，输出文件地址，默认：./ibas/conf/service_routing.xml。              '
echo '    4. 参数3，数据服务地址模板，默认：${ModuleName}/services/rest/data/。         '
echo '    5. 参数4，视图服务地址模板，默认：.../${ModuleName}/。                        '
echo '    6. 参数5，共享库目录，默认./ibas_lib。                                       '
echo '    7. 提前下载btulz.transforms并放置.\ibas_tools\目录。                        '
echo '    8. 提前配置app.xml的数据库信息。                                            '
echo '****************************************************************************'
# 设置参数变量
WORK_FOLDER=$PWD
# 设置ibas_tools目录
TOOLS_FOLDER=${WORK_FOLDER}/ibas_tools
TOOLS_TRANSFORM=${TOOLS_FOLDER}/btulz.transforms.bobas-0.1.0.jar
if [ ! -e "${TOOLS_TRANSFORM}" ]; then
  echo not found btulz.transforms, in [${TOOLS_FOLDER}].
  exit 1
fi
# 设置配置文件
CONF_APP=$1
if [ "${CONF_APP}" = "" ]; then CONF_APP=${WORK_FOLDER}/ibas/conf/app.xml; fi
if [ ! -e "${CONF_APP}" ]; then
  echo not found app.xml.
  exit 1
fi
# 设置输出文件
CONF_ROUTING=$2
if [ "${CONF_ROUTING}" = "" ]; then CONF_ROUTING=${WORK_FOLDER}/ibas/conf/service_routing.xml; fi
# 设置数据服务地址
URL_DATA=$3
if [ "${URL_DATA}" = "" ]; then URL_DATA=".../\${ModuleName}/services/rest/data/"; fi
# 设置视图服务地址
URL_VIEW=$4
if [ "${URL_VIEW}" = "" ]; then URL_VIEW=".../\${ModuleName}/"; fi
# 设置LIB目录
IBAS_LIB=$5
if [ "${IBAS_LIB}" = "" ]; then IBAS_LIB=${WORK_FOLDER}/ibas_lib; fi

# 开始时间
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
# 显示参数信息
echo ----------------------------------------------------
echo 开始时间：${START_TIME}
echo 工具地址：${TOOLS_TRANSFORM}
echo 配置文件：${CONF_APP}
echo 输出文件：${CONF_ROUTING}
echo 数据服务地址：${URL_DATA}
echo 视图服务地址：${URL_VIEW}
echo 共享LIB目录：${IBAS_LIB}
echo ----------------------------------------------------
# 链接数据库类
for file in $(ls "${IBAS_LIB}" | grep 'bobas.*.db.*.jar'); do
  if [ ! -e "${TOOLS_FOLDER}/${file}" ]; then
    ln -s "${IBAS_LIB}/${file}" "${TOOLS_FOLDER}/${file}"
  fi
done
java -jar "${TOOLS_TRANSFORM}" routing "-config=${CONF_APP}" "-out=${CONF_ROUTING}" "-dataUrl=${URL_DATA}" "-viewUrl=${URL_VIEW}"

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
echo 完成时间：${END_TIME}，共$((END_SECONDS - START_SECONDS))秒
