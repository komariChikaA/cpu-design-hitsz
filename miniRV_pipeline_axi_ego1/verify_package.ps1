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

$requiredFiles = @(
    'miniRV.xpr',
    'rebuild_ego1.tcl',
    'src/coe/main.mem',
    'src/rtl/miniRV_SoC.v',
    'src/rtl/cpu_top.v',
    'src/rtl/cpu_core.v',
    'src/rtl/axi_master.v',
    'src/rtl/axi_board_soc.v',
    'src/rtl/board_bram.v',
    'src/rtl/pipeline/ALU_multicycle.v',
    'src/rtl/pipeline/ALU_trace.v',
    'src/rtl/pipeline/forward_unit.v',
    'src/rtl/pipeline/pipeline_regs.v',
    'src/rtl/ip/IROM/IROM.xci',
    'src/rtl/ip/DRAM/DRAM.xci',
    'src/rtl/ip/clk_wiz_0/clk_wiz_0.xci',
    'src/xdc/clock.xdc',
    'src/xdc/miniRV_SoC.xdc'
)

foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $root $relativePath
    Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Missing required file: $relativePath"
}
Write-Host 'PASS: required project files are present'

$xprPath = Join-Path $root 'miniRV.xpr'
$xprText = [IO.File]::ReadAllText($xprPath)
[xml]$null = $xprText
Assert-True ($xprText -match 'Option Name="Part" Val="xc7a35tcsg324-1"') 'miniRV.xpr targets the wrong FPGA part'
Assert-True ($xprText -match 'Option Name="TopModule" Val="miniRV_SoC"') 'miniRV_SoC is not the project top'
Assert-True ($xprText -notmatch 'RUN_TRACE') 'RUN_TRACE must not be defined in the board project'

$requiredXprSources = @(
    'pipeline/ALU_multicycle.v',
    'pipeline/ALU_trace.v',
    'pipeline/forward_unit.v',
    'pipeline/pipeline_regs.v',
    'axi_board_soc.v',
    'board_bram.v'
)
foreach ($source in $requiredXprSources) {
    Assert-True ($xprText -match [regex]::Escape($source)) "miniRV.xpr does not reference $source"
}
foreach ($obsolete in @('Data_RAM.v', 'Inst_ROM.v', 'NPC.v', 'PC.v', 'ddr3_model.sv')) {
    Assert-True ($xprText -notmatch [regex]::Escape($obsolete)) "miniRV.xpr still references obsolete source $obsolete"
}

$pathMatches = [regex]::Matches($xprText, '<File Path="\$PPRDIR/([^"]+)"')
foreach ($match in $pathMatches) {
    $relativePath = $match.Groups[1].Value.Replace('/', [IO.Path]::DirectorySeparatorChar)
    Assert-True (Test-Path -LiteralPath (Join-Path $root $relativePath)) "Broken miniRV.xpr file reference: $relativePath"
}
Write-Host 'PASS: Vivado project XML, part, top and source references are valid'

$memoryPath = Join-Path $root 'src/coe/main.mem'
$wordCount = 0
foreach ($line in [IO.File]::ReadLines($memoryPath)) {
    Assert-True ($line -match '^[0-9a-fA-F]{8}$') "Invalid main.mem word at line $($wordCount + 1)"
    $wordCount++
}
Assert-True ($wordCount -eq 38400) "Expected 38400 words in main.mem, found $wordCount"
Write-Host 'PASS: main.mem contains 38400 valid 32-bit words'

$iromText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/ip/IROM/IROM.xci'))
$dramText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/ip/DRAM/DRAM.xci'))
$clockText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/ip/clk_wiz_0/clk_wiz_0.xci'))
Assert-True ($iromText -match '"Component_Name".*"IROM"') 'IROM.xci has the wrong component name'
Assert-True ($iromText -match '"Write_Depth_A".*"12800"') 'IROM.xci depth is not 12800'
Assert-True ($iromText -match '"Write_Width_A".*"32"') 'IROM.xci width is not 32'
Assert-True ($dramText -match '"Component_Name".*"DRAM"') 'DRAM.xci has the wrong component name'
Assert-True ($dramText -match '"Write_Depth_A".*"25600"') 'DRAM.xci depth is not 25600'
Assert-True ($dramText -match '"Write_Width_A".*"32"') 'DRAM.xci width is not 32'
Assert-True ($clockText -match '"PRIM_IN_FREQ".*"100\.000"') 'Clock wizard input is not 100 MHz'
Assert-True ($clockText -match '"CLKOUT1_REQUESTED_OUT_FREQ".*"50"') 'Clock wizard output is not 50 MHz'
Assert-True ($clockText -match '"USE_RESET".*"false"') 'Clock wizard unexpectedly exposes a reset port'
Write-Host 'PASS: IROM, DRAM and clock-wizard XCI settings are correct'

$xdcText = [IO.File]::ReadAllText((Join-Path $root 'src/xdc/miniRV_SoC.xdc'))
foreach ($port in @('fpga_rst', 'fpga_clk', 'sw', 'led', 'dig_en', 'dig_seg', 'dig_seg1', 'rx', 'tx')) {
    Assert-True ($xdcText -match "get_ports\s+$port") "EGO1 pin constraints do not cover $port"
}
foreach ($indexedPort in @('sw', 'led', 'dig_en', 'dig_seg', 'dig_seg1')) {
    Assert-True ($xdcText -match "get_ports\s+$indexedPort\[\s*0\]") "EGO1 pin constraints do not cover $indexedPort bit 0"
}
$clockXdcText = [IO.File]::ReadAllText((Join-Path $root 'src/xdc/clock.xdc'))
Assert-True ($clockXdcText -match 'create_clock.*-period\s+10.*get_ports\s+fpga_clk') '100 MHz board clock constraint is missing'
Write-Host 'PASS: EGO1 clock and representative I/O constraints are present'

$aluText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/pipeline/ALU_multicycle.v'))
Assert-True ($aluText.Contains('operation_issued')) 'Fixed multi-cycle operation validity is missing'
Assert-True ($aluText.Contains('operation_start | unit_busy')) 'Launch-cycle busy handling is missing'

$coreText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/cpu_core.v'))
Assert-True ($coreText.Contains('active_alu_op')) 'Invalid-bubble ALU opcode masking is missing'

foreach ($relativePath in @('src/rtl/axi_master.v', 'src/rtl/axi_board_soc.v')) {
    $text = [IO.File]::ReadAllText((Join-Path $root $relativePath))
    Assert-True (-not $text.Contains('or posedge areset')) "BRAM-facing AXI state still uses asynchronous reset in $relativePath"
}
Write-Host 'PASS: fixed pipeline M-extension and BRAM-facing reset markers are present'

Write-Host ''
Write-Host 'EGO1 package verification passed.'
Write-Host 'Next step in Vivado: source rebuild_ego1.tcl'
