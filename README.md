# GitHub Repository Module

> **Note**: DEMO PROJECT - Used for learning/experimenting with Terraform and sharing ideas with others.

This Terraform module creates and manages GitHub repositories with support for:

- Repository configuration (visibility, features, topics)
- Template repositories
- GitHub Pages configuration
- Repository environments
- Repository-level and environment-level secrets
- Webhooks

## About This Module

This is my personal Terraform module that I use across many of my projects to maintain standardized repository configurations, environment management, and secret handling. I use it as much to manage my many projects as I do to learn and advance my knowledge and hands-on experience with Terraform.

Feel free to explore the code, ask questions, or adapt it for your own use cases!

## Usage

### Recommended: Managing Multiple Repositories with `for_each`

The recommended approach is to use this module with `for_each` to manage multiple repositories from a single configuration, storing your repository definitions in a `tfvars` file. This approach scales well and keeps your configuration DRY.

#### Main Configuration (`main.tf`)

```hcl
module "github_repositories" {
  source = "github.com/joel-grant/terraform_github_repos"
  
  for_each = var.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility
  is_template = try(each.value.is_template, false)
  has_issues  = try(each.value.has_issues, true)
  has_wiki    = try(each.value.has_wiki, true)
  has_projects = try(each.value.has_projects, true)
  topics      = try(each.value.topics, [])
  pages       = try(each.value.pages, null)
  template    = try(each.value.template, null)
  environments = try(each.value.environments, {})
  repository_secrets = try(each.value.repository_secrets, {})
  webhooks    = try(each.value.webhooks, {})
}
```

#### Variables Definition (`variables.tf`)

```hcl
variable "repositories" {
  description = "Map of repositories to create"
  type = map(object({
    description        = string
    visibility         = string
    is_template        = optional(bool, false)
    has_issues         = optional(bool, true)
    has_wiki           = optional(bool, true)
    has_projects       = optional(bool, true)
    topics             = optional(list(string), [])
    pages              = optional(object({
      source = object({
        branch = string
        path   = optional(string, "/")
      })
    }))
    template = optional(object({
      owner      = string
      repository = string
    }))
    environments = optional(map(object({
      secrets = optional(map(string), {})
    })), {})
    repository_secrets = optional(map(string), {})
    webhooks = optional(map(object({
      url          = string
      content_type = optional(string, "json")
      insecure_ssl = optional(bool, false)
      secret       = optional(string)
      events       = list(string)
      active       = optional(bool, true)
    })), {})
  }))
  default = {}
}
```

#### Repository Configuration (`terraform.tfvars`)

```hcl
repositories = {
  "my-awesome-app" = {
    description = "My awesome web application"
    visibility  = "public"
    topics      = ["react", "nodejs", "terraform"]
    environments = {
      production = {
        secrets = {
          "DATABASE_URL" = "prod-database-connection-string"
          "API_KEY"      = "prod-api-key"
        }
      }
      staging = {
        secrets = {
          "DATABASE_URL" = "staging-database-connection-string"
          "API_KEY"      = "staging-api-key"
        }
      }
    }
    repository_secrets = {
      "DOCKERHUB_TOKEN" = "dockerhub-access-token"
      "NPM_TOKEN"       = "npm-publish-token"
    }
    # Simple webhook example
    webhooks = {
      "slack-notifications" = {
        url    = "https://hooks.slack.com/services/xxx/yyy/zzz"
        events = ["push", "pull_request", "release"]
      }
    }
  }

  "fully-configured-repo" = {
    description = "Repository with comprehensive webhook configuration"
    visibility  = "private"
    topics      = ["example", "webhooks"]
    
    # Full webhook configuration with all options
    # See: https://docs.github.com/en/webhooks/webhook-events-and-payloads
    webhooks = {
      # CI/CD pipeline trigger
      "ci-pipeline" = {
        url          = "https://ci.example.com/webhook"
        content_type = "json"           # "json" (default) or "form"
        secret       = "WEBHOOK_SECRET" # Optional: for payload verification
        insecure_ssl = false            # Default: false
        active       = true             # Default: true
        events       = [
          "push",                       # Any git push
          "pull_request",               # PR opened, closed, synchronized, etc.
          "workflow_run",               # GitHub Actions workflow completed
        ]
      }
      
      # Slack/Discord notifications
      "team-notifications" = {
        url    = "https://hooks.slack.com/services/xxx/yyy/zzz"
        events = [
          "issues",                     # Issue opened, edited, closed
          "issue_comment",              # Comment on issue or PR
          "pull_request_review",        # PR review submitted
          "pull_request_review_comment",# Comment on PR diff
          "release",                    # Release published, created, etc.
          "deployment_status",          # Deployment succeeded/failed
        ]
      }
      
      # Security monitoring
      "security-alerts" = {
        url          = "https://security.example.com/github-webhook"
        content_type = "json"
        secret       = "SECURITY_WEBHOOK_SECRET"
        events       = [
          "branch_protection_rule",     # Branch protection changed
          "code_scanning_alert",        # Code scanning alert
          "dependabot_alert",           # Dependabot vulnerability alert
          "repository_vulnerability_alert", # Security advisory
          "secret_scanning_alert",      # Secret detected in code
          "security_advisory",          # Security advisory published
        ]
      }
    }
  }
  
  "terraform-modules" = {
    description = "Collection of reusable Terraform modules"
    visibility  = "public"
    topics      = ["terraform", "infrastructure", "modules"]
    has_wiki    = false
  }
  
  "documentation-site" = {
    description = "Project documentation website"
    visibility  = "public"
    topics      = ["documentation", "gatsby", "markdown"]
    pages = {
      source = {
        branch = "main"
        path   = "/docs"
      }
    }
  }
  
  "private-api" = {
    description = "Internal API service"
    visibility  = "private"
    topics      = ["api", "golang", "microservice"]
    environments = {
      production = {
        secrets = {
          "DB_PASSWORD"    = "super-secret-prod-password"
          "JWT_SECRET"     = "jwt-signing-secret"
          "REDIS_URL"      = "redis://prod-redis:6379"
        }
      }
    }
  }
}
```

