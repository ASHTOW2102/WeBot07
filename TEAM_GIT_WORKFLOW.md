# Safe team Git workflow

`main` is the protected working version. Nobody writes directly to it. Every
change starts in a short-lived feature branch and reaches `main` through a
Pull Request reviewed and merged by Ashish (`@ASHTOW2102`).

## Create a feature branch

Start every task from the latest `main`. Use your name and a short task name:

```powershell
git switch main
git fetch origin --prune
git pull --ff-only origin main
git switch -c feature/your-name-short-task
```

Examples are `feature/muqeem-goalkeeper`, `feature/shareeq-ball-tracking`, and
`feature/lu-team-controller`. Never reuse a branch for an unrelated task.

## Commit and publish the feature

```powershell
git branch --show-current
git status
git add --all
git status
git commit -m "Describe the completed change"
git push -u origin HEAD
```

Check the staged file list before committing. Do not include temporary files,
local settings, generated output, or unrelated work.

## Open and compare the Pull Request

On GitHub, select **Pull requests**, then **New pull request**:

- Base branch: `main`
- Compare branch: your `feature/...` branch

In **Files changed**, inspect every added, changed, and deleted line. Complete
the Pull Request checklist and request Ashish (`@ASHTOW2102`) as reviewer.

## Update a feature branch when main changes

```powershell
git switch feature/your-name-short-task
git fetch origin --prune
git rebase origin/main
git push --force-with-lease
```

Use `git rebase --abort` if conflict resolution goes wrong. Never use plain
`--force`, and never force-push `main`.

## Approval, backup, and merge

Ashish checks the file comparison, runs the affected Webots simulation, and
approves only when it works. Repository protection must require:

- A Pull Request before merging into `main`
- One approving review
- Code-owner review (`.github/CODEOWNERS` makes Ashish the code owner)
- Dismissal of stale approvals after new commits
- Resolved conversations
- No force pushes and no deletion of `main`

Immediately before merging, Ashish creates and publishes a backup branch and
annotated tag from an up-to-date, clean local `main`:

```powershell
git switch main
git pull --ff-only origin main
.\scripts\backup-main.ps1
```

Only after the script reports a published backup does Ashish use **Create a
merge commit** on GitHub. This keeps the feature history and merge boundary
visible.

Do not delete a feature branch until the merge succeeds and the backup branch
and tag are visible on GitHub.

## Recover a bad merge

Do not rewrite shared history. Revert the merge with a new Pull Request:

```powershell
git switch main
git pull --ff-only origin main
git switch -c feature/ashish-revert-bad-merge
git revert -m 1 MERGE_COMMIT_HASH
git push -u origin HEAD
```

The `backup/main-...` branch and `backup-main-...` tag preserve the exact
pre-merge version on GitHub.
