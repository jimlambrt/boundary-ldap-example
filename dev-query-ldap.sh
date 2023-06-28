#!/bin/sh
#
# this script will dump the contents of the ldap server embedded within
# "boundary dev".  You must define/export the BOUNDARY_LDAP_PORT before running
# this script, so it will know the port (which always changes), that the ldap
# server is listening on.

if [[ -z "${BOUNDARY_LDAP_PORT}" ]]; then
    echo "Please define/export the BOUNDARY_LDAP_PORT envvar before running this script"
    exit
fi

# dump the contents of boundary dev's ldap server
ldapsearch -w password -D "cn=admin,ou=people,dc=example,dc=org" -b "dc=example,dc=com" -x -H "ldap://localhost:${BOUNDARY_LDAP_PORT}"  "cn=*"