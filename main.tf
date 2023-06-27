terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.8"
    }
  }
}

# define a provider for a locally running: "boundary dev"
provider "boundary" {
  addr                   = "http://127.0.0.1:9200"
  auth_method_id         = "ampw_1234567890"
  auth_method_login_name = "admin"
  auth_method_password   = "password"
}

resource "boundary_auth_method_ldap" "forumsys_ldap" {
  name          = "forumsys public LDAP"
  scope_id      = "global"
  urls          = ["ldap://ldap.forumsys.com"]
  user_dn       = "dc=example,dc=com"
  user_attr     = "uid"
  group_dn      = "dc=example,dc=com"
  bind_dn       = "cn=read-only-admin,dc=example,dc=com"
  bind_password = "password"
  state         = "active-public"
  enable_groups = true
  discover_dn   = true
}

resource "boundary_account_ldap" "jim" {
  auth_method_id = boundary_auth_method_ldap.forumsys_ldap.id
  login_name     = "einstein"
  name           = "einstein"
  description    = "user account for einstein"
}


resource "boundary_user" "jim" {
  name        = "einstein"
  description = "User resource for einstein"
  scope_id    = "global"
  account_ids = [boundary_account_ldap.jim.id]
}

resource "boundary_managed_group_ldap" "forumsys_scientists" {
  name           = "scientists"
  description    = "forumsys scientists managed group"
  auth_method_id = boundary_auth_method_ldap.forumsys_ldap.id
  group_names    = ["Scientists"]
}

resource "boundary_role" "project_admin" {
  name          = "admin_scientists"
  description   = "default dev project: forumsys administrators role"
  principal_ids = [boundary_managed_group_ldap.forumsys_scientists.id]
  grant_strings = ["id=*;type=*;actions=*"]
  scope_id      = "p_1234567890"
}

