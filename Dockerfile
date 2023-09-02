FROM kasmweb/core-ubuntu-focal:1.13.1-rolling
LABEL org.opencontainers.image.source="https://github.com/jpartain89/dockerfiles"
LABEL org.opencontainers.image.description="Ubuntu Desktop with Tor Browser"
LABEL org.opencontainers.image.licenses=MIT
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########
### Envrionment config
ENV DEBIAN_FRONTEND noninteractive
ENV KASM_RX_HOME $STARTUPDIR/kasmrx
ENV INST_SCRIPTS $STARTUPDIR/install

RUN \
    --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y \
        vlc \
        git \
        tmux \
        gnupg2 \
        gnupg-utils \
        nano \
        zip \
        xdotool \
        tar \
        unrar \
        xz-utils \
        curl \
        cryptsetup \
        jq \
        wireguard

### Install Tools
COPY ./install/ $INST_SCRIPTS/tools/
RUN bash $INST_SCRIPTS/tools/install_torbrowser.sh

RUN wget -q https://installers.privateinternetaccess.com/download/pia-linux-3.3.1-06924.run && \
    sh pia-linux-3.3.1-06924.run

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/list/* | true

######### End Customizations ###########

RUN chown 1000:0 $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
