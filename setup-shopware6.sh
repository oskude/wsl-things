#!/usr/bin/bash

# assumptions
# - apache runs as this user (so we dont need to hassle with file modes)

# TODO arguments
# - http port
# - project name
# - with zip or git?

MY_USER="$USER"
MY_PROJECT_ROOT="$HOME"
MY_PROJECT_NAME="sw6zip"
MY_HTTP_PORT=2001
MY_HTTPD_PORT_FILE="/etc/apache2/ports.conf"
MY_HTTPD_VIRTHOST_DIR="/etc/apache2/sites-available"
MY_CACHE_DIR="$HOME/.cache/upwave"

MY_SHOPWARE_ZIP_URL="https://www.shopware.com/en/Download/redirect/version/sw6/file/install_v6.4.6.0_d9cbaace226440bf1b7107a4597f5e35f96ed763.zip"
MY_SHOPWARE_ZIP_FILE="${MY_SHOPWARE_ZIP_URL##*/}"

MY_PROJECT_ROOT=$(realpath "$MY_PROJECT_ROOT")
MY_PROJECT_DIR="${MY_PROJECT_ROOT}/${MY_PROJECT_NAME}"
MY_DOCROOT="${MY_PROJECT_DIR}/public"

MY_PKGS=(
	php-curl
	php-xml
	php-gd
	php-intl
	php-json
	php-mbstring
	php-mysql
	php-zip
	unzip
	jq
)

echo "### Install Packages ########################################################"

sudo apt install -y ${MY_PKGS[*]}

echo "### Get Shopware Files ######################################################"

mkdir -p "$MY_CACHE_DIR"

if [[ -e "${MY_CACHE_DIR}/${MY_SHOPWARE_ZIP_FILE}" ]]
then
	echo "### ${MY_CACHE_DIR}/${MY_SHOPWARE_ZIP_FILE} already exists, skipping download..."
else
	cd "$MY_CACHE_DIR"
		curl -LO "$MY_SHOPWARE_ZIP_URL"
	cd -
fi

echo "### Setup Shopware Files ####################################################"

if [[ -e "$MY_PROJECT_DIR" ]]
then
	echo "### $MY_PROJECT_DIR already exists, skipping setup..."
else
	mkdir -p "$MY_PROJECT_DIR"
	cd "$MY_PROJECT_DIR"
		unzip "${MY_CACHE_DIR}/${MY_SHOPWARE_ZIP_FILE}"
	cd -
fi

echo "### Setup Apache Server #####################################################"

if ! grep -Fxq "Listen ${MY_HTTP_PORT}" "$MY_HTTPD_PORT_FILE"
then
	echo "Listen ${MY_HTTP_PORT}" | sudo tee -a "$MY_HTTPD_PORT_FILE" >/dev/null
fi

sudo tee "${MY_HTTPD_VIRTHOST_DIR}/${MY_PROJECT_NAME}.conf" >/dev/null <<-EOF
	<VirtualHost *:$MY_HTTP_PORT>
	  DocumentRoot "${MY_PROJECT_DIR}/public"
	  <Directory "${MY_PROJECT_DIR}/public">
	    Require all granted
	    AllowOverride All
	  </Directory>
	</VirtualHost>
EOF

sudo a2ensite "$MY_PROJECT_NAME"
sudo service apache2 restart

echo "### Setup MySQL Database ####################################################"

sudo mysql <<-EOF
	CREATE USER IF NOT EXISTS '$MY_PROJECT_NAME'@'localhost' IDENTIFIED BY '$MY_PROJECT_NAME';
	CREATE DATABASE IF NOT EXISTS $MY_PROJECT_NAME;
	GRANT ALL ON $MY_PROJECT_NAME.* TO '$MY_PROJECT_NAME'@'localhost';
EOF
