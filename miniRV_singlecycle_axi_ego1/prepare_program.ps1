param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('0_uart_test', '1_formatIO_test', '2_sort_test')]
    [string]$TestName
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$testCoe = Join-Path $scriptDir "software\c_test\$TestName\main.coe"
$savedCoe = Join-Path $scriptDir "outputs\programs\$TestName\main.coe"
$targetMem = Join-Path $scriptDir 'src\coe\main.mem'
$converter = Join-Path $scriptDir 'tools\bin2mem.py'

if (Test-Path -LiteralPath $savedCoe -PathType Leaf) {
    $sourceCoe = $savedCoe
} elseif (Test-Path -LiteralPath $testCoe -PathType Leaf) {
    $sourceCoe = $testCoe
} else {
    throw "No compiled main.coe found for $TestName. Run prepare_program.sh on Linux first."
}

python $converter $sourceCoe $targetMem
if ($LASTEXITCODE -ne 0) {
    throw 'bin2mem.py failed'
}

$wordCount = (Get-Content -LiteralPath $targetMem).Count
if ($wordCount -ne 38400) {
    throw "Expected 38400 words in main.mem, found $wordCount"
}

Write-Host "Prepared $TestName from $sourceCoe"
Write-Host "Updated $targetMem ($wordCount words)"
Write-Host 'Next step in Vivado Tcl Console: source rebuild_ego1.tcl'
