ldapsearch -w password -D "cn=read-only-admin,dc=example,dc=com" -b "dc=example,dc=com" -x -H "ldap://ldap.forumsys.com"  "uid=einstein"

ldapsearch -w password -D "cn=read-only-admin,dc=example,dc=com" -b "dc=example,dc=com" -x -H "ldap://ldap.forumsys.com"  "ou=Scientists"