# Git Rules

## Branch Naming

- Use descriptive branch names with the following prefixes:
  - `feature/` - New features (e.g. `feature/user-authentication`)
  - `fix/` - Bug fixes (e.g. `fix/login-error`)
  - `docs/` - Documentation changes (e.g. `docs/api-guide`)
  - `chore/` - Maintenance tasks (e.g. `chore/update-dependencies`)
  - `refactor/` - Code refactoring (e.g. `refactor/payment-service`)
  - `test/` - Test additions or changes (e.g. `test/user-endpoints`)
  - `perf/` - Performance improvements (e.g. `perf/database-queries`)
  - `hotfix/` - Urgent production fixes (e.g. `hotfix/security-patch`)
- Use kebab-case for branch names (lowercase with hyphens)
- Keep branch names concise but descriptive

## Commit Messages

- Commit messages MUST use lowercase conventional prefixes:
  - `feat: ...`
  - `fix: ...`
  - `docs: ...`
  - `chore: ...`
  - `refactor: ...`
  - `test: ...`
  - `perf: ...`
  - `ci: ...`
  - `build: ...`
  - `style: ...`
  - `revert: ...`
- Keep the subject line:
  - lowercase
  - imperative mood (e.g. "add", "remove", "update", "fix")
  - concise (aim <= 72 chars)
- Optional scope is allowed if the repo uses it:
  - `feat(ui): add merch grid`
  - `fix(api): handle missing env var`

Use the following strategy:

- One logical change per commit.
- Do not mix refactors with behavior changes unless necessary.
- Avoid drive-by formatting changes unrelated to the task.
- If you must do a large change, split it into a sequence:
  1) refactor prep (no behavior change)
  2) feature/fix
  3) docs/tests