[CmdletBinding()]
param(
    [switch]$Push,
    [uri]$BaseUri = "https://cpu-design.p.cs-lab.top/"
)

$ErrorActionPreference = "Stop"
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))

& (Join-Path $PSScriptRoot "sync-site.ps1") -BaseUri $BaseUri

Push-Location $repoRoot
try {
    & git add -A -- mirror
    if ($LASTEXITCODE -ne 0) { throw "git add failed." }

    & git diff --cached --quiet -- mirror
    $diffExit = $LASTEXITCODE
    if ($diffExit -eq 0) {
        Write-Host "The website is unchanged; no commit is needed."
        return
    }
    if ($diffExit -ne 1) { throw "git diff failed with exit code $diffExit." }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
    & git commit -m "chore: sync experiment guide ($timestamp)" -- mirror
    if ($LASTEXITCODE -ne 0) { throw "git commit failed. Check Git identity and repository state." }

    if ($Push) {
        $branch = (& git branch --show-current).Trim()
        if ($LASTEXITCODE -ne 0 -or -not $branch) { throw "Cannot determine the current branch." }
        & git push origin "HEAD:$branch"
        if ($LASTEXITCODE -ne 0) { throw "git push failed. The local mirror commit was kept for a later push." }
    } else {
        Write-Host "Created a local commit without pushing it."
    }
} finally {
    Pop-Location
}
