#!/usr/bin/with-contenv bash

# update from git
if [[ "${SMA_UPDATE}" == "true" ]]
then
    git -C ${SMA_PATH} pull origin master
fi

# permissions
chown -R abc:abc ${SMA_PATH}
chmod -R 775 ${SMA_PATH}/*.sh

# update autoprocess
python3 ${SMA_PATH}/update.py

exit $?
