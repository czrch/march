# Review Uncommitted Changes Workflow

## Objective
Conduct a thorough, contextual, and in-depth code review of all uncommitted changes in the current project, providing actionable feedback on code quality, potential issues, and improvements.

## Prerequisites
- Active git repository with uncommitted changes
- Access to project files and history
- Understanding of project context and conventions

## Workflow Steps

### 1. Initial Analysis
**Identify uncommitted changes:**
- Run `git status` to see modified, added, and deleted files
- Run `git diff` to view line-by-line changes in tracked files
- Run `git diff --cached` to review staged changes
- Check for untracked files that may be relevant

**Gather context:**
- Identify the scope and nature of changes (feature, bugfix, refactor, etc.)
- Understand which modules/components are affected
- Review commit history context: `git log --oneline -10`

### 2. Structural Review
**Examine file organization:**
- Are new files placed in appropriate directories?
- Do file names follow project conventions?
- Are there any files that should be in .gitignore?
- Check for inadvertent binary or large files

**Assess architectural impact:**
- Do changes maintain existing architectural patterns?
- Are new dependencies justified and documented?
- Is there proper separation of concerns?
- Are interfaces and contracts preserved?

### 3. Code Quality Analysis
**Review each changed file systematically:**
- Read the full file context, not just the diff
- Verify changes align with the file's purpose
- Check for code duplication or opportunities for DRY
- Assess function/method complexity and length
- Evaluate variable and function naming clarity

**Language-specific best practices:**
- Proper error handling and edge cases
- Memory management and resource cleanup
- Type safety and null checks
- Async/await patterns and promise handling
- Security considerations (input validation, XSS, SQL injection, etc.)

### 4. Logic and Correctness
**Analyze algorithmic soundness:**
- Verify logic flow and conditional branches
- Check for off-by-one errors and boundary conditions
- Identify potential race conditions or concurrency issues
- Review loop invariants and termination conditions
- Test data flow and state management

**Evaluate test coverage:**
- Are there tests for new functionality?
- Do existing tests need updates?
- Are edge cases covered?
- Check test quality and assertions

### 5. Performance and Efficiency
**Identify performance concerns:**
- Unnecessary computations or redundant operations
- Database query efficiency (N+1 problems, missing indexes)
- Memory usage patterns and potential leaks
- Network call optimization and caching opportunities
- Big O complexity of new algorithms

### 6. Maintainability Review
**Code readability:**
- Clear and consistent formatting
- Appropriate comments for complex logic (not obvious code)
- Self-documenting code with meaningful names
- Proper use of language idioms

**Documentation:**
- Are public APIs documented?
- Do complex functions have explanatory comments?
- Is README or related docs updated if needed?
- Are breaking changes clearly marked?

### 7. Integration and Dependencies
**Dependency analysis:**
- Review changes to package.json, requirements.txt, go.mod, etc.
- Check for security vulnerabilities in new dependencies
- Verify version compatibility
- Assess impact on bundle size or build time

**API and interface changes:**
- Are breaking changes necessary and documented?
- Is backward compatibility maintained where needed?
- Are deprecation warnings added for old APIs?
- Do contracts match implementation?

### 8. Security Review
**Security considerations:**
- Authentication and authorization checks
- Input validation and sanitization
- Secure data storage and transmission
- Proper secret management (no hardcoded credentials)
- Protection against common vulnerabilities (OWASP Top 10)
- Logging sensitive data exposure

### 9. Git and Version Control
**Commit readiness:**
- Are changes logically grouped?
- Should changes be split into multiple commits?
- Are there debug statements or console.logs to remove?
- Check for commented-out code that should be deleted
- Verify no temporary or experimental code remains

### 10. Comprehensive Summary
**Compile findings into categories:**
- **Critical Issues**: Must fix before commit (bugs, security, breaking changes)
- **High Priority**: Should fix (code quality, maintainability issues)
- **Medium Priority**: Consider addressing (performance, conventions)
- **Low Priority**: Nice to have (minor refactoring, style improvements)
- **Positive Observations**: Well-implemented aspects worth noting

**Provide actionable recommendations:**
- Specific line references for issues
- Suggested code improvements with examples
- Links to relevant documentation or standards
- Testing strategies for risky changes

### 11. Context-Aware Insights
**Project-specific considerations:**
- Review against project's coding standards and style guide
- Consider team conventions and patterns used elsewhere
- Evaluate consistency with existing codebase
- Check adherence to project architecture decisions

**Business logic validation:**
- Do changes align with requirements?
- Are there unintended side effects?
- Is the user experience impact considered?
- Are there implications for existing features?

## Output Format

### Summary
Brief overview of the changes and overall assessment.

### Files Changed
List of all modified files with brief description of changes.

### Detailed Findings
For each significant issue or observation:
- **File**: path/to/file.ext
- **Lines**: 45-67
- **Severity**: Critical/High/Medium/Low
- **Issue**: Description of the problem
- **Recommendation**: Specific fix or improvement
- **Example**: Code snippet if applicable

### Metrics
- Total files changed
- Lines added/removed
- Complexity assessment
- Test coverage impact

### Final Recommendation
Clear verdict: Ready to commit / Needs revision / Requires significant refactoring

## Notes
- Balance thoroughness with pragmatism
- Consider project maturity and technical debt context
- Focus on high-impact issues over minor style preferences
- Be constructive and educational in feedback
- Acknowledge good practices and improvements
