# Docker SFTP over LDAP backend

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


| Environnement          | Usage                                                               |
| ---------------------- | --------------------------------------------------------            |
| LDAP_URI   (mandatory) | The LDAP uri (uris) of the server(s)                                |
| LDAP_BASE   (mandatory)| The LDAP base for search                                            |
| LDAP_BASE_USER         | The LDAP base specific for users account objects                    |
| LDAP_BIND_USER         | The bind DN of to access to LDAP server                             |
| LDAP_BIND_PWD          | The bind password                                                   |
| LDAP_TLS_STARTTLS      | Should the LDAP client must use a starttls connection ? (true|false)|
| LDAP_TLS_CACERT        | The path to the CA.crt (don't forget to mount it with docker -v)    |
| LDAP_TLS_CERT          |                                                                     |
| LDAP_TLS_KEY           |                                                                     |

For example of values, you can refer to the Dockerfile

## Installation

```
git clone
docker build -t docker-sftp-ldap .
```

## Usage

```
docker run -p 22:22 -e "LDAP_URI=ldap://ldap.domain.com" -e "LDAP_BASE=dc=domain,dc=com" docker-sftp-ldap
```
