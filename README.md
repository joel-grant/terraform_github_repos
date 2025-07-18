# GitHub Repository Module

This Terraform module creates and manages GitHub repositories with support for:

- Repository configuration (visibility, features, topics)
- Template repositories
- GitHub Pages configuration
- Repository environments
- Repository-level and environment-level secrets

## About

This module is particularly useful for maintaining complex projects that require standardized repository configurations, environment management, and secret handling. I use this module across many of my projects that have significant complexity to ensure consistent setup and management of GitHub repositories, environments, and secrets.  Feel free to use as well or as a guide to understanding more about Terraform!

## Usage

### Using from GitHub

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

### Using with a specific version

```hcl
module "my_repository" {
  source = "github.com/joel-grant/terraform_github_repos?ref=v1.0.0"

  name        = "my-awesome-repo"
  description = "An awesome repository"
  visibility  = "public"
  
  topics = ["terraform", "github", "automation"]
}
```

### Using locally

```hcl
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
