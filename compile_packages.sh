#!/bin/sh
echo '****************************************************************************'
echo '             compile_packages.sh                                            '
echo '                      by niuren.zhu                                         '
echo '                           2016.06.17                                       '
echo '  说明：                                                                    '
echo '    1. 安装apache-maven，sudo apt-get install maven                         '
echo '    2. 解压apache-maven，并设置系统变量MAVEN_HOME为解压的程序目录。         '
echo '    3. 添加PATH变量到MAVEN_HOME\bin，并检查JAVE_HOME配置是否正确。          '
echo '    4. 运行提示符运行mvn -v 检查安装是否成功。                              '
echo '    5. 此脚本会遍历当前目录的子目录，查找pom.xml并编译jar包到release目录。  '
echo '    6. 可在compile_order.txt文件中调整编译顺序。                            '
echo '****************************************************************************'
# 设置参数变量
WORK_FOLDER=`pwd`
echo --当前工作的目录是[${WORK_FOLDER}]

echo --清除项目缓存
if [ -e ${WORK_FOLDER}/release/ ]
then
  rm -rf ${WORK_FOLDER}/release/
fi
mkdir -p ${WORK_FOLDER}/release/

echo --压缩文件为tar包
tar -cvf btulz.scripts.tar ibas/*.sh ibas/*.bat
cp -f btulz.scripts.tar ${WORK_FOLDER}/release/
rm -rf btulz.scripts.tar

echo --编译完成
