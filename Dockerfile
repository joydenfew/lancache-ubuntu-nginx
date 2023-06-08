FROM joydenfew/lancachenet-ubuntu:latest
MAINTAINER LanCache.Net Team <team@lancache.net>
ARG DEBIAN_FRONTEND=noninteractive
COPY overlay/ /
RUN apt-get update && apt-get install -y nginx-full inotify-tools
RUN \
    chmod 777 /opt/nginx/startnginx.sh && \
    rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
	mkdir -p /etc/nginx/sites-enabled/ && \
	mkdir -p /etc/nginx/stream-enabled/ && \
	for SITE in /etc/nginx/sites-available/*; do [ -e "$SITE" ] || continue; ln -s $SITE /etc/nginx/sites-enabled/`basename $SITE`; done && \
	for SITE in /etc/nginx/stream-available/*; do [ -e "$SITE" ] || continue; ln -s $SITE /etc/nginx/stream-enabled/`basename $SITE`; done && \
    mkdir -p /var/www/html && \
    chmod 777 /var/www/html /var/lib/nginx && \
    chmod -R 777 /var/log/nginx && \
    chmod -R 755 /hooks /init && \
    chmod 755 /var/www && \
    chmod -R 666 /etc/nginx/sites-* /etc/nginx/conf.d/* /etc/nginx/stream.d/* /etc/nginx/stream-*
RUN \
    apt update && apt install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev libgroonga-dev libpam0g-dev && \ 
    cd /build_ngnix/nginx-1.14.0 && \
    ./configure --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module --add-dynamic-module=../ngx_http_auth_pam_module --with-http_slice_module --with-stream --with-stream_ssl_preread_module --with-http_stub_status_module && \
    make && make install && \
    nginx -v && \
    mkdir /var/www/html/modules && \
    cp -r /usr/lib/nginx/modules/* /var/www/html/modules/
 
EXPOSE 80
