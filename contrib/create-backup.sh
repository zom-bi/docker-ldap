#!/bin/bash
CONF_LOCATION=/data/slapd.d
CONTAINER_NAME=ldap

# dump configuration
docker exec -it ldap slapcat -F $CONF_LOCATION -n 0 > conf.ldif

# dump data
docker exec -it ldap slapcat -F $CONF_LOCATION -n 1 > data.ldif
