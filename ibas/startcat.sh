#!/bin/bash
echo '****************************************************************************'
echo '                 startcat.sh                                                '
echo '                      by niuren.zhu                                         '
echo '                           2020.08.26                                       '
echo '  说明：                                                                     '
echo '    1. 列示并选择配置文件。                                                    '
echo '    2. 选择启动模式（后台/前台）。                                              '
echo '    3. 启动Tomcat。                                                          '
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
CATALINA=${WORK_FOLDER}/bin/catalina.sh
if [ ! -e ${TOMCAT} ]; then
  echo --没有TOMCAT启动脚本
  exit 0
fi

# 启动前清理运行目录：日志保留最近 3 天，其余临时目录全部清空。
echo --清理Tomcat运行目录
if [ -f "${WORK_FOLDER}/catalina.out" ]; then
  : > "${WORK_FOLDER}/catalina.out"
fi
cleanLogFolder() {
  if [ -d "$1" ]; then
    # find 按整天取整，因此 +2 表示已满 3 天；GNU find 等环境回退使用修改时间。
    if find "$1" -type f -Btime +2 -print -quit >/dev/null 2>&1; then
      find "$1" -type f -Btime +2 -delete
    else
      find "$1" -type f -mtime +2 -delete
    fi
  fi
}
cleanFolder() {
  if [ -d "$1" ]; then
    find "$1" -mindepth 1 -depth -exec rm -rf {} +
  fi
}
cleanLogFolder "${WORK_FOLDER}/logs"
cleanLogFolder "${WORK_FOLDER}/ibas/logs"
cleanFolder "${WORK_FOLDER}/temp"
cleanFolder "${WORK_FOLDER}/ibas_packages/backup"
cleanFolder "${WORK_FOLDER}/history"

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
    printf "  %s) %s\n" "$(expr $INDEX + 1)" "$(basename "${FILES[$INDEX]}")"
  done
  printf "  %s) %s\n" "0" "~last.${FILE_TYPE}"
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

echo --启动模式选择
echo "  1) 后台启动（日志输出到文件）"
echo "  2) 前台启动（默认，当前终端输出日志）"
read -p "--请输入启动模式[2]: " START_MODE
if [ "${START_MODE}" = "1" ]; then
  echo --后台启动Tomcat
  "${TOMCAT}"
else
  if [ -e "${CATALINA}" ]; then
    echo --前台启动Tomcat，日志输出到当前终端，按Ctrl+C可停止
    "${CATALINA}" run
  else
    echo --未找到catalina脚本[${CATALINA}]，使用后台启动
    "${TOMCAT}"
  fi
fi
