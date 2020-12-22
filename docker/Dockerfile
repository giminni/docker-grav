# syntax=docker/dockerfile:1.2

# Read the README.md file for multi-architecture instructions
FROM --platform=${BUILDPLATFORM} php:7.4-apache AS build

# If needed, add here labels
LABEL MAINTAINER="Giovanni Minniti <minniti@t-online.de> (@giminni)"

# If needed, pass docker arguments to builder instance.
# The first two arguments are reserved.
ARG \
    BUILDPLATFORM \
    TARGETPLATFORM \
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
    DEHYDRATED_VER \
    GRAV_NAME \
    GRAV_TAG \
    GRAV_USER \
    GRAV_KIND \
    GRAV_URLFILE \
    GRAV_URL \
    GRAV_SUEXEC_URL \
    GRAV_SUEXEC_FILE \
    GRAV_UID \
    GRAV_GID \
    GRAV_SHELL

# If available, override enviroment variables from docker build arguments
ENV PATH="${PATH:-"/var/www/html/bin:$PATH"}" \
    LANG="${LANG:-"C.UTF-8"}" \
    LC_ALL="${LC_ALL:-"C.UTF-8"}" \
    TZ="${TZ:-"Europe/Berlin"}" \
    TERM="${TERM:-"xterm-256color"}" \
    CACHE_USER="${CACHE_USER:-"rpiadmin"}" \
    CACHE_HOST="${CACHE_HOST:-"172.17.0.1"}" \
    CCACHE_DIR="${CCACHE_DIR:-"/tmp/cache/.ccache"}" \
    PHPCACHE_DIR="${PHPCACHE_DIR:-"/tmp/cache/.phpcache"}" \
    CACHE_DIR="${CACHE_DIR:-"/home/${CACHE_USER}/Workspace/docker-grav/cache"}" \
    DEHYDRATED_VER="${DEHYDRATED_VER:-"0.7.0"}" \
    GRAV_NAME="${GRAV_NAME:-"grav-admin"}" \
    GRAV_TAG=="${GRAV_TAG:-"latest"}" \
    GRAV_USER="${GRAV_USER:-"grav"}" \
    GRAV_KIND="${GRAV_KIND:-"core"}" \
    GRAV_URLFILE="${GRAV_URLFILE:-"${GRAV_NAME}-${GRAV_TAG}.zip"}" \
    GRAV_URL="${GRAV_URL:-"https://getgrav.org/download/${GRAV_KIND}/${GRAV_NAME}/${GRAV_TAG}"}" \
    GRAV_SUEXEC_URL="${GRAV_SUEXEC_URL:-"https://raw.githubusercontent.com/ncopa/su-exec/master"}" \
    GRAV_SUEXEC_FILE="${GRAV_SUEXEC_FILE:-"su-exec.c"}" \
    GRAV_UID=${GRAV_UID:-1000} \
    GRAV_GID=${GRAV_GID:-1000} \
    GRAV_SHELL="${GRAV_SHELL:-"/bin/bash"}"

# Copy runlet stubs into /usr/local/bin directory
COPY docker/runlet-head.sh docker/runlet-tail.sh /usr/local/bin/

# Create local APT installation cache
RUN --mount=type=cache,id=apt,target=/var/cache/apt \
    --mount=type=cache,id=apt,target=/var/lib/apt;

# Execute OS installation runlet
COPY docker/runlet-os-installation.sh /usr/local/bin/
RUN /usr/local/bin/runlet-os-installation.sh exec;

# Execute Linux user installation runlet
COPY docker/runlet-user-installation.sh /usr/local/bin/
RUN /usr/local/bin/runlet-user-installation.sh exec;

# Install user secret file into the docker image
RUN --mount=type=secret,id=grav_pwd.key,mode=400,required=true \
    cat /run/secrets/grav_pwd.key | chpasswd -e;

# Install SSH secrets files into the docker image
RUN --mount=type=secret,id=grav_rsa,mode=400 \
    cat /run/secrets/grav_rsa > /home/${GRAV_USER}/.ssh/id_rsa;
RUN --mount=type=secret,id=grav_rsa.pub,mode=600 \
    cat /run/secrets/grav_rsa.pub > /home/${GRAV_USER}/.ssh/id_rsa.pub;

# Execute user configuration runlet
COPY docker/runlet-user-configuration.sh /usr/local/bin/
RUN /usr/local/bin/runlet-user-configuration.sh exec;

# Execute OS configuration runlet
COPY docker/runlet-os-configuration.sh /usr/local/bin/
RUN /usr/local/bin/runlet-os-configuration.sh exec;

# Execute PHP installation runlet
COPY docker/runlet-php-installation.sh /usr/local/bin/
RUN /usr/local/bin/runlet-php-installation.sh exec;

# Execute PHP configuration runlet
COPY docker/runlet-php-configuration.sh /usr/local/bin/
RUN /usr/local/bin/runlet-php-configuration.sh exec;

# Copy local grav core, skeletons, plugins into docker image
COPY rootfs/tmp/ /tmp/

# Execute Grav installation runlet
COPY docker/runlet-grav-installation.sh /usr/local/bin/
RUN /usr/local/bin/runlet-grav-installation.sh exec;

# Execute OS post installation runlet
COPY docker/runlet-post-configuration.sh /usr/local/bin/
RUN /usr/local/bin/runlet-post-configuration.sh exec;

# Execute SSL installation runlet
COPY docker/runlet-ssl-installation.sh /usr/local/bin/
RUN /usr/local/bin/runlet-ssl-installation.sh exec;

# Execute Apache configuration runlet
COPY docker/runlet-apache-configuration.sh /usr/local/bin/
RUN /usr/local/bin/runlet-apache-configuration.sh exec; 

# Execute Cleanup installation runlet
COPY docker/runlet-cleanup-installation.sh /usr/local/bin/
RUN /usr/local/bin/runlet-cleanup-installation.sh noexec;

# Copy docker entrypoint before execution
# COPY docker-entrypoint.sh /usr/local/bin/

# Set work directory
WORKDIR /var/www/html

# Define export data directory
VOLUME ["/var/www/html"]

# Expose network service ports
EXPOSE 22 80 443

# Define entrypoint foil
# ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Define extra command line arguments
CMD ["sh", "-c", "/usr/sbin/sshd && cron && apache2-foreground"]

# Enable line below for debugging instead the above one
# CMD ["bash"]
