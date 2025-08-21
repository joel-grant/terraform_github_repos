# GitHub Repository Module

> **Note**: This is a personal Terraform module that I (Joel Grant) use to manage my own GitHub repositories. It's shared publicly for educational purposes and as a reference for others learning Terraform and GitHub automation. Feel free to use it, fork it, or adapt it for your own needs!

This Terraform module creates and manages GitHub repositories with support for:

- Repository configuration (visibility, features, topics)
- Template repositories
- GitHub Pages configuration
- Repository environments
- Repository-level and environment-level secrets

## About This Module

This is my personal Terraform module that I use across many of my projects to maintain standardized repository configurations, environment management, and secret handling. It's particularly useful for complex projects that require consistent setup and management of GitHub repositories, environments, and secrets.

Feel free to explore the code, ask questions, or adapt it for your own use cases!

## Usage

The recommended approach is to use this module with `for_each` to manage multiple repositories from a single configuration, storing your repository definitions in a `tfvars` file.

### Main Configuration (`main.tf`)

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
}
```

### Variables Definition (`variables.tf`)

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
      build_type = optional(string, "workflow")
      cname      = optional(string)
    }))
    template = optional(object({
      owner      = string
      repository = string
    }))
    environments = optional(map(object({
      secrets = optional(map(string), {})
    })), {})
    repository_secrets = optional(map(string), {})
  }))
  default = {}
}
```

### Repository Configuration (`terraform.tfvars`)

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
      build_type = "workflow"
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

### Using with a specific version

```hcl
module "github_repositories" {
  source = "github.com/joel-grant/terraform_github_repos?ref=v1.0.0"
  
  for_each = var.repositories
  # ... rest of configuration
}
```

### Using locally

```hcl
module "github_repositories" {
  source = "./terraform_github_repos"
  
  for_each = var.repositories
  # ... rest of configuration
}
```
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
