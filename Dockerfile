FROM alpine:3

LABEL maintainer="sanjusss sanjusss@qq.com"

ENV HTTP_PORT=80
ENV EXTERNAL_PORT=80
ENV USER_NAME=admin
ENV PASSWORD=admin
ENV PUID=1000
ENV PGID=1000
ENV TRACKER_URL=https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt
ENV ENABLE_UPDATE_TRACKER=true

VOLUME /data
VOLUME /conf

WORKDIR /app
ADD app /app
RUN chmod +x /app/*.sh
ADD nginx.conf /etc/nginx/conf.d
ADD conf /app/conf
RUN echo '*/15 * * * * /app/updatebttracker.sh' > /etc/crontabs/root
CMD /app/run.sh
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD /app/healthcheck.sh
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --no-cache \
    aria2 \
    wget \
    apache2-utils \
    sudo \
    nginx \
    curl

RUN ARIAGN_VERSION=`curl --silent "https://api.github.com/repos/mayswind/AriaNg/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'` \
    && mkdir -p /run/nginx \
    && mkdir -p /usr/share/nginx/html \
    && rm -rf /usr/share/nginx/html/* \
    && wget -N --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${ARIAGN_VERSION}/AriaNg-${ARIAGN_VERSION}.zip \
    && unzip AriaNg-${ARIAGN_VERSION}.zip -d /usr/share/nginx/html \
    && rm -rf AriaNg-${ARIAGN_VERSION}.zip \
    && echo Set disable_coredump false >> /etc/sudo.conf

RUN apk del \
    wget