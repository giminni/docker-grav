#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Add ${GRAV_USER} to sudoers list..."
echo "${GRAV_USER}    ALL=(ALL:ALL) ALL" > /etc/sudoers.d/${GRAV_USER}
chmod 400 /etc/sudoers.d/${GRAV_USER}
echo "Setting SSH file ownership for user ${GRAV_USER}..."
cat /home/${GRAV_USER}/.ssh/id_rsa.pub >> /home/${GRAV_USER}/.ssh/authorized_keys
chmod 400 /home/${GRAV_USER}/.ssh/id_rsa
chmod 600 /home/${GRAV_USER}/.ssh/id_rsa.pub
chmod 600 /home/${GRAV_USER}/.ssh/authorized_keys
chown -R ${GRAV_USER}:${GRAV_USER} /home/${GRAV_USER}/.ssh

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"