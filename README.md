# Docker SFTP over LDAP backend

[![](https://images.microbadger.com/badges/image/turgon37/sftp-ldap.svg)](https://microbadger.com/images/turgon37/sftp-ldap "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/turgon37/sftp-ldap.svg)](https://microbadger.com/images/turgon37/sftp-ldap "Get your own version badge on microbadger.com")

This image contains a instance of sshd configured as SFTP server only and a SSSD configured to run as a ldap client.

### Example of usage

You can use it to allow you owncloud/nextcloud instance to mount the user's home folder from a secure SFTP, that is bind to the central LDAP server for passwords.

## Docker Informations

   * This port is available on this image

| Port              | Usage                 |
| ----------------- | ---------------       |
| 22                | SFTP port             |

   * This volume is bind on this image

| Volume| Usage                                                 |
| ----- | ----------------------------------------------------- |
| /data | The data path, and the root folder of the SFTP server |


  * This image takes theses environnements variables as parameters


| Environnement          | Usage                                                                                             |
| ---------------------- | ------------------------------------------------------------------------------------------------- |
| LDAP_URI   (mandatory) | The LDAP uri (uris) of the server(s)                                                              |
| LDAP_BASE   (mandatory)| The LDAP base for search                                                                          |
| LDAP_BASE_USER         | The LDAP base DN specific for users accounts objects                                              |
| LDAP_BASE_GROUP        | The LDAP base DN specific for groups accounts objects                                             |
| LDAP_BIND_USER         | The bind DN of to access to LDAP server                                                           |
| LDAP_BIND_PWD          | The bind password                                                                                 |
| LDAP_TLS_STARTTLS      | Should the LDAP client must use a starttls connection ? (true/false) false by default             |
| LDAP_TLS_CACERT        | The path to the CA.crt (don't forget to mount it with docker -v)                                  |
| LDAP_TLS_CERT          | The path to the client certificate if exists                                                      |
| LDAP_TLS_KEY           | The path to the client private key if exists                                                      |
| LDAP_ATTR_SSHPUBLICKEY | The name of the LDAP attributes which contains user's ssh public keys (default sshPublicKey       |
| LDAP_HOMEDIR           | The template which SSSD use to build the user's home path. (see sssd.conf override_homedir option)|
| SFTP_CHROOT            | The folder in which the SSHD daemon will perform a Chroot of sftp users                           |


For example of values, you can refer to the Dockerfile

## Installation

```
git clone
docker build -t docker-sftp-ldap .
```

## Usage

Basic usage with an LDAP server

```
docker run -p 22:22 -e "LDAP_URI=ldap://ldap.domain.com" -e "LDAP_BASE=dc=domain,dc=com" docker-sftp-ldap
```


## Specific configuration examples

* Use with an existing FreeIPA server to serve home's folder

First you will to create a account for sftp service. Refer to you IPA web interface for this. Once the service is create, you must add a password to the corresponding LDAP entity
Then you have to create a docker-compose entry like this

```
homes-sftp:
    image: turgon37/sftp-ldap
    environment:
      - 'LDAP_URI=ldap://fqdn.domain.com'
      - 'LDAP_BASE=cn=accounts,dc=domain,dc=com'
      - 'LDAP_BASE_USER=cn=users,cn=accounts,dc=domain,dc=com'
      - 'LDAP_BASE_GROUP=cn=groups,cn=accounts,dc=domain,dc=com'
      - 'LDAP_BIND_USER=krbprincipalname=docker-sftp/fqdn.domain.com@DOMAIN.COM,cn=services,cn=accounts,dc=domain,dc=com'
      - 'LDAP_BIND_PWD=XXXXXXXXXXXXX'
      - 'LDAP_HOMEDIR=/homes/%u-%U'
      - 'LDAP_ATTR_SSHPUBLICKEY=ipasshpubkey'
      - 'LDAP_TLS_STARTTLS=true'
      - 'LDAP_TLS_CACERT=/etc/ssl/ca.pem'
    ports:
      - '2222:22'
    volumes:
      - "/mnt/homes/:/data/homes"
      - "/etc/ssl/Root-ca.pem:/etc/ssl/ca.pem:ro"
```

You should now, have a running SFTP server on port 2222. You can login using Login + (password or ssh-private key)
