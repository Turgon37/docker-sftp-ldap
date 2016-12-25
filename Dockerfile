FROM debian:jessie
MAINTAINER Pierre GINDRAUD <pgindraud@gmail.com>

ENV LDAP_URI ldap://ldap.host.net/
ENV LDAP_BASE dc=example,dc=com
#ENV LDAP_BASE_USER
#ENV LDAP_BIND_USER cn=sssd,dc=example,dc=net
#ENV LDAP_BIND_PWD xxxxxxxx

ENV LDAP_TLS_STARTTLS false
#ENV LDAP_TLS_CACERT /etc/ssl/ca.crt
#ENV LDAP_TLS_CERT /etc/ssl/cert.crt
#ENV LDAP_TLS_KEY /etc/ssl/cert.key

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server openssh-sftp-server sssd-ldap libnss-sss libpam-sss \
    supervisor && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd && chmod 0755 /var/run/sshd && \
    mkdir -p /data

COPY sssd.conf  /etc/sssd/sssd.conf
COPY supervisord.conf /etc/supervisord.conf
COPY start.sh /start.sh

RUN chown root:root /data && \
    chmod 755 /data && \
    chmod 600 /etc/sssd/sssd.conf && \
    chmod +x /start.sh

EXPOSE 22
VOLUME ['/data']

CMD ["/start.sh"]
