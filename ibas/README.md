# btulz.scripts
关于ibas的一些脚本

## ibas | for ibas framework
* gits.sh/bat 批量操作脚本
~~~
./gits.sh fetch
参数1：git命令；clones为批量克隆
~~~

* builds.sh/bat 前端编译并压缩脚本
~~~
./builds.sh [ibas.initialfantasy]
参数1：模块名称，可选
~~~

* compiles.sh/bat 后端编译并打包脚本
~~~
./compiles.sh [ibas.initialfantasy]
参数1：模块名称，可选
~~~

* deploy_apps.sh/bat 部署war包脚本
~~~
./deploy_apps.sh
注意：需要要在tomcat目录运行
~~~

* initialize_apps.sh/bat 应用初始化脚本（创建数据库及初始数据）
~~~
./initialize_apps.sh
注意：需要要在tomcat目录运行，配合deploy_apps脚本
~~~

* startcat.sh/bat 选择配置文件的tomcat启动脚本
~~~
./startcat.sh
注意：需要要tomcat目录运行
~~~

* deploy_docker.sh/bat 使用docker部署多个应用脚本
~~~
./deploy_docker.sh
参数1：应用名称，可选
~~~

* clears.sh/bat 清理编译打包文件脚本
~~~
./clears.sh
~~~

* copy_wars.sh/bat 获取打包文件脚本
~~~
./copy_wars.sh ~/Codes/
参数1：代码目录
~~~

* deploy_wars.sh 发布应用包脚本
~~~
./deploy_wars.sh 20210901
参数1：版本号
~~~

### 鸣谢 | thanks
[牛加人等于朱](http://baike.baidu.com/view/1769.htm "NiurenZhu")<br>
[Color-Coding](http://colorcoding.org/ "咔啦工作室")<br>
