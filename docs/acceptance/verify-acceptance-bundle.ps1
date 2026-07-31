$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Push-Location $repoRoot

try {
    $requiredAcceptanceDocs = @(
        'docs/acceptance/README.md',
        'docs/acceptance/coremark-pipeline.html',
        'docs/acceptance/COREMARK_PIPELINE_AXI_DEFENSE.md',
        'docs/acceptance/COREMARK_PIPELINE_AXI_STUDY_GUIDE.md',
        'docs/acceptance/CACHE_IMPLEMENTATION_AND_DEFENSE.md',
        'docs/acceptance/PIPELINE_AB_GROUP_SCRIPT.md',
        'docs/acceptance/WAVEFORM_DEFENSE.md',
        'docs/acceptance/module-waveforms.html',
        'docs/acceptance/MODULE_WAVEFORM_MATRIX.md',
        'docs/acceptance/verify-acceptance-bundle.ps1'
    )

    $requiredCode = @(
        'miniRV_singlecycle_axi/src/rtl/cpu_core.v',
        'miniRV_singlecycle_axi/src/rtl/cpu_top.v',
        'miniRV_singlecycle_axi/src/rtl/axi_master.v',
        'miniRV_pipeline/src/rtl/cpu_core.v',
        'miniRV_pipeline/src/rtl/pipeline/pipeline_regs.v',
        'miniRV_pipeline/src/rtl/pipeline/forward_unit.v',
        'miniRV_pipeline_axi/src/rtl/cpu_core.v',
        'miniRV_pipeline_axi/src/rtl/cpu_top.v',
        'miniRV_pipeline_axi/src/rtl/axi_master.v',
        'miniRV_singlecycle_axi_ego1/src/rtl/axi_board_soc.v',
        'miniRV_singlecycle_axi_ego1/src/rtl/simple_uart.v',
        'miniRV_pipeline_axi_ego1/src/rtl/cpu_core.v',
        'miniRV_pipeline_axi_ego1/src/rtl/cpu_top.v',
        'miniRV_pipeline_axi_ego1/src/rtl/ICache.v',
        'miniRV_pipeline_axi_ego1/src/rtl/DCache.v',
        'miniRV_pipeline_axi_ego1/src/rtl/axi_master.v',
        'miniRV_pipeline_axi_ego1/src/rtl/axi_board_soc.v'
    )

    $requiredReports = @(
        'trace_test/miniRV_AXI_report.md',
        'trace_test/miniRV_AXI_run_all_tests.log',
        'trace_test/miniRV_pipeline_report.md',
        'trace_test/miniRV_pipeline_run_all_tests.log',
        'trace_test/miniRV_pipeline_axi_report.md',
        'trace_test/miniRV_pipeline_axi_run_all_tests.log',
        'trace_test/miniRV_pipeline_cache_axi_report.md',
        'trace_test/miniRV_pipeline_cache_axi_run_all_tests.log',
        'trace_test/miniRV_pipeline_cache_iverilog.log',
        'docs/course-report/board-evidence/coremark/cache-result.md'
    )

    $singleNames = @(
        'start', 'add', 'addi', 'sub', 'and', 'andi', 'or', 'ori', 'xor', 'xori',
        'sll', 'slli', 'srl', 'srli', 'sra', 'srai', 'slt', 'sltu', 'slti',
        'sltiu', 'auipc', 'lui', 'jal', 'jalr', 'beq', 'bne', 'blt', 'bltu',
        'bge', 'bgeu', 'lb', 'lbu', 'lh', 'lhu', 'lw', 'sb', 'sh', 'sw',
        'mul', 'mulh', 'mulhu', 'div', 'divu', 'rem', 'remu'
    )
    $requiredVcd = @(
        $singleNames | ForEach-Object { "waveform/single/$_.vcd" }
    ) + @(
        'docs/course-report/vcd/06_pipeline_load_use_hazard.vcd',
        'docs/course-report/vcd/07_pipeline_five_stage_forward_branch.vcd',
        'docs/course-report/vcd/06_no_cache_axi_transaction.vcd',
        'docs/course-report/vcd/08_axi_cacheline_burst.vcd',
        'docs/course-report/vcd/10_cache_refill_hit_uncached.vcd',
        'docs/course-report/vcd/11_board_bram_burst.vcd',
        'docs/course-report/vcd/09_board_peripheral_mmio_uart.vcd'
    )

    $requiredEvidence = @(
        'docs/course-report/figures/01_singlecycle_datapath.png',
        'docs/course-report/figures/04_pipeline_datapath.png',
        'docs/course-report/figures/05_axi_state_machine.png',
        'docs/course-report/figures/06a_pipeline_load_use_hazard.png',
        'docs/course-report/figures/06b_no_cache_axi_read.png',
        'docs/course-report/figures/06c_no_cache_axi_write.png',
        'docs/course-report/board-evidence/singlecycle/ctest0/uart-terminal.png',
        'docs/course-report/board-evidence/singlecycle/ctest1/terminal.png',
        'docs/course-report/board-evidence/singlecycle/ctest2/terminal-1.png',
        'docs/course-report/board-evidence/coremark/serial-result.png',
        'docs/course-report/board-evidence/coremark/board-2.jpg',
        'docs/course-report/board-evidence/pipeline/implementation-status.png'
    )

    $failures = [System.Collections.Generic.List[string]]::new()

    function Test-TrackedFile {
        param([string]$RelativePath, [string]$Kind)

        if (-not (Test-Path -LiteralPath $RelativePath -PathType Leaf)) {
            $script:failures.Add("MISSING ${Kind}: $RelativePath")
            return
        }

        & git ls-files --error-unmatch -- $RelativePath *> $null
        if ($LASTEXITCODE -ne 0) {
            $script:failures.Add("UNTRACKED ${Kind}: $RelativePath")
        }
    }

    foreach ($path in $requiredAcceptanceDocs) {
        Test-TrackedFile $path 'ACCEPTANCE'
    }
    foreach ($path in $requiredCode) {
        Test-TrackedFile $path 'CODE'
    }
    foreach ($path in $requiredReports) {
        Test-TrackedFile $path 'REPORT'
    }
    foreach ($path in $requiredEvidence) {
        Test-TrackedFile $path 'EVIDENCE'
    }
    foreach ($path in $requiredVcd) {
        Test-TrackedFile $path 'VCD'
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $header = (Get-Content -LiteralPath $path -TotalCount 300) -join "`n"
            foreach ($marker in @('$timescale', '$scope')) {
                if (-not $header.Contains($marker)) {
                    $failures.Add("INVALID VCD ($marker absent): $path")
                }
            }
            if (-not (Select-String -LiteralPath $path -SimpleMatch '$enddefinitions' -Quiet)) {
                $failures.Add("INVALID VCD (`$enddefinitions absent): $path")
            }
        }
    }

    Write-Host 'Acceptance bundle inventory'
    Write-Host "  Acceptance docs: $($requiredAcceptanceDocs.Count)"
    Write-Host "  Code modules : $($requiredCode.Count)"
    Write-Host "  Reports/results: $($requiredReports.Count)"
    Write-Host "  Raw VCD files: $($requiredVcd.Count)"
    Write-Host "  Figures/photos: $($requiredEvidence.Count)"

    if ($failures.Count -gt 0) {
        Write-Host ''
        $failures | ForEach-Object { Write-Host "FAIL: $_" }
        exit 1
    }

    Write-Host ''
    Write-Host 'PASS: every required module, report, VCD and evidence file exists and is tracked by Git.'
}
finally {
    Pop-Location
}
