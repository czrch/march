# GitHub CLI (gh) Agent Reference

## Authentication

```bash
gh auth status                    # Check auth
gh auth login                     # Login
gh repo set-default [owner/repo]  # Set default repo
```

## Repository

```bash
# View
gh repo view [owner/repo]
gh repo view --json name,description,url,isPrivate,defaultBranch

# Edit
gh repo edit --description "desc"
gh repo edit --homepage "url"
gh repo edit --visibility public|private|internal
gh repo edit --enable-issues=true|false
gh repo edit --enable-wiki=true|false
gh repo edit --default-branch main
gh repo edit --add-topic "topic" --remove-topic "old"

# Create/Clone/Fork
gh repo create my-repo --public|--private [--description "desc"]
gh repo clone owner/repo [path]
gh repo fork owner/repo [--clone]

# List
gh repo list owner [--limit 100] [--json name,url,isPrivate]
```

**JSON fields**: name, description, url, homepageUrl, isPrivate, isFork, isArchived, defaultBranch, createdAt, updatedAt, pushedAt, stargazerCount, forkCount, watchers, openIssuesCount, licenseInfo, primaryLanguage, languages, owner

## Pull Requests

```bash
# List
gh pr list [--state all|closed|merged]
gh pr list [--author @me|username] [--assignee @me|username]
gh pr list [--label "bug,priority"] [--limit 100]
gh pr list --json number,title,state,url,author,reviewDecision

# View
gh pr view [123|url]
gh pr view 123 --json title,body,state,author,reviews,commits
gh pr view 123 --comments
gh pr view 123 --web

# Checks
gh pr checks [123]
gh pr checks --watch
gh pr checks --json name,state,conclusion,detailsUrl

# Diff
gh pr diff 123 [--patch] [--name-only]

# Create
gh pr create [--title "t" --body "b"]
gh pr create --base main --head branch
gh pr create --draft
gh pr create --fill|--fill-first
gh pr create --assignee @me --label bug --reviewer user

# Checkout
gh pr checkout 123

# Review
gh pr review 123 --approve|--request-changes|--comment [--body "msg"]

# Merge
gh pr merge 123 --merge|--squash|--rebase [--delete-branch]
gh pr merge 123 --auto

# Edit
gh pr edit 123 --title "new" --body "new"
gh pr edit 123 --add-assignee user --remove-assignee user
gh pr edit 123 --add-label bug --remove-label wontfix
gh pr edit 123 --add-reviewer user

# State
gh pr close 123 [--delete-branch]
gh pr reopen 123
gh pr ready 123
```

**JSON fields**: number, title, state, url, headRefName, baseRefName, createdAt, updatedAt, closedAt, mergedAt, author, assignees, labels, isDraft, mergeable, reviewDecision, statusCheckRollup, commits

## GitHub Actions

```bash
# List Runs
gh run list [--limit 50]
gh run list --workflow workflow.yml
gh run list --branch main
gh run list --event push|pull_request
gh run list --status completed|in_progress|failure
gh run list --json databaseId,status,conclusion,workflowName,event,headBranch

# View Run
gh run view [123456]
gh run view 123456 --json jobs,conclusion,status,workflowName
gh run view 123456 --log [--log-failed]
gh run view 123456 --web

# Watch
gh run watch [123456] [--exit-status]

# Re-run
gh run rerun 123456 [--failed]

# Artifacts
gh run download 123456 [--name artifact] [--dir path]

# Control
gh run cancel 123456
gh run delete 123456

# Workflows
gh workflow list [--json name,path,state,id]
gh workflow view workflow.yml [--web]
gh workflow enable|disable workflow.yml
gh workflow run workflow.yml [--ref branch] [-f input1=val1]
```

**Run JSON fields**: databaseId, name, status, conclusion, workflowName, workflowDatabaseId, event, headBranch, headSha, createdAt, updatedAt, startedAt, url, jobs

## Issues

```bash
# List
gh issue list [--state all|closed]
gh issue list [--author @me] [--assignee @me]
gh issue list [--label "bug"] [--limit 100]
gh issue list --json number,title,state,labels,author,assignees

# View
gh issue view 123 [--comments] [--web]
gh issue view 123 --json title,body,state,labels,assignees

# Create
gh issue create [--title "t" --body "b"]
gh issue create --label bug --assignee @me
gh issue create --web

# Edit
gh issue edit 123 --title "new" --body "new"
gh issue edit 123 --add-label bug --remove-label wontfix
gh issue edit 123 --add-assignee user --remove-assignee user

# State
gh issue close 123 [--reason "completed"|"not planned"]
gh issue reopen 123

# Comment
gh issue comment 123 --body "text"

# Pin
gh issue pin|unpin 123
```

**JSON fields**: number, title, state, body, url, createdAt, updatedAt, closedAt, author, assignees, labels, milestone, comments, isPullRequest

## Releases

```bash
# List
gh release list [--limit 50]
gh release list --json tagName,name,createdAt,publishedAt,isPrerelease

# View
gh release view [v1.0.0] [--web]
gh release view v1.0.0 --json tagName,name,body,assets

# Create
gh release create v1.0.0 [--title "t" --notes "n"]
gh release create v1.0.0 --draft|--prerelease
gh release create v1.0.0 --notes-file CHANGELOG.md
gh release create v1.0.0 --generate-notes
gh release create v1.0.0 file1.zip file2.tar.gz

# Edit
gh release edit v1.0.0 --title "new" --notes "new"
gh release edit v1.0.0 --draft=false --prerelease=false

# Delete
gh release delete v1.0.0 [--yes]

# Assets
gh release download v1.0.0 [--pattern "*.tar.gz"] [--archive zip|tar.gz]
gh release upload v1.0.0 file.zip [--clobber]
```

**JSON fields**: tagName, name, body, createdAt, publishedAt, isDraft, isPrerelease, isLatest, url, assets, author

## Common Patterns

```bash
# Get current PR number
gh pr view --json number --jq '.number'

# Check if PR exists for branch
gh pr list --head branch --json number --jq '.[0].number'

# Get latest run status
gh run list --limit 1 --json conclusion --jq '.[0].conclusion'

# Get PR review status (APPROVED|CHANGES_REQUESTED|REVIEW_REQUIRED|null)
gh pr view 123 --json reviewDecision --jq '.reviewDecision'

# List failed runs
gh run list --status failure --limit 10

# Export to JSON
gh pr list --json number,title,state,url > prs.json
gh issue list --json number,title,state,url > issues.json

# Check mergeable status
gh pr view 123 --json mergeable,mergeStateStatus --jq '.'

# Batch approve (caution!)
for pr in $(gh pr list --json number --jq '.[].number'); do
  gh pr review $pr --approve --body "LGTM"
done

# Monitor CI with exit code
gh run watch --exit-status && echo "Success" || echo "Failed"

# Get latest release tag
gh release view --json tagName --jq '.tagName'
```

## Agent Tips

- Always use `--json` for structured data
- Use `jq` for JSON processing (or `--jq` flag)
- Check `gh auth status` before automation
- Use `--repo owner/repo` to operate on any repo without cd
- Check exit codes `$?` for error handling
- Default limit is often 30, use `--limit` for more
- Most commands assume current repo/branch context
- Add `--json` with no fields to discover available fields
- Watch commands can hang if workflow stuck
- Be aware of GitHub API rate limits
