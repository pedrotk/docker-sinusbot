FROM debian:jessie
MAINTAINER Alexander Trost <galexrt@googlemail.com>

# SinusBot config
ENV SINUS_VERSION="0.9.8" SINUS_DIR="/opt/sinusbot" SINUS_DATA="/data"
    TS3_VERSION="3.0.16" TS3_OFFSET="49134" TS3_DIR="$SINUS_DIR/TeamSpeak3-Client-linux_amd64"
    YTDL_VERSION="latest" YTDL_BIN="/usr/local/bin/youtube-dl"
# Install dependencies
RUN apt-get update -q && apt-get install -yq \
    wget \
    x11vnc \
    xinit \
    xvfb \
    libxcursor1 \
    libglib2.0-0 \
    python \
    bzip2 \
    ca-certificates && \
    update-ca-certificates && \
    wget -qO $YTDL_BIN https://yt-dl.org/downloads/$YTDL_VERSION/youtube-dl && \
    chmod a+rx $YTDL_BIN && \
    echo LC_ALL=en_US.UTF-8 >> /etc/default/locale && \
    echo LANG=en_US.UTF-8 >> /etc/default/locale && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd -r sinusbot && \
    useradd -r -g sinusbot -d "$SINUS_DIR" sinusbot && \
    mkdir -p "$SINUS_DIR" "$SINUS_DATA" "$TS3_DIR" && \
    chown sinusbot:sinusbot "$SINUS_DIR" "$SINUS_DATA" "$TS3_DIR"
USER sinusbot
# Download and install the SinusBot
RUN wget -qO- http://frie.se/ts3bot/sinusbot-$SINUS_VERSION.tar.bz2 | \
    tar -xjf- -C "$SINUS_DIR" && \
    wget -qO- http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run | \
    tail -c +$TS3_OFFSET | \
    tar -xzf- -C "$TS3_DIR" && \
    cp "$SINUS_DIR/config.ini.dist" "$SINUS_DIR/config.ini" && \
    echo YoutubeDLPath = \"$YTDL_BIN\" >> ./config.ini && \
    cp "$SINUS_DIR/plugin/libsoundbot_plugin.so" "$TS3_DIR/plugins"
VOLUME "$SINUS_DIR"
EXPOSE 8087
ENTRYPOINT ["/entrypoint.sh"]
