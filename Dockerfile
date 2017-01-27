FROM debian:jessie
MAINTAINER Pierre GINDRAUD <pgindraud@gmail.com>

ENV LDAP_URI=ldap://ldap.host.net/ \
    LDAP_BASE=dc=example,dc=com \
    LDAP_TLS_STARTTLS=false \
    LDAP_HOMEDIR=%u \
    LDAP_ATTR_SSHPUBLICKEY=sshPublicKey \
    SFTP_CHROOT=/data
#   LDAP_BASE_USER=cn=users,dc=example,dc=com
#   LDAP_BASE_GROUP=cn=groups,dc=example,dc=com
#   LDAP_BIND_USER=cn=sssd,dc=example,dc=net
#   LDAP_BIND_PWD=xxxxxxxx
#   LDAP_TLS_CACERT=/etc/ssl/ca.crt
#   LDAP_TLS_CERT=/etc/ssl/cert.crt
#   LDAP_TLS_KEY=/etc/ssl/cert.key

# Install dependencies
RUN apt-get update && apt-get install -y \
    libnss-sss \
    libpam-sss \
    openssh-server \
    openssh-sftp-server \
    sssd-ldap \
    supervisor && \

# clean dependencies
    apt-get autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* && \
# remove default debian keys
    rm -f /etc/ssh/ssh_host_*key* && \
    mkdir /var/run/sshd && chmod 0755 /var/run/sshd && \
# prepare data dir
    mkdir -p /data && \
# configure sshd
    sed -i 's|^AuthorizedKeysFile|#AuthorizedKeysFile|' /etc/ssh/sshd_config && \
    echo 'AuthorizedKeysFile /dev/null' >> /etc/ssh/sshd_config && \
    echo 'AuthorizedKeysCommandUser nobody' >> /etc/ssh/sshd_config && \
    echo 'AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys' >> /etc/ssh/sshd_config && \
    sed -i 's|sftp-server$|sftp-server -e -u 002|' /etc/ssh/sshd_config && \
    echo 'ForceCommand internal-sftp' >> /etc/ssh/sshd_config && \
    echo 'ChrootDirectory SFTP_CHROOT' >> /etc/ssh/sshd_config

# copy local files
COPY root/ /

RUN chown root:root /data && \
    chmod 755 /data && \
    chmod 600 /etc/sssd/sssd.conf && \
    chmod +x /start.sh

EXPOSE 22
VOLUME ["/data"]

CMD ["/start.sh"]
