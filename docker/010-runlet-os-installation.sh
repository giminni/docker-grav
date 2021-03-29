#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Installing tools & dependencies..."
rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
apt update
apt upgrade -y
apt install -y --no-install-recommends \
    ca-certificates \
    openssl \
    dropbear \
    openssh-client \
    iputils-ping \
    jq \
    net-tools \
    sudo \
    tree \
    wget \
    unzip \
    ccache \
    cron \
    g++ \
    git \
    vim \
    rsync \
    zip \
    dnsutils \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libpq-dev \
    libyaml-dev \
    libzip4 \
    libzip-dev \
    zlib1g-dev \
    libicu-dev

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"
