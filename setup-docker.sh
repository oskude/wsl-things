#!/usr/bin/bash
# we need this cause ubuntu 20.04 has too old docker things

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
sudo apt install ca-certificates curl gnupg lsb-release
if [[ -e "/usr/share/keyrings/docker-archive-keyring.gpg" ]]
then
	echo "### /usr/share/keyrings/docker-archive-keyring.gpg already exists, skipping download..."
else
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
fi
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli

# https://docs.docker.com/compose/install/
if [[ -e "/usr/local/bin/docker-compose" ]]
then
	echo "### /usr/local/bin/docker-compose already exists, skipping download..."
else
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
fi

sudo gpasswd -a $USER docker
echo "### Re-login to run docker as normal user"
