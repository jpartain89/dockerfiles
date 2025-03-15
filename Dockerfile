FROM kasmweb/ubuntu-focal-desktop-vpn:1.16.1-rolling-weekly as builder
LABEL org.opencontainers.image.source="https://github.com/jpartain89/dockerfiles"
LABEL org.opencontainers.image.description="Ubuntu Desktop with Tor Browser"
LABEL org.opencontainers.image.licenses=MIT
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########
### Envrionment config
ENV DEBIAN_FRONTEND=noninteractive
ENV KASM_RX_HOME=$STARTUPDIR/kasmrx
ENV INST_SCRIPTS=$STARTUPDIR/install

RUN \
    --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
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
        sudo && \
        echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' | tee -a /etc/sudoers.d/kasm-user

### Install Tools
COPY ./install/install_torbrowser.sh ${INST_SCRIPTS}/
RUN bash ${INST_SCRIPTS}/install_torbrowser.sh

RUN echo "/usr/bin/desktop_ready && \
    ln -svf /CentralShare ${HOME}/Desktop/CentralShare &&" > ${STARTUPDIR}/custom_startup.sh && \
    chmod +x ${STARTUPDIR}/custom_startup.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
