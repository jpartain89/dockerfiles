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

### Install Tools
#COPY ./install/ $INST_SCRIPTS/tools/
#RUN bash $INST_SCRIPTS/tools/install_tools.sh && \
#    bash $INST_SCRIPTS/tools/install_torbrowser.sh
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
        curl

RUN <<EOF
    TOR_HOME=$HOME/tor-browser/
    mkdir -p $TOR_HOME
    if [ "$(arch)" == "aarch64" ]; then
        SF_VERSION=$(curl -sI https://sourceforge.net/projects/tor-browser-ports/files/latest/download | awk -F'(ports/|/tor)' '/location/ {print $3}')
        FULL_TOR_URL="https://downloads.sourceforge.net/project/tor-browser-ports/${SF_VERSION}/tor-browser-linux-arm64-${SF_VERSION}_ALL.tar.xz"
    else
        TOR_URL=$(curl -q https://www.torproject.org/download/ | grep downloadLink | grep linux64 | sed 's/.*href="//g'  | cut -d '"' -f1 | head -1)
        FULL_TOR_URL="https://www.torproject.org/${TOR_URL}"
    fi
    wget --quiet "${FULL_TOR_URL}" -O /tmp/torbrowser.tar.xz
    tar -xJf /tmp/torbrowser.tar.xz -C $TOR_HOME
    rm /tmp/torbrowser.tar.xz
EOF
RUN <<EOF
    cp $TOR_HOME/tor-browser/start-tor-browser.desktop $TOR_HOME/tor-browser/start-tor-browser.desktop.bak
    cp $TOR_HOME/tor-browser/Browser/browser/chrome/icons/default/default128.png /usr/share/icons/tor.png
    chown 1000:0 /usr/share/icons/tor.png
    sed -i 's/^Name=.*/Name=Tor Browser/g' $TOR_HOME/tor-browser/start-tor-browser.desktop
    sed -i 's/Icon=.*/Icon=\/usr\/share\/icons\/tor.png/g' $TOR_HOME/tor-browser/start-tor-browser.desktop
    sed -i 's/Exec=.*/Exec=sh -c \x27"$HOME\/tor-browser\/tor-browser\/Browser\/start-tor-browser" --detach || ([ !  -x "$HOME\/tor-browser\/tor-browser\/Browser\/start-tor-browser" ] \&\& "$(dirname "$*")"\/Browser\/start-tor-browser --detach)\x27 dummy %k/g'  $TOR_HOME/tor-browser/start-tor-browser.desktop
EOF
RUN <<EOF
    cat >> $TOR_HOME/tor-browser/Browser/TorBrowser/Data/Browser/profile.default/prefs.js <<EOL
    user_pref("app.normandy.enabled", false);
    user_pref("app.update.download.promptMaxAttempts", 0);
    user_pref("app.update.elevation.promptMaxAttempts", 0);
    user_pref("app.update.checkInstallTime", false);
    user_pref("app.update.background.interval", 315360000);
    user_pref("extensions.torlauncher.prompt_at_startup", false);
    user_pref("extensions.torlauncher.quickstart", true);
    user_pref("browser.download.lastDir", "/home/kasm-user/Downloads");
    user_pref("torbrowser.settings.bridges.builtin_type", "");
    user_pref("torbrowser.settings.bridges.enabled", false);
    user_pref("torbrowser.settings.bridges.source", -1);
    user_pref("torbrowser.settings.enabled", true);
    user_pref("torbrowser.settings.firewall.enabled", false);
    user_pref("torbrowser.settings.proxy.enabled", false);
    user_pref("torbrowser.settings.quickstart.enabled", true);
    user_pref("browser.urlbar.matchOnlyTyped", true);
    user_pref("browser.xul.error_pages.expert_bad_cert", true);
    user_pref("media.autoplay.block-webaudio", true);
    user_pref("network.IDN_show_punycode", true);
    user_pref("pdfjs.disabled", true);
    user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
    user_pref("webgl.disabled", true);
    user_pref("browser.cache.memory.enable", false);
    user_pref("browser.chrome.site_icons", false);
    user_pref("browser.shell.shortcutFavicons", false);
    user_pref("dom.storage.enabled", false);
    user_pref("javascript.enabled", false);
    user_pref("media.webm.enabled", false);
    user_pref("network.prefetch-next", false);
    user_pref("network.websocket.delay-failed-reconnects", false);
    user_pref("pdfjs.enabledCache.state", false);
    user_pref("services.sync.prefs.sync.network.cookie.cookieBehavior", false);
    user_pref("services.sync.prefs.sync.network.cookie.lifetimePolicy", false);
    user_pref("browser.cache.disk.enable", false);
    user_pref("browser.safebrowsing.downloads.remote.enabled", false);
    user_pref("browser.send_pings", false);
    user_pref("extensions.pocket.enabled", false);
    user_pref("geo.enabled", false);
    user_pref("media.peerconnection.enabled", false);
    user_pref("network.prefetch-next", false);
    user_pref("services.sync.prefs.sync.media.autoplay.default", false);
    user_pref("browser.display.use_document_fonts", 0);
    user_pref("network.http.sendRefererHeader", 0);
    user_pref("bidi.support", 0);
    EOL
EOF

RUN <<EOF
    # Maintain backwards compatability with old image definitions that expect tor to be launched from /tmp
    mkdir -p /tmp/tor-browser/Browser/
    ln -s $TOR_HOME/tor-browser/start-tor-browser.desktop /tmp/tor-browser/Browser/start-tor-browser.desktop\

    chown -R 1000:0 $TOR_HOME/

    cp $TOR_HOME/tor-browser/start-tor-browser.desktop $HOME/Desktop/
    chown 1000:0  $HOME/Desktop/start-tor-browser.desktop
EOF

######### End Customizations ###########

RUN chown 1000:0 $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
