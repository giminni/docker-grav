# syntax=docker/dockerfile:1.2

# Read the README.md file for multi-architecture instructions
FROM --platform=${BUILDPLATFORM} php:7.4-apache AS build

# If needed, add here labels
LABEL MAINTAINER="Giovanni Minniti <minniti@t-online.de> (@giminni)"

# Allow docker buildx build arguments to be overridden at buildtime.
# The first two arguments are reserved for docker buildx builder.
ARG \
    BUILDPLATFORM \
    TARGETPLATFORM \
    DEBIAN_FRONTEND \
    PATH \
    LANG \
    LC_ALL \
    TZ \
    TERM \
    CACHE_USER \
    CACHE_HOST \
    CCACHE_DIR \
    PHPCACHE_DIR \
    CACHE_DIR \
    GRAV_NAME \
    GRAV_TAG \
    GRAV_USER \
    GRAV_KIND \
    GRAV_URLFILE \
    GRAV_URL \
    GRAV_UID \
    GRAV_GID \
    GRAV_SHELL \
    DEHYDRATED_VER \
    DEHYDRATED_FILE \
    DEHYDRATED_URL \
    GOCROND_VER \
    GOCROND_FILE \
    GOCROND_URL \
    SUEXEC_URL \
    SUEXEC_FILE \
    APACHE_RUN_USER \
    APACHE_RUN_GROUP \
    APACHE_LOG_DIR

# If available, override enviroment variables from docker build arguments, or
# pass it using runtime -env arguments, otherwise the default value are used.
ENV DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-"noninteractive"}" \ 
    PATH="${PATH:-"/var/www/html/bin:$PATH"}" \
    LANG="${LANG:-"C.UTF-8"}" \
    LC_ALL="${LC_ALL:-"C.UTF-8"}" \
    TZ="${TZ:-"Europe/Berlin"}" \
    TERM="${TERM:-"xterm-256color"}" \
    CACHE_USER="${CACHE_USER:-"rpiadmin"}" \
    CACHE_HOST="${CACHE_HOST:-"172.17.0.1"}" \
    CCACHE_DIR="${CCACHE_DIR:-"/tmp/cache/.ccache"}" \
    PHPCACHE_DIR="${PHPCACHE_DIR:-"/tmp/cache/.phpcache"}" \
    CACHE_DIR="${CACHE_DIR:-"/home/${CACHE_USER}/Workspace/docker-grav/cache"}" \
    GRAV_NAME="${GRAV_NAME:-"grav-admin"}" \
    GRAV_TAG=="${GRAV_TAG:-"latest"}" \
    GRAV_USER="${GRAV_USER:-"grav"}" \
    GRAV_KIND="${GRAV_KIND:-"core"}" \
    GRAV_URLFILE="${GRAV_URLFILE:-"${GRAV_NAME}-${GRAV_TAG}.zip"}" \
    GRAV_URL="${GRAV_URL:-"https://getgrav.org/download/${GRAV_KIND}/${GRAV_NAME}/${GRAV_TAG}"}" \
    GRAV_UID=${GRAV_UID:-1000} \
    GRAV_GID=${GRAV_GID:-1000} \
    GRAV_SHELL="${GRAV_SHELL:-"/bin/bash"}" \
    DEHYDRATED_VER="${DEHYDRATED_VER:-"0.7.0"}" \
    DEHYDRATED_FILE="${DEHYDRATED_FILE:-"dehydrated-${DEHYDRATED_VER}.tar.gz"}" \
    DEHYDRATED_URL="${DEHYDRATED_URL:-"https://github.com/dehydrated-io/dehydrated/releases/download"}" \
    GOCROND_VER="${GOCROND_VER:-"20.7.0"}" \
    GOCROND_FILE="${GOCROND_FILE:-"go-crond-64-linux"}" \
    GOCROND_URL="${GOCROND_URL:-"https://github.com/webdevops/go-crond/releases/download"}" \
    SUEXEC_URL="${SUEXEC_URL:-"https://raw.githubusercontent.com/ncopa/su-exec/master"}" \
    SUEXEC_FILE="${SUEXEC_FILE:-"su-exec.c"}" \
    APACHE_RUN_USER="${APACHE_RUN_USER:-${GRAV_USER}}" \
    APACHE_RUN_GROUP="${APACHE_RUN_GROUP:-${GRAV_USER}}" \
    APACHE_LOG_DIR="${APACHE_LOG_DIR:-"/tmp"}"

