#!/bin/sh
echo '****************************************************************************'
echo '              deploy_wars.sh                                                '
echo '                      by niuren.zhu                                         '
echo '                           2017.09.19                                       '
echo '  说明：                                                                    '
echo '    1. 遍历工作目录，部署war包到MAVEN服务。                                 '
echo '    2. 参数1，发布VERSION的版本。                                           '
echo '    3. 参数2，发布MAVEN的地址。                                             '
echo '    4. 在MAVEN的setting.xml<servers>节点下添加                              '
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
if [ "${REPOSITORY_URL}" = "" ]; then REPOSITORY_URL=http://maven.colorcoding.org/repository/maven-releases; fi
# MAVEN参数信息
REPOSITORY_ID=ibas-maven
GROUP_ID=org.colorcoding.apps

echo --检查maven运行环境
mvn -v >/dev/null
if [ $? -ne 0 ]; then
  echo 请检查MAVEN是否正常
  exit 1
fi

echo --工作目录：${WORK_FOLDER}
echo --发布地址：${REPOSITORY_URL}
# 重置上传失败脚本
if [ -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
  rm -rf ${WORK_FOLDER}/~redeploy_fails_wars.sh
fi
while read line; do
  if [ -e ${WORK_FOLDER}/${line}/release ]; then
    echo ---开始部署：${line}
    if [ "${line}" = "ibas-typescript" ]; then
      # 前端壳包
      for PACKAGE in $(find ${WORK_FOLDER}/${line}/ -name "ibas.root*.war"); do
        # 获取包标识
        ARTIFACT_ID=${PACKAGE##*/}
        ARTIFACT_ID=${ARTIFACT_ID%-*}
        if [ "${VERSION}" = "" ]; then
          # 未提供版本号，则使用POM文件
          DEPLOY_COMMAND="mvn -q deploy:deploy-file \
            -Dfile=${PACKAGE} \
            -DpomFile=${WORK_FOLDER}/${line}/pom.xml \
            -Durl=${REPOSITORY_URL} \
            -DrepositoryId=${REPOSITORY_ID} \
            -Dpackaging=war"
        else
          # 提供版本号，独立上传
          DEPLOY_COMMAND="mvn -q deploy:deploy-file \
            -DgroupId=${GROUP_ID} \
            -DartifactId=${ARTIFACT_ID} \
            -Dversion=${VERSION} \
            -Dfile=${PACKAGE} \
            -Durl=${REPOSITORY_URL} \
            -DrepositoryId=${REPOSITORY_ID} \
            -Dpackaging=war"
        fi
        eval ${DEPLOY_COMMAND}
        if [ $? -ne 0 ]; then
          if [ ! -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
            echo '#!/bin/sh' >${WORK_FOLDER}/~redeploy_fails_wars.sh
          fi
          echo 'echo ---开始部署：'${line} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
          echo ${DEPLOY_COMMAND} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
        fi
      done
    else
      # 模块包
      for PACKAGE in $(find ${WORK_FOLDER}/${line}/ -name "${line}*.war"); do
        # 获取包标识
        ARTIFACT_ID=${PACKAGE##*/}
        ARTIFACT_ID=${ARTIFACT_ID%-*}
        if [ "${VERSION}" = "" ]; then
          # 未提供版本号，则使用POM文件
          DEPLOY_COMMAND="mvn -q deploy:deploy-file \
            -Dfile=${PACKAGE} \
            -DpomFile=${WORK_FOLDER}/${line}/${ARTIFACT_ID}/pom.xml \
            -Durl=${REPOSITORY_URL} \
            -DrepositoryId=${REPOSITORY_ID} \
            -Dpackaging=war"
        else
          # 提供版本号，独立上传
          DEPLOY_COMMAND="mvn -q deploy:deploy-file \
            -DgroupId=${GROUP_ID} \
            -DartifactId=${ARTIFACT_ID} \
            -Dversion=${VERSION} \
            -Dfile=${PACKAGE} \
            -Durl=${REPOSITORY_URL} \
            -DrepositoryId=${REPOSITORY_ID} \
            -Dpackaging=war"
        fi
        eval ${DEPLOY_COMMAND}
        if [ $? -ne 0 ]; then
          if [ ! -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
            echo '#!/bin/sh' >${WORK_FOLDER}/~redeploy_fails_wars.sh
          fi
          echo 'echo ---开始部署：'${line} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
          echo ${DEPLOY_COMMAND} >>${WORK_FOLDER}/~redeploy_fails_wars.sh
        fi
      done
    fi
  fi
done <${WORK_FOLDER}/compile_order.txt | sed 's/\r//g'
cd ${WORK_FOLDER}/
if [ -e ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
  if [ ! -x ${WORK_FOLDER}/~redeploy_fails_wars.sh ]; then
    chmod +x ${WORK_FOLDER}/~redeploy_fails_wars.sh
  fi
fi
echo --操作完成
