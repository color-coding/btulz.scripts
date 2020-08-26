#!/bin/bash
echo '****************************************************************************'
echo '                 startcat.sh                                                '
echo '                      by niuren.zhu                                         '
echo '                           2020.08.26                                       '
echo '  说明：                                                                     '
echo '    1. 列示并选择配置文件。                                                    '
echo '    2. 启动Tomcat。                                                          '
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

# 函数：列示并选择文件
chooseFile() {
  FILE_FOLDER=$1
  FILE_TYPE=$2
  FILES=()
  INDEX=0
  echo --文件类型：${FILE_TYPE}
  echo --列示目录：${FILE_FOLDER}
  for FILE in $(ls ${FILE_FOLDER}/${FILE_TYPE//./*}); do
    if [ "${FILE}" != "${FILE_FOLDER}/${FILE_TYPE}" ]; then
      FILES[$INDEX]=$FILE
      INDEX=$(expr $INDEX + 1)
    fi
  done
  echo --检索到[${#FILES[@]}]个文件：
  for INDEX in "${!FILES[@]}"; do
    printf "  %s) %s\n" "$(expr $INDEX + 1)" "${FILES[$INDEX]}"
  done
  printf "  %s) %s\n" "0" "${FILE_FOLDER}/~last.${FILE_TYPE}"
  read -p "--请输入选择的文件序号: " INDEX
  if [ "${INDEX}" = "" ]; then
    CHS_FILE=
  elif [ "${INDEX}" = "0" ]; then
    CHS_FILE=${FILE_FOLDER}/~last.${FILE_TYPE}
  else
    CHS_FILE=${FILES[$(expr $INDEX - 1)]}
  fi
  if [ -e "${CHS_FILE}" ]; then
    echo --应用文件：${CHS_FILE}
    cp -f "${FILE_FOLDER}/${FILE_TYPE}" "${FILE_FOLDER}/~last.${FILE_TYPE}"
    cp -f "${CHS_FILE}" "${FILE_FOLDER}/${FILE_TYPE}"
  else
    echo --未选择\&跳过
  fi
}

# 选择文件
echo --后端配置文件选择
chooseFile "${CONFIG_FOLDER}" "app.xml"
echo

echo --服务路由文件选择
chooseFile "${CONFIG_FOLDER}" "service_routing.xml"
echo

echo --前端配置文件选择
chooseFile "${CONFIG_FOLDER}" "config.json"
echo

echo --启动Tomcat
"${TOMCAT}"
