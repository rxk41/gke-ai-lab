output "enabled_services" { value = sort(tolist(local.services)) }
