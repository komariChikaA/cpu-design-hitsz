[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))

Push-Location $repoRoot
try {
    & git config core.hooksPath .githooks
    if ($LASTEXITCODE -ne 0) { throw "Failed to configure the Git hook." }
    Write-Host "Enabled .githooks/post-merge for this clone."
    Write-Host "A pull that updates the branch will now mirror, commit, and push the guide."
} finally {
    Pop-Location
}
