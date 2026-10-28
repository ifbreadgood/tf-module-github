variable "name" {
  description = "The name of the repository."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.name))
    error_message = "Repository name must contain only alphanumeric characters, hyphens, periods, or underscores."
  }
}

variable "description" {
  description = "A description of the repository."
  type        = string
  default     = ""
}

variable "homepage_url" {
  description = "URL of a page describing the project."
  type        = string
  default     = null
}

variable "visibility" {
  description = "Repository visibility ('public', 'private', or 'internal')."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "Repository visibility must be 'public', 'private', or 'internal'."
  }
}

variable "has_issues" {
  description = "Enable GitHub Issues on the repository."
  type        = bool
  default     = true
}

variable "has_discussions" {
  description = "Enable GitHub Discussions on the repository."
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "Enable GitHub Projects on the repository."
  type        = bool
  default     = false
}

variable "has_wiki" {
  description = "Enable GitHub Wiki on the repository."
  type        = bool
  default     = false
}

variable "is_template" {
  description = "Whether this is a template repository."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Allow merge commits on the repository."
  type        = bool
  default     = false
}

variable "allow_squash_merge" {
  description = "Allow squash merges on the repository."
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merges on the repository."
  type        = bool
  default     = false
}

variable "allow_auto_merge" {
  description = "Allow auto-merging pull requests on the repository."
  type        = bool
  default     = true
}

variable "allow_update_branch" {
  description = "Always suggest updating pull request branches."
  type        = bool
  default     = true
}

variable "squash_merge_commit_title" {
  description = "Default squash merge commit title ('PR_TITLE' or 'COMMIT_OR_PR_TITLE')."
  type        = string
  default     = "PR_TITLE"

  validation {
    condition     = contains(["PR_TITLE", "COMMIT_OR_PR_TITLE"], var.squash_merge_commit_title)
    error_message = "squash_merge_commit_title must be 'PR_TITLE' or 'COMMIT_OR_PR_TITLE'."
  }
}

variable "squash_merge_commit_message" {
  description = "Default squash merge commit message ('PR_BODY', 'COMMIT_MESSAGES', or 'BLANK')."
  type        = string
  default     = "PR_BODY"

  validation {
    condition     = contains(["PR_BODY", "COMMIT_MESSAGES", "BLANK"], var.squash_merge_commit_message)
    error_message = "squash_merge_commit_message must be 'PR_BODY', 'COMMIT_MESSAGES', or 'BLANK'."
  }
}

variable "delete_branch_on_merge" {
  description = "Automatically delete head branch after a pull request is merged."
  type        = bool
  default     = true
}

variable "gitignore_template" {
  description = "Gitignore template name without extension (e.g. 'Haskell')."
  type        = string
  default     = null
}

variable "license_template" {
  description = "License template name without extension (e.g. 'mit' or 'agpl-3.0')."
  type        = string
  default     = "agpl-3.0"
}

variable "archived" {
  description = "Specifies if the repository should be archived."
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "Archive the repository instead of deleting on destroy."
  type        = bool
  default     = true
}

variable "topics" {
  description = "The list of topics of the repository."
  type        = list(string)
  default     = []
}

variable "default_branch" {
  description = "The name of the branch to set as the default."
  type        = string
  default     = "main"

  validation {
    condition     = length(trimspace(var.default_branch)) > 0
    error_message = "default_branch must not be empty."
  }
}

variable "template" {
  description = "Optional configuration to create the repository from a template repository."
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default = null

  validation {
    condition = var.template == null ? true : try(
      length(trimspace(var.template.owner)) > 0 && length(trimspace(var.template.repository)) > 0,
      false
    )
    error_message = "template owner and repository must not be empty."
  }
}

variable "security_and_analysis_on_private_repo" {
  description = "Security and analysis configuration applied when repository visibility is not public."
  type = object({
    enable_advanced_security                     = bool
    enable_secret_scanning                       = bool
    enable_secret_scanning_push_protection       = bool
    # enable_secret_scanning_ai_detection          = bool
    # enable_secret_scanning_non_provider_patterns = bool
    # enable_code_security                         = bool
  })
  default = {
    enable_advanced_security                     = false
    enable_secret_scanning                       = false
    enable_secret_scanning_push_protection       = false
    # enable_secret_scanning_ai_detection          = false
    # enable_secret_scanning_non_provider_patterns = false
    # enable_code_security                         = false
  }
  nullable = false
}