# Copy runlet stubs into /usr/local/bin directory
COPY docker/runlet-head.sh docker/runlet-tail.sh /usr/local/bin/

# Create local APT installation cache
RUN --mount=type=cache,id=apt,target=/var/cache/apt \
    --mount=type=cache,id=apt,target=/var/lib/apt;

# 010: Execute OS installation runlet
COPY docker/010-runlet-os-installation.sh /usr/local/bin/
RUN /usr/local/bin/010-runlet-os-installation.sh exec;

# 020: Execute OS configuration runlet
COPY docker/020-runlet-os-configuration.sh /usr/local/bin/
RUN /usr/local/bin/020-runlet-os-configuration.sh exec;

# 030: Execute Linux user installation runlet
COPY docker/030-runlet-user-installation.sh /usr/local/bin/
RUN /usr/local/bin/030-runlet-user-installation.sh exec;

# Install user secret file into the docker image
RUN --mount=type=secret,id=grav_pwd.key,mode=400,required=true \
    cat /run/secrets/grav_pwd.key | chpasswd -e;

# Install SSH secrets files into the docker image
RUN --mount=type=secret,id=grav_rsa,mode=400 \
    cat /run/secrets/grav_rsa > /home/${GRAV_USER}/.ssh/id_rsa;
RUN --mount=type=secret,id=grav_rsa.pub,mode=600 \
    cat /run/secrets/grav_rsa.pub > /home/${GRAV_USER}/.ssh/id_rsa.pub;

# 040: Execute user configuration runlet
COPY docker/040-runlet-user-configuration.sh /usr/local/bin/
RUN /usr/local/bin/040-runlet-user-configuration.sh exec;

# 050: Execute cache download runlet
COPY docker/050-runlet-cache-download.sh /usr/local/bin/
RUN /usr/local/bin/050-runlet-cache-download.sh exec;

# 060: Execute PHP installation runlet
COPY docker/060-runlet-php-installation.sh /usr/local/bin/
RUN /usr/local/bin/060-runlet-php-installation.sh exec;

# 070: Execute PHP configuration runlet
COPY docker/070-runlet-php-configuration.sh /usr/local/bin/
RUN /usr/local/bin/070-runlet-php-configuration.sh exec;

# Copy local grav core, skeletons, plugins into docker image
COPY rootfs/tmp/ /tmp/

# 080: Execute Grav installation runlet
COPY docker/080-runlet-grav-installation.sh /usr/local/bin/
RUN /usr/local/bin/080-runlet-grav-installation.sh exec;

# 090: Execute OS post installation runlet
COPY docker/090-runlet-post-configuration.sh /usr/local/bin/
RUN /usr/local/bin/090-runlet-post-configuration.sh exec;

# 100: Execute SSL installation runlet
COPY docker/100-runlet-ssl-installation.sh /usr/local/bin/
RUN /usr/local/bin/100-runlet-ssl-installation.sh exec;

# 110: Execute Apache configuration runlet
COPY docker/110-runlet-apache-configuration.sh /usr/local/bin/
RUN /usr/local/bin/110-runlet-apache-configuration.sh exec; 

# 120: Execute cache upload runlet
COPY docker/120-runlet-cache-upload.sh /usr/local/bin/
RUN /usr/local/bin/120-runlet-cache-upload.sh exec;

# 130: Execute Cleanup installation runlet
COPY docker/130-runlet-cleanup-installation.sh /usr/local/bin/
RUN /usr/local/bin/130-runlet-cleanup-installation.sh exec;

# Remove development artefacts
RUN \
    set -eux; \
    echo "Remove runlets, symlinks, but phar..."; \
    find /usr/local/bin -maxdepth 1 -type l | grep -vE "phar" | xargs -r rm -f; \
    rm -f /usr/local/bin/*runlet*;

# Set work directory
WORKDIR /var/www/html

# Define export data directory
VOLUME ["/var/www/html"]

# Expose network service ports
EXPOSE 22 80 443

# Define entrypoint for container
COPY docker/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# To debug at runtime enter 'bash' below or use --entrypoint 
# and exchange docker flag -d with -ti in docker run directive.
CMD ["init"]
