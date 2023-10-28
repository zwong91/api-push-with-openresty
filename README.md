# `Openresty`实现广播
>
> Q：什么是`openresty`
>
> A：OpenResty® 是一个基于 [Nginx](https://openresty.org/cn/nginx.html) 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

>Q: 一个请求通过or 复制多个流量到上游， openresty 提供lua的可编程性
>
>A: 一个请求到达Nginx后将请求发到所有endpoint上，即配置文件中upstream中的每个server上。业务场景为：每个用户连接在同一个服务不同的节点上，如果需要向用户发出命令传递信息，在只发一次请求的前提下，经过Nginx后只能到达服务的某一个节点上，这样可能导致命令不能转发到相对应用户所在的节点上，所以需要将请求转发到每一个节点上，保证命令传递的有效性

```sh
#Openresty依赖添加lua-resty-http 直接使用lib
git clone https://github.com/ledgetech/lua-resty-http.git
cp lua-resty-http/lib/resty/* /usr/local/openresty/lualib/resty/
```

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
