#!/usr/bin/env bash
set -ex
apt-get update
apt-get install -y \
  vlc \
  git \
  tmux \
  gnupg2 \
  gnupg-utils \
  nano \
  zip \
  xdotool \
  tar \
  unrar
