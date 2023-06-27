terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.8"
    }
  }
}

# configure the provider for a locally running: "boundary dev" 
provider "boundary" {
  addr                   = "http://127.0.0.1:9200"
  auth_method_id         = "ampw_1234567890" # default pre-provisioned password auth method
  auth_method_login_name = "admin"           # default pre-provisioned account
  auth_method_password   = "password"
}

# create a new LDAP auth method that uses Online LDAP test server from Forum
# Systems.  For more info see:
# https://www.forumsys.com/2022/05/10/online-ldap-test-server/ 
resource "boundary_auth_method_ldap" "forumsys_ldap" {
  name          = "forumsys public LDAP"
  scope_id      = "global"                               # add the new auth method to the global scope
  urls          = ["ldap://ldap.forumsys.com"]           # the addr of the LDAP server
  user_dn       = "dc=example,dc=com"                    # the basedn for users
  user_attr     = "uid"                                  # the user attribute
  group_dn      = "dc=example,dc=com"                    # the basedn for groups
  bind_dn       = "cn=read-only-admin,dc=example,dc=com" # the dn to use when binding
  bind_password = "password"                             # passwd to use when binding
  state         = "active-public"                        # make sure the new auth-method is available to everyone
  enable_groups = true                                   # this turns-on the discovery of a user's groups
  discover_dn   = true                                   # this turns-on the discovery of an authenticating user's dn
}

# Since we didn't make the new LDAP auth method the primary global scope auth
# method, we need to provision an LDAP account, so we can associate it with a
# soon to be provisioned user.   The "einstein" login name is an existing entry
# in the forum systems LDAP server.
resource "boundary_account_ldap" "einstein" {
  auth_method_id = boundary_auth_method_ldap.forumsys_ldap.id
  login_name     = "einstein" # this is the user attribute value used during login
  name           = "einstein"
  description    = "user account for einstein"
}

// Once again, we didn't make the new LDAP auth method the primary global scope
// auth method, so we need to provision a user and associate it with the
// einstein LDAP account.
resource "boundary_user" "einstein" {
  name        = "einstein"
  description = "User resource for einstein"
  scope_id    = "global"
  account_ids = [boundary_account_ldap.einstein.id]
}

# let's provision an LDAP manage group for the "Scientist" group provided by the
# forum systems LDAP server.
resource "boundary_managed_group_ldap" "forumsys_scientists" {
  name           = "scientists"
  description    = "forumsys scientists managed group"
  auth_method_id = boundary_auth_method_ldap.forumsys_ldap.id
  group_names    = ["Scientists"]
}

# let's grant the forumsys_scientists full privs in the default boundary dev
# project, which result in members of the group being able to connect to hosts
# contained in that project. 
resource "boundary_role" "project_admin" {
  name          = "admin_scientists"
  description   = "default dev project: forumsys administrators role"
  principal_ids = [boundary_managed_group_ldap.forumsys_scientists.id]
  grant_strings = ["id=*;type=*;actions=*"]
  scope_id      = "p_1234567890" # the default pre-provisioned project
}

