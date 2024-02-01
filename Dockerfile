FROM kasmweb/core-ubuntu-focal:1.14.0-rolling as builder
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
    apt-get update && apt-get install -y --no-install-recommends \
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
        openvpn \
        sudo && \
        echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

### Install Tools
COPY ./install/install_torbrowser.sh ${INST_SCRIPTS}/
RUN bash ${INST_SCRIPTS}/install_torbrowser.sh

# Download PIA ovpn Files
RUN cd /etc/openvpn && \
wget https://www.privateinternetaccess.com/openvpn/openvpn.zip && \
unzip openvpn.zip && \
rm openvpn.zip

FROM builder AS final
COPY --from=builder / /

######### End Customizations ###########

RUN chown 1000:0 $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
