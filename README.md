# `Openresty`实现广播
>
> Q：什么是`openresty`
>
> A：OpenResty® 是一个基于 [Nginx](https://openresty.org/cn/nginx.html) 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

```sh
#Openresty依赖添加lua-resty-http 直接使用lib
git clone https://github.com/ledgetech/lua-resty-http.git
cp lua-resty-http/lib/resty/* /usr/local/openresty/lualib/resty/
```
## 创建下面三个文件

## `docker-compose.yml`

``` yaml
version: '3.8'
services:
  proxy_nginx: 
    build:
      context: .
      dockerfile: Nginx
    restart: always
    ports:
      - "8888:80"
    container_name: proxy_nginx
    networks:
      proxy_network: 
        ipv4_address: 192.168.1.112

networks:
  proxy_network:
    name: "proxy_network"
    driver: "bridge"
    ipam:
      config:
        - subnet: 192.168.1.0/24
```

## `Nginx`

```Dockerfile
FROM openresty/openresty:1.21.4.1-0-jammy

RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

```

## `nginx.conf`

```conf nginx
worker_processes  16;
error_log /usr/local/openresty/nginx/logs/perror.log;
pid       /usr/local/openresty/nginx/logs/nginx.pid;
events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /usr/local/openresty/nginx/logs/paccess.log  main;
    open_log_file_cache off;

    # See Move default writable paths to a dedicated directory (#119)
    # https://github.com/openresty/docker-openresty/issues/119
    client_body_temp_path /var/run/openresty/nginx-client-body;
    proxy_temp_path       /var/run/openresty/nginx-proxy;
    fastcgi_temp_path     /var/run/openresty/nginx-fastcgi;
    uwsgi_temp_path       /var/run/openresty/nginx-uwsgi;
    scgi_temp_path        /var/run/openresty/nginx-scgi;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  60;

    #gzip  on;

    upstream backend {
        server 192.168.1.62:9006;
        server 192.168.1.65:9006;
        server 192.168.1.203:9006;
        server 192.168.1.186:9006;
    }

    server {
        listen 0.0.0.0:80;
        #server_name  127.0.0.1;
        #resolver 1.1.1.1;
        location = /upstreams {
            default_type text/plain;
            content_by_lua_block {
                local http = require "resty.http"
                local httpc = http.new()
                local upstream = require "ngx.upstream"
                local get_servers = upstream.get_servers
                local get_upstreams = upstream.get_upstreams
                local us = get_upstreams()
                for _, u in ipairs(us) do
                    ngx.say("upstream ", u, ":")
                    local srvs, err = get_servers(u)
                    if not srvs then
                        ngx.log(ngx.ERR,"failed to get servers in upstream ", u)
                    else
                        for _, srv in ipairs(srvs) do
                            local res, err = httpc:request_uri("http://"..srv["addr"])
                            if res.status == ngx.HTTP_OK then
                                ngx.print(res.body)
                            else
                                ngx.print(res.status)
                            end
                            ngx.print("\n")
                        end
                    end
                end
            }
        }

        location / {
            proxy_pass http://backend;
            proxy_connect_timeout 3s;
            proxy_timeout 10s;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
        root   /usr/local/openresty/nginx/html;
        }
    }
}
```

## proxy_nginx
***一个请求到达Nginx后将请求发到所有endpoint上，即配置文件中upstream中的每个server上。业务场景为：每个用户连接在同一个服务不同的节点上，如果需要向用户发出命令传递信息，在只发一次请求的前提下，经过Nginx后只能到达服务的某一个节点上，这样可能导致命令不能转发到相对应用户所在的节点上，所以需要将请求转发到每一个节点上，保证命令传递的有效性***

```sh
# 启动容器
docker-compose up -d 
docker compose ps
docker exec -it proxy_nginx bash

docker-compose logs
docker logs -f proxy_nginx
```

### cli 测试代码示例

```sh
https://orange-fiesta-7r55q7rj5rwfx444-8888.app.github.dev/
```
