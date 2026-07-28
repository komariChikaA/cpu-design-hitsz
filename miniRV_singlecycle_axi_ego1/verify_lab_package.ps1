param(
    [switch]$RequireProgramArtifacts
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )
    if (-not $Condition) {
        throw $Message
    }
}

function Read-ProgramImage {
    param(
        [string]$TestName,
        [int]$TestNumber
    )

    $programDir = Join-Path $scriptDir "outputs\programs\$TestName"
    $memPath = Join-Path $programDir 'main.mem'
    $coePath = Join-Path $programDir 'main.coe'
    $binPath = Join-Path $programDir 'main.bin'
    $mapPath = Join-Path $programDir 'main.map'
    $asmPath = Join-Path $programDir 'main.s'

    foreach ($path in @($memPath, $coePath, $binPath, $mapPath, $asmPath)) {
        Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Missing artifact: $path"
    }

    $words = @(Get-Content -LiteralPath $memPath)
    Assert-True ($words.Count -eq 38400) "$TestName main.mem has $($words.Count) words"
    $invalidWords = @($words | Where-Object { $_ -notmatch '^[0-9A-Fa-f]{8}$' })
    Assert-True ($invalidWords.Count -eq 0) "$TestName main.mem contains invalid words"

    $coeText = Get-Content -LiteralPath $coePath -Raw -Encoding ASCII
    $coeWords = [regex]::Matches(
        $coeText,
        '(?m)^[0-9A-Fa-f]{8}[,;]?\r?$'
    ).Count
    Assert-True ($coeWords -gt 0) "$TestName COE contains no program words"
    Assert-True ($coeWords -le 38400) "$TestName COE is larger than 38400 words"

    $binLength = (Get-Item -LiteralPath $binPath).Length
    Assert-True (
        $binLength -eq ($coeWords * 4)
    ) "$TestName BIN size is $binLength bytes"

    $binaryText = [Text.Encoding]::ASCII.GetString(
        [IO.File]::ReadAllBytes($binPath)
    )
    Assert-True (
        $binaryText.Contains('2024311081_2024311453')
    ) "$TestName does not contain both student IDs"
    Assert-True (
        $binaryText.Contains("Test #$TestNumber")
    ) "$TestName does not contain its Test #$TestNumber marker"

    if ($coeWords -lt 38400) {
        $nonzeroPadding = @(
            $words[$coeWords..38399] |
                Where-Object { $_ -ne '00000000' }
        )
        Assert-True (
            $nonzeroPadding.Count -eq 0
        ) "$TestName contains nonzero padding after the program"
    }

    $hash = (Get-FileHash -LiteralPath $memPath -Algorithm SHA256).Hash
    Write-Host (
        "PASS {0}: program={1} words image=38400 SHA256={2}" -f
        $TestName, $coeWords, $hash
    )
    return $hash
}

$requiredPaths = @(
    'miniRV.xpr',
    'rebuild_ego1.tcl',
    'prepare_program.ps1',
    'src\coe\main.mem',
    'src\rtl\miniRV_SoC.v',
    'src\rtl\cpu_top.v',
    'src\rtl\cpu_core.v',
    'src\rtl\axi_master.v',
    'src\rtl\axi_board_soc.v',
    'src\rtl\board_bram.v',
    'src\rtl\ip\IROM\IROM.xci',
    'src\rtl\ip\DRAM\DRAM.xci',
    'src\rtl\ip\clk_wiz_0\clk_wiz_0.xci',
    'src\xdc\miniRV_SoC.xdc',
    'src\xdc\clock.xdc'
)
foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $scriptDir $relativePath
    Assert-True (
        Test-Path -LiteralPath $fullPath -PathType Leaf
    ) "Missing project file: $relativePath"
}

