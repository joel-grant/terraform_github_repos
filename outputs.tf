output "repository_name" {
  description = "The name of the created repository"
  value       = github_repository.this.name
}

output "repository_full_name" {
  description = "The full name of the repository (owner/name)"
  value       = github_repository.this.full_name
}

output "repository_id" {
  description = "The ID of the repository"
  value       = github_repository.this.repo_id
}

output "repository_html_url" {
  description = "The HTML URL of the repository"
  value       = github_repository.this.html_url
}

output "repository_ssh_clone_url" {
  description = "The SSH clone URL of the repository"
  value       = github_repository.this.ssh_clone_url
}

output "repository_http_clone_url" {
  description = "The HTTP clone URL of the repository"
  value       = github_repository.this.http_clone_url
}

output "environments" {
  description = "Map of created environments"
  value       = { for k, v in github_repository_environment.environments : k => v.environment }
}
