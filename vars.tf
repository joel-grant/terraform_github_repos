variable "name" {
  description = "The name of the repository"
  type        = string
}

variable "description" {
  description = "The description of the repository"
  type        = string
  default     = ""
}

variable "visibility" {
  description = "The visibility of the repository (public, private, internal)"
  type        = string
  default     = "private"
  
  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "Visibility must be one of: public, private, internal."
  }
}

variable "is_template" {
  description = "Whether the repository is a template"
  type        = bool
  default     = false
}

variable "has_issues" {
  description = "Whether the repository has issues enabled"
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Whether the repository has wiki enabled"
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Whether the repository has projects enabled"
  type        = bool
  default     = true
}

variable "topics" {
  description = "A list of topics for the repository"
  type        = list(string)
  default     = []
}

variable "pages" {
  description = "GitHub Pages configuration"
  type = object({
    source = object({
      branch = string
      path   = string
    })
  })
  default = null
}

variable "template" {
  description = "Template repository configuration"
  type = object({
    owner      = string
    repository = string
  })
  default = null
}

variable "environments" {
  description = "Map of environments to create with their secrets"
  type = map(object({
    secrets = map(string)
  }))
  default = {}
}

variable "repository_secrets" {
  description = "Map of repository-level secrets"
  type        = map(string)
  default     = {}
}
