[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

& (Join-Path $root 'verify_coremark_package.ps1')

$definesText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/defines.vh'))
$cpuTopText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/cpu_top.v'))
$axiMasterText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/axi_master.v'))
$axiSlaveText = [IO.File]::ReadAllText((Join-Path $root 'src/rtl/axi_board_soc.v'))

Assert-True ($definesText -match '(?m)^`define ENABLE_ICACHE\s*$') `
    'ENABLE_ICACHE is not active'
Assert-True ($definesText -match '(?m)^`define ENABLE_DCACHE\s*$') `
    'ENABLE_DCACHE is not active'
Assert-True ($definesText -match '(?m)^`define IC_LINE_COUNT\s+64\s*$') `
    'ICache is not configured for 64 lines'
Assert-True ($definesText -match '(?m)^`define DC_LINE_COUNT\s+64\s*$') `
    'DCache is not configured for 64 lines'
Write-Host 'PASS: ICache and DCache are enabled'

Assert-True ($cpuTopText.Contains('ICache #(')) `
    'cpu_top does not instantiate ICache'
Assert-True ($cpuTopText.Contains('DCache #(')) `
    'cpu_top does not instantiate DCache'
Write-Host 'PASS: cpu_top instantiates both caches'

Assert-True ($axiMasterText.Contains('assign m_axi_arlen   = read_len;')) `
    'AXI Master does not drive ARLEN'
Assert-True ($axiMasterText.Contains('localparam [7:0] IC_AXI_LEN')) `
    'AXI Master does not define ICache burst length'
Assert-True ($axiMasterText.Contains('localparam [7:0] DC_AXI_LEN')) `
    'AXI Master does not define DCache burst length'
Assert-True ($axiMasterText.Contains('m_axi_rlast || (read_beat == read_len)')) `
    'AXI Master does not terminate refill using RLAST/read length'
Assert-True ($axiSlaveText.Contains('read_len_reg         <= s_axi_arlen;')) `
    'Board AXI Slave does not latch ARLEN'
Assert-True ($axiSlaveText.Contains('assign s_axi_rlast')) `
    'Board AXI Slave does not generate RLAST'
Write-Host 'PASS: AXI cache-line burst refill is present'

Write-Host ''
Write-Host 'Windows Cache CoreMark package verification passed.'
Write-Host 'Vivado GUI: open miniRV.xpr, then source rebuild_ego1.tcl'
Write-Host 'Batch build: build_cache_coremark_windows.cmd'
