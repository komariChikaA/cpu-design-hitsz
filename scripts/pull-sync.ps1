[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))

Push-Location $repoRoot
try {
    # Prevent an installed post-merge hook from running the same sync twice.
    $env:CPU_MIRROR_SKIP_HOOK = "1"
    try {
        & git pull
        if ($LASTEXITCODE -ne 0) { throw "git pull failed; the mirror was not started." }
    } finally {
        Remove-Item Env:CPU_MIRROR_SKIP_HOOK -ErrorAction SilentlyContinue
    }

    & (Join-Path $PSScriptRoot "sync-and-publish.ps1") -Push
} finally {
    Pop-Location
}
