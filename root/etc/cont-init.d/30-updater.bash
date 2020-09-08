#!/usr/bin/with-contenv bash

# update packages
apt-get update
apt-get upgrade -y

# update SMA from git
git -C ${SMA_PATH} reset --hard HEAD
git -C ${SMA_PATH} pull origin master

# update pip3 requirements
pip3 install -r /usr/local/sma/setup/requirements.txt --upgrade --user

exit 0
