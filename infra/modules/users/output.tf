locals {
  for_env = {
    for env in local.envs :
    env => [
      # Include usernames which have a role set for the current env
      for name, roles in local.users : name if lookup(roles, env, false) != false
    ]
  }

  with_role = {
    for env_role in setproduct(local.envs, local.roles) : # e.g. [[dev, readonly], [dev, support], [staging, admin]]
    "${env_role[0]}_${env_role[1]}" => [
      # Include usernmes whose role for the current env matches the current role
      for users_name, users_roles in local.users : users_name
      if lookup(users_roles, env_role[0], false) == env_role[1]
    ]
  }
}

output "all" {
  value = local.users
}

output "for_env" {
  value = local.for_env
}

output "with_role" {
  value = local.with_role
}
