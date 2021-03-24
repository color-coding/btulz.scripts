#!/bin/sh
echo '*****************************************************************'
echo '              deploy_packages.sh                                 '
echo '                    by niuren.zhu                                '
echo '                          2017.09.07                             '
echo '  说明：                                                         '
echo '    1. 发布jar包到maven仓库。                                    '
echo '    2. 在setting.xml的<servers>节点下添加                        '
echo '          <server>                                               '
echo '              <id>ibas-maven</id>                                '
echo '              <username>用户名</username>                        '
echo '              <password>密码</password>                          '
echo '          </server>                                              '
echo '*****************************************************************'

# *******设置参数变量*******
WORK_FOLDER=$(pwd)
# 仓库根地址
ROOT_URL=http://maven.colorcoding.org/repository/
# 仓库名称
REPOSITORY=$1
# 设置默认仓库名称
if [ "${REPOSITORY}" = "" ]; then REPOSITORY=maven-releases; fi
# 使用的仓库信息
REPOSITORY_ID=ibas-maven
REPOSITORY_URL=${ROOT_URL}${REPOSITORY}

echo --检查maven运行环境
mvn -v >/dev/null
if [ $? -ne 0 ]; then
  echo 请检查MAVEN是否正常
  exit 1
fi

echo --发布地址：${REPOSITORY_URL}
# 发布工具包集合
if [ -e ${WORK_FOLDER}/release/btulz.scripts.tar ]; then
  mvn deploy:deploy-file \
    -DgroupId=org.colorcoding.tools \
    -DartifactId=btulz.scripts \
    -Durl=${REPOSITORY_URL} \
    -DrepositoryId=${REPOSITORY_ID} \
    -Dfile=${WORK_FOLDER}/release/btulz.scripts.tar \
    -Dpackaging=tar \
    -Dversion=latest
fi
echo --操作完成
