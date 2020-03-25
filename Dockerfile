FROM stilliard/pure-ftpd

ENV FTP_USER=qpsdemo \
    FTP_PASSWORD=qpsdemo \
    FTP_HOME_DIRECTORY=/share/ftp \
    PASV_PORT_MIN=30000 \
    PASV_PORT_MAX=30009 \
    CONTAINER_USER_UID=ftpuser \
    MAX_CLIENTS_NUMBER=50 \
    MAX_CLIENTS_PER_IP=10 \
    DOWNLOAD_LIMIT_KB=0 \
    UPLOAD_LIMIT_KB=0 \
    MAX_SIMULTANEOUS_SESSIONS=0 \
    LOG_ENABLED=0

COPY run.sh /pure-ftpd/run.sh
RUN chmod u+x /pure-ftpd/run.sh

RUN chmod -R a+rw /share/ftp/

CMD ["/pure-ftpd/run.sh"] 
