#!/bin/sh
echo '****************************************************************************'
echo '                 initialize_apps.sh                                         '
echo '                      by niuren.zhu                                         '
echo '                      2018.01.27                                           '
echo '  说明：                                                                     '
echo '    1. 分析jar包创建数据结构和初始化数据，需要在Tomcat目录。                      '
echo '    2. 参数1，配置文件（app.xml）路径，默认WEB-INF\app.xml。                   '
echo '    3. 提前下载btulz.transforms并放置.\ibas_tools\目录。                       '
echo '    4. 注意维护ibas.release的顺序说明。                                        '
echo '****************************************************************************'
# 设置参数变量
WORK_FOLDER=$PWD
# 设置配置文件
if [ "$1" != "" ]; then
  if [ ! -e "$1" ]; then
    echo not found config file, $1.
    exit 1
  fi
  IBAS_APP=$1
fi
# 设置ibas_tools目录
TOOLS_FOLDER=${WORK_FOLDER}/ibas_tools
TOOLS_TRANSFORM=${TOOLS_FOLDER}/$(ls -r ${TOOLS_FOLDER} | grep 'btulz.transforms.bobas-' | grep -v 'source' | head -n1)
if [ ! -e "${TOOLS_TRANSFORM}" ]; then
  echo not found btulz.transforms, in [${TOOLS_FOLDER}].
  exit 1
fi
# 设置webapps目录
IBAS_DEPLOY=${WORK_FOLDER}/webapps
if [ ! -e "${IBAS_DEPLOY}" ]; then
  echo not found webapps.
  exit 1
fi
# 设置lib目录
IBAS_LIB=${WORK_FOLDER}/ibas_lib

# 开始时间
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
# 显示参数信息
echo ----------------------------------------------------
echo 开始时间：${START_TIME}
echo 工具地址：${TOOLS_TRANSFORM}
echo 部署目录：${IBAS_DEPLOY}
echo 共享目录：${IBAS_LIB}
if [ -e "${IBAS_APP}" ]; then
  echo 配置文件：${IBAS_APP}
fi
echo ----------------------------------------------------

echo 开始分析${IBAS_DEPLOY}目录下数据
db_jar=bobas\.businessobjectscommon\.db\.
# 检查是否存在模块说明文件，此文件描述模块初始化顺序。
if [ ! -e "${IBAS_DEPLOY}/ibas.release.txt" ]; then
  ls -ltr "${IBAS_DEPLOY}" | awk '/^d/{print $NF}' >"${IBAS_DEPLOY}/ibas.release.txt"
fi
while read folder; do
  echo --${folder}
  # 设置配置文件，优先使用传入参数
  FILE_APP=${IBAS_APP}
  if [ ! -e "${FILE_APP}" ]; then
    FILE_APP=${IBAS_DEPLOY}/${folder}/WEB-INF/app.xml
  fi
  if [ -e "${FILE_APP}" ]; then
    # 使用模块目录jar包
    if [ -e "${IBAS_DEPLOY}/${folder}/WEB-INF/lib" ]; then
      for file in $(ls "${IBAS_DEPLOY}/${folder}/WEB-INF/lib" | grep ${db_jar}); do
        echo ----${file}
        FILE_DATA=${IBAS_DEPLOY}/${folder}/WEB-INF/lib/${file}
        echo ----开始创建数据结构
        java -jar ${TOOLS_TRANSFORM} ds "-data=${FILE_DATA}" "-config=${FILE_APP}"
      done
      FILE_CLASSES=
      for file in $(ls "${IBAS_DEPLOY}/${folder}/WEB-INF/lib" | grep \..jar); do
        FILE_CLASSES=${FILE_CLASSES}${IBAS_DEPLOY}/${folder}/WEB-INF/lib/${file}\;
      done
      for file in $(ls "${IBAS_DEPLOY}/${folder}/WEB-INF/lib" | grep ibas\.${folder}\.); do
        echo ----${file}
        FILE_DATA=${IBAS_DEPLOY}/${folder}/WEB-INF/lib/${file}
        echo ----开始创建数据结构
        java -jar ${TOOLS_TRANSFORM} ds "-data=${FILE_DATA}" "-config=${FILE_APP}"
        echo ----开始初始化数据
        java -jar ${TOOLS_TRANSFORM} init "-data=${FILE_DATA}" "-config=${FILE_APP}" "-classes=${FILE_CLASSES}"
      done
    fi
    # 使用共享目录jar包
    if [ -e "${IBAS_LIB}" ]; then
      for file in $(ls "${IBAS_LIB}" | grep ${db_jar}); do
        echo ----${file}
        FILE_DATA=${IBAS_LIB}/${file}
        echo ----开始创建数据结构
        java -jar ${TOOLS_TRANSFORM} ds "-data=${FILE_DATA}" "-config=${FILE_APP}"
      done
      db_jar=__DONE__
      FILE_CLASSES=
      for file in $(ls "${IBAS_LIB}" | grep \..jar); do
        FILE_CLASSES=${FILE_CLASSES}${IBAS_LIB}/${file}\;
      done
      for file in $(ls "${IBAS_LIB}" | grep ibas\.${folder}\.); do
        echo ----${file}
        FILE_DATA=${IBAS_LIB}/${file}
        echo ----开始创建数据结构
        java -jar ${TOOLS_TRANSFORM} ds "-data=${FILE_DATA}" "-config=${FILE_APP}"
        echo ----开始初始化数据
        java -jar ${TOOLS_TRANSFORM} init "-data=${FILE_DATA}" "-config=${FILE_APP}" "-classes=${FILE_CLASSES}"
      done
    fi
  fi
  echo --
done <"${IBAS_DEPLOY}/ibas.release.txt" | sed 's/\r//g' | sed 's/\n//g'
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
