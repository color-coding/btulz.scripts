# btulz.scripts
关于ibas的一些脚本

## ibas | for ibas framework

### 开发阶段

| 脚本 | 说明 | 参数 |
|------|------|------|
| gits.sh/bat | 批量执行git命令 | 参数：git命令；clone时补全compile_order.txt |
| compiles.sh/bat | 后端编译打包 | 参数：模块名称，不提供则按compile_order.txt |
| builds.sh/bat | 前端编译压缩JS | 参数：模块名称，不提供则按compile_order.txt |
| clears.sh/bat | 清理编译产物和日志 | 参数1：工作目录，默认当前目录 |
| copy_wars.sh/bat | 收集war包到ibas_packages | 参数1：工作目录，默认当前目录 |

### 部署阶段

| 脚本 | 说明 | 参数 |
|------|------|------|
| download_apps.sh/bat | 按列表下载应用到ibas_packages | 参数1：应用版本，默认时间戳 |
| deploy_apps.sh/bat | 部署war包到webapps | 参数1：IBAS主目录(默认./ibas)；参数2：包目录；参数3：部署目录；参数4：共享库目录 |
| initialize_apps.sh/bat | 初始化数据库结构和数据 | 参数1：配置文件路径，默认WEB-INF/app.xml |
| update_db.sh | 更新数据库结构 | 参数1：结构文件(jar/xml/目录)；参数2：配置文件，默认./ibas/conf/app.xml |
| update_routing.sh/bat | 生成服务路由配置 | 参数1：配置文件；参数2：输出文件；参数3：数据服务地址模板；参数4：视图服务地址模板；参数5：共享库目录 |
| deploy_wars.sh | 发布war包到Maven仓库 | 参数1：版本号；参数2：仓库地址；参数3：仓库标识 |
| startcat.sh/bat | 选择配置并启动Tomcat | 无参数 |

### Docker部署

| 脚本 | 说明 | 参数 |
|------|------|------|
| deploy_docker.sh/bat | Docker容器化部署 | 参数1：网站名称 |

> **注意**：deploy_apps、initialize_apps、startcat 需在Tomcat目录运行；initialize_apps、update_db、update_routing 需提前放置btulz.transforms工具到ibas_tools目录。

### 鸣谢 | thanks
[牛加人等于朱](http://baike.baidu.com/view/1769.htm "NiurenZhu")<br>
[Color-Coding](http://colorcoding.org/ "咔啦工作室")<br>
