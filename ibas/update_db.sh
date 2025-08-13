#!/bin/sh
echo '****************************************************************************'
echo '     update_db.sh                                                           '
echo '            by niuren.zhu                                                   '
echo '               2022.10.27                                                   '
echo '  说明：                                                                     '
echo '    1. 更新数据库结构。                                                        '
echo '    2. 参数1，结构文件地，jar, xml或目录。                                       '
echo '    3. 参数2，配置文件地址，默认：./ibas/conf/app.xml。                          '
echo '    4. 提前下载btulz.transforms并放置.\ibas_tools\目录。                        '
echo '    5. 提前配置app.xml的数据库信息。                                            '
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
# 设置java路径
if [ -e "${WORK_FOLDER}/jdk/bin" ]; then
  JAVA_HOME=${WORK_FOLDER}/jdk
  PATH=${JAVA_HOME}/bin:${PATH}
fi
# 设置数据文件
DS_FILE=$1
if [ "${DS_FILE}" = "" ]; then
  echo not found ds files.
  exit 1
fi
# 设置配置文件
CONF_APP=$2
if [ "${CONF_APP}" = "" ]; then CONF_APP=${WORK_FOLDER}/ibas/conf/app.xml; fi
if [ ! -e "${CONF_APP}" ]; then
  echo not found app.xml.
  exit 1
fi

# 开始时间
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
# 显示参数信息
echo ----------------------------------------------------
echo 开始时间：${START_TIME}
echo 工具地址：${TOOLS_TRANSFORM}
echo 数据文件：${DS_FILE}
echo 配置文件：${CONF_APP}
echo ----------------------------------------------------

if [ -d "${DS_FILE}" ]; then
  echo 遍历目录：${DS_FILE}
  for file in $(ls -tr "${DS_FILE}" | grep 'ds_*.*xml'); do
    if [ -f "${DS_FILE}/${file}" ]; then
      echo 开始解析：${DS_FILE}/${file}
      java -jar ${TOOLS_TRANSFORM} ds "-data=${DS_FILE}/${file}" "-config=${CONF_APP}"
    fi
  done
  for file in $(ls -tr "${DS_FILE}" | grep 'ibas.*.*.jar'); do
    if [ -f "${DS_FILE}/${file}" ]; then
      echo 开始解析：${DS_FILE}/${file}
      java -jar ${TOOLS_TRANSFORM} ds "-data=${DS_FILE}/${file}" "-config=${CONF_APP}"
    fi
  done
fi
if [ -f "${DS_FILE}" ]; then
  echo 开始解析：${DS_FILE}
  java -jar ${TOOLS_TRANSFORM} ds "-data=${DS_FILE}" "-config=${CONF_APP}"
fi

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
