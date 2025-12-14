# Workflow: Prepare Commit (Do Not Push)

Use this workflow when there are local changes that need to be organized into clean, reviewable commits. The goal is to leave the branch in a ready‑to‑push state **without pushing**.

## Objectives
- Logically group all uncommitted changes.
- Create one or more commits with clear, appropriate messages/descriptions.
- Bump the project version if a versioning mechanism exists.
- Run pre‑commit hooks at least once (preferably more) before committing, if available.
- Build and/or run tests if available.
- Provide a concise summary of what is ready to push.
- **DO NOT PUSH.**

## Inputs / Assumptions
- You are in a git repository with uncommitted changes.
- Project may or may not have pre‑commit, tests, build scripts, or explicit versioning.
- Follow any repo conventions found in `AGENTS.md`, `CONTRIBUTING.md`, or existing commit history.

## Steps

### 1) Inventory current state
1. Show status and staged/unstaged diffs:
   - `git status -sb`
   - `git diff`
   - `git diff --staged`
2. If changes are large or scattered, list files by area:
   - `git diff --name-status`
3. Identify any generated, vendored, or irrelevant files and exclude them if appropriate.

### 2) Propose logical groupings
1. Cluster changes by purpose and scope, e.g.:
   - feature vs. refactor vs. fix vs. docs
   - by module/package/directory
   - by independent logical steps
2. For each cluster, describe:
   - what user‑visible behavior changes (if any)
   - why the change is needed
   - any risks or follow‑ups
3. Confirm grouping with the user before staging if ambiguous.

### 3) Run pre‑commit early (if available)
1. Detect pre‑commit configuration:
   - look for `.pre-commit-config.yaml`, `pre-commit` in `pyproject.toml`, `package.json`, `Makefile`, etc.
2. If present, run on all files:
   - `pre-commit run --all-files` (or repo equivalent)
3. Fix issues, rerun pre‑commit. Repeat until clean or only justified skips remain.
4. If no pre‑commit exists, note that and continue.

### 4) Stage and commit each group
For each logical group:
1. Stage only the files/hunks belonging to the group:
   - prefer `git add -p` / `git add <paths>`
2. Re‑review staged diff:
   - `git diff --staged`
3. Write a commit message that matches repo style:
   - imperative, specific, and scoped
   - include context in body if needed (what/why/how)
4. Commit:
   - `git commit`
5. If pre‑commit runs on commit and fails, fix and re‑commit (amend if appropriate).

### 5) Bump version (if available)
1. Detect versioning scheme:
   - `package.json` (npm/yarn/pnpm)
   - `pyproject.toml` / `setup.cfg`
   - `Cargo.toml`, `pom.xml`, `gradle.properties`, etc.
2. Determine bump level from changes:
   - patch for fixes
   - minor for backwards‑compatible features
   - major for breaking changes
3. Apply bump using repo tooling if present:
   - e.g., `npm version patch|minor|major --no-git-tag-version`
   - or update version file manually if that’s the norm.
4. Run pre‑commit/tests again if version bump touches code or metadata.
5. Commit the version bump separately unless repo conventions say otherwise.
6. If no explicit versioning exists, state that clearly.

### 6) Build and/or run tests (if available)
1. Detect build/test commands:
   - `package.json` scripts, `Makefile`, `justfile`, CI configs, `README`, etc.
2. Run the narrowest relevant checks first, then full suite if feasible:
   - examples: `npm test`, `pnpm test`, `pytest`, `cargo test`, `go test ./...`, `make test`, `make build`
3. Fix failures, rerun until passing.
4. If no tests/build exist, note that and proceed.

### 7) Final verification
1. Ensure working tree is clean:
   - `git status -sb`
2. Review commit list:
   - `git log --oneline -n <N>`
3. Sanity check that commits are:
   - logically separated
   - well messaged
   - passing pre‑commit/tests/build
   - include version bump if applicable

### 8) Provide ready‑to‑push summary (do not push)
In chat, provide:
1. A bullet list of commits (hash + subject).
2. One‑line purpose for each commit.
3. Any version bump performed (old → new).
4. Commands run and their results (pre‑commit/tests/build).
5. Any known limitations, TODOs, or follow‑ups.
6. Explicit reminder: **branch is ready, but nothing was pushed**.

## Guardrails
- **Never run `git push`.**
- Do not squash or rebase unless the user asks.
- Do not include unrelated formatting or drive‑by refactors in commits.
- Keep commits reviewable and minimal for their intent.

