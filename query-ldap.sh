#!/bin/sh

# search for the einstein user
ldapsearch -w password -D "cn=read-only-admin,dc=example,dc=com" -b "dc=example,dc=com" -x -H "ldap://ldap.forumsys.com"  "uid=einstein"
# search for the Scientists group
ldapsearch -w password -D "cn=read-only-admin,dc=example,dc=com" -b "dc=example,dc=com" -x -H "ldap://ldap.forumsys.com"  "ou=Scientists"