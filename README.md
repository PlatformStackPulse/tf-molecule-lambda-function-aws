# tf-molecule-lambda-function-aws

[![Terraform Format](https://img.shields.io/badge/terraform-fmt-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-lambda-function-aws/actions)
[![Terraform Validate](https://img.shields.io/badge/terraform-validate-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-lambda-function-aws/actions)
[![TFLint](https://img.shields.io/badge/tflint-passing-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-lambda-function-aws/actions)
[![Terraform Test](https://img.shields.io/badge/tests-3%20passed-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-molecule-lambda-function-aws/actions)
[![Security Scan](https://img.shields.io/badge/trivy-passing-brightgreen?logo=aqua)](https://github.com/PlatformStackPulse/tf-molecule-lambda-function-aws/actions)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-blue?logo=conventionalcommits)](https://conventionalcommits.org)
[![Documentation](https://img.shields.io/badge/docs-terraform--docs-blue?logo=readthedocs)](https://github.com/PlatformStackPulse/tf-molecule-lambda-function-aws/actions)
[![License](https://img.shields.io/badge/license-MIT-blue?logo=opensourceinitiative)](LICENSE)

Terraform molecule that composes Lambda atoms into a production-ready AWS Lambda function with a dedicated CloudWatch log group and an optional invoke permission.

## Features

- **Production-ready Lambda function** — runtime, handler, timeout, memory, architecture, and environment variables, deployed from a local zip (`filename`) or an S3 object (`s3_bucket`/`s3_key`).
- **Dedicated CloudWatch log group** — created ahead of the function at `/aws/lambda/<id>` with configurable retention and optional KMS encryption.
- **Optional invoke permission** — grants a named principal (e.g. `apigateway.amazonaws.com`, `events.amazonaws.com`) permission to invoke the function; created only when `permission_principal` is set.
- **tf-label identity & tagging** — consistent naming and tags via `namespace`/`environment`/`stage`/`name` (or a passed-in `context`), and an `enabled` switch to create nothing.
- **Composed from pinned atoms** — every underlying atom is sourced at a fixed commit SHA for reproducible builds.

### Atoms Composed

| Atom | Purpose |
|------|---------|
| `tf-atom-lambda-function-aws` | Creates the Lambda function |
| `tf-atom-cloudwatch-log-group-aws` | Creates the dedicated CloudWatch log group |
| `tf-atom-lambda-permission-aws` | (Optional) Grants invoke permission to a principal |

## Usage

```hcl
module "api_handler" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-lambda-function-aws.git?ref=v1.0.0"

  namespace   = "psp"
  environment = "prod"
  name        = "api-handler"

  # Required
  role_arn = module.lambda_role.role_arn

  # Deployment package (filename OR s3_bucket/s3_key)
  runtime  = "provided.al2023"
  handler  = "bootstrap"
  filename = "${path.module}/dist/bootstrap.zip"

  environment_variables = {
    TABLE_NAME = "my-table"
    LOG_LEVEL  = "info"
  }

  # Grant API Gateway permission to invoke
  permission_principal  = "apigateway.amazonaws.com"
  permission_source_arn = "arn:aws:execute-api:eu-west-2:123456789:api-id/*"

  log_retention_in_days = 14
}
```

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_function"></a> [function](#module\_function) | git::https://github.com/PlatformStackPulse/tf-atom-lambda-function-aws.git | 89ef0df3aea9e41890875f501004ff428b102bba |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | git::https://github.com/PlatformStackPulse/tf-atom-cloudwatch-log-group-aws.git | d05ce1626c5f7079ed66a5888fb58e2556d4e9aa |
| <a name="module_permission"></a> [permission](#module\_permission) | git::https://github.com/PlatformStackPulse/tf-atom-lambda-permission-aws.git | f9cb20f9bfbff65fbc58b9f7eacafc418375aef0 |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/PlatformStackPulse/tf-label.git | v1.0.0 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM execution role for the Lambda function | `string` | n/a | yes |
| <a name="input_architectures"></a> [architectures](#input\_architectures) | Instruction set architecture (x86\_64 or arm64) | `list(string)` | <pre>[<br/>  "arm64"<br/>]</pre> | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes and tags, which are merged. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    namespace           = optional(string, null)<br/>    tenant              = optional(string, null)<br/>    environment         = optional(string, null)<br/>    stage               = optional(string, null)<br/>    name                = optional(string, null)<br/>    delimiter           = optional(string, null)<br/>    attributes          = optional(list(string), [])<br/>    tags                = optional(map(string), {})<br/>    label_order         = optional(list(string), null)<br/>    regex_replace_chars = optional(string, null)<br/>    id_length_limit     = optional(number, null)<br/>    label_key_case      = optional(string, null)<br/>    label_value_case    = optional(string, null)<br/>    labels_as_tags      = optional(set(string), null)<br/>    descriptor_formats = optional(map(object({<br/>      format = string<br/>      labels = list(string)<br/>    })), {})<br/>  })</pre> | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Lambda function | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | <pre>map(object({<br/>    format = string<br/>    labels = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'. | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Map of environment variables for the function | `map(string)` | `{}` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | Path to the deployment package (mutually exclusive with s3\_bucket/s3\_key) | `string` | `null` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint (e.g., index.handler, bootstrap) | `string` | `"bootstrap"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` to keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>Note: The value of the `name` tag, if included, will be the `id`, not the `name`. | `set(string)` | `null` | no |
| <a name="input_log_kms_key_id"></a> [log\_kms\_key\_id](#input\_log\_kms\_key\_id) | KMS key ARN for CloudWatch log encryption | `string` | `null` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | CloudWatch log retention in days (0 = never expire) | `number` | `30` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB (128-10240) | `number` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique. | `string` | `null` | no |
| <a name="input_permission_principal"></a> [permission\_principal](#input\_permission\_principal) | Principal allowed to invoke (e.g., apigateway.amazonaws.com). Set to null to skip. | `string` | `null` | no |
| <a name="input_permission_source_arn"></a> [permission\_source\_arn](#input\_permission\_source\_arn) | Source ARN for the invoke permission (e.g., API Gateway execution ARN) | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime identifier (e.g., nodejs20.x, python3.12, provided.al2023) | `string` | `"provided.al2023"` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket containing the deployment package | `string` | `null` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key of the deployment package | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element. A customer identifier, indicating who this instance of a resource is for. | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Function timeout in seconds (1-900) | `number` | `30` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the module is enabled |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN (for API Gateway integration) |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the CloudWatch log group |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch log group |
<!-- END_TF_DOCS -->

## Tests

Unit tests use the native `terraform test` framework with a mocked AWS provider, so no
real AWS credentials or network calls are required. They assert on plan-known values only
(the tf-label `id`, the `enabled` flag, and optional-atom instantiation).

```bash
# Unit tests (mocked provider — no AWS credentials)
terraform init -backend=false
terraform test -test-directory=tests/unit

# via Makefile
make test-unit
```

Integration tests (which require real AWS credentials) live under `tests/integration` and
run with `terraform test -test-directory=tests/integration` (`make test-integration`).
