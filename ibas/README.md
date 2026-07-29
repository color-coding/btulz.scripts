<div align="center">

# IBAS Scripts

**Build · Deploy · Manage**

IBAS 框架配套的构建部署脚本集 —— 覆盖开发编译、应用部署、数据库初始化、Docker 容器化等全生命周期。

Shell/Batch scripts for IBAS framework — covering compilation, deployment, database initialization, and Docker orchestration.

[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)](#)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20cmd-green.svg)](https://www.gnu.org/software/bash/)
[![IBAS](https://img.shields.io/badge/IBAS-Framework-orange.svg)](https://github.com/color-coding/ibas-framework)

</div>

---

## 📖 目录 | Table of Contents

- [🏗️ 工作流概览 | Workflow](#️-工作流概览--workflow)
- [📦 脚本清单 | Scripts](#-脚本清单--scripts)
- [🚀 快速开始 | Quick Start](#-快速开始--quick-start)
- [🐳 Docker 部署 | Docker](#-docker-部署--docker)
- [📚 相关项目 | Related Projects](#-相关项目--related-projects)

---

## 🏗️ 工作流概览 | Workflow

```
开发阶段    gits ──► compiles ──► builds ──► clears ──► copy_wars
                                                              │
部署阶段    download_apps ◄──────────────────────────────────┘
              └──► deploy_apps ──► initialize_apps
                      │              └──► update_db
                      │              └──► update_routing
                      └──► startcat
发布阶段    deploy_wars ──► Maven Repository
容器化      deploy_docker
```

---

## 📦 脚本清单 | Scripts

### 开发阶段 | Development

| 脚本 | 说明 | 参数 |
|------|------|------|
| `gits.sh` / `gits.bat` | 批量执行 Git 命令 | 参数1：Git 命令；`clone` 时补全 `compile_order.txt` |
| `compiles.sh` / `compiles.bat` | 后端编译打包 | 参数：模块名称，不提供则按 `compile_order.txt` |
| `builds.sh` / `builds.bat` | 前端编译压缩 JS | 参数：模块名称，不提供则按 `compile_order.txt` |
| `clears.sh` / `clears.bat` | 清理编译产物和日志 | 参数1：工作目录，默认当前目录 |
| `copy_wars.sh` / `copy_wars.bat` | 收集 WAR 包到 `ibas_packages` | 参数1：工作目录，默认当前目录 |

### 部署阶段 | Deployment

| 脚本 | 说明 | 参数 |
|------|------|------|
| `download_apps.sh` / `download_apps.bat` | 按列表下载应用到 `ibas_packages` | 参数1：应用版本，默认时间戳 |
| `deploy_apps.sh` / `deploy_apps.bat` | 部署 WAR 包到 webapps | 参数1：IBAS 主目录；参数2：包目录；参数3：部署目录；参数4：共享库目录 |
| `initialize_apps.sh` / `initialize_apps.bat` | 初始化数据库结构和数据 | 参数1：配置文件路径，默认 `WEB-INF/app.xml` |
| `update_db.sh` | 更新数据库结构 | 参数1：结构文件（jar/xml/目录）；参数2：配置文件 |
| `update_routing.sh` / `update_routing.bat` | 生成服务路由配置 | 参数1：配置文件；参数2：输出文件；参数3：数据服务地址；参数4：视图服务地址；参数5：共享库目录 |
| `deploy_wars.sh` | 发布 WAR 包到 Maven 仓库 | 参数1：版本号；参数2：仓库地址；参数3：仓库标识 |
| `startcat.sh` / `startcat.bat` | 选择配置并启动 Tomcat（支持后台/前台模式） | 无参数，交互选择启动模式 |

### Docker 部署 | Docker

| 脚本 | 说明 | 参数 |
|------|------|------|
| `deploy_docker.sh` / `deploy_docker.bat` | Docker 容器化部署 | 参数1：网站名称 |

> ⚠️ **注意**：`deploy_apps`、`initialize_apps`、`startcat` 需在 Tomcat 目录运行；`initialize_apps`、`update_db`、`update_routing` 需提前放置 `btulz.transforms` 工具到 `ibas_tools` 目录。

---

## 🚀 快速开始 | Quick Start

### 开发流程

```bash
cd /your/workspace/ibas

# 批量拉取代码
./ibas/gits.sh pull

# 后端编译
./ibas/compiles.sh

# 前端编译
./ibas/builds.sh

# 收集 WAR 包
./ibas/copy_wars.sh
```

### 部署流程

```bash
cd /your/tomcat

# 下载应用
./ibas/download_apps.sh

# 部署 WAR 包
./ibas/deploy_apps.sh

# 初始化数据库
./ibas/initialize_apps.sh

# 生成服务路由
./ibas/update_routing.sh

# 启动 Tomcat
./ibas/startcat.sh
```

---

## 🐳 Docker 部署 | Docker

```bash
# 交互式容器化部署
./ibas/deploy_docker.sh my-website
```

可选组件：容器网络（ibas-net）、Portainer 管理平台、Nginx 反向代理、JMX 远程诊断、文件服务。

---

## 📚 相关项目 | Related Projects

| 项目 | 说明 |
|------|------|
| [ibas-framework](https://github.com/color-coding/ibas-framework) | IBAS 业务对象框架 |
| [btulz.transforms](https://github.com/color-coding/btulz.transforms) | 代码生成与数据转换工具 |
| [ibas-typescript](https://github.com/color-coding/ibas-typescript) | 前端架构，基于 SAP OpenUI5 |

---

<div align="center">

**[Color-Coding Studio](http://colorcoding.org/)** · 咔啦工作室

</div>
