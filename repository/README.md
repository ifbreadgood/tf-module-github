# GitHub Repository Terraform Module

Provisions and governs GitHub repositories with opinionated, secure-by-default configurations.

## Architecture & Design Rationale

The module design enforces strict security posture, branch governance, and commit hygiene based on industry standards.

| Area | Implementation & Rationale ("Why it is the way it is") | Best Practice Basis |
| :--- | :----------------------------------------------------- | :------------------ |
| **Accidental Deletion & Drift** | `archive_on_destroy = true` archives rather than permanently deletes the repository on `terraform destroy`. `delete_branch_on_merge = true` cleans up head branches. | **CIS GitHub Benchmark**: Protects source code, release artifacts, and namespace from accidental deletion or takeover; prevents stale branch drift. |
| **Commit History & Merging** | Enforces squash merging only (`allow_squash_merge = true`, merge commits and rebase merges disabled). Standardizes commit messages to `PR_TITLE` and `PR_BODY`. Enables `allow_auto_merge` and `allow_update_branch`. | **Conventional Commits & Trunk-Based Development**: Enforces clean, linear, bisectable history on the default branch, prevents merge bubble pollution, and automates PR promotion. |
| **Branch Governance** | Uses `github_repository_ruleset` targeting `~DEFAULT_BRANCH` (replacing legacy branch protection). Enforces peer review (`required_approving_review_count = 1`), `dismiss_stale_reviews_on_push`, `require_code_owner_review`, `require_last_push_approval`, thread resolution, and blocks force pushes (`non_fast_forward`). | **CIS GitHub Benchmark & OpenSSF Scorecard**: Dynamic ref targeting (`~DEFAULT_BRANCH`) without hardcoding branch names. Invalidates reviews upon push to prevent post-approval malicious tampering. |
| **Security Scanning & GHAS** | Public repositories automatically enable CodeQL, Secret Scanning, and Push Protection. Private repositories require explicit opt-in via `var.security_and_analysis_on_private_repo`. | **OpenSSF & GitHub Licensing Model**: Enforces free security features on public repositories, while avoiding Terraform `422 Unprocessable Entity` errors and unexpected GHAS billing on unlicensed private repos. |
| **Supply Chain Security** | Explicit dependency ordering (`depends_on`) ensures `vulnerability_alerts` is provisioned prior to `dependabot_security_updates`. | **SLSA & Executive Order 14028**: Ensures automated dependency vulnerability detection and security patches while avoiding race conditions during parallel API execution. |
| **Repository Hygiene & Push Rules** | Dedicated push ruleset enforces `max_file_size = 10` MB. | **Git Performance Best Practices**: Blocks accidental check-in of large binary blobs or datasets that permanently bloat git packfiles; enforces Git LFS usage for large files. |
| **Module Boundaries & Validations** | Strict input validation rules (regex for repo naming, enums for visibility and squash formatting). Omits provider and backend blocks; reserves `migrations.tf` for state refactoring. | **HashiCorp Standard Module Structure**: Guarantees fail-fast validation before provider API calls and preserves module reusability across callers without provider lock-in. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | 6.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ------- |
| [github_branch_default.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_dependabot_security_updates.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_dependabot_security_updates) | resource |
| [github_repository_ruleset.default_branch](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_ruleset.max_file_size](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |
| [github_repository_vulnerability_alerts.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_vulnerability_alerts) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allow_auto_merge"></a> [allow\_auto\_merge](#input\_allow\_auto\_merge) | Allow auto-merging pull requests on the repository. | `bool` | `true` | no |
| <a name="input_allow_merge_commit"></a> [allow\_merge\_commit](#input\_allow\_merge\_commit) | Allow merge commits on the repository. | `bool` | `false` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | Allow rebase merges on the repository. | `bool` | `false` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | Allow squash merges on the repository. | `bool` | `true` | no |
| <a name="input_allow_update_branch"></a> [allow\_update\_branch](#input\_allow\_update\_branch) | Always suggest updating pull request branches. | `bool` | `true` | no |
| <a name="input_archive_on_destroy"></a> [archive\_on\_destroy](#input\_archive\_on\_destroy) | Archive the repository instead of deleting on destroy. | `bool` | `true` | no |
| <a name="input_archived"></a> [archived](#input\_archived) | Specifies if the repository should be archived. | `bool` | `false` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | The name of the branch to set as the default. | `string` | `"main"` | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | Automatically delete head branch after a pull request is merged. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | A description of the repository. | `string` | `""` | no |
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | Gitignore template name without extension (e.g. 'Haskell'). | `string` | `null` | no |
| <a name="input_has_discussions"></a> [has\_discussions](#input\_has\_discussions) | Enable GitHub Discussions on the repository. | `bool` | `false` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | Enable GitHub Issues on the repository. | `bool` | `true` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | Enable GitHub Projects on the repository. | `bool` | `false` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | Enable GitHub Wiki on the repository. | `bool` | `false` | no |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | URL of a page describing the project. | `string` | `null` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | Whether this is a template repository. | `bool` | `false` | no |
| <a name="input_license_template"></a> [license\_template](#input\_license\_template) | License template name without extension (e.g. 'mit' or 'agpl-3.0'). | `string` | `"agpl-3.0"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the repository. | `string` | n/a | yes |
| <a name="input_security_and_analysis_on_private_repo"></a> [security\_and\_analysis\_on\_private\_repo](#input\_security\_and\_analysis\_on\_private\_repo) | Security and analysis configuration applied when repository visibility is not public. | <pre>object({<br/>    enable_advanced_security                     = optional(bool, false)<br/>    enable_secret_scanning                       = optional(bool, false)<br/>    enable_secret_scanning_push_protection       = optional(bool, false)<br/>    enable_secret_scanning_ai_detection          = optional(bool, false)<br/>    enable_secret_scanning_non_provider_patterns = optional(bool, false)<br/>    enable_code_security                         = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_squash_merge_commit_message"></a> [squash\_merge\_commit\_message](#input\_squash\_merge\_commit\_message) | Default squash merge commit message ('PR_BODY', 'COMMIT_MESSAGES', or 'BLANK'). | `string` | `"PR_BODY"` | no |
| <a name="input_squash_merge_commit_title"></a> [squash\_merge\_commit\_title](#input\_squash\_merge\_commit\_title) | Default squash merge commit title ('PR_TITLE' or 'COMMIT_OR_PR_TITLE'). | `string` | `"PR_TITLE"` | no |
| <a name="input_template"></a> [template](#input\_template) | Optional configuration to create the repository from a template repository. | <pre>object({<br/>    owner                = string<br/>    repository           = string<br/>    include_all_branches = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | The list of topics of the repository. | `list(string)` | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Repository visibility ('public', 'private', or 'internal'). | `string` | `"public"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
