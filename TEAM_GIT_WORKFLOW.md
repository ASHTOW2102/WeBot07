# Simple team workflow

Each person always works on their own branch:

- Ashish: `ashish`
- Muqeem: `muqeem`
- Shareeq: `shareeq`
- LU: `lu`

Do not push directly to `main`. Only Ashish (`@ASHTOW2102`) accepts and merges
Pull Requests into `main`.

## Each member makes changes

Replace `YOUR_BRANCH` with your assigned branch name:

```powershell
git switch YOUR_BRANCH
git pull --ff-only origin YOUR_BRANCH
```

Make and test the changes, then run:

```powershell
git add --all
git status
git commit -m "Describe your change"
git push origin YOUR_BRANCH
```

## Open a Pull Request

On GitHub, open a Pull Request with:

- Base: `main`
- Compare: your own branch

Check **Files changed**, explain what you changed, and request Ashish
(`@ASHTOW2102`) as reviewer. Do not merge it yourself.

## Ashish reviews and merges

Ashish compares the files and tests the Webots project. Immediately before
accepting the Pull Request, Ashish creates a backup:

```powershell
git switch main
git pull --ff-only origin main
.\scripts\backup-main.ps1
```

After the backup is published, Ashish accepts and merges the Pull Request on
GitHub. Repository rules prevent other members from changing `main`.

## After a Pull Request is merged

The member updates their own branch with the new `main`:

```powershell
git switch YOUR_BRANCH
git fetch origin
git merge origin/main
git push origin YOUR_BRANCH
```

Then they continue working on the same assigned branch.
