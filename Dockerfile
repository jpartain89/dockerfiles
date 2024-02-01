FROM kasmweb/core-ubuntu-focal:1.14.0-rolling as builder
LABEL org.opencontainers.image.source="https://github.com/jpartain89/dockerfiles"
LABEL org.opencontainers.image.description="Ubuntu Desktop with Tor Browser"
LABEL org.opencontainers.image.licenses=MIT
USER root

ARG PIA_USER
ARG PIA_PASS
ENV PIA_USER=$PIA_USER
ENV PIA_PASS=$PIA_PASS
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
        wireguard \
        wireguard-tools \
        sudo && \
        echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

### Install Tools
COPY ./install/install_torbrowser.sh $INST_SCRIPTS/
RUN bash $INST_SCRIPTS/install_torbrowser.sh

##### PIA VPN Repo
RUN git clone https://github.com/pia-foss/manual-connections && \
    cd manual-connections && \
    sudo PIA_USER=$PIA_USER PIA_PASS=$PIA_PASS PIA_PF=true PIA_DNS=true DISABLE_IPV6=yes \
        PREFERRED_REGION=us_texas VPN_PROTOCOL=wireguard DIP_TOKEN=no ./run_setup.sh

FROM builder AS final
COPY --from=builder / /

######### End Customizations ###########

RUN chown 1000:0 $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
