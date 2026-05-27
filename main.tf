# -----------------------------------------------------
# Molecule: Lambda Function
# Composes Lambda atoms into a production-ready function
# with CloudWatch log group and optional invoke permission.
# -----------------------------------------------------

# --- CloudWatch Log Group (created first for Lambda to write to) ---
module "log_group" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-cloudwatch-log-group-aws.git?ref=d05ce1626c5f7079ed66a5888fb58e2556d4e9aa"

  context           = module.this.context
  log_group_name    = "/aws/lambda/${module.this.id}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_kms_key_id
}

# --- Lambda Function ---
module "function" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-lambda-function-aws.git?ref=89ef0df3aea9e41890875f501004ff428b102bba"

  context               = module.this.context
  description           = var.description
  role_arn              = var.role_arn
  handler               = var.handler
  runtime               = var.runtime
  timeout               = var.timeout
  memory_size           = var.memory_size
  filename              = var.filename
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  architectures         = var.architectures
  environment_variables = var.environment_variables

  depends_on = [module.log_group]
}

# --- Invoke Permission (optional, for API Gateway / EventBridge / etc.) ---
module "permission" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-lambda-permission-aws.git?ref=f9cb20f9bfbff65fbc58b9f7eacafc418375aef0"
  count  = var.permission_principal != null ? 1 : 0

  context       = module.this.context
  function_name = module.function.function_name
  principal     = var.permission_principal
  source_arn    = var.permission_source_arn

  depends_on = [module.function]
}
