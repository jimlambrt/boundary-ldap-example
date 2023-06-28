# Boundary LDAP example

## Overview

This repo contains an example of creating a new Boundary [LDAP auth
method](https://developer.hashicorp.com/boundary/docs/concepts/domain-model/auth-methods)
and using it to authenticate to a local `boundary dev` instance.

The example uses an [Online LDAP Test
Server](https://www.forumsys.com/2022/05/10/online-ldap-test-server/) provided
by Forum Systems. Using this directory eliminates the need for you to download,
install and configure an LDAP sever in order to test/run the example. The test
directory contains users and groups and for this example we'll be using the
`einstein` user and the `Scientists` group.

NOTE: Unfortunately, Boundary `v0.13.0` has a defect, so you'll need to either
build Boundary locally or wait for a patch release before running this example.
Luckily, building Boundary is pretty simple:

```sh
git clone https://github.com/hashicorp/boundary.git
cd boundary
make tools
make install
```

### See Also

As part of developing Boundary's LDAP auth method, a few other pkgs were open
sourced:

* [cap LDAP](https://github.com/hashicorp/cap/tree/main/ldap)
* [gldap](https://github.com/jimlambrt/gldap)

## Example files

* [main.tf](main.tf) - contains all the required TF
* [query-ldap.sh](query-ldap.sh) - query the Forum Systems LDAP service for both the `einstein`
  account and the `Scientist` group.
* [dev-query-ldap.sh](dev-query-ldap.sh) - query the LDAP server embedded within `boundary dev`

## Usage

```sh
# first start up boundary locally
boundary dev

# first, before we begin the "real" demo, it might surprise you to learn that 
# "boundary dev" as an LDAP server embedded within it, which you can use to 
# authenticate.  Crazy right?  Using the gldap pkg (see above) you can build 
# your own custom LDAP service too... if you want/need to.

boundary authenticate ldap -auth-method-id amldap_1234567890 -login-name admin

# read info about the dev ldap auth method
boundary auth-methods read -id amldap_1234567890

# now, back to the real topic of our discussion/demo where we'll use terraform to create 
# a new LDAP auth method, along with some other required resources.
# in a separate terminal, initialize a new/existing terraform working dir

terraform init

# update the "boundary dev" configuration using terraform:
#   1) creates a new LDAP auth method
#   2) creates a an LDAP account, and associates it with an LDAP user
#   3) creates an LDAP managed group
#   4) creates a Role and adds the LDAP managed group as a principal

terraform apply


# list all the available active-public auth methods

boundary auth-methods list --recursive


# find the newly created auth-method named "forumsys public LDAP"

# and set an envvar with its ID

export AUTH_METHOD_ID=<new-ldap-auth-method-id>


# authenticate using the new forumsys public LDAP auth-method using 
# the einstein login name.

boundary authenticate ldap -auth-method-id $AUTH_METHOD_ID -login-name einstein


# when the authen cmd above is successful, you'll see the acct id in it's output.
# now, read that acct info and you'll see that it's a member of the "Scientists" 
# managed group

boundary accounts read <ldap-account-id for einstein>


# now connect to one of the existing boundary targets using einstein's auth-token

boundary connect ssh -target-id ttcp_1234567890


# try to read the forumsys public LDAP, which will fail
# (einstein doesn't have permission)

boundary auth-methods read -id $AUTH_METHOD_ID


# authenticate as the default admin login name, using the default primary auth-method

boundary authenticate password -auth-method-id ampw_1234567890 -login-name admin


# now, you can successfully read the forumsys public LDAP using the admin auth-token
boundary auth-methods read -id $AUTH_METHOD_ID

```
