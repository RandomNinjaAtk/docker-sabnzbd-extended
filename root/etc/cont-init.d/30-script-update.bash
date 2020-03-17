#!/usr/bin/with-contenv bash

# update from git
if [[ "${UPDATE}" == "true" ]]; then
    git -C ${SABSCRIPTS_PATH} pull origin master && \
    git -C ${SMA_PATH} pull origin master
fi

exit 0
