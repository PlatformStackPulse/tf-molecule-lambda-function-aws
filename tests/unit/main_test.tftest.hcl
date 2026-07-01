# Unit Tests — tf-molecule-lambda-function-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# They assert on plan-KNOWN values only (tf-label id, enabled flag,
# input pass-throughs), never on computed arn/id attributes which are
# unknown under a mock provider.
#
# Run with:      terraform test -test-directory=tests/unit
# Run verbose:   terraform test -test-directory=tests/unit -verbose

mock_provider "aws" {}

variables {
  # tf-label required identity
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  # Module-specific required input
  role_arn = "arn:aws:iam::123456789012:role/eg-test-thing-exec"

  # Deployment package (sample values, not resolved under mock)
  filename = "dist/bootstrap.zip"
}

# ---------------------------------------------------------------------------
# Test: module is enabled and produces a stable, plan-known label id
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "Module should report enabled == true when enabled input is left at its default (true)."
  }

  assert {
    condition     = module.this.id == "eg-test-thing"
    error_message = "tf-label id should be 'eg-test-thing' for namespace=eg stage=test name=thing."
  }
}

# ---------------------------------------------------------------------------
# Test: optional invoke-permission atom is NOT instantiated by default
# ---------------------------------------------------------------------------
run "permission_not_created_by_default" {
  command = plan

  assert {
    condition     = length(module.permission) == 0
    error_message = "permission atom must not be created when permission_principal is null."
  }
}

# ---------------------------------------------------------------------------
# Test: disabling the module produces nothing and reports enabled == false
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = output.enabled == false
    error_message = "Module should report enabled == false when enabled = false."
  }
}
