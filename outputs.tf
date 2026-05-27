output "enabled" {
  description = "Whether the module is enabled"
  value       = local.enabled
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.function.function_arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = module.function.function_name
}

output "invoke_arn" {
  description = "Invoke ARN (for API Gateway integration)"
  value       = module.function.invoke_arn
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.log_group.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.log_group.name
}
