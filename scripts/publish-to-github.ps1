# Run after: gh auth login
# Creates the GitHub repo, pushes main, adds topics, and enables GitHub Pages.

$ErrorActionPreference = "Stop"
$git = "C:\Program Files\Git\bin\git.exe"
$gh = "C:\Program Files\GitHub CLI\gh.exe"
$repoName = "fire-calculator"

Set-Location (Split-Path -Parent $PSScriptRoot)

& $gh auth status | Out-Null

$hasOrigin = $false
& $git remote 2>$null | ForEach-Object { if ($_ -eq "origin") { $hasOrigin = $true } }

if (-not $hasOrigin) {
  & $gh repo create $repoName --public --source=. --remote=origin --push --description "FIRE calculator: spend-down and perpetual withdrawal projection"
} else {
  & $git push -u origin main
}

& $gh repo edit --add-topic fire --add-topic calculator --add-topic personal-finance --add-topic javascript --add-topic github-pages

& $gh api -X POST "/repos/{owner}/$repoName/pages" `
  -f build_type=legacy `
  -f "source[branch]=main" `
  -f "source[path]=/" 2>$null

if ($LASTEXITCODE -ne 0) {
  Write-Host "Pages may already be enabled. Check: https://github.com/$(& $gh api user -q .login)/$repoName/settings/pages"
} else {
  $user = & $gh api user -q .login
  Write-Host "GitHub Pages will be at: https://$user.github.io/$repoName/"
}
