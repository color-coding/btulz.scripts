#!/bin/bash
echo '****************************************************************************'
echo '                  deploy_docker.sh                                          '
echo '                     by niuren.zhu                                          '
echo '                        2020.12.04                                          '
echo '  说明：                                                                     '
echo '    1. 参数1，文件夹为网站目录。并构建运行容器。                                   '
echo '    2. 运行前，自主把应用war包，拷贝至网站目录下的ibas_packages下。                 '
echo '    3. 应用配置及数据文件，在网站目录的ibas目录。                                  '
echo '    4. 脚本会自动在root/conf.d，创建网站的nginx配置。                            '
echo '    5. 若开启容器管理平台，可以通过索引页链接打开。                                '
echo '    6. 若开启Tomcat远程诊断，可以用jconsole连接，注意端口冲突。                    '
echo '    7. 网站目录host文件会自动添加到容器。                                        '
echo '****************************************************************************'
# 设置参数变量
WORK_FOLDER=$PWD
echo --工作目录：${WORK_FOLDER}
# 获取网站名称
WEBSITE=$1
if [ "${WEBSITE}" = "" ]; then
    read -p "----请输入网站名称: " WEBSITE
else
    echo "--网站名称：${WEBSITE}"
fi
if [ "${WEBSITE}" = "" ]; then
    exit 1
fi
if [ ! -e ${WORK_FOLDER}/${WEBSITE} ]; then
    mkdir -p ${WORK_FOLDER}/${WEBSITE}
fi
# 启动容器控制台
CONTAINER_PORTAINER=portainer
if [ ! -e ${WORK_FOLDER}/portainer ]; then
    read -p "----创建容器管理平台（Portainer）？（n or [y]）: " PORTAINER
    if [ "${PORTAINER}" = "" ]; then
        PORTAINER=y
    fi
    if [ "${PORTAINER}" = "y" ]; then
        mkdir -p ${WORK_FOLDER}/portainer
        # 获取端口号
        read -p "----管理平台端口（9000）: " PORTAINER_PORT
        if [ "${NGINX_PORT}" = "" ]; then
            PORTAINER_PORT=9000
        fi
        docker run -d \
            --name=${CONTAINER_PORTAINER} \
            --restart=always \
            -m 256m \
            -p ${PORTAINER_PORT}:9000 \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v ${WORK_FOLDER}/portainer:/data \
            --privileged=true \
            portainer/portainer-ce
    fi
    echo --容器管理平台：${CONTAINER_PORTAINER}
fi
# 获取数据库容器
read -p "----请输入数据库容器（ibas-db-mysql）: " CONTAINER_DATABASE
if [ "${CONTAINER_DATABASE}" = "" ]; then
    CONTAINER_DATABASE=ibas-db-mysql
fi
echo --数据库容器：${CONTAINER_DATABASE}
# 创建网站容器
CONTAINER_TOMCAT=ibas-tomcat-${WEBSITE}
echo --网站容器：${CONTAINER_TOMCAT}
# 检查数据目录
mkdir -p ${WORK_FOLDER}/${WEBSITE}/ibas/conf/
mkdir -p ${WORK_FOLDER}/${WEBSITE}/ibas/data/
mkdir -p ${WORK_FOLDER}/${WEBSITE}/ibas/logs/
mkdir -p ${WORK_FOLDER}/${WEBSITE}/ibas_packages/
read -p "----重建网站容器？（n or [y]）: " RESET_TOMCAT
if [ "${RESET_TOMCAT}" = "" ]; then
    RESET_TOMCAT=y
