[CmdletBinding()]
param(
    [uri]$BaseUri = "http://10.249.14.10:2012/",
    [ValidateRange(1, 50000)]
    [int]$MaxFiles = 10000,
    [ValidateRange(1, 600)]
    [int]$TimeoutSec = 30,
    [ValidateRange(0, 10)]
    [int]$Retries = 3
)

$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "sync-site.ps1") `
    -BaseUri $BaseUri `
    -OutputDir "materials" `
    -MaxFiles $MaxFiles `
    -TimeoutSec $TimeoutSec `
    -Retries $Retries `
    -Incremental
