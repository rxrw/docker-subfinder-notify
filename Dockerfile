FROM lsiobase/alpine:3.12 as builder
# set label
LABEL maintainer="NG6"
ARG S6_VER=2.1.0.2
WORKDIR /downloads
# download s6-overlay
RUN	if [ "$(uname -m)" = "x86_64" ];then s6_arch=amd64;elif [ "$(uname -m)" = "aarch64" ];then s6_arch=aarch64;elif [ "$(uname -m)" = "armv7l" ];then s6_arch=arm; fi  \
&&  wget --no-check-certificate https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.gz  \
&&	mkdir ./s6-overlay \
&&  tar -xvzf s6-overlay-${s6_arch}.tar.gz -C ./s6-overlay

FROM python:3.6-slim-buster
# set label
LABEL maintainer="Jens Lee"
ENV TZ=Asia/Shanghai PUID=1027 PGID=100

ARG $EXCLUDE
ARG $INTERNAL_SUB_SKIP

# copy files
COPY root/ /
COPY --from=builder /downloads/s6-overlay/  /

# install subfinder
RUN apt -y update
RUN apt -y install unrar-free inotify-tools ffmpeg
RUN pip install subfinder
RUN useradd -u 1000 -U -d /config -s /bin/false abc \
&&  usermod -G users abc  \
&&  echo "**** cleanup ****" \
&&  apt-get clean \
&&	apt-get autoremove \
&&  rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

ADD looking4video /usr/bin/

RUN chmod 755 /usr/bin/looking4video

ADD config /config

# volumes
VOLUME /config /media

ENTRYPOINT [ "/init" ]