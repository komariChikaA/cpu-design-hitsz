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
    'rebuild_ego1_ila.tcl',
    'setup_ila_ego1.tcl',
    'ILA_DEBUG_GUIDE.md',
    'AXI_LONG_LATENCY_REPLAY_FIX.md',
    'START_PIPELINE_ACCEPTANCE.md',
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
$memoryWords = [Collections.Generic.List[string]]::new()
$wordCount = 0
foreach ($line in [IO.File]::ReadLines($memoryPath)) {
    Assert-True ($line -match '^[0-9a-fA-F]{8}$') "Invalid main.mem word at line $($wordCount + 1)"
    $memoryWords.Add($line.ToLowerInvariant())
    $wordCount++
}
Assert-True ($wordCount -eq 38400) "Expected 38400 words in main.mem, found $wordCount"
Write-Host 'PASS: main.mem contains 38400 valid 32-bit words'

function Read-CoeWords {
    param([string]$Path)

    $words = [Collections.Generic.List[string]]::new()
    foreach ($line in [IO.File]::ReadLines($Path)) {
        $value = $line.Trim().TrimEnd(',', ';')
        if ($value -match '^[0-9a-fA-F]{8}$') {
            $words.Add($value.ToLowerInvariant())
        }
    }
    return $words
}

$iromCoeWords = Read-CoeWords (Join-Path $root 'src/coe/board_irom.coe')
$dramCoeWords = Read-CoeWords (Join-Path $root 'src/coe/board_dram.coe')
Assert-True ($iromCoeWords.Count -eq 12800) "Expected 12800 words in board_irom.coe, found $($iromCoeWords.Count)"
Assert-True ($dramCoeWords.Count -eq 25600) "Expected 25600 words in board_dram.coe, found $($dramCoeWords.Count)"
for ($index = 0; $index -lt 12800; $index++) {
    Assert-True ($iromCoeWords[$index] -eq $memoryWords[$index]) "board_irom.coe differs from main.mem at word $index"
}
for ($index = 0; $index -lt 25600; $index++) {
    Assert-True ($dramCoeWords[$index] -eq $memoryWords[$index + 12800]) "board_dram.coe differs from main.mem at word $($index + 12800)"
}
Write-Host 'PASS: board IROM/DRAM COE files exactly match main.mem'

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
Assert-True ($coreText.Contains('assign ex_bj_f = ex_bj_taken;')) 'Board AXI control-flow redirect fix is missing'
Assert-True ($coreText.Contains('load_duplicate || mul_duplicate')) 'Long-latency ID replay fix is missing'
Assert-True (-not $coreText.Contains('load_use_hazard || load_entering_id || mul_entering_id || effective_freeze')) 'Obsolete long-latency ID replay stall is still present'

foreach ($relativePath in @('src/rtl/axi_master.v', 'src/rtl/axi_board_soc.v')) {
    $text = [IO.File]::ReadAllText((Join-Path $root $relativePath))
    Assert-True (-not $text.Contains('or posedge areset')) "BRAM-facing AXI state still uses asynchronous reset in $relativePath"
}
Write-Host 'PASS: fixed M-extension, AXI redirect, long-latency replay and BRAM-facing reset markers are present'

$topText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/miniRV_SoC.v'))
$ilaSetupText = [IO.File]::ReadAllText((Join-Path $root 'setup_ila_ego1.tcl'))
Assert-True ($topText -match 'wire\s+\[199:0\]\s+ila_probe') '200-bit Cache/UART ILA probe bus is missing'
Assert-True ($topText.Contains('board_debug_pc')) 'CPU PC is not connected to the board ILA bus'
Assert-True ($topText.Contains('uart_debug_rx_state')) 'UART RX state is not connected to the board ILA bus'
Assert-True ($ilaSetupText.Contains('set expected_probe_width 200')) 'ILA setup expects the wrong probe width'
Assert-True ($ilaSetupText.Contains('create_debug_core u_ila_boot ila')) 'ILA debug core creation is missing'
Write-Host 'PASS: deterministic ILA board-debug flow is present'

Write-Host ''
Write-Host 'EGO1 package verification passed.'
Write-Host 'Normal build: source rebuild_ego1.tcl'
Write-Host 'ILA build: source rebuild_ego1_ila.tcl'
