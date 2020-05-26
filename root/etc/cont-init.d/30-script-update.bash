#!/usr/bin/with-contenv bash

# update from git
if [[ "${UPDATE_EXT}" == "TRUE" ]]; then
    git -C ${SABSCRIPTS_PATH} reset --hard HEAD && \
    git -C ${SABSCRIPTS_PATH} pull origin master
fi

# update from git
if [[ "${UPDATE_SMA}" == "TRUE" ]]; then
    git -C ${SMA_PATH} reset --hard HEAD && \
    git -C ${SMA_PATH} pull origin master
fi

# update pip3 requirements
pip3 install -r /usr/local/sma/setup/requirements.txt --upgrade --user

exit 0