#### Webhook Events Reference

For a complete list of available webhook events, see the [GitHub Webhook Events documentation](https://docs.github.com/en/webhooks/webhook-events-and-payloads).

**Commonly used events:**

| Event | Description |
|-------|-------------|
| `push` | Any push to a repository |
| `pull_request` | Pull request opened, closed, synchronized, reopened, etc. |
| `release` | Release created, published, edited, deleted |
| `issues` | Issue opened, edited, deleted, closed, reopened, etc. |
| `issue_comment` | Comment on an issue or pull request |
| `workflow_run` | GitHub Actions workflow run requested or completed |
| `deployment` | Deployment created |
| `deployment_status` | Deployment status updated |
| `create` | Branch or tag created |
| `delete` | Branch or tag deleted |

**Security-related events:**

| Event | Description |
|-------|-------------|
| `branch_protection_rule` | Branch protection rule created, edited, or deleted |
| `code_scanning_alert` | Code scanning alert created, fixed, etc. |
| `dependabot_alert` | Dependabot alert created, dismissed, fixed, etc. |
| `secret_scanning_alert` | Secret scanning alert created, resolved, etc. |
| `repository_vulnerability_alert` | Security vulnerability alert |

**Collaboration events:**

| Event | Description |
|-------|-------------|
| `pull_request_review` | Pull request review submitted, edited, dismissed |
| `pull_request_review_comment` | Comment on pull request diff |
| `pull_request_review_thread` | Pull request review thread resolved/unresolved |
| `discussion` | Discussion created, edited, answered, etc. |
| `discussion_comment` | Comment on a discussion |
| `star` | Repository starred or unstarred |
| `watch` | User started watching repository |
| `fork` | Repository forked |

### Managing Secrets with Terraform Cloud

When using Terraform Cloud (or HCP Terraform), you'll need a **variable map pattern** to reference secrets in your `tfvars` file. This is because Terraform's language doesn't allow `var.` references inside `.tfvars` files.

#### The Problem

```hcl
# ❌ This does NOT work in terraform.tfvars
repositories = {
  "my-repo" = {
    repository_secrets = {
      "DOCKERHUB_TOKEN" = var.DOCKERHUB_TOKEN  # Variables not allowed here!
    }
  }
}
```

#### The Solution: Variable Map Pattern

Use string references in your `tfvars`, then resolve them to actual variable values in `main.tf`:

##### Step 1: Define your secrets as Terraform Cloud variables

In Terraform Cloud, create workspace variables or variable sets for your secrets (e.g., `DOCKERHUB_TOKEN`, `API_KEY`, etc.). Mark them as sensitive.

##### Step 2: Create a variable map in `main.tf`

```hcl
locals {
  # Map variable names (strings) to actual variable values
  variable_map = {
    "DOCKERHUB_TOKEN"   = var.DOCKERHUB_TOKEN
    "NPM_TOKEN"         = var.NPM_TOKEN
    "PRODUCTION_DB_URL" = var.PRODUCTION_DB_URL
    "STAGING_DB_URL"    = var.STAGING_DB_URL
    # Add all your Terraform Cloud variables here
  }

  # Transform repository secrets from string references to actual values
  resolved_repositories = {
    for repo_name, repo_config in var.repositories : repo_name => merge(repo_config, {
      repository_secrets = {
        for secret_name, variable_name in try(repo_config.repository_secrets, {}) :
        secret_name => local.variable_map[variable_name]
      }
      environments = {
        for env_name, env_config in try(repo_config.environments, {}) : env_name => {
          secrets = {
            for secret_name, variable_name in try(env_config.secrets, {}) :
            secret_name => local.variable_map[variable_name]
          }
        }
      }
    })
  }
}

# Use resolved_repositories instead of var.repositories
module "github_repositories" {
  source = "github.com/joel-grant/terraform_github_repos"
  
  for_each = local.resolved_repositories

  name               = each.key
  description        = each.value.description
  visibility         = each.value.visibility
  is_template        = try(each.value.is_template, false)
  has_issues         = try(each.value.has_issues, true)
  has_wiki           = try(each.value.has_wiki, true)
  has_projects       = try(each.value.has_projects, true)
  topics             = try(each.value.topics, [])
  pages              = try(each.value.pages, null)
  template           = try(each.value.template, null)
  environments       = each.value.environments
  repository_secrets = each.value.repository_secrets
  webhooks           = try(each.value.webhooks, {})
}
```

##### Step 3: Reference secrets by name in `terraform.tfvars`

```hcl
repositories = {
  "my-app" = {
    description = "My application"
    visibility  = "private"
    repository_secrets = {
      # These are variable NAMES (strings), not actual values
      "DOCKERHUB_TOKEN" = "DOCKERHUB_TOKEN"
      "NPM_TOKEN"       = "NPM_TOKEN"
    }
    environments = {
      production = {
        secrets = {
          "DATABASE_URL" = "PRODUCTION_DB_URL"  # References var.PRODUCTION_DB_URL
        }
      }
      staging = {
        secrets = {
          "DATABASE_URL" = "STAGING_DB_URL"     # References var.STAGING_DB_URL
        }
      }
    }
  }
}
```

#### Why This Pattern?

- **Clean tfvars** — Repository configuration stays readable and declarative
- **Secrets in Terraform Cloud** — Sensitive values never appear in your codebase
- **Scalable** — Add new repositories by editing only `tfvars`
- **Maintainable** — Adding a new secret only requires updating `variable_map`

### Alternative: Single Repository Usage

For simple use cases or when managing just one repository, you can use the module directly:

#### Using from GitHub

```hcl
module "my_repository" {
  source = "github.com/joel-grant/terraform_github_repos"

  name        = "my-awesome-repo"
  description = "An awesome repository"
  visibility  = "public"
  
  topics = ["terraform", "github", "automation"]
  
  environments = {
    production = {
      secrets = {
        "API_KEY"      = var.production_api_key
        "DATABASE_URL" = var.production_database_url
      }
    }
    staging = {
      secrets = {
        "API_KEY"      = var.staging_api_key
        "DATABASE_URL" = var.staging_database_url
      }
    }
  }
  
  repository_secrets = {
    "DOCKERHUB_TOKEN"    = var.dockerhub_token
    "RELEASE_TOKEN"      = var.release_token
  }
}
```

#### Using with a specific version

```hcl
# For multiple repositories (recommended)
module "github_repositories" {
  source = "github.com/joel-grant/terraform_github_repos?ref=v1.0.0"
  
  for_each = var.repositories
  # ... rest of configuration
}

# For single repository
module "my_repository" {
  source = "github.com/joel-grant/terraform_github_repos?ref=v1.0.0"

  name        = "my-awesome-repo"
  description = "An awesome repository"
  visibility  = "public"
  
  topics = ["terraform", "github", "automation"]
}
```

#### Using locally

```hcl
# For multiple repositories (recommended)
module "github_repositories" {
  source = "./terraform_github_repos"
  
  for_each = var.repositories
  # ... rest of configuration
}

# For single repository
module "my_repository" {
  source = "./terraform_github_repos"

  name        = "my-awesome-repo"
  description = "An awesome repository"
  visibility  = "public"
  
  topics = ["terraform", "github", "automation"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the repository | `string` | n/a | yes |
| description | The description of the repository | `string` | `""` | no |
| visibility | The visibility of the repository (public, private, internal) | `string` | `"private"` | no |
| is_template | Whether the repository is a template | `bool` | `false` | no |
| has_issues | Whether the repository has issues enabled | `bool` | `true` | no |
| has_wiki | Whether the repository has wiki enabled | `bool` | `true` | no |
| has_projects | Whether the repository has projects enabled | `bool` | `true` | no |
| topics | A list of topics for the repository | `list(string)` | `[]` | no |
| pages | GitHub Pages configuration | `object` | `null` | no |
| template | Template repository configuration | `object` | `null` | no |
| environments | Map of environments to create with their secrets | `map(object)` | `{}` | no |
| repository_secrets | Map of repository-level secrets | `map(string)` | `{}` | no |
| webhooks | Map of webhooks to create for the repository | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_name | The name of the created repository |
| repository_full_name | The full name of the repository (owner/name) |
| repository_id | The ID of the repository |
| repository_html_url | The HTML URL of the repository |
| repository_ssh_clone_url | The SSH clone URL of the repository |
| repository_http_clone_url | The HTTP clone URL of the repository |
| environments | Map of created environments |
| webhooks | Map of created webhooks with their IDs and URLs |
