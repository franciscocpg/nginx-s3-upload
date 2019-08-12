FROM openresty/openresty:xenial


# Install necessary tools to download lua-resty-s3
RUN apt-get update && \
    apt-get install -y git openssl


# Install lua-resty-s3
RUN git clone https://github.com/descomplica/lua-resty-s3 /tmp/lua-resty-s3 && \
    mkdir -p /etc/lua && \
    cp -rf /tmp/lua-resty-s3/lib/* /etc/lua

COPY s3.lua /etc/lua/
COPY config/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
