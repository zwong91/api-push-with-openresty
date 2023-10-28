FROM openresty/openresty:1.21.4.1-0-jammy

RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

# RUN apt-get update && apt-get install -y vim netcat

COPY proxy/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD proxy/lua/resty /usr/local/openresty/lualib/resty

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

