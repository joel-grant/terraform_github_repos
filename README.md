# GitHub Repository Module

This Terraform module creates and manages GitHub repositories with support for:

- Repository configuration (visibility, features, topics)
- Template repositories
- GitHub Pages configuration
- Repository environments
- Repository-level and environment-level secrets

## Usage

```hcl
module "my_repository" {
  source = "./modules/github-repository"

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
