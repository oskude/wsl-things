# WSL Notes

- I assume `wsl --install` has to be done only once per **machine**
  - Note that it does more than just `wsl --install -d Ubuntu`
- Distros installed with `wsl --install -d ...` are only for that user
- Ports on same machine are shared. (yet you can start on same port, and first one is served. And if you close first server, the second server is served!)
- We can serve on ports below 1024 without windows admin rights

TODO
- Do we have to shutdown wsl? (before shutting down computer)
- Does it matter if we put webapp files in `/mnt/c/Users/<winuser>` or `/home/<linuser>`?
- Windows 11 Build 22000 or higher https://docs.microsoft.com/en-us/windows/wsl/tutorials/gui-apps

# WSL2 Initial Setup

https://docs.microsoft.com/en-us/windows/wsl/install

> NOTE: WSL2 requires Windows 10 Version 1903 or higher, with Build 18362 or higher

> TIP: To get automatic updates for WSL Kernel, enable "Receive updates for other Microsoft products when you update Windwos" in "Advanced Windows Update options"

1. Start PowerShell as Administrator
   1. Run `wsl --install`
1. Reboot
1. Login with same windows user
1. A "Ubuntu Terminal" with `Installing, this may take few minutes...` appears
   1. When done, asks to create a linux user/pass.
   1. Running `cat /proc/version` should show `...WSL2...`
   1. Exit with `exit`
1. Install [Windows Terminal] from MS-Store
   - TODO: How do we install it for ALL users?
1. Start [Windows Terminal]
   1. Running `wsl --status` should show `Default Version: 2`
   1. Exit with `exit`
1. Reboot

# Install Ubuntu as normal user

1. Install [Windows Terminal] from MS-Store
   - TODO: How do we install it for ALL users?
1. Start [Windows Terminal]
   1. Run `wsl --set-default-version 2`
   1. Running `wsl --status` should show `Default Version: 2`
   1. Run `wsl --install -d Ubuntu`
   1. A "Ubuntu Terminal" with `Installing, this may take few minutes...` appears
      1. When done, asks to create a linux user/pass.
      1. Running `cat /proc/version` should show `...WSL2...`
      1. Exit all terminals with `exit`

If `wsl` installed with version 1:

```
PS> wsl -l -v
  NAME       STATE        VERSION
* Ubuntu     Stopped      1
```

Convert it to version 2 with:

```
PS> wsl --set-version Ubuntu 2
```

# Start/Login to Ubuntu

1. Start [Windows Terminal]
1. Select [Ubuntu] from drop-down menu

# Update Ubuntu

```
$ sudo apt update
$ sudo apt upgrade
$ exit
```

Start a new PS shell, and run
```
PS> wsl --terminate Ubuntu
```

# Edit Linux Files from Windows

https://devblogs.microsoft.com/commandline/do-not-change-linux-files-using-windows-apps-and-tools/

## Vanilla

- use path `\\wsl$\Ubuntu` to access all the files in Ubuntu
   - BUT apparently you cannot change system files without windows-admin rights?
- You can safely change your user files at `\\wsl$\Ubuntu\home\<youruser>`

## Visual Studio Code Extension

1. Install extension [Remote - WSL]
1. In linux shell run `code /etc/apache2/ports.conf`?
   - Installs a "VS Code Server" in linux users home
1. TODO: access denied, so only works for user files

# Edit Windows files from Linux

- Your Windows drives are at `/mnt/` eg. `/mnt/c`

# Install Apache HTTP Server
```
$ sudo apt install apache2
```

# Apache HTTPD Test 1 : Are ports shared?

1. Login as normal Windows-User1
   1. Start [Windows Terminal]
   1. Select [Ubuntu] from drop-down menu
   1. Start Apache HTTPD service
      ```
      $ sudo service apache2 start
      ```
      > (WOW! it runs on port 80 without windows admin rights!?)
   1. Edit default html page
      ```
      $ echo "page of user 1" | sudo tee /var/www/html/index.html
      ```
   1. Open http://localhost in browser
1. Login as normal Windows-User2 (leave Windows-User1 logged in!)
   1. Open http://localhost in browser, and we get the same page!


# Apache HTTPD Test 2 : What happens if 2 Apaches want to start on same port?

1. Login as normal Windows-User1
   1. Start [Windows Terminal]
   1. Select [Ubuntu] from drop-down menu
   1. Start Apache HTTPD service
      ```
      $ sudo service apache2 start
      ```
   1. Open http://localhost in browser and we see "page of user 1"
1. Login as normal Windows-User2 (leave Windows-User1 logged in!)
   1. Start [Windows Terminal]
   1. Select [Ubuntu] from drop-down menu
   1. Start Apache HTTPD service
      ```
      $ sudo service apache2 start
      ```
      > WOW! it starts!?
   1. Edit default html page
      ```
      $ echo "page of user 2" | sudo tee /var/www/html/index.html
      ```
   1. Open http://localhost in browser, and we get "page of user 1"
1. Login back to normal Windows-User1 (leave Windows-User2 logged in!)
   1. Stop Apache HTTPD service
      ```
      $ sudo service apache2 stop
      ```
   1. Open http://localhost in browser, and we get "page of user 2"

# Shopware 6 Development Test 1: Release zip file

```
$ ./init-ubuntu.sh
$ ./setup-shopware6.sh
```

open http://localhost:2001 in browser

> setting `APP_ENV="dev"` in `.env` also works!

> `./bin/build-storefront.sh` also works!

# Shopware 6 Development Test 2: Development git repo

```
$ ./setup-composer.sh
$ exit
```

Login back to wsl and run:

https://developer.shopware.com/docs/guides/installation/docker

```
$ sudo service docker start
$ cd ~
$ git clone https://github.com/shopware/development sw6dev
$ cd sw6dev
$ ./psh.phar docker:start
$ ./psh.phar docker:ssh
$ ./psh.phar install
$ exit
```

open http://localhost:8000 in browser

when done, stop all the docker containers
```
$ ./psh.phar docker:stop
```

> TODO: how do we change all the ports (that would intefer in multi-user setup)?
