module "processor" {
  source = "../../"

  namespace   = "psp"
  environment = "dev"
  name        = "event-processor"

  role_arn = "arn:aws:iam::123456789012:role/lambda-role"
  runtime  = "provided.al2023"
  handler  = "bootstrap"
  filename = "${path.module}/dummy.zip"

  environment_variables = {
    STAGE = "dev"
  }

  log_retention_in_days = 7
}

output "function_arn" {
  value = module.processor.function_arn
}
