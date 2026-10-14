# Safe team Git workflow

This repository uses `main` as the protected, working version of the project.
Each team member works only on their own branch:

- Ashish: `ashish`
- Muqeem: `muqeem`
- Shareeq: `shareeq`
- LU: `lu`

## One-time setup for each member

Clone the repository, then switch to your own branch:

```powershell
git clone https://github.com/ASHTOW2102/WeBot07.git
cd WeBot07
git switch ashish     # Replace with your assigned branch name
git pull --ff-only origin ashish
```

Configure your identity if Git asks for it:

```powershell
git config user.name "Your Name"
git config user.email "your-email@example.com"
```

## Normal daily work

Always confirm the branch before editing:

```powershell
git status
git branch --show-current
```

Save small, meaningful commits and push them to GitHub frequently:

```powershell
git add --all
git status
git commit -m "Describe the completed change"
git push origin HEAD
```

Do not work directly on `main`, and do not share one working folder between
people. Each member should have their own clone.

## Bring the latest `main` into a member branch

Do this before asking to merge your work:

```powershell
git switch YOUR_BRANCH
git status                         # Must be clean
git fetch origin --prune
git rebase origin/main
git push --force-with-lease origin YOUR_BRANCH
```

If a rebase conflict occurs, edit the marked files, test the project, then run:

```powershell
git add PATH_TO_FIXED_FILE
git rebase --continue
```

Use `git rebase --abort` to return safely to the state before the rebase.
Never use plain `--force`; use only `--force-with-lease` on your own branch.

## Safe merge into `main` with a backup

Only the integration lead should run these commands. Replace `YOUR_BRANCH`
with one of `ashish`, `muqeem`, `shareeq`, or `lu`. Replace the timestamp with
the current date and time, for example `2026-10-14-1530`.

```powershell
git switch main
git status                              # Stop unless the tree is clean
git pull --ff-only origin main
git branch backup/main-2026-10-14-1530
git tag -a backup-2026-10-14-1530 -m "Backup before merging YOUR_BRANCH"
git push origin backup/main-2026-10-14-1530 backup-2026-10-14-1530
git merge --no-ff origin/YOUR_BRANCH
```

Now run the Webots simulation/tests. Push `main` only after they pass:

```powershell
git push origin main
```

If the merge has conflicts or tests fail before committing the merge:

```powershell
git merge --abort
```

If a bad merge was already pushed, do not rewrite shared history. Restore it
with a new commit:

```powershell
git switch main
git pull --ff-only origin main
git revert -m 1 MERGE_COMMIT_HASH
git push origin main
```

The backup branch and tag remain on GitHub, so the exact pre-merge state is
recoverable even if a computer is lost. GitHub branch protection should also
be enabled for `main`: require a pull request, at least one approval, required
tests, and disable force pushes and deletion.

## Recommended review method

After pushing a member branch, open a GitHub Pull Request from that branch into
`main`. Another member reviews it. The integration lead then follows the backup
steps above and merges only after Webots/testing succeeds.
