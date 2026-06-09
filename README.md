<div align="center">

# btulz.scripts

**IBAS Deployment & Build Toolchain**

IBAS 框架配套的构建部署工具集 —— 涵盖后端编译、前端打包、应用下载、容器部署、数据库初始化、服务路由配置等全生命周期脚本，开箱即用。

A collection of shell/batch scripts for building, deploying, and managing IBAS framework applications — covering compilation, packaging, deployment, database initialization, and Docker orchestration.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)](#-环境要求--prerequisites)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20cmd-green.svg)](https://www.gnu.org/software/bash/)
[![IBAS](https://img.shields.io/badge/IBAS-Framework-orange.svg)](https://github.com/color-coding/ibas-framework)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#-贡献--contributing)

</div>

---

## 📖 目录 | Table of Contents

- [✨ 特性 | Features](#-特性--features)
- [🏗️ 工作流概览 | Workflow](#️-工作流概览--workflow)
- [📦 脚本清单 | Scripts](#-脚本清单--scripts)
- [🚀 快速开始 | Quick Start](#-快速开始--quick-start)
- [💡 使用指南 | Usage Guide](#-使用指南--usage-guide)
- [🐳 Docker 部署 | Docker Deployment](#-docker-部署--docker-deployment)
- [⚙️ 配置文件 | Configuration](#️-配置文件--configuration)
- [📚 相关项目 | Related Projects](#-相关项目--related-projects)
- [🤝 贡献 | Contributing](#-贡献--contributing)
- [📄 许可证 | License](#-许可证--license)
- [🙏 鸣谢 | Thanks](#-鸣谢--thanks)

---

## ✨ 特性 | Features

- **🔧 跨平台支持** — 每个脚本同时提供 `.sh`（Linux / macOS）和 `.bat`（Windows）版本，命令参数一致
- **📦 模块化编译** — 基于 `compile_order.txt` 定义编译顺序，支持批量或指定模块编译
- **🏗️ 前后端一体** — 后端 Maven 编译打包（`compiles`）与前端 JS 压缩构建（`builds`）分离
- **🚀 一键部署** — 从应用下载、WAR 包部署到 Tomcat 启动，全链路脚本化
- **🐳 Docker 编排** — 容器化部署，自动创建网络、Nginx 反向代理、Portainer 管理平台
- **🗄️ 数据库管理** — 自动分析 JAR 包创建数据库结构并初始化数据
- **🔀 服务路由** — 自动分析模块生成服务路由配置
- **🔄 批量 Git 操作** — 遍历工作目录下所有仓库批量执行 Git 命令
- **🧹 环境清理** — 清理编译产物、日志文件及失效符号链接
- **⏱️ 执行计时** — 脚本自动记录开始与结束时间，统计执行耗时

---

## 🏗️ 工作流概览 | Workflow

```
┌──────────────────────────────────────────────────────────┐
│                    开发阶段 · Development                   │
│   gits ──► builds ──► compiles ──► copy_wars             │
├──────────────────────────────────────────────────────────┤
│                    部署阶段 · Deployment                    │
│  download_apps ──► deploy_apps ──► initialize_apps        │
│           └──►  update_routing ──► startcat  │
├──────────────────────────────────────────────────────────┤
│                 发布阶段 · Release                          │
│            deploy_wars ──► Maven Repository               │
├──────────────────────────────────────────────────────────┤
│               容器化阶段 · Containerization                 │
│                    deploy_docker                           │
└──────────────────────────────────────────────────────────┘
```

---

## 📦 脚本清单 | Scripts

### 开发阶段 | Development

| 脚本 | 说明 | 参数 |
|------|------|------|
| `gits.sh` / `gits.bat` | 批量执行 Git 命令，遍历含 `.git` 的子目录 | 参数1：Git 命令；`clone` 时补全 `compile_order.txt` |
| `builds.sh` / `builds.bat` | 前端编译，使用 uglifyjs 压缩 `*.js` 为 `*.min.js` | 参数：模块名称，不提供则按 `compile_order.txt` |
| `compiles.sh` / `compiles.bat` | 后端编译打包，调用各模块的 `compile_packages.sh` | 参数：模块名称，不提供则按 `compile_order.txt` |
| `deploy_wars.sh` | 发布 WAR 包到 Maven 仓库 | 参数1：版本号；参数2：仓库地址；参数3：仓库标识 |

### 部署阶段 | Deployment

| 脚本 | 说明 | 参数 |
|------|------|------|
| `download_apps.sh` / `download_apps.bat` | 按列表下载应用到 `ibas_packages` | 参数1：应用版本，默认时间戳 |
| `deploy_apps.sh` / `deploy_apps.bat` | 部署 WAR 包到 webapps，集中配置与日志 | 参数1：IBAS 主目录；参数2：包目录；参数3：部署目录；参数4：共享库目录 |
| `initialize_apps.sh` / `initialize_apps.bat` | 初始化数据库结构和数据 | 参数1：配置文件路径，默认 `WEB-INF/app.xml` |
| `update_routing.sh` / `update_routing.bat` | 生成服务路由配置 | 参数1：配置文件；参数2：输出文件；参数3：数据服务地址；参数4：视图服务地址；参数5：共享库目录 |
| `startcat.sh` / `startcat.bat` | 选择配置文件并启动 Tomcat | 无参数 |

### Docker 部署 | Docker

| 脚本 | 说明 | 参数 |
|------|------|------|
| `deploy_docker.sh` / `deploy_docker.bat` | Docker 容器化部署，含 Nginx、Portainer | 参数1：网站名称 |

---

## 🚀 快速开始 | Quick Start

### 环境要求 | Prerequisites

- **Shell** — Bash（Linux / macOS）或 CMD（Windows）
- **JDK** 1.8+（数据库初始化相关脚本）
- **Maven** 3.x（后端编译脚本）
- **Git**（批量 Git 操作脚本）
- **Node.js + uglify-es**（前端压缩脚本，`npm install uglify-es -g`）
- **Docker**（容器化部署脚本）
- **curl**（应用下载脚本）

### 获取脚本 | Get the Scripts

```bash
# 克隆仓库
git clone https://github.com/color-coding/btulz.scripts.git
cd btulz.scripts

# 或直接从 Maven 仓库下载
# http://maven.colorcoding.org/repository/maven-public/
```

### 典型开发流程 | Typical Development Flow

```bash
cd /your/source_folder

# 1. 批量拉取最新代码
./gits.sh pull

# 2. 前端编译压缩
./builds.sh

# 3. 后端编译打包（按 compile_order.txt 顺序）
./compiles.sh
```

### 典型部署流程 | Typical Deployment Flow

```bash
cd /your/tomcat_folder

# 1. 下载应用包
./download_apps.sh 202507011200

# 2. 部署 WAR 包到 webapps
./deploy_apps.sh

# 3. 初始化数据库
./initialize_apps.sh

# 4. 生成服务路由配置
./update_routing.sh

# 5. 选择配置并启动 Tomcat
./startcat.sh
```

---

## 💡 使用指南 | Usage Guide

### compile_order.txt 编译顺序

多数脚本依赖工作目录下的 `compile_order.txt` 文件定义模块处理顺序。若文件不存在，脚本会自动按目录修改时间生成。

```
# 示例 compile_order.txt
ibas-typescript
ibas.initialfantasy
ibas.importexport
ibas.accounting
```

### 批量 Git 操作

```bash
# 批量拉取
./gits.sh pull

# 批量切换分支
./gits.sh checkout master

# 批量克隆（自动读取 compile_order.txt）
./gits.sh clone https://github.com/color-coding/
```

### 前端编译环境变量

| 环境变量 | 说明 |
|----------|------|
| `TS_COMPRESS_DISABLED=true` | 禁用 JS 文件压缩 |
| `TS_COMPRESS_NO_ORIGINAL=true` | 压缩后不保留原始文件（直接替换） |

### 部署目录结构

`deploy_apps` 部署后的目录结构：

```
tomcat/
├── ibas/                  ← IBAS 主目录
│   ├── conf/              ← 集中配置文件（app.xml, service_routing.xml 等）
│   ├── data/              ← 数据文件
│   └── logs/              ← 集中日志
├── ibas_lib/              ← 共享库 JAR 包
├── ibas_packages/         ← 应用 WAR 包
├── ibas_tools/            ← 工具（btulz.transforms）
└── webapps/               ← Tomcat 部署目录
```

> ⚠️ **注意**：部署前请在 `catalina.properties` 中配置 `shared.loader="${catalina.home}/ibas_lib/*.jar"`，并在 `context.xml` 中添加 `<Resources allowLinking="true" />`。

---

## 🐳 Docker 部署 | Docker Deployment

`deploy_docker.sh` 提供完整的容器化部署方案：

```bash
# 启动交互式部署
./deploy_docker.sh my-website
```

部署过程中可选择：

- **容器网络** — 自动创建 `ibas-net` Docker 网络
- **Portainer** — 容器管理平台（可选）
- **Tomcat 容器** — IBAS 应用运行容器
- **Nginx 反向代理** — 自动生成站点配置
- **JMX 远程诊断** — 可选开启 Tomcat 远程监控
- **文件服务** — 可选的文件管理服务

---

## ⚙️ 配置文件 | Configuration

| 文件 | 说明 | 位置 |
|------|------|------|
| `compile_order.txt` | 模块编译/处理顺序 | 工作目录根 |
| `packages.txt` | 应用下载列表，支持 `${APP_VERSION}` 变量 | 工作目录根 |
| `ibas.release.txt` | 模块初始化顺序 | `webapps/` |
| `app.xml` | IBAS 应用配置（数据库连接等） | `ibas/conf/` 或 `WEB-INF/` |
| `service_routing.xml` | 服务路由配置 | `ibas/conf/` |

### packages.txt 示例

```
http://maven.colorcoding.org/repository/maven-releases/org/colorcoding/apps/ibas.accounting.service-${APP_VERSION}.war
http://maven.colorcoding.org/repository/maven-releases/org/colorcoding/apps/ibas.sales.service-${APP_VERSION}.war
```

---

## 📚 相关项目 | Related Projects

| 项目 | 说明 |
|------|------|
| [ibas-framework](https://github.com/color-coding/ibas-framework) | IBAS 业务对象框架，本工具集的主要服务对象 |
| [btulz.transforms](https://github.com/color-coding/btulz.transforms) | 代码生成与数据转换工具，数据库初始化脚本依赖此工具 |
| [ibas.businessone](https://github.com/color-coding/ibas.businessone) | SAP Business One 集成层 |
| [ibas-typescript](https://github.com/color-coding/ibas-typescript) | 前端架构，配合 IBAS 服务端，基于 SAP OpenUI5 |

---

## 🤝 贡献 | Contributing

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支（`git checkout -b feature/amazing-feature`）
3. 提交更改（`git commit -m 'Add amazing feature'`）
4. 推送到分支（`git push origin feature/amazing-feature`）
5. 发起 Pull Request

---

## 📄 许可证 | License

本项目基于 [MIT License](LICENSE) 开源。

---

## 🙏 鸣谢 | Thanks

<div align="center">

**[Color-Coding Studio](http://colorcoding.org/)** · 咔啦工作室

</div>
