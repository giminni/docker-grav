#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Adding user and group ${GRAV_USER}..."
groupadd --gid ${GRAV_GID} ${GRAV_USER}
useradd \
     --create-home \
     --shell ${GRAV_SHELL} \
     --uid ${GRAV_UID} \
     --gid ${GRAV_GID} \
     --home-dir /home/${GRAV_USER} \
     --comment "Standard SSH user (DO NOT REMOVE)" \
${GRAV_USER}
echo "Adding ${GRAV_USER} to user group www-data and tty..."
usermod -a -G www-data,tty ${GRAV_USER}
echo "Creating ${GRAV_USER} SSH directory..."
mkdir -vp /home/${GRAV_USER}/.ssh
touch /home/${GRAV_USER}/.ssh/known_hosts
touch /home/${GRAV_USER}/.ssh/authorized_keys
ssh-keyscan -t rsa github.com >> /home/${GRAV_USER}/.ssh/known_hosts
echo "Changing ownership to ${GRAV_USER}"
chown -R ${GRAV_USER}:${GRAV_USER} /home/${GRAV_USER}

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"
