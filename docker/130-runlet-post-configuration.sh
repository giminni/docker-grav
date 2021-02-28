#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Setting ownership to ${GRAV_USER}..."
chown -R ${GRAV_USER}:${GRAV_USER} /var/www/
echo "Setting composer link..."
ln -s /var/www/html/bin/composer-phar /var/www/html/bin/composer
echo "Creating run directory for SSH daemon..."
mkdir -vp /run/sshd
echo "Downloading ${SUEXEC_FILE} file..."
test -f /tmp/${SUEXEC_FILE} || wget -q --show-progress --progress=bar:force \
    -O /tmp/${SUEXEC_FILE} \
${SUEXEC_URL}/${SUEXEC_FILE}
echo "Compiling ${SUEXEC_FILE} file..."
gcc -Wall /tmp/${SUEXEC_FILE} -o /usr/local/bin/su-exec
echo "Changing dropbear permission for user ${GRAV_USER}..."
chown -R ${GRAV_USER}:${GRAV_USER} /etc/dropbear
echo "Downloading ${GOCROND_FILE} file..."
test -f /tmp/${GOCROND_FILE} || wget -q --show-progress --progress=bar:force \
    -O /usr/local/bin/gocrond \
${GOCROND_URL}/${GOCROND_VER}/${GOCROND_FILE}
chmod +x /usr/local/bin/gocrond
echo "Create cron job for Grav maintenance scripts for ${GRAV_USER}..."
#echo "* * * * * cd /var/www/${GRAV_NAME}; /usr/local/bin/php bin/grav scheduler 1>>/dev/null 2>&1" | crontab -u ${GRAV_USER} -
echo "* * * * * cd /var/www/${GRAV_NAME}; /usr/local/bin/php bin/grav scheduler 1>/dev/null 2>&1" | crontab -u ${GRAV_USER} -
echo "Copy ${GRAV_USER} crontab file to ${GRAV_USER} home directory..."
cp /var/spool/cron/crontabs/"${GRAV_USER}" /home/"${GRAV_USER}"/crontab
chown "${GRAV_USER}":"${GRAV_USER}" /home/"${GRAV_USER}"/crontab
echo "Add vim solarized8 theme for root and ${GRAV_USER}..."
mkdir -p /home/"${GRAV_USER}"/.vim/colors
mkdir -p /root/.vim/colors
git clone https://github.com/lifepillar/vim-solarized8.git \
    /tmp/vim/pack/themes/opt/solarized8
cp /tmp/vim/pack/themes/opt/solarized8/colors/solarized8.vim \
    /home/"${GRAV_USER}"/.vim/colors
cp /tmp/vim/pack/themes/opt/solarized8/colors/solarized8.vim \
    /root/.vim/colors
cat <<-"EOF" > /root/.vimrc
syntax enable
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=0
let g:solarized_degrade=0
let g:solarized_bold=1
let g:solarized_underline=1
let g:solarized_italic=1
let g:solarized_contrast="high"
let g:solarized_visibility="high"
colorscheme solarized8
EOF
cp /root/.vimrc /home/"${GRAV_USER}"/.vimrc
chown -R "${GRAV_USER}":"${GRAV_USER}" /home/"${GRAV_USER}"/.vim
chown "${GRAV_USER}":"${GRAV_USER}" /home/"${GRAV_USER}"/.vimrc

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"