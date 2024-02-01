#!/bin/sh
echo '****************************************************************************'
echo '              deploy_wars.sh                                                '
echo '                      by niuren.zhu                                         '
echo '                           2017.09.19                                       '
echo '  说明：                                                                     '
echo '    1. 遍历工作目录，部署war包到MAVEN服务。                                      '
echo '    2. 参数1，发布VERSION的版本。                                              '
echo '    3. 参数2，发布MAVEN的地址。                                                '
echo '    4. 参数3，发布MAVEN标识（涉及用户信息）。                                    '
echo '    5. 在MAVEN的setting.xml的<servers>节点下添加                               '
echo '          <server>                                                          '
echo '              <id>ibas-maven</id>                                           '
echo '              <username>用户名</username>                                   '
echo '              <password>密码</password>                                     '
echo '          </server>                                                         '
echo '****************************************************************************'

# 工作目录
WORK_FOLDER=$(pwd)
# 版本信息
VERSION=$1
# 仓库地址
REPOSITORY_URL=$2
if [ "${REPOSITORY_URL}" = "" ]; then
  REPOSITORY_URL=http://maven.colorcoding.org/repository/maven-releases
fi
# 仓库ID（涉及上传用户）
REPOSITORY_ID=$3
if [ "${REPOSITORY_ID}" = "" ]; then
  REPOSITORY_ID=ibas-maven
fi
GROUP_ID=org.colorcoding.apps

echo --检查maven运行环境
mvn -v >/dev/null
if [ $? -ne 0 ]; then
  echo 请检查MAVEN是否正常
  exit 1
fi
# 部署包，使用POM
# 参数1：war文件路径
# 参数2：pom文件路径
deployWarPom() {
  WAR_FILE=$1
  POM_FILE=$2
  ARTIFACT_ID=${WAR_FILE##*/}
  ARTIFACT_ID=${ARTIFACT_ID%-*}
  # 拼接命令
  DEPLOY_COMMAND="mvn -q deploy:deploy-file \
    -Dfile=${WAR_FILE} \
    -DpomFile=${POM_FILE} \
    -Durl=${REPOSITORY_URL} \
    -DrepositoryId=${REPOSITORY_ID} \
    -Dpackaging=war"
  # 执行命令
  echo ----开始部署：${ARTIFACT_ID}, ${POM_FILE}
  eval ${DEPLOY_COMMAND}
  # 记录失败命令
  if [ $? -ne 0 ]; then
    if [ ! -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
      echo '#!/bin/sh' >${WORK_FOLDER}/~redeploy_fails_wars.sh
    fi
    echo 'echo --开始部署：'${ARTIFACT_ID} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
    echo ${DEPLOY_COMMAND} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
  fi
}
# 部署包，使用标记
# 参数1：war文件路径
# 参数2：版本
deployWar() {
  WAR_FILE=$1
  VERSION=$2
  ARTIFACT_ID=${WAR_FILE##*/}
  ARTIFACT_ID=${ARTIFACT_ID%-*}
  # 拼接命令
  DEPLOY_COMMAND="mvn -q deploy:deploy-file \
    -DgroupId=${GROUP_ID} \
    -DartifactId=${ARTIFACT_ID} \
    -Dversion=${VERSION} \
    -Dfile=${WAR_FILE} \
    -Durl=${REPOSITORY_URL} \
    -DrepositoryId=${REPOSITORY_ID} \
    -Dpackaging=war"
  # 执行命令
  echo ----开始部署：${ARTIFACT_ID}, ${VERSION}
  eval ${DEPLOY_COMMAND}
  # 记录失败命令
  if [ $? -ne 0 ]; then
    if [ ! -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
      echo '#!/bin/sh' >${WORK_FOLDER}/~redeploy_fails_wars.sh
    fi
    echo 'echo --开始部署：'${ARTIFACT_ID} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
    echo ${DEPLOY_COMMAND} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
  fi
}
START_TIME=$(date +'%Y-%m-%d %H:%M:%S')
echo --开始时间：${START_TIME}
echo --工作目录：${WORK_FOLDER}
echo --发布地址：${REPOSITORY_URL}
# 重置上传失败脚本
if [ -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
  rm -rf ${WORK_FOLDER}/~redeploy_fails_wars.sh
fi
while read LINE; do
  if [ -e ${WORK_FOLDER}/${LINE}/release ]; then
    echo ---开始分析：${LINE}
    for FILE in $(find ${WORK_FOLDER}/${LINE}/release -name "ibas.*.service-*.war"); do
      if [ "${VERSION}" = "" ]; then
        # 没提供版本号，使用POM文件
        POM=${FILE##*/}
        POM=${POM%-*}
        POM=${WORK_FOLDER}/${LINE}/${POM}/pom.xml
        if [ -f ${POM} ]; then
          deployWarPom ${FILE} ${POM}
        else
          echo ----没有POM文件：${FILE}
        fi
      else
        # 提供版本号
        deployWar ${FILE} ${VERSION}
      fi
    done
  fi
done <${WORK_FOLDER}/compile_order.txt | sed 's/\r//g'
cd ${WORK_FOLDER}/
if [ -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
  if [ ! -x ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
    chmod +x ${WORK_FOLDER}/~redeploy_fails_wars.sh
  fi
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
echo --操作完成：${END_TIME}，共$((END_SECONDS - START_SECONDS))秒
