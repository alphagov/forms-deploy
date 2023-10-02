locals {
  for_env = {
    for env in local.envs :
    env => [
      for name, roles in local.users : name if roles[env] != false
    ]
  }

  with_role = {
    for env_role in setproduct(local.envs, local.roles) :
    "${env_role[0]}_${env_role[1]}" => [
      for name, roles in local.users : name if roles[env_role[0]] == env_role[1]
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
