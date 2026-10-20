$ErrorActionPreference = 'Stop'

$branch = git branch --show-current
if ($branch -ne 'main') {
    throw "Backup must be run from main; current branch is '$branch'."
}

if (git status --porcelain) {
    throw 'Working tree is not clean. Commit or stash changes before backup.'
}

git fetch origin main
if ($LASTEXITCODE -ne 0) { throw 'Could not fetch origin/main.' }

$localMain = git rev-parse main
$remoteMain = git rev-parse origin/main
if ($localMain -ne $remoteMain) {
    throw 'Local main does not exactly match origin/main. Pull safely first.'
}

$stamp = Get-Date -Format 'yyyy-MM-dd-HHmmss'
$backupBranch = "backup/main-$stamp"
$backupTag = "backup-main-$stamp"

git branch $backupBranch $localMain
if ($LASTEXITCODE -ne 0) { throw 'Could not create backup branch.' }

git tag -a $backupTag $localMain -m "Backup before Pull Request merge at $stamp"
if ($LASTEXITCODE -ne 0) { throw 'Could not create backup tag.' }

git push origin "refs/heads/$backupBranch" "refs/tags/$backupTag"
if ($LASTEXITCODE -ne 0) { throw 'Could not publish backup branch and tag.' }

Write-Host "Backup published: $backupBranch and $backupTag at $localMain"
