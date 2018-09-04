#!/usr/bin/env bash

set -e
export DEBIAN_FRONTEND=noninteractive
NGINX_VERSION="1.13.6"
OPENTRACING_VERSION="1.5.0"
NGINX_OPENTRACING_VERSION="0.6.0"
OUTPUT_DIR=/build
apt-get update
apt-get install -y \
        --no-install-recommends \
        --no-install-suggests \
        build-essential \
        cmake \
        ca-certificates \
        pkg-config \
        automake \
        autogen \
        autoconf \
        libtool \
        libssl-dev \
        libpcre3-dev \
        zlib1g-dev \
        curl
cd /tmp
echo "Build opentracing-cpp"
curl --progress-bar -L https://github.com/opentracing/opentracing-cpp/archive/v${OPENTRACING_VERSION}.tar.gz -o opentracing.tar.gz
tar zxf opentracing.tar.gz
cd /tmp/opentracing-cpp-${OPENTRACING_VERSION}
mkdir .build && cd .build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF ..
make && make install
cd /tmp
echo "Download nginx-opentracing"
curl --progress-bar -L https://github.com/opentracing-contrib/nginx-opentracing/archive/v${NGINX_OPENTRACING_VERSION}.tar.gz -o nginx-opentracing.tar.gz
tar zxf nginx-opentracing.tar.gz
echo "Download nginx"
curl --progress-bar -L https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz
tar zxf nginx.tar.gz
cd /tmp/nginx-${NGINX_VERSION}
./configure \
         --prefix=/usr/local/openresty/nginx \
         --with-pcre-jit \
         --with-stream \
         --with-stream_ssl_module \
         --with-stream_ssl_preread_module \
         --with-http_v2_module \
         --without-mail_pop3_module \
         --without-mail_imap_module \
         --without-mail_smtp_module \
         --with-http_ssl_module \
         --with-http_stub_status_module \
         --with-http_realip_module \
         --with-http_addition_module \
         --with-http_auth_request_module \
         --with-http_secure_link_module \
         --with-http_random_index_module \
         --with-http_gzip_static_module \
         --with-http_sub_module \
         --with-http_dav_module \
         --with-http_flv_module \
         --with-http_mp4_module \
         --with-http_gunzip_module \
         --with-threads \
         --add-dynamic-module=/tmp/nginx-opentracing-${NGINX_OPENTRACING_VERSION}/opentracing
make modules
cp objs/ngx_http_opentracing_module.so $OUTPUT_DIR/
cp /usr/local/lib/libopentracing.so.${OPENTRACING_VERSION} $OUTPUT_DIR/
cp /usr/local/lib/libopentracing_mocktracer.so.${OPENTRACING_VERSION} $OUTPUT_DIR/
