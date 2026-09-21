module "greeting" {
  source = "../../modules/greeting"
  name   = "arcane-centaur"
}

output "message" {
  value = module.greeting.greeting
}