$xpr = Get-Content -LiteralPath (Join-Path $scriptDir 'miniRV.xpr') -Raw
Assert-True (
    $xpr.Contains('xc7a35tcsg324-1')
) 'miniRV.xpr does not target EGO1 xc7a35tcsg324-1'
Assert-True (
    $xpr.Contains('TopModule" Val="miniRV_SoC"')
) 'miniRV.xpr top module is not miniRV_SoC'

$irom = Get-Content -LiteralPath (
    Join-Path $scriptDir 'src\rtl\ip\IROM\IROM.xci'
) -Raw
$dram = Get-Content -LiteralPath (
    Join-Path $scriptDir 'src\rtl\ip\DRAM\DRAM.xci'
) -Raw
$clock = Get-Content -LiteralPath (
    Join-Path $scriptDir 'src\rtl\ip\clk_wiz_0\clk_wiz_0.xci'
) -Raw
Assert-True ($irom.Contains('"value": "12800"')) 'IROM depth is not 12800'
Assert-True ($dram.Contains('"value": "25600"')) 'DRAM depth is not 25600'
Assert-True (
    $clock.Contains('"CLKOUT1_REQUESTED_OUT_FREQ"') -and
    $clock.Contains('"value": "50"')
) 'Clock output is not configured for 50 MHz'

$selectedPath = Join-Path $scriptDir 'src\coe\main.mem'
$selectedWords = @(Get-Content -LiteralPath $selectedPath)
Assert-True ($selectedWords.Count -eq 38400) 'Selected main.mem is not 38400 words'
$invalidSelectedWords = @(
    $selectedWords | Where-Object { $_ -notmatch '^[0-9A-Fa-f]{8}$' }
)
Assert-True (
    $invalidSelectedWords.Count -eq 0
) 'Selected main.mem contains invalid words'
$selectedHash = (Get-FileHash -LiteralPath $selectedPath -Algorithm SHA256).Hash

$artifactRoots = @(
    '0_uart_test',
    '1_formatIO_test',
    '2_sort_test'
) | ForEach-Object {
    Join-Path $scriptDir "outputs\programs\$_\main.mem"
}
$allArtifactsPresent = @(
    $artifactRoots | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }
).Count -eq $artifactRoots.Count

if ($allArtifactsPresent) {
    $test0Hash = Read-ProgramImage '0_uart_test' 0
    $test1Hash = Read-ProgramImage '1_formatIO_test' 1
    $test2Hash = Read-ProgramImage '2_sort_test' 2

    if ($selectedHash -eq $test0Hash) {
        Write-Host 'Selected program: C_TEST0 (0_uart_test)'
    } elseif ($selectedHash -eq $test1Hash) {
        Write-Host 'Selected program: C_TEST1 (1_formatIO_test)'
    } elseif ($selectedHash -eq $test2Hash) {
        Write-Host 'Selected program: C_TEST2 (2_sort_test)'
    } else {
        throw "Selected main.mem does not match C_TEST0, C_TEST1 or C_TEST2: $selectedHash"
    }
} elseif ($RequireProgramArtifacts) {
    throw 'Program artifacts are missing. Run prepare_program.sh for C_TEST0, C_TEST1 and C_TEST2 first.'
} else {
    Write-Host 'INFO: generated C_TEST artifacts are absent; source/package checks only'
    Write-Host "Selected main.mem SHA256=$selectedHash"
}

$shellScripts = @(Get-ChildItem -LiteralPath $scriptDir -Recurse -Filter '*.sh')
foreach ($shellScript in $shellScripts) {
    $carriageReturns = @(
        [IO.File]::ReadAllBytes($shellScript.FullName) |
            Where-Object { $_ -eq 13 }
    )
    Assert-True (
        $carriageReturns.Count -eq 0
    ) "CRLF found in shell script: $($shellScript.FullName)"
}

Write-Host 'Project: xc7a35tcsg324-1 / miniRV_SoC / 50 MHz'
Write-Host 'LAB PACKAGE CHECK: PASS'
