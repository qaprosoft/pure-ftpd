#!/bin/sh

if [ "${LOG_ENABLED}" = "1" ]; then
    set -x
fi

echo "##############################################################################"
echo "Starting container"
echo "##############################################################################"

ADDED_OPTS=""

#
# Updating ftp user home permissions
#
if [ ! -d ${FTP_HOME_DIRECTORY} ]; then
    mkdir -p "${FTP_HOME_DIRECTORY}"
fi
chown -R ${CONTAINER_USER_UID}:${CONTAINER_GROUP_UID} ${FTP_HOME_DIRECTORY}

#
# Checking password file
#
if [ ! -f /etc/pure-ftpd/pureftpd.passwd ]; then
    echo "Password file not found.\nCreating initial virtual user ${FTP_USER}"
    echo "${FTP_PASSWORD}\n${FTP_PASSWORD}" \
        | pure-pw useradd ${FTP_USER} \
                -u ${CONTAINER_USER_UID} \
		-g ${CONTAINER_GROUP_UID} \
                -d ${FTP_HOME_DIRECTORY} \
                -t ${DOWNLOAD_LIMIT_KB} \
                -T ${UPLOAD_LIMIT_KB} \
                -y ${MAX_SIMULTANEOUS_SESSIONS}
else 
    echo "Using existing Password file."
fi

#
# Checking database file
#
if [ ! -f /etc/pure-ftpd/pureftpd.pdb ]; then
    echo "Database file not found.\nCreating database file."
    pure-pw mkdb
else
    echo "Using existing database file."
    (pure-pw show ${FTP_USER} | grep -v "Password")
fi

#
# Checking log status
#
if [ "${LOG_ENABLED}" = "1" ]; then
    echo "Pure-ftp log enabled."

    echo "Starting rsyslogd."
    rsyslogd

    ADDED_OPTS="--verboselog -O clf:/var/log/pure-ftpd/pureftpd-clf.log"
else
    echo "Pure-ftpd log disabled."
fi

echo "Using added opts '${ADDED_OPTS}'"

echo "Launching pure-ftpd server ..."
/usr/sbin/pure-ftpd \
                -c ${MAX_CLIENTS_NUMBER} -C ${MAX_CLIENTS_PER_IP} \
                -l puredb:/etc/pure-ftpd/pureftpd.pdb \
                -E -j -R \
                -P $PUBLICHOST \
                -p ${PASV_PORT_MIN}:${PASV_PORT_MAX} \
                -H \
                ${ADDED_OPTS}
