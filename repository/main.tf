resource "github_repository" "this" {
  #checkov:skip=CKV_GIT_1: Repository visibility is configurable via input variable
  name         = var.name
  description  = var.description
  homepage_url = var.homepage_url
  is_template  = var.is_template
  visibility   = var.visibility
  topics       = var.topics

  has_issues      = var.has_issues
  has_discussions = var.has_discussions
  has_projects    = var.has_projects
  has_wiki        = var.has_wiki

  allow_merge_commit  = var.allow_merge_commit
  allow_squash_merge  = var.allow_squash_merge
  allow_rebase_merge  = var.allow_rebase_merge
  allow_auto_merge    = var.allow_auto_merge
  allow_update_branch = var.allow_update_branch

  squash_merge_commit_title   = var.squash_merge_commit_title
  squash_merge_commit_message = var.squash_merge_commit_message
  delete_branch_on_merge      = var.delete_branch_on_merge

  auto_init          = true
  gitignore_template = var.gitignore_template
  license_template   = var.license_template

  archived           = var.archived
  archive_on_destroy = var.archive_on_destroy

  dynamic "template" {
    for_each = var.template != null ? [var.template] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }

  security_and_analysis {
    dynamic "advanced_security" {
      for_each = var.visibility != "public" && var.security_and_analysis_on_private_repo.enable_advanced_security ? ["enabled"] : []
      content {
        status = advanced_security.value
      }
    }
    code_security {
      status = var.visibility == "public" ? "enabled" : var.security_and_analysis_on_private_repo.enable_code_security ? "enabled" : "disabled"
    }
    secret_scanning_ai_detection {
      status = var.visibility == "public" ? "enabled" : var.security_and_analysis_on_private_repo.enable_secret_scanning_ai_detection ? "enabled" : "disabled"
    }
    secret_scanning_non_provider_patterns {
      status = var.visibility == "public" ? "enabled" : var.security_and_analysis_on_private_repo.enable_secret_scanning_non_provider_patterns ? "enabled" : "disabled"
    }
    secret_scanning {
      status = var.visibility == "public" ? "enabled" : var.security_and_analysis_on_private_repo.enable_secret_scanning ? "enabled" : "disabled"
    }
    secret_scanning_push_protection {
      status = var.visibility == "public" ? "enabled" : var.security_and_analysis_on_private_repo.enable_secret_scanning_push_protection ? "enabled" : "disabled"
    }
  }
}

resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.this.name
}

resource "github_repository_dependabot_security_updates" "this" {
  enabled    = true
  repository = github_repository.this.name
  depends_on = [github_repository_vulnerability_alerts.this]
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.default_branch
}

resource "github_repository_ruleset" "default_branch" {
  name        = "default-branch"
  enforcement = "active"
  target      = "branch"
  repository  = github_repository.this.name

  conditions {
    ref_name {
      exclude = []
      include = ["~DEFAULT_BRANCH"]
    }
  }

  rules {
    non_fast_forward = true

    pull_request {
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
      required_approving_review_count   = 1
    }

    dynamic "required_code_scanning" {
      for_each = var.visibility == "public" ? ["codeql"] : []
      content {
        required_code_scanning_tool {
          alerts_threshold          = "all"
          security_alerts_threshold = "all"
          tool                      = "CodeQL"
        }
      }
    }
  }

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  depends_on = [github_branch_default.this]
}

# push rules not allowed on public repos
resource "github_repository_ruleset" "max_file_size" {
  count = var.visibility != "public" ? 1 : 0

  name        = "max-file-size"
  enforcement = "active"
  target      = "push"
  repository  = github_repository.this.name

  rules {
    max_file_size {
      max_file_size = 10
    }
  }
}
