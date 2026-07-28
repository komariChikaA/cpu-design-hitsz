[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )
    if (-not $Condition) {
        throw $Message
    }
}

& (Join-Path $root 'verify_package.ps1')

$requiredFiles = @(
    'START_COREMARK_ACCEPTANCE.md',
    'COREMARK_BUILD_INFO.md',
    'software/c_test/4_coremark/Makefile',
    'software/c_test/4_coremark/compile.sh',
    'software/c_test/4_coremark/main.coe',
    'software/c_test/4_coremark/main.s',
    'software/c_test/4_coremark/prebuilt/coremark.elf',
    'software/c_test/4_coremark/prebuilt/coremark.bin',
    'software/c_test/4_coremark/src/common/ram.lds',
    'software/c_test/4_coremark/src/common/sc_print.c',
    'software/c_test/4_coremark/src/coremark/core_portme.c',
    'software/c_test/4_coremark/src/coremark/src/core_main.c',
    'software/c_test/4_coremark/src/coremark/src/core_list_join.c',
    'software/c_test/4_coremark/src/coremark/src/core_matrix.c',
    'software/c_test/4_coremark/src/coremark/src/core_state.c'
)

foreach ($relativePath in $requiredFiles) {
    Assert-True (Test-Path -LiteralPath (Join-Path $root $relativePath) -PathType Leaf) `
        "Missing CoreMark file: $relativePath"
}
Write-Host 'PASS: CoreMark sources, build script and acceptance documents are present'

$memoryPath = Join-Path $root 'src/coe/main.mem'
$expectedHash = '6ACE2393153B87ACAFA9B740979E265ABDA63CF6D223BBCF8DAEB32FF8729D2D'
$actualHash = (Get-FileHash -LiteralPath $memoryPath -Algorithm SHA256).Hash
Assert-True ($actualHash -eq $expectedHash) `
    "Wrong CoreMark main.mem. Expected $expectedHash, found $actualHash"

$memoryWords = [IO.File]::ReadAllLines($memoryPath)
Assert-True ($memoryWords.Count -eq 38400) `
    "CoreMark main.mem must contain 38400 words, found $($memoryWords.Count)"
Write-Host "PASS: formal 700-iteration CoreMark image hash matches ($actualHash)"

$expectedElfHash = 'F3D280467C4889EDFD45E3F289D1C24F7E001F60C7FE321BA26716965E2D6070'
$expectedBinHash = 'F7FD6A05E9A3E66E88590837E9709A86F3C69D4FD38BD5C798FCED6760255B59'
$actualElfHash = (Get-FileHash -LiteralPath (
    Join-Path $root 'software/c_test/4_coremark/prebuilt/coremark.elf') -Algorithm SHA256).Hash
$actualBinHash = (Get-FileHash -LiteralPath (
    Join-Path $root 'software/c_test/4_coremark/prebuilt/coremark.bin') -Algorithm SHA256).Hash
Assert-True ($actualElfHash -eq $expectedElfHash) 'Prebuilt CoreMark ELF hash is wrong'
Assert-True ($actualBinHash -eq $expectedBinHash) 'Prebuilt CoreMark binary hash is wrong'
Write-Host 'PASS: prebuilt CoreMark ELF and binary hashes match the formal image'

$portText = [IO.File]::ReadAllText(
    (Join-Path $root 'software/c_test/4_coremark/src/coremark/core_portme.c'))
$coreMainText = [IO.File]::ReadAllText(
    (Join-Path $root 'software/c_test/4_coremark/src/coremark/src/core_main.c'))
$makeText = [IO.File]::ReadAllText(
    (Join-Path $root 'software/c_test/4_coremark/Makefile'))
$printText = [IO.File]::ReadAllText(
    (Join-Path $root 'software/c_test/4_coremark/src/common/sc_print.c'))

Assert-True ($portText -match '#define\s+MHZ\s+50\b') 'CoreMark MHZ is not 50'
Assert-True ($portText.Contains('2024311081_2024311453')) 'Student IDs are missing'
Assert-True ($portText.Contains('0xC0A5u')) 'CoreMark success LED marker is missing'
Assert-True ($portText.Contains('0xC0DE600Du')) 'CoreMark success display marker is missing'
Assert-True ($portText.Contains('t_h_before != t_h_after')) `
    'Atomic 64-bit board timer read is missing'
Assert-True ($coreMainText.Contains('board_result(total_errors);')) `
    'CoreMark result is not connected to board indicators'
Assert-True ($coreMainText.Contains('Must execute for at least 10 secs')) `
    'Official minimum runtime validation is missing'
Assert-True ($makeText -match 'ITERATIONS\s*\?=\s*700') `
    'CoreMark default iteration count is not 700'
Assert-True ($makeText -match 'ARCH\s*\?=\s*im') `
    'CoreMark default architecture is not RV32IM'
Assert-True ($printText.Contains('"%d.%03d"')) `
    'Fixed three-decimal score output is missing'
Write-Host 'PASS: 50 MHz, RV32IM, 700 iterations, IDs, timer and board result markers are correct'

$programCoe = Get-Content -LiteralPath (
    Join-Path $root 'software/c_test/4_coremark/main.coe')
$programWords = @($programCoe | ForEach-Object {
    $value = $_.Trim().TrimEnd(',', ';')
    if ($value -match '^[0-9a-fA-F]{8}$') {
        $value.ToLowerInvariant()
    }
})
Assert-True ($programWords.Count -eq 13422) `
    "Expected 13422 CoreMark program words, found $($programWords.Count)"
for ($index = 0; $index -lt $programWords.Count; $index++) {
    Assert-True ($programWords[$index] -eq $memoryWords[$index].ToLowerInvariant()) `
        "CoreMark main.coe differs from main.mem at word $index"
}
Write-Host 'PASS: CoreMark main.coe matches the formal board image'

$bytes = [Text.StringBuilder]::new($memoryWords.Count * 4)
foreach ($wordText in $memoryWords) {
    $word = [Convert]::ToUInt32($wordText, 16)
    [void]$bytes.Append([char]($word -band 0xFF))
    [void]$bytes.Append([char](($word -shr 8) -band 0xFF))
    [void]$bytes.Append([char](($word -shr 16) -band 0xFF))
    [void]$bytes.Append([char](($word -shr 24) -band 0xFF))
}
$imageText = $bytes.ToString()
foreach ($marker in @(
    'miniRV Pipeline AXI EGO1 CoreMark',
    '2024311081_2024311453',
    'CPU clock: %d MHz',
    'Correct operation validated.',
    'CoreMark/MHz : %f',
    'FINISH'
)) {
    Assert-True ($imageText.Contains($marker)) "CoreMark image marker is missing: $marker"
}
Write-Host 'PASS: identity, validation and score strings are embedded in main.mem'

$dumpText = [IO.File]::ReadAllText(
    (Join-Path $root 'software/c_test/4_coremark/main.s'))
foreach ($instruction in @('mul', 'div', 'rem')) {
    Assert-True ($dumpText -match "\b$instruction[a-z]*\s") `
        "CoreMark disassembly does not contain an M-extension $instruction instruction"
}
Assert-True ($dumpText.Contains('<board_result>')) `
    'CoreMark board_result function is missing from the linked image'
Write-Host 'PASS: linked CoreMark image contains M-extension instructions and board result logic'

Write-Host ''
Write-Host 'CoreMark package verification passed.'
Write-Host 'Build in Vivado: source rebuild_ego1.tcl'
Write-Host 'Expected final board state: LED C0A5, display C0DE600D'
