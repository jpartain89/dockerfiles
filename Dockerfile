ARG BASE_TAG="develop"
ARG BASE_IMAGE="core-ubuntu-focal"
FROM kasmweb/core-ubuntu-focal:develop
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

### Install Tools
COPY ./install/ $INST_SCRIPTS/tools/
RUN bash $INST_SCRIPTS/tools/install_tools.sh && \
    bash $INST_SCRIPTS/tools/install_torbrowser.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