fi
if [ "${RESET_TOMCAT}" = "y" ]; then
    read -p "----开启Tomcat远程诊断？（[n] or y）: " JMX_TOMCAT
    if [ "${JMX_TOMCAT}" = "y" ]; then
        read -p "----远程诊断端口？（8900）: " JMX_PORT
        if [ "${JMX_PORT}" = "" ]; then
            JMX_PORT=8900
        fi
        # 检查环境变量文件
        if [ -e ${WORK_FOLDER}/${WEBSITE}/tomcat_setenv.sh ]; then
            rm -f ${WORK_FOLDER}/${WEBSITE}/tomcat_setenv.sh
        fi
        cat >${WORK_FOLDER}/${WEBSITE}/tomcat_setenv.sh <<EOF
# Tomcat Environment Variables
JAVA_OPTS="\$JAVA_OPTS -Dcom.sun.management.jmxremote"
JAVA_OPTS="\$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
JAVA_OPTS="\$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false"
JAVA_OPTS="\$JAVA_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT"
JAVA_OPTS="\$JAVA_OPTS -Dcom.sun.management.jmxremote.rmi.port=$JMX_PORT"
JAVA_OPTS="\$JAVA_OPTS -Djava.rmi.server.hostname=$(hostname)"
EOF
        DOCKER_JMX="${DOCKER_JMX} -v ${WORK_FOLDER}/${WEBSITE}/tomcat_setenv.sh:/usr/local/tomcat/bin/setenv.sh"
        DOCKER_JMX="${DOCKER_JMX} -p ${JMX_PORT}:${JMX_PORT}"
    fi
    # 删除重建
    read -p "----网站容器内存？（1024m）: " MEM_TOMCAT
    if [ "${MEM_TOMCAT}" = "" ]; then
        MEM_TOMCAT=1024
    fi
    MEM_JAVA=$(expr ${MEM_TOMCAT} - 128)
    # 使用host
    if [ -e ${WORK_FOLDER}/${WEBSITE}/hosts ]; then
        read -p "----检测到host文件是否使用？（[n] or y）: " USE_HOSTS
        if [ "${USE_HOSTS}" = "y" ]; then
            HOST_TOMCAT=
            while read HOST; do
                if [ "${HOST}" == "" ]; then
                    continue
                fi
                if [[ ${HOST} == \#* ]]; then
                    continue
                fi
                HOST_IP=$(echo ${HOST} | cut -d " " -f 1)
                if [ "${HOST_IP}" == "" ]; then
                    continue
                fi
                if [ "${HOST_IP}" == "::1" ]; then
                    continue
                fi
                if [ "${HOST_IP}" == "127.0.0.1" ]; then
                    continue
                fi
                if [ "${HOST_IP}" == "255.255.255.255" ]; then
                    continue
                fi
                HOST_NAME=$(echo ${HOST} | cut -d " " -f 2)
                if [ "${HOST_NAME}" == "" ]; then
                    continue
                fi
                if [ "${HOST_NAME}" == "localhost" ]; then
                    continue
                fi
                HOST_TOMCAT=$(echo ${HOST_TOMCAT} --add-host=${HOST_NAME}:${HOST_IP})
            done <"${WORK_FOLDER}/${WEBSITE}/hosts"
        fi
    fi
    # 使用镜像
    if [ -e ${WORK_FOLDER}/${WEBSITE}/CONTAINER_IMAGE ]; then
        DEF_IMAGE_TOMCAT=$(cat ${WORK_FOLDER}/${WEBSITE}/CONTAINER_IMAGE)
    fi
    if [ "${DEF_IMAGE_TOMCAT}" = "" ]; then
        DEF_IMAGE_TOMCAT=colorcoding/tomcat:ibas-alpine
    fi
    read -p "----网站容器镜像？（${DEF_IMAGE_TOMCAT}）: " IMAGE_TOMCAT
    if [ "${IMAGE_TOMCAT}" = "" ]; then
        IMAGE_TOMCAT=${DEF_IMAGE_TOMCAT}
    fi
    docker rm -vf ${CONTAINER_TOMCAT} >/dev/null
    docker run -d \
        --name ${CONTAINER_TOMCAT} \
        -m ${MEM_TOMCAT}m \
        -v ${WORK_FOLDER}/${WEBSITE}/ibas:/usr/local/tomcat/ibas \
        -v ${WORK_FOLDER}/${WEBSITE}/ibas_packages:/usr/local/tomcat/ibas_packages \
        --link ${CONTAINER_DATABASE}:${CONTAINER_DATABASE} \
        -e TZ="Asia/Shanghai" \
        -e JAVA_OPTS="-Xmx${MEM_JAVA}m" \
        --privileged=true \
        ${DOCKER_JMX} \
        ${HOST_TOMCAT} \
        ${IMAGE_TOMCAT}
    echo ${IMAGE_TOMCAT} >${WORK_FOLDER}/${WEBSITE}/CONTAINER_IMAGE
else
    # 启动更新，需要做好目录映射
    docker start ${CONTAINER_TOMCAT}
fi
# 释放程序包
docker exec -it ${CONTAINER_TOMCAT} /usr/local/tomcat/deploy_apps.sh
# 升级数据库
read -p "----刷新数据库？（[n] or y）: " UPDATE_DATABASE
if [ "${UPDATE_DATABASE}" = "y" ]; then
    docker exec -it ${CONTAINER_TOMCAT} /usr/local/tomcat/initialize_apps.sh
fi
# 重新启动容器
docker restart ${CONTAINER_TOMCAT} >/dev/null

# 更新根网站
CONTAINER_NGINX=ibas-nginx-root
NGINX_CONFD=${WORK_FOLDER}/root/conf.d
NGINX_CERT=${WORK_FOLDER}/root/cert
NGINX_NAME=$(hostname)
NGINX_PORT_HTTP=
NGINX_PORT_HTTPS=

echo --网站根节点：${CONTAINER_NGINX}
read -p "----更新根节点？（n or [y]）: " UPDATE_ROOT
if [ "${UPDATE_ROOT}" = "" ]; then
    UPDATE_ROOT=y
fi
if [ "${UPDATE_ROOT}" = "n" ]; then
    exit 0
fi
# 获取端口号
read -p "----根节点http端口（80）: " NGINX_PORT_HTTP
if [ "${NGINX_PORT_HTTP}" = "" ]; then
    NGINX_PORT_HTTP=80
fi
read -p "----根节点https端口（443）: " NGINX_PORT_HTTPS
if [ "${NGINX_PORT_HTTPS}" = "" ]; then
    NGINX_PORT_HTTPS=443
fi
# 检查数据目录
mkdir -p ${NGINX_CERT}
mkdir -p ${NGINX_CONFD}
if [ ! -e ${NGINX_CONFD}/default.conf ]; then
    cat >${NGINX_CONFD}/default.conf <<EOF
server {
    listen       ${NGINX_PORT_HTTP};
    server_name  localhost ${NGINX_NAME};

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # 加载其他路径配置
    include /etc/nginx/conf.d/*.location;
}

server {
    listen ${NGINX_PORT_HTTPS};
    server_name ${NGINX_NAME};
    ssl on;
    ssl_certificate   /etc/nginx/cert/1_${NGINX_NAME}_bundle.crt;
    ssl_certificate_key  /etc/nginx/cert/2_${NGINX_NAME}.key;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # 加载其他路径配置
    include /etc/nginx/conf.d/*.location;
}
EOF
fi
if [ ! -e ${NGINX_CONFD}/sapbydesign.location ]; then
    cat >${NGINX_CONFD}/sapbydesign.location <<EOF
# byd cn (https://myXXXXXX.sapbyd.cn/)
location /sap/byd/cn/ {
    client_max_body_size 10m;
    client_body_buffer_size 128k;
    proxy_connect_timeout 1800;
    proxy_send_timeout 1800;
    proxy_read_timeout 1800;
    proxy_buffer_size 4k;
    proxy_buffers 32 4k;
    proxy_busy_buffers_size 64k;

    resolver 223.5.5.5 223.6.6.6;
    if (\$request_method = 'OPTIONS') {
        add_header Access-Control-Allow-Origin \$http_origin;
        add_header Access-Control-Allow-Credentials true;
        add_header Access-Control-Allow-Headers \$http_access_control_request_headers;
        add_header Access-Control-Allow-Headers x-sap-request-xsrf,x-csrf-token,authorization,origin,x-requested-with,access-control-request-headers,content-type,access-control-request-method,accept;
        add_header Access-Control-Expose-Headers x-sap-request-xsrf,x-csrf-token,authorization,origin,x-requested-with,access-control-request-headers,content-type,access-control-request-method,accept,sap-xsrf;
        add_header Access-Control-Allow-Methods GET,POST,DELETE,PUT,OPTIONS;
        return 200;
    }

    rewrite ^/sap/byd/cn/(my[0-9]+)/(.*)\$ /\$2 break;
    proxy_pass  https://\$1.sapbyd.cn/\$2\?$args;
    proxy_cookie_path /sap/ap/ui/login /;
}
EOF
fi
if [ ! -e ${NGINX_CONFD}/${WEBSITE}.location ]; then
    # 配置文件需要物理存在
    cat >${NGINX_CONFD}/${WEBSITE}.location <<EOF
location /${WEBSITE}/ {
    proxy_connect_timeout 1800;
    proxy_send_timeout 1800;
    proxy_read_timeout 1800;

    proxy_pass http://${CONTAINER_TOMCAT}:8080/;
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header REMOTE-HOST \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
}
EOF
fi
# 容器管理平台索引
if [ -e ${WORK_FOLDER}/portainer ]; then
    PORTAINER_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "9000/tcp") 0).HostPort}}' portainer || echo "")
    LINK_PORTAINER="<p><a href=":${PORTAINER_PORT}" target="_blank">Portainer</a></p>"
fi
# 如果未获取到端口则不生成索引
if [ "${PORTAINER_PORT}" = "" ]; then
    LINK_PORTAINER=
fi
# 重新创建根网站容器
LINK_TOMCATS=
LINK_APPS=
for ITEM in $(docker ps --format "table {{.Names}}" | grep ibas-tomcat-); do
    LINK_TOMCATS="${LINK_TOMCATS} --link ${ITEM}"
    LINK_APPS="${LINK_APPS} <p><a href="${ITEM:12}" target="_blank">${ITEM:12}</a>  ($(docker inspect -f {{.Created}} ${ITEM}))</p>"
done
# 应用索引文件
cat >${WORK_FOLDER}/root/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ibas apps!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
</head>
<body>
    <h1>Welcome to ibas apps!</h1>
    ${LINK_PORTAINER}
    ${LINK_APPS}
</body>
<script>
    let as = document.body.getElementsByTagName("a");
    for (let index = 0; index < as.length; index++) {
        let element = as[index];
        let href = element.getAttribute("href");
        if (typeof href === "string" && href.startsWith(":")) {
            href = window.location.origin.replace(window.location.host, window.location.hostname + href);
        }
        element.setAttribute("href", href);
    }
</script>
</html>
EOF
docker rm -vf ${CONTAINER_NGINX} >/dev/null
docker run -d \
    --name ${CONTAINER_NGINX} \
    -p ${NGINX_PORT_HTTP}:80 \
    -p ${NGINX_PORT_HTTPS}:443 \
    -m 64m \
    -v ${NGINX_CONFD}:/etc/nginx/conf.d/ \
    -v ${NGINX_CERT}:/etc/nginx/cert/ \
    -v ${WORK_FOLDER}/root/index.html:/usr/share/nginx/html/index.html \
    ${LINK_TOMCATS} \
    --privileged=true \
    nginx:alpine
echo --网站地址：http://${NGINX_NAME}:${NGINX_PORT_HTTP}/${WEBSITE}/
echo --网站地址：https://${NGINX_NAME}:${NGINX_PORT_HTTPS}/${WEBSITE}/
