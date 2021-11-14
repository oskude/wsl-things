#!/usr/bin/bash

# what this does
# - install basic php webdev packages
# - install up to date composer and nodejs
# - clear apache ports (TODO: suboptimal)
# - setup apache to run vhosts as current user

MY_USER="$USER"
MY_PHP_CONF_FILE="/etc/php/7.4/apache2/php.ini"
MY_SUDOERS_DIR="/etc/sudoers.d"
MY_APACHE_PORTS_FILE="/etc/apache2/ports.conf"
MY_APACHE_CONF_AVAIL_DIR="/etc/apache2/conf-available"

MY_PKGS=(
	git
	php-cli
	apache2
	libapache2-mod-php
	libapache2-mpm-itk
	mysql-server
	nodejs
)

echo "### Install Non Repo Tools ##################################################"

# cause composer in ubuntu 20.04 is too old
if [[ -e /usr/local/bin/composer ]]
then
	echo "### /usr/local/bin/composer already exists, skipping download..."
else
	sudo curl -Lo /usr/local/bin/composer https://getcomposer.org/download/latest-stable/composer.phar
	sudo chmod +x /usr/local/bin/composer
fi

echo "### Add Extra Repos #########################################################"

# cause nodejs in ubuntu 20.04 is too old
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -

echo "### Install Packages ########################################################"

sudo apt install -y ${MY_PKGS[*]}

echo "### Initialize Apache #######################################################"

# TODO: i dont like this... BUT we do NOT want to have default ports there!
# ALSO: we cannot start apache if ports.conf is empty!
sudo cp /dev/null "$MY_APACHE_PORTS_FILE"

# TODO: too "dangerous"?
#echo "$MY_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "${MY_SUDOERS_DIR}/${MY_USER}"

sudo tee "${MY_APACHE_CONF_AVAIL_DIR}/runasuser.conf" >/dev/null <<-EOF
	<IfModule mpm_itk_module>
	  AssignUserId $MY_USER $MY_USER
	</IfModule>
EOF
sudo a2enconf runasuser

sudo a2enmod rewrite

echo "### Initialize PHP ##########################################################"

sudo sed -i '/^ *memory_limit/s/=.*/= 512M/' "$MY_PHP_CONF_FILE"
sudo sed -i '/^ *upload_max_filesize/s/=.*/= 6M/' "$MY_PHP_CONF_FILE"

echo "### Initialize MySQL ########################################################"

# TODO: set mysql port!!!!

# NOTE: root login works only with `sudo mysql`
# AND THIS DOES JACK SHIT:
#sudo mysql_secure_installation
