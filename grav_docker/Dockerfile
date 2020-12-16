# syntax=docker/dockerfile:1.2

# Read the README.md file for instructions
FROM php:7.4-apache AS build

LABEL MAINTAINER="Giovanni Minniti <minniti@t-online.de> (@giminni)"

ARG PATH \
    LANG \
    LC_ALL \
    TZ \
    TERM \
    CCACHE_DIR \
    CACHE_DIR \
    CACHE_USER \
    CACHE_HOST \
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

ENV PATH="${PATH:-"/var/www/html/bin:$PATH"}" \
    LANG="${LANG:-"C.UTF-8"}" \
    LC_ALL="${LC_ALL:-"C.UTF-8"}" \
    TZ="${TZ:-"Europe/Berlin"}" \
    TERM="${TERM:-"xterm-256color"}" \
    CCACHE_DIR="${CCACHE_DIR:-"/tmp/cache/.ccache"}" \
    CACHE_DIR="${CACHE_DIR:-"/home/rpiadmin/Workspace/docker-grav"}" \
    CACHE_USER="${CACHE_USER:-"rpiadmin"}" \
    CACHE_HOST="${CACHE_HOST:-"172.17.0.1"}" \
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

COPY ./grav_rootfs/* /
# COPY docker-entrypoint.sh /entrypoint.sh

RUN set -eux; \    
    echo "[STAGE] Apache configuration..."; \
    echo "Setting apache modules and rewrites..."; \
    a2enmod rewrite expires; \
    sed -i 's/ServerTokens OS/ServerTokens ProductOnly/g' \
    /etc/apache2/conf-available/security.conf;

RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,id=apt,target=/var/cache/apt \
    --mount=type=cache,id=apt,target=/var/lib/apt \
    set -eux; \
    echo "[STAGE] OS installation..."; \
    echo "Installing tools & dependencies..."; \
    apt update; \
    apt upgrade -y; \
    apt install -y --no-install-recommends \
        ca-certificates \
        openssl \
        openssh-server \
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
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpq-dev \
        libyaml-dev \
        libzip4 \
        libzip-dev \
        zlib1g-dev \
        libicu-dev;

RUN set -eux; \    
    echo "[STAGE] User ${GRAV_USER} installation..."; \
    echo "Adding user and group ${GRAV_USER}..."; \
    groupadd --gid ${GRAV_GID} ${GRAV_USER}; \
    useradd \
    --create-home \
    --shell ${GRAV_SHELL} \
    --uid ${GRAV_UID} \
    --gid ${GRAV_GID} \
    --home-dir /home/${GRAV_USER} \
    --comment "Standard SSH user (DO NOT REMOVE)" \
    ${GRAV_USER}; \
    echo "Adding ${GRAV_USER} to user group www-data..."; \
    usermod -a -G www-data ${GRAV_USER}; \
    echo "Creating ${GRAV_USER} SSH directory..."; \
    mkdir -vp /home/${GRAV_USER}/.ssh; \
    touch /home/${GRAV_USER}/.ssh/known_hosts; \
    touch /home/${GRAV_USER}/.ssh/authorized_keys; \
    ssh-keyscan -t rsa github.com >> /home/${GRAV_USER}/.ssh/known_hosts; \
    echo "Changing ownership to ${GRAV_USER}"; \
    chown -R ${GRAV_USER}:${GRAV_USER} /home/${GRAV_USER};

RUN --mount=type=secret,id=grav_pwd.key,mode=400,required=true \
    cat /run/secrets/grav_pwd.key | chpasswd -e;

RUN --mount=type=secret,id=grav_rsa,mode=400 \
    cat /run/secrets/grav_rsa > /home/${GRAV_USER}/.ssh/id_rsa;

RUN --mount=type=secret,id=grav_rsa.pub,mode=600 \
    cat /run/secrets/grav_rsa.pub > /home/${GRAV_USER}/.ssh/id_rsa.pub;

RUN set -eux; \
    echo "[STAGE] User ${GRAV_USER} configuration..."; \
    echo "Setting SSH file ownership for user ${GRAV_USER}..."; \
    cat /home/${GRAV_USER}/.ssh/id_rsa.pub >> /home/${GRAV_USER}/.ssh/authorized_keys; \
    chmod 400 /home/${GRAV_USER}/.ssh/id_rsa; \
    chmod 600 /home/${GRAV_USER}/.ssh/id_rsa.pub; \
    chmod 600 /home/${GRAV_USER}/.ssh/authorized_keys; \
    chown -R ${GRAV_USER}:${GRAV_USER} /home/${GRAV_USER}/.ssh;

RUN set -eux; \
    echo "[STAGE] OS configuration..."; \
    echo "Setting timezone to ${TZ}..."; \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime; \
    echo "Configuring Ccache tool..."; \
    /usr/sbin/update-ccache-symlinks; \
    for PROG in $(ls /usr/lib/ccache); do ln -s $(which ccache) /usr/local/bin/${PROG}; done; \
    echo "Downloading cached packages from global cache repository..."; \
    rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}/.ccache ${CCACHE_DIR%/*};

RUN set -eux; \
    echo "[STAGE] PHP installation..."; \
    echo "Installing PHP extensions..."; \
    docker-php-ext-install opcache pdo pdo_mysql pdo_pgsql pgsql; \
    docker-php-ext-configure intl; \
    docker-php-ext-install intl; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j$(nproc) gd; \
    docker-php-ext-install zip; \
    pecl install apcu yaml-2.0.4; \
    docker-php-ext-enable apcu yaml; \
    pear config-set php_ini /usr/local/etc/php/conf.d/php-recommended.ini; \
    pecl install xdebug;

RUN set -eux; \
    echo "[STAGE] PHP configuration..."; \
    echo "Setting recommended PHP.ini values..."; \
    { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'upload_max_filesize=128M'; \
    echo 'post_max_size=128M'; \
    echo 'expose_php=off'; \
    echo ''; \
    echo '[XDebug]'; \
    echo 'xdebug.remote_enable=1'; \
    echo 'xdebug.remote_autostart=1'; \
    } > /usr/local/etc/php/conf.d/php-recommended.ini

RUN set -eux; \
    echo "[STAGE] Grav installation..."; \
    echo "Installing ${GRAV_URLFILE}..."; \
    test -f /tmp/${GRAV_URLFILE} || wget --progress=bar:force \
        -O /tmp/${GRAV_URLFILE} \
        ${GRAV_URL}; \
    cd /var/www; \
    rm -rf /var/www/html;\
    unzip /tmp/${GRAV_URLFILE}; \
    echo "Creating symlink for URL access..."; \
    ln -s /var/www/${GRAV_NAME} /var/www/html; \
    echo "Exporting ${GRAV_NAME} path to users..."; \
    echo "export PATH=/var/www/html/bin:${PATH}" >> /home/${GRAV_USER}/.bashrc; \
    echo "export PATH=/var/www/html/bin:${PATH}" >> /root/.bashrc; \
    echo "Create cron job for Grav maintenance scripts for www-data..."; \
    echo "* * * * * cd /var/www/${GRAV_NAME}; /usr/local/bin/php bin/grav scheduler 1>>/dev/null 2>&1" | crontab -u www-data -;

RUN set -eux; \    
    echo "[STAGE] OS configuration..."; \
    echo "Setting ownership to www-data..."; \
    chown -R www-data:www-data /var/www/; \
    echo "Setting composer link..."; \
    ln -s /var/www/html/bin/composer-phar /var/www/html/bin/composer; \
    echo "Creating run directory for SSH daemon..."; \ 
    mkdir -vp /run/sshd; \
    echo "Downloading su-exec..."; \
    test -f /tmp/${GRAV_SUEXEC_FILE} || wget --progress=bar:force \
        -O /tmp/${GRAV_SUEXEC_FILE} \
    ${GRAV_SUEXEC_URL}/${GRAV_SUEXEC_FILE}; \
    echo "Compiling su-exec..."; \
    gcc -Wall /tmp/${GRAV_SUEXEC_FILE} -o /usr/local/bin/su-exec;

RUN set -eux; \
    echo "Uploading compiled files to global cache repository"; \
    rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
       ${CCACHE_DIR} ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}; \
    echo "[STAGE] Cleanup installation..."; \
    echo "Removing installation artefacts..."; \
    apt autoremove -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /tmp/*;

WORKDIR /var/www/html

VOLUME ["/var/www/html"]

EXPOSE 22 80 443

# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["apache2-foreground"]
# CMD ["bash"]
CMD ["sh", "-c", "/usr/sbin/sshd && cron && apache2-foreground"]
# CMD ["/usr/local/bin/su-exec", "grav", "sh", "-c", "/usr/sbin/sshd && cron && apache2-foreground"]
