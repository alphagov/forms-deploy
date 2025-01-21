locals {
  for_account = {
    for account in local.accounts :
    account => [
      # Include usernames which have a role set for the current env
      for name, roles in local.users : name if lookup(roles, account, false) != false
    ]
  }

  with_role = {
    for account_role in setproduct(local.accounts, local.roles) : # e.g. [[dev, readonly], [dev, support], [staging, admin]]
    "${account_role[0]}_${account_role[1]}" => [
      # Include usernames whose role for the current env matches the current role
      for users_name, users_roles in local.users : users_name
      if lookup(users_roles, account_role[0], false) == account_role[1]
    ]
  }
}

output "all" {
  value = local.users
}

output "for_account" {
  value = local.for_account
}

output "with_role" {
  value = local.with_role
}
