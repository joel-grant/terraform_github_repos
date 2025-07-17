resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  is_template = var.is_template

  has_issues   = var.has_issues
  has_wiki     = var.has_wiki
  has_projects = var.has_projects

  dynamic "pages" {
    for_each = var.pages != null ? [var.pages] : []
    content {
      source {
        branch = pages.value.source.branch
        path   = pages.value.source.path
      }
    }
  }

  dynamic "template" {
    for_each = var.template != null ? [var.template] : []
    content {
      owner      = template.value.owner
      repository = template.value.repository
    }
  }

  topics = var.topics
}

# Create environments
resource "github_repository_environment" "environments" {
  for_each = var.environments

  environment = each.key
  repository  = github_repository.this.name
}

# Create repository-level secrets
resource "github_actions_secret" "repository_secrets" {
  for_each = var.repository_secrets

  repository      = github_repository.this.name
  secret_name     = each.key
  plaintext_value = each.value
}

# Create environment-level secrets
resource "github_actions_environment_secret" "environment_secrets" {
  for_each = local.environment_secrets_flat

  environment     = each.value.environment
  repository      = github_repository.this.name
  secret_name     = each.value.secret_name
  plaintext_value = each.value.secret_value

  depends_on = [github_repository_environment.environments]
}

# Flatten environment secrets for easier iteration
locals {
  environment_secrets_flat = merge([
    for env_name, env_config in var.environments : {
      for secret_name, secret_value in env_config.secrets : 
      "${env_name}_${secret_name}" => {
        environment   = env_name
        secret_name   = secret_name
        secret_value  = secret_value
      }
    }
  ]...)
}
