#!/bin/sh

set -e

# Set a config value into sssd.conf
# $1 : the name of the config to set
# $2 : the value of the config
setSSSDConfig() {
  sed -i "s|${1}|${2}|" /etc/sssd/sssd.conf
}

# Uncommet a config value into sssd.conf
# $1 : the name of the config option to uncomment
enableSSSDConfig() {
  sed -i "s|^#${1}|${1}|" /etc/sssd/sssd.conf
}

# Set permanents configs
setSSSDConfig 'LDAP_URI' "${LDAP_URI}"
setSSSDConfig 'LDAP_BASE_ROOT' "${LDAP_BASE}"
setSSSDConfig 'LDAP_TLS_STARTTLS' "${LDAP_TLS_STARTTLS}"

# Set LDAP base for users entities is set
if [ -n "$LDAP_BASE_USER" ]; then
  enableSSSDConfig ldap_user_search_base
  setSSSDConfig 'LDAP_BASE_USER' "${LDAP_BASE_USER}"
fi

# Configure authentication of sssd ldap client if needed
if [ -n "$LDAP_BIND_USER" -a -n "$LDAP_BIND_PWD" ]; then
  enableSSSDConfig ldap_default_bind_dn
  setSSSDConfig 'LDAP_BIND_USER' "${LDAP_BIND_USER}"
  enableSSSDConfig ldap_default_authtok
  setSSSDConfig 'LDAP_BIND_PWD' "${LDAP_BIND_PWD}"
  enableSSSDConfig  ldap_default_authtok_type
fi

# configure the path to the server's certificate authority
if [ -n "$LDAP_TLS_CACERT" ]; then
  enableSSSDConfig ldap_tls_cacert
  setSSSDConfig 'LDAP_TLS_CACERT' "${LDAP_TLS_CACERT}"
fi

# Configure LDAP client's certificate if needed
if [ -n "$LDAP_TLS_CERT" -a -n "$LDAP_TLS_KEY" ]; then
  enableSSSDConfig ldap_tls_cert
  setSSSDConfig 'LDAP_TLS_CERT' "${LDAP_TLS_CERT}"
  enableSSSDConfig ldap_tls_key
  setSSSDConfig 'LDAP_TLS_KEY' "${LDAP_TLS_KEY}"
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
